import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dashboard_page.dart';

class ManagerPage extends StatefulWidget {
  final String username;
  final String role;
  final String userId;

  ManagerPage({
    required this.username,
    required this.role,
    required this.userId,
  });

  @override
  _ManagerPageState createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  final String apiBase =
      "http://192.168.254.115/my_application/my_php_api/raw_materials";
  List materials = [];
  bool isLoading = true;

  // 🔹 Sorting state
  int? sortColumnIndex;
  bool sortAscending = true;

  // 🔹 Show/Hide hidden materials
  bool showHidden = false;

  @override
  void initState() {
    super.initState();
    fetchMaterials();
  }

  Future<void> fetchMaterials() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$apiBase/get_materials.php"));
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() => materials = data['materials']);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🔹 Toggle visible/hidden
  Future<void> toggleMaterial(int id, String currentStatus) async {
    String newStatus = currentStatus == "visible" ? "hidden" : "visible";
    try {
      await http.post(
        Uri.parse("$apiBase/toggle_material.php"),
        body: {"id": id.toString(), "status": newStatus},
      );
      fetchMaterials();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Toggle failed")));
    }
  }

  // 🔹 Add or edit material
  Future<void> addOrEditMaterial({Map? material}) async {
    TextEditingController nameCtrl = TextEditingController(
      text: material?['name'] ?? "",
    );
    TextEditingController qtyCtrl = TextEditingController(
      text: material?['quantity']?.toString() ?? "",
    );

    String selectedType = material?['type'] ?? "weight";
    String selectedUnit = material?['unit'] ?? "kg";

    List<String> getUnitsForType(String type) {
      switch (type) {
        case "weight":
          return ["kg", "g"];
        case "volume":
          return ["liter", "ml"];
        case "count":
          return ["pcs", "dozen", "box", "tray"];
        default:
          return ["pcs"];
      }
    }

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(material == null ? "New Material" : "Edit Material"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: "Material Name"),
              ),
              TextField(
                controller: qtyCtrl,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // ✅ only integers
                ],
              ),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ["weight", "volume", "count"]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    selectedType = v!;
                    selectedUnit = getUnitsForType(selectedType)[0];
                  });
                },
                decoration: InputDecoration(labelText: "Type"),
              ),
              DropdownButtonFormField<String>(
                value: selectedUnit,
                items: getUnitsForType(selectedType)
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => selectedUnit = v!),
                decoration: InputDecoration(labelText: "Unit"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (qtyCtrl.text.isEmpty ||
                    int.tryParse(qtyCtrl.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please enter a valid integer quantity"),
                    ),
                  );
                  return; // stop here if invalid
                }

                String url = material == null
                    ? "$apiBase/create_material.php"
                    : "$apiBase/update_material.php";

                await http.post(
                  Uri.parse(url),
                  body: {
                    "id": material?['id']?.toString() ?? "",
                    "name": nameCtrl.text,
                    "quantity": qtyCtrl.text,
                    "type": selectedType,
                    "unit": selectedUnit,
                  },
                );

                Navigator.pop(context);
                fetchMaterials();
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Delete material
  Future<void> deleteMaterial(Map material) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete ${material['name']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await http.post(
        Uri.parse("$apiBase/delete_material.php"),
        body: {"id": material['id'].toString()},
      );
      final result = json.decode(response.body);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      fetchMaterials();
    }
  }

  // 🔹 Sorting helper
  void onSort<T>(
    Comparable<T> Function(Map material) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      materials.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardPage(
                  username: widget.username,
                  role: widget.role,
                  userId: widget.userId,
                ),
              ),
            );
          },
        ),
        title: Text("Manager - Raw Materials"),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      // 🔹 Main Table Container
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.95,
                        ),
                        margin: const EdgeInsets.only(top: 70),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: 900),
                            child: DataTable(
                              sortColumnIndex: sortColumnIndex,
                              sortAscending: sortAscending,
                              columnSpacing: 40,
                              headingRowHeight: 56,
                              dataRowHeight: 56,
                              columns: [
                                DataColumn(
                                  label: Text("ID"),
                                  numeric: true,
                                  onSort: (colIndex, asc) {
                                    onSort<num>(
                                      (m) =>
                                          int.tryParse(m['id'].toString()) ?? 0,
                                      colIndex,
                                      asc,
                                    );
                                  },
                                ),
                                DataColumn(
                                  label: Text("Name"),
                                  onSort: (colIndex, asc) {
                                    onSort<String>(
                                      (m) => m['name'] ?? "",
                                      colIndex,
                                      asc,
                                    );
                                  },
                                ),
                                DataColumn(
                                  label: Text("Quantity"),
                                  numeric: true,
                                  onSort: (colIndex, asc) {
                                    onSort<num>(
                                      (m) =>
                                          num.tryParse(
                                            m['quantity'].toString(),
                                          ) ??
                                          0,
                                      colIndex,
                                      asc,
                                    );
                                  },
                                ),
                                DataColumn(
                                  label: Text("Type"),
                                  onSort: (colIndex, asc) {
                                    onSort<String>(
                                      (m) => m['type'] ?? "",
                                      colIndex,
                                      asc,
                                    );
                                  },
                                ),
                                DataColumn(
                                  label: Text("Unit"),
                                  onSort: (colIndex, asc) {
                                    onSort<String>(
                                      (m) => m['unit'] ?? "",
                                      colIndex,
                                      asc,
                                    );
                                  },
                                ),
                                DataColumn(
                                  label: Text("Status"),
                                  onSort: (colIndex, asc) {
                                    onSort<String>(
                                      (m) => m['status'] ?? "",
                                      colIndex,
                                      asc,
                                    );
                                  },
                                ),
                                const DataColumn(label: Text("Actions")),
                              ],
                              rows: materials
                                  .where(
                                    (m) =>
                                        showHidden || m['status'] == "visible",
                                  )
                                  .map<DataRow>((material) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(material['id'].toString()),
                                        ),
                                        DataCell(
                                          Text(material['name'] ?? "Unnamed"),
                                        ),
                                        DataCell(
                                          Text(material['quantity'].toString()),
                                        ),
                                        DataCell(Text(material['type'] ?? "")),
                                        DataCell(Text(material['unit'] ?? "")),
                                        DataCell(
                                          Text(material['status'] ?? ""),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () =>
                                                    addOrEditMaterial(
                                                      material: material,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  material['status'] ==
                                                          "visible"
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color:
                                                      material['status'] ==
                                                          "visible"
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                                onPressed: () => toggleMaterial(
                                                  int.parse(
                                                    material['id'].toString(),
                                                  ),
                                                  material['status'],
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    deleteMaterial(material),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        ),
                      ),

                      // 🔹 Add Entry + Show/Hide Buttons (top right above container)
                      // 🔹 Show/Hide + Add Entry Buttons (top right above container)
                      Positioned(
                        right: 10,
                        top: 0,
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(
                                showHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              label: Text(
                                showHidden
                                    ? "Hide Hidden Items"
                                    : "Show Hidden Items",
                              ),
                              onPressed: () {
                                setState(() {
                                  showHidden = !showHidden;
                                });
                              },
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              icon: Icon(Icons.add),
                              label: Text("Add Entry"),
                              onPressed: () => addOrEditMaterial(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
