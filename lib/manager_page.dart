import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
import 'task_page.dart';
import 'dash.dart';
import 'ui/manager_page_ui.dart'; // <-- Import the UI

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
      "http://localhost/my_application/my_php_api/raw_materials";
  List materials = [];
  bool isLoading = true;

  int? sortColumnIndex;
  bool sortAscending = true;

  bool showHidden = false;
  bool _isSidebarOpen = false;

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
          backgroundColor: const Color.fromARGB(
            255,
            41,
            41,
            41,
          ).withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            material == null ? "New Material" : "Edit Material",
            style: TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Material Name",
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orangeAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Quantity",
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orangeAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.black87,
                  value: selectedType,
                  items: ["weight", "volume", "count"]
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t, style: TextStyle(color: Colors.white)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedType = v!;
                      selectedUnit = getUnitsForType(selectedType)[0];
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Type",
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.black87,
                  value: selectedUnit,
                  items: getUnitsForType(selectedType)
                      .map(
                        (u) => DropdownMenuItem(
                          value: u,
                          child: Text(u, style: TextStyle(color: Colors.white)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedUnit = v!),
                  decoration: InputDecoration(
                    labelText: "Unit",
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (qtyCtrl.text.isEmpty ||
                    int.tryParse(qtyCtrl.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid integer")),
                  );
                  return;
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

  Future<void> deleteMaterial(Map material) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Delete ${material['name']}?"),
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

  void toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ManagerPageUI(
      isSidebarOpen: _isSidebarOpen,
      toggleSidebar: toggleSidebar,
      materials: materials,
      isLoading: isLoading,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      showHidden: showHidden,
      onShowHiddenToggle: () => setState(() => showHidden = !showHidden),
      onAddEntry: () => addOrEditMaterial(),
      onEditMaterial: (material) => addOrEditMaterial(material: material),
      onDeleteMaterial: deleteMaterial,
      onToggleMaterial: toggleMaterial,
      onSort: onSort,
      username: widget.username,
      role: widget.role,
      userId: widget.userId,
      onHome: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => dash()),
          (route) => false,
        );
      }, // <-- This now goes to dash page
      onDashboard: () {
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
      onTaskPage: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskPage(
              userId: widget.userId,
              username: widget.username,
              role: widget.role,
            ),
          ),
        );
      },
      onLogout: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => dash()),
          (route) => false,
        );
      },
    );
  }
}
