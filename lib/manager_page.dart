import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
import 'task_page.dart';
import 'dash.dart';

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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.95), Colors.grey[900]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Row(
            children: [
              // Sidebar
              AnimatedContainer(
                duration: Duration(milliseconds: 250),
                width: _isSidebarOpen ? 220 : 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  border: Border(
                    right: BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
                child: Column(
                  children: [
                    // Home button
                    _SidebarItem(
                      imagePath: "assets/images/home.png",
                      label: "Home",
                      isOpen: _isSidebarOpen,
                      onTap: () {
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

                    // Dashboard button (clickable)
                    _SidebarItem(
                      imagePath:
                          "assets/images/dashboard.png", // choose your dashboard icon
                      label: "Dashboard",
                      isOpen: _isSidebarOpen,
                      onTap: () {
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

                    // Manager - Current Page (highlighted & unclickable)
                    _SidebarItem(
                      imagePath: "assets/images/manager.png",
                      label: "Materials Records",
                      isOpen: _isSidebarOpen,
                      onTap: () {}, // disables click
                      color: Colors.orangeAccent, // highlighted color
                    ),
                    // New Sub-Module #2 button
                    if (widget.role.toLowerCase() == "manager")
                      _SidebarItem(
                        imagePath:
                            "assets/images/submodule.png", // placeholder icon
                        label: "Sub-Module #2",
                        isOpen: _isSidebarOpen,
                        onTap: () {
                          // does nothing for now
                        },
                        color: Colors.white, // default color
                      ),
                    // Tasks button
                    _SidebarItem(
                      imagePath: "assets/images/task.png",
                      label: "Tasks",
                      isOpen: _isSidebarOpen,
                      onTap: () {
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
                    ),

                    // Logout button
                    _SidebarItem(
                      imagePath: "assets/images/logout.png",
                      label: "Logout",
                      isOpen: _isSidebarOpen,
                      color: Colors.redAccent,
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.clear();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => dash()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.grey[900]!],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isSidebarOpen
                                  ? Icons.arrow_back_ios
                                  : Icons.menu,
                            ),
                            color: Colors.orange,
                            onPressed: toggleSidebar,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Manager - Raw Materials",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 3, color: Colors.orange),
                    Expanded(
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.95,
                                        ),
                                        margin: EdgeInsets.only(top: 70),
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                            255,
                                            37,
                                            37,
                                            37,
                                          ).withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                            constraints: BoxConstraints(
                                              minWidth: 900,
                                            ),
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
                                                dataTableTheme: DataTableThemeData(
                                                  headingTextStyle: TextStyle(
                                                    color: Colors
                                                        .white, // <-- arrows inherit this
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  dataTextStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                  dividerThickness: 1,
                                                ),
                                              ),
                                              child: DataTable(
                                                sortColumnIndex:
                                                    sortColumnIndex,
                                                sortAscending: sortAscending,
                                                columnSpacing: 40,
                                                headingRowHeight: 56,
                                                dataRowHeight: 56,
                                                columns: [
                                                  DataColumn(
                                                    label: Text("ID"),
                                                    onSort: (columnIndex, ascending) {
                                                      setState(() {
                                                        sortColumnIndex =
                                                            columnIndex;
                                                        sortAscending =
                                                            ascending;
                                                        materials.sort(
                                                          (a, b) => ascending
                                                              ? int.parse(
                                                                  a['id']
                                                                      .toString(),
                                                                ).compareTo(
                                                                  int.parse(
                                                                    b['id']
                                                                        .toString(),
                                                                  ),
                                                                )
                                                              : int.parse(
                                                                  b['id']
                                                                      .toString(),
                                                                ).compareTo(
                                                                  int.parse(
                                                                    a['id']
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                        );
                                                      });
                                                    },
                                                  ),
                                                  DataColumn(
                                                    label: Text("Name"),
                                                    onSort: (columnIndex, ascending) {
                                                      setState(() {
                                                        sortColumnIndex =
                                                            columnIndex;
                                                        sortAscending =
                                                            ascending;
                                                        materials.sort(
                                                          (a, b) => ascending
                                                              ? (a['name'] ??
                                                                        "")
                                                                    .compareTo(
                                                                      b['name'] ??
                                                                          "",
                                                                    )
                                                              : (b['name'] ??
                                                                        "")
                                                                    .compareTo(
                                                                      a['name'] ??
                                                                          "",
                                                                    ),
                                                        );
                                                      });
                                                    },
                                                  ),
                                                  DataColumn(
                                                    label: Text("Qty"),
                                                    onSort: (columnIndex, ascending) {
                                                      setState(() {
                                                        sortColumnIndex =
                                                            columnIndex;
                                                        sortAscending =
                                                            ascending;
                                                        materials.sort(
                                                          (a, b) => ascending
                                                              ? int.parse(
                                                                  a['quantity']
                                                                      .toString(),
                                                                ).compareTo(
                                                                  int.parse(
                                                                    b['quantity']
                                                                        .toString(),
                                                                  ),
                                                                )
                                                              : int.parse(
                                                                  b['quantity']
                                                                      .toString(),
                                                                ).compareTo(
                                                                  int.parse(
                                                                    a['quantity']
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                        );
                                                      });
                                                    },
                                                  ),
                                                  DataColumn(
                                                    label: Text("Type"),
                                                    onSort: (columnIndex, ascending) {
                                                      setState(() {
                                                        sortColumnIndex =
                                                            columnIndex;
                                                        sortAscending =
                                                            ascending;
                                                        materials.sort(
                                                          (a, b) => ascending
                                                              ? (a['type'] ??
                                                                        "")
                                                                    .compareTo(
                                                                      b['type'] ??
                                                                          "",
                                                                    )
                                                              : (b['type'] ??
                                                                        "")
                                                                    .compareTo(
                                                                      a['type'] ??
                                                                          "",
                                                                    ),
                                                        );
                                                      });
                                                    },
                                                  ),
                                                  DataColumn(
                                                    label: Text("Unit"),
                                                    onSort: (columnIndex, ascending) {
                                                      setState(() {
                                                        sortColumnIndex =
                                                            columnIndex;
                                                        sortAscending =
                                                            ascending;
                                                        materials.sort(
                                                          (a, b) => ascending
                                                              ? (a['unit'] ??
                                                                        "")
                                                                    .compareTo(
                                                                      b['unit'] ??
                                                                          "",
                                                                    )
                                                              : (b['unit'] ??
                                                                        "")
                                                                    .compareTo(
                                                                      a['unit'] ??
                                                                          "",
                                                                    ),
                                                        );
                                                      });
                                                    },
                                                  ),
                                                  DataColumn(
                                                    label: Text("Status"),
                                                    onSort: (columnIndex, ascending) {
                                                      setState(() {
                                                        sortColumnIndex =
                                                            columnIndex;
                                                        sortAscending =
                                                            ascending;
                                                        materials.sort(
                                                          (a, b) => ascending
                                                              ? (a['status'] ??
                                                                        "")
                                                                    .compareTo(
                                                                      b['status'] ??
                                                                          "",
                                                                    )
                                                              : (b['status'] ??
                                                                        "")
                                                                    .compareTo(
                                                                      a['status'] ??
                                                                          "",
                                                                    ),
                                                        );
                                                      });
                                                    },
                                                  ),
                                                  DataColumn(
                                                    label: Text("Actions"),
                                                  ),
                                                ],
                                                rows: materials
                                                    .where(
                                                      (m) =>
                                                          showHidden ||
                                                          m['status'] ==
                                                              "visible",
                                                    )
                                                    .map<DataRow>((material) {
                                                      return DataRow(
                                                        cells: [
                                                          DataCell(
                                                            Text(
                                                              material['id']
                                                                  .toString(),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                              material['name'] ??
                                                                  "Unnamed",
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                              material['quantity']
                                                                  .toString(),
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                              material['type'] ??
                                                                  "",
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                              material['unit'] ??
                                                                  "",
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Text(
                                                              material['status'] ??
                                                                  "",
                                                            ),
                                                          ),
                                                          DataCell(
                                                            Row(
                                                              children: [
                                                                IconButton(
                                                                  icon: Icon(
                                                                    Icons.edit,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                  onPressed: () =>
                                                                      addOrEditMaterial(
                                                                        material:
                                                                            material,
                                                                      ),
                                                                ),
                                                                IconButton(
                                                                  icon: Icon(
                                                                    material['status'] ==
                                                                            "visible"
                                                                        ? Icons
                                                                              .visibility
                                                                        : Icons
                                                                              .visibility_off,
                                                                    color:
                                                                        material['status'] ==
                                                                            "visible"
                                                                        ? Colors
                                                                              .green
                                                                        : Colors
                                                                              .red,
                                                                  ),
                                                                  onPressed: () => toggleMaterial(
                                                                    int.parse(
                                                                      material['id']
                                                                          .toString(),
                                                                    ),
                                                                    material['status'],
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  icon: Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                  onPressed: () =>
                                                                      deleteMaterial(
                                                                        material,
                                                                      ),
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
                                      ),
                                      Positioned(
                                        right: 10,
                                        top: 20,
                                        child: Row(
                                          children: [
                                            // Show/Hide Hidden button
                                            SizedBox(
                                              height: 40, // fixed height
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    showHidden = !showHidden;
                                                  });
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[850]!
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center, // align icon and text
                                                    children: [
                                                      Icon(
                                                        showHidden
                                                            ? Icons
                                                                  .visibility_off
                                                            : Icons.visibility,
                                                        color:
                                                            Colors.orangeAccent,
                                                        size:
                                                            20, // explicitly set size
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        showHidden
                                                            ? "Hide Hidden"
                                                            : "Show Hidden",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            // Add Entry button
                                            SizedBox(
                                              height: 40, // same height
                                              child: InkWell(
                                                onTap: () =>
                                                    addOrEditMaterial(),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[850]!
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center, // center icon and text
                                                    children: [
                                                      SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: Image.asset(
                                                          "assets/images/add.png",
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        "Add Entry",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final String imagePath;
  final String label;
  final bool isOpen;
  final VoidCallback onTap;
  final Color? color;

  const _SidebarItem({
    required this.imagePath,
    required this.label,
    required this.isOpen,
    required this.onTap,
    this.color,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovering = false;
  bool _showText = false;

  @override
  void didUpdateWidget(covariant _SidebarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !_showText) {
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted && widget.isOpen) setState(() => _showText = true);
      });
    } else if (!widget.isOpen && _showText) {
      setState(() => _showText = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: _isHovering
                ? Colors.orange.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.contain,
                  color: widget.color,
                ),
              ),
              if (_showText) ...[
                SizedBox(width: 12),
                AnimatedOpacity(
                  opacity: _showText ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 250),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.color ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
