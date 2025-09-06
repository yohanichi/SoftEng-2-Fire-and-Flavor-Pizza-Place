import 'package:flutter/material.dart';

class ManagerPageUI extends StatelessWidget {
  final bool isSidebarOpen;
  final VoidCallback toggleSidebar;
  final List materials;
  final bool isLoading;
  final int? sortColumnIndex;
  final bool sortAscending;
  final bool showHidden;
  final VoidCallback onShowHiddenToggle;
  final VoidCallback onAddEntry;
  final Function(Map) onEditMaterial;
  final Function(Map) onDeleteMaterial;
  final Function(int, String) onToggleMaterial;
  final void Function(Comparable Function(Map), int, bool) onSort;
  final String username;
  final String role;
  final String userId;
  final VoidCallback onHome;
  final VoidCallback onDashboard;
  final VoidCallback onTaskPage;
  final Future<void> Function() onLogout;

  const ManagerPageUI({
    required this.isSidebarOpen,
    required this.toggleSidebar,
    required this.materials,
    required this.isLoading,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.showHidden,
    required this.onShowHiddenToggle,
    required this.onAddEntry,
    required this.onEditMaterial,
    required this.onDeleteMaterial,
    required this.onToggleMaterial,
    required this.onSort,
    required this.username,
    required this.role,
    required this.userId,
    required this.onHome,
    required this.onDashboard,
    required this.onTaskPage,
    required this.onLogout,
    Key? key,
  }) : super(key: key);

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
              _Sidebar(
                isSidebarOpen: isSidebarOpen,
                onHome: onHome,
                onDashboard: onDashboard,
                onTaskPage: onTaskPage,
                role: role,
                onLogout: onLogout,
              ),
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
                              isSidebarOpen ? Icons.arrow_back_ios : Icons.menu,
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
                                            child: DataTable(
                                              sortColumnIndex: sortColumnIndex,
                                              sortAscending: sortAscending,
                                              columnSpacing: 40,
                                              headingRowHeight: 56,
                                              dataRowHeight: 56,
                                              columns: [
                                                DataColumn(
                                                  label: Text(
                                                    "ID",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onSort:
                                                      (
                                                        columnIndex,
                                                        ascending,
                                                      ) => onSort(
                                                        (m) =>
                                                            int.tryParse(
                                                              m['id']
                                                                  .toString(),
                                                            ) ??
                                                            0,
                                                        columnIndex,
                                                        ascending,
                                                      ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Name",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onSort:
                                                      (
                                                        columnIndex,
                                                        ascending,
                                                      ) => onSort(
                                                        (m) => m['name'] ?? '',
                                                        columnIndex,
                                                        ascending,
                                                      ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Qty",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onSort:
                                                      (
                                                        columnIndex,
                                                        ascending,
                                                      ) => onSort(
                                                        (m) =>
                                                            int.tryParse(
                                                              m['quantity']
                                                                  .toString(),
                                                            ) ??
                                                            0,
                                                        columnIndex,
                                                        ascending,
                                                      ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Type",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onSort:
                                                      (
                                                        columnIndex,
                                                        ascending,
                                                      ) => onSort(
                                                        (m) => m['type'] ?? '',
                                                        columnIndex,
                                                        ascending,
                                                      ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Unit",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onSort:
                                                      (
                                                        columnIndex,
                                                        ascending,
                                                      ) => onSort(
                                                        (m) => m['unit'] ?? '',
                                                        columnIndex,
                                                        ascending,
                                                      ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Status",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onSort:
                                                      (
                                                        columnIndex,
                                                        ascending,
                                                      ) => onSort(
                                                        (m) =>
                                                            m['status'] ?? '',
                                                        columnIndex,
                                                        ascending,
                                                      ),
                                                ),
                                                DataColumn(
                                                  label: Text(
                                                    "Actions",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
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
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            material['name'] ??
                                                                "Unnamed",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            material['quantity']
                                                                .toString(),
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            material['type'] ??
                                                                "",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            material['unit'] ??
                                                                "",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                            material['status'] ??
                                                                "",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                            ),
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
                                                                    onEditMaterial(
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
                                                                onPressed: () =>
                                                                    onToggleMaterial(
                                                                      int.parse(
                                                                        material['id']
                                                                            .toString(),
                                                                      ),
                                                                      material['status'],
                                                                    ),
                                                              ),
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons.delete,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                                onPressed: () =>
                                                                    onDeleteMaterial(
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
                                      Positioned(
                                        right: 10,
                                        top: 20,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              child: InkWell(
                                                onTap: onShowHiddenToggle,
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
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        showHidden
                                                            ? Icons
                                                                  .visibility_off
                                                            : Icons.visibility,
                                                        color:
                                                            Colors.orangeAccent,
                                                        size: 20,
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
                                            SizedBox(
                                              height: 40,
                                              child: InkWell(
                                                onTap: onAddEntry,
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
                                                            .center,
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

// Sidebar with hover support
class _Sidebar extends StatefulWidget {
  final bool isSidebarOpen;
  final VoidCallback onHome;
  final VoidCallback onDashboard;
  final VoidCallback onTaskPage;
  final String role;
  final Future<void> Function() onLogout;

  const _Sidebar({
    required this.isSidebarOpen,
    required this.onHome,
    required this.onDashboard,
    required this.onTaskPage,
    required this.role,
    required this.onLogout,
    Key? key,
  }) : super(key: key);

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  String? hoveredLabel;
  bool showText = false;

  @override
  void didUpdateWidget(covariant _Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSidebarOpen && !showText) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && widget.isSidebarOpen) {
          setState(() => showText = true);
        }
      });
    } else if (!widget.isSidebarOpen && showText) {
      setState(() => showText = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      width: widget.isSidebarOpen ? 220 : 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border(right: BorderSide(color: Colors.orange, width: 2)),
      ),
      child: Column(
        children: [
          _SidebarItem(
            imagePath: "assets/images/home.png",
            label: "Home",
            isOpen: widget.isSidebarOpen && showText,
            onTap: widget.onHome,
            hovered: hoveredLabel == "Home",
            onHover: (hovering) {
              setState(() => hoveredLabel = hovering ? "Home" : null);
            },
          ),
          _SidebarItem(
            imagePath: "assets/images/dashboard.png",
            label: "Dashboard",
            isOpen: widget.isSidebarOpen && showText,
            onTap: widget.onDashboard,
            hovered: hoveredLabel == "Dashboard",
            onHover: (hovering) {
              setState(() => hoveredLabel = hovering ? "Dashboard" : null);
            },
          ),
          _SidebarItem(
            imagePath: "assets/images/manager.png",
            label: "Materials Records",
            isOpen: widget.isSidebarOpen && showText,
            onTap: () {},
            color: Colors.orangeAccent,
            isActive: true, // <-- Highlight when on Manager page
            hovered: hoveredLabel == "Materials Records",
            onHover: (hovering) {
              setState(
                () => hoveredLabel = hovering ? "Materials Records" : null,
              );
            },
          ),
          if (widget.role.toLowerCase() == "manager")
            _SidebarItem(
              imagePath: "assets/images/submodule.png",
              label: "Sub-Module #2",
              isOpen: widget.isSidebarOpen && showText,
              onTap: () {},
              color: Colors.white,
              hovered: hoveredLabel == "Sub-Module #2",
              onHover: (hovering) {
                setState(
                  () => hoveredLabel = hovering ? "Sub-Module #2" : null,
                );
              },
            ),
          _SidebarItem(
            imagePath: "assets/images/task.png",
            label: "Tasks",
            isOpen: widget.isSidebarOpen && showText,
            onTap: widget.onTaskPage,
            hovered: hoveredLabel == "Tasks",
            onHover: (hovering) {
              setState(() => hoveredLabel = hovering ? "Tasks" : null);
            },
          ),
          _SidebarItem(
            imagePath: "assets/images/logout.png",
            label: "Logout",
            isOpen: widget.isSidebarOpen && showText,
            color: Colors.redAccent,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Text(
                    "Confirm Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    "Are you sure you want to log out?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget
                            .onLogout(); // ✅ Now triggers only after confirmation
                      },
                      child: Text(
                        "Logout",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
            },
            hovered: hoveredLabel == "Logout",
            onHover: (hovering) {
              setState(() => hoveredLabel = hovering ? "Logout" : null);
            },
          ),
        ],
      ),
    );
  }
}

// Sidebar item with hover effect
class _SidebarItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isOpen;
  final VoidCallback onTap;
  final Color? color;
  final bool hovered;
  final ValueChanged<bool> onHover;
  final bool isActive;

  const _SidebarItem({
    required this.imagePath,
    required this.label,
    required this.isOpen,
    required this.onTap,
    this.color,
    this.hovered = false,
    required this.onHover,
    this.isActive = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final highlightColor = hovered
        ? (color ?? Colors.orangeAccent).withOpacity(0.25)
        : isActive
        ? (color ?? Colors.orangeAccent).withOpacity(0.2)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: highlightColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  color: color,
                ),
              ),
              if (isOpen) ...[
                SizedBox(width: 12),
                AnimatedOpacity(
                  opacity: isOpen ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 250),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color ?? Colors.white,
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
