import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TotalIncomePage extends StatefulWidget {
  final List<Map<String, dynamic>> orders;

  const TotalIncomePage({super.key, required this.orders});

  @override
  State<TotalIncomePage> createState() => _TotalIncomePageState();
}

class _TotalIncomePageState extends State<TotalIncomePage> {
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = true;
  late List<Map<String, dynamic>> flatItems;
  double totalProfit = 0.0;
  final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
    setState(() => isLoading = true);
    flatItems = [];

    for (var order in widget.orders) {
      if (order['items'] is List) {
        for (var item in order['items']) {
          final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
          final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;

          // --- Parse addons and size ---
          List<Map<String, String>> structuredAddons = [];
          if (item['addons'] != null) {
            try {
              var decoded = item['addons'] is String
                  ? json.decode(item['addons'])
                  : item['addons'];
              if (decoded is List) {
                for (var a in decoded) {
                  if (a is String) {
                    structuredAddons.add({"name": a, "type": "addon"});
                  } else if (a is Map) {
                    structuredAddons.add({
                      "name": a["name"] ?? "",
                      "type": a["type"] ?? "addon",
                    });
                  }
                }
              }
            } catch (_) {}
          }

          // Include size as a special addon
          if (item['size'] != null && item['size'].toString().isNotEmpty) {
            structuredAddons.add({
              "name": item['size'].toString(),
              "type": "size",
            });
          }

          debugPrint(
            "Menu: ${item['menuItem']}, Addons/Size: $structuredAddons",
          );

          flatItems.add({
            'menuItem': item['menuItem'],
            'price': price,
            'quantity': qty,
            'created_at': order['orderDate'] ?? '',
            'addons': structuredAddons,
          });
        }
      }
    }

    // Fetch ingredient costs
    try {
      final ingredientData = await Future.wait(
        flatItems.map(
          (item) => fetchIngredientCostWithBreakdown(
            item['menuItem'],
            item['addons'],
          ),
        ),
      );

      totalProfit = 0;
      for (int i = 0; i < flatItems.length; i++) {
        final ingredientCost = ingredientData[i]['totalCost'] ?? 0.0;
        flatItems[i]['ingredientCost'] = ingredientCost;
        flatItems[i]['ingredientsBreakdown'] =
            ingredientData[i]['breakdown'] ?? [];
        totalProfit +=
            (flatItems[i]['price'] - ingredientCost) * flatItems[i]['quantity'];
      }
    } catch (e) {
      debugPrint("Error fetching ingredient costs: $e");
    }

    setState(() => isLoading = false);
  }

  Future<Map<String, dynamic>> fetchIngredientCostWithBreakdown(
    String menuName,
    List<Map<String, String>> addons,
  ) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final url = Uri.parse(
        "$baseUrl/profit/get_full_ingredient_cost.php?name=$menuName&addons=${jsonEncode(addons)}",
      );

      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return {
          'totalCost': (data['ingredient_cost'] ?? 0).toDouble(),
          'breakdown': data['breakdown'] ?? [],
        };
      }
    } catch (e) {
      debugPrint("Error fetching ingredient cost: $e");
    }

    return {'totalCost': 0.0, 'breakdown': []};
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (startDate ?? DateTime.now())
          : (endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredItems = flatItems.where((item) {
      if (startDate == null && endDate == null) return true;
      try {
        final createdAt = DateTime.parse(item['created_at'] ?? '');
        if (startDate != null && createdAt.isBefore(startDate!)) return false;
        if (endDate != null && createdAt.isAfter(endDate!)) return false;
        return true;
      } catch (_) {
        return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Total Income"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date picker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _pickDate(context, true),
                    icon: const Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                    ),
                    label: Text(
                      "From",
                      style: GoogleFonts.poppins(color: Colors.orange),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () => _pickDate(context, false),
                    icon: const Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                    ),
                    label: Text(
                      "To",
                      style: GoogleFonts.poppins(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Total profit
            Row(
              children: [
                Text(
                  "Total Profit: ",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatter.format(totalProfit),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // List of items
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        "No items found for the selected date.",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final price = item['price'] ?? 0.0;
                        final ingredientCost = item['ingredientCost'] ?? 0.0;
                        final qty = item['quantity'] ?? 1;
                        final breakdown =
                            item['ingredientsBreakdown'] as List<dynamic>? ??
                            [];
                        final totalItemCost = ingredientCost * qty;
                        final totalRevenue = price * qty;
                        final profit = totalRevenue - totalItemCost;

                        String createdAtText = '';
                        if (item['created_at'] != null &&
                            item['created_at'] != '') {
                          try {
                            final dt = DateTime.parse(item['created_at']);
                            createdAtText = DateFormat(
                              'MMM dd, yyyy hh:mm a',
                            ).format(dt);
                          } catch (_) {
                            createdAtText = item['created_at'].toString();
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (createdAtText.isNotEmpty)
                                Text(
                                  createdAtText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                item['menuItem'] ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Price: ${formatter.format(price)}"),
                              Text("Quantity: $qty"),
                              if (breakdown.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  "Ingredients Breakdown:",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ...breakdown.map((b) {
                                  final name = b['name'] ?? '';
                                  final unitCost = (b['unitCost'] ?? 0)
                                      .toDouble();
                                  final qtyUsed = (b['quantity'] ?? 0)
                                      .toDouble();
                                  final type = (b['type'] ?? 'menu')
                                      .toString()
                                      .toLowerCase();
                                  final totalCost = (unitCost * qtyUsed * qty)
                                      .toDouble();

                                  String typeLabel = '';
                                  if (type == 'addon') typeLabel = ' (Addon)';
                                  if (type == 'size') typeLabel = ' (Size)';

                                  return Text(
                                    "• $name$typeLabel: ($unitCost × $qtyUsed) × $qty = ${formatter.format(totalCost)}",
                                    style: TextStyle(
                                      color: type == 'addon'
                                          ? Colors.blueAccent
                                          : type == 'size'
                                          ? Colors.deepOrange
                                          : Colors.black87,
                                    ),
                                  );
                                }),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                "Total Ingredient Cost: ${formatter.format(totalItemCost)}",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "Profit: ${formatter.format(profit)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
