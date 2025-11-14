import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

Future<void> showTotalIncomePopup(
  BuildContext context,
  List<Map<String, dynamic>> orders,
) async {
  final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

  double totalProfit = 0.0;

  // Flatten all order items and calculate profit per item
  List<Map<String, dynamic>> flatItems = [];
  for (var order in orders) {
    if (order['items'] is List) {
      for (var item in order['items']) {
        final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
        final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;

        // Fetch ingredient cost later
        flatItems.add({
          'menuItem': item['menuItem'],
          'price': price,
          'quantity': qty,
        });
      }
    }
  }

  // Fetch ingredient costs
  List<Future<Map<String, dynamic>>> ingredientFutures = flatItems
      .map((item) => fetchIngredientCostWithBreakdown(item['menuItem']))
      .toList();

  List<Map<String, dynamic>> ingredientData = await Future.wait(
    ingredientFutures,
  );

  // Attach ingredient costs & breakdown, and calculate total profit
  for (int i = 0; i < flatItems.length; i++) {
    final ingredientCost = ingredientData[i]['totalCost'] ?? 0.0;
    flatItems[i]['ingredientCost'] = ingredientCost;
    flatItems[i]['ingredientsBreakdown'] = ingredientData[i]['breakdown'] ?? [];

    final qty = flatItems[i]['quantity'];
    final price = flatItems[i]['price'];
    totalProfit += (price - ingredientCost) * qty; // ✅ profit
  }

  return showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Total Income",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formatter.format(totalProfit),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 8),
              Text("Orders counted: ${orders.length}"),
              const SizedBox(height: 12),

              // Scrollable list of items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: flatItems.map((item) {
                      final breakdown =
                          item['ingredientsBreakdown'] as List<dynamic>? ?? [];
                      final totalIngredientCost =
                          item['ingredientCost'] * item['quantity'];
                      final totalRevenue = item['price'] * item['quantity'];
                      final totalProfit = totalRevenue - totalIngredientCost;
                      final profitMargin = totalRevenue == 0
                          ? 0
                          : (totalProfit / totalRevenue) * 100;

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
                            Text(
                              item['menuItem'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Price: ${formatter.format(item['price'])} × Qty: ${item['quantity']} = ${formatter.format(totalRevenue)}",
                            ),
                            Text(
                              "Ingredient Cost: ${formatter.format(item['ingredientCost'])} × Qty: ${item['quantity']} = ${formatter.format(totalIngredientCost)}",
                            ),
                            Text(
                              "Profit: ${formatter.format(totalProfit)} (${profitMargin.toStringAsFixed(2)}%)",
                            ),
                            const SizedBox(height: 6),
                            if (breakdown.isNotEmpty) ...[
                              const Text(
                                "Ingredients Breakdown:",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              ...breakdown.map(
                                (b) => Text(
                                  "• ${b['name']}: ${formatter.format(b['cost'])}",
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Close button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Fetch ingredient cost + breakdown from API
Future<Map<String, dynamic>> fetchIngredientCostWithBreakdown(
  String menuName,
) async {
  try {
    final baseUrl = await ApiConfig.getBaseUrl();
    final url = Uri.parse(
      "$baseUrl/profit/get_full_ingredient_cost.php?name=$menuName",
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
