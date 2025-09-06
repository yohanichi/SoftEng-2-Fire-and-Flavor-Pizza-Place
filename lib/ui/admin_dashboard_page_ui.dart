import 'package:flutter/material.dart';

class AdminDashboardPageUI extends StatelessWidget {
  final bool isSidebarOpen;
  final VoidCallback toggleSidebar;
  final List users;
  final bool isLoading;
  final Function(Map?) openUserDialog;
  final Function(int, String, String) deleteUser;
  final VoidCallback logout;
  final String loggedInUsername;
  final VoidCallback onHome; // <-- Add this
  final VoidCallback onDashboard;
  final VoidCallback onTasks;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(Comparable Function(Map), int, bool) onSort;

  const AdminDashboardPageUI({
    required this.isSidebarOpen,
    required this.toggleSidebar,
    required this.users,
    required this.isLoading,
    required this.openUserDialog,
    required this.deleteUser,
    required this.logout,
    required this.loggedInUsername,
    required this.onHome, // <-- Add this
    required this.onDashboard,
    required this.onTasks,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                  onHome: onHome, // <-- Add this
                  onDashboard: onDashboard,
                  onTasks: onTasks,
                  logout: logout,
                ),
                // Main Content
                Expanded(
                  child: Column(
                    children: [
                      // Top Bar
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
                                isSidebarOpen
                                    ? Icons.arrow_back_ios
                                    : Icons.menu,
                                color: Colors.orange,
                              ),
                              onPressed: toggleSidebar,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Admin Dashboard",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            SizedBox(
                              height: 40,
                              child: InkWell(
                                onTap: () => openUserDialog(null),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[850]!.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                          "assets/images/add.png",
                                          color: Colors.orangeAccent,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Add User",
                                        style: TextStyle(
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.bold,
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
                      Container(height: 3, color: Colors.orange),
                      // Main container
                      Expanded(
                        child: isLoading
                            ? Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                child: Center(
                                  child: Container(
                                    margin: EdgeInsets.all(16),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(
                                        255,
                                        37,
                                        37,
                                        37,
                                      ).withOpacity(0.85),
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
                                                  (columnIndex, ascending) =>
                                                      onSort(
                                                        (u) =>
                                                            int.tryParse(
                                                              u['id']
                                                                  .toString(),
                                                            ) ??
                                                            0,
                                                        columnIndex,
                                                        ascending,
                                                      ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Username",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onSort:
                                                  (columnIndex, ascending) =>
                                                      onSort(
                                                        (u) =>
                                                            u['username'] ?? '',
                                                        columnIndex,
                                                        ascending,
                                                      ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Role",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onSort:
                                                  (columnIndex, ascending) =>
                                                      onSort(
                                                        (u) => u['role'] ?? '',
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
                                                  (columnIndex, ascending) =>
                                                      onSort(
                                                        (u) =>
                                                            u['status'] ?? '',
                                                        columnIndex,
                                                        ascending,
                                                      ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Email",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onSort:
                                                  (columnIndex, ascending) =>
                                                      onSort(
                                                        (u) => u['email'] ?? '',
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
                                          rows: users.map<DataRow>((user) {
                                            int userId =
                                                int.tryParse(
                                                  user['id'].toString(),
                                                ) ??
                                                0;
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  Text(
                                                    userId.toString(),
                                                    style: TextStyle(
                                                      color: Colors
                                                          .white70, // <-- Lighten text here
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    user['username'],
                                                    style: TextStyle(
                                                      color: Colors
                                                          .white70, // <-- Lighten text here
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    user['role'],
                                                    style: TextStyle(
                                                      color: Colors
                                                          .white70, // <-- Lighten text here
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    user['status'] ?? 'active',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .white70, // <-- Lighten text here
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    user['email'] ?? '',
                                                    style: TextStyle(
                                                      color: Colors
                                                          .white70, // <-- Lighten text here
                                                    ),
                                                  ),
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
                                                            openUserDialog(
                                                              user,
                                                            ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () =>
                                                            deleteUser(
                                                              userId,
                                                              user['username'],
                                                              user['role'],
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
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
    );
  }
}

// Sidebar with hover support
class _Sidebar extends StatefulWidget {
  final bool isSidebarOpen;
  final VoidCallback onHome; // <-- Add this
  final VoidCallback onDashboard;
  final VoidCallback onTasks;
  final VoidCallback logout;

  const _Sidebar({
    required this.isSidebarOpen,
    required this.onHome, // <-- Add this
    required this.onDashboard,
    required this.onTasks,
    required this.logout,
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
            onTap: widget.onHome, // <-- FIXED
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
            imagePath: "assets/images/admin.png",
            label: "Admin Dashboard",
            isOpen: widget.isSidebarOpen && showText,
            isActive: true,
            onTap: () {},
            hovered: hoveredLabel == "Admin Dashboard",
            onHover: (hovering) {
              setState(
                () => hoveredLabel = hovering ? "Admin Dashboard" : null,
              );
            },
          ),
          _SidebarItem(
            imagePath: "assets/images/task.png",
            label: "Tasks",
            isOpen: widget.isSidebarOpen && showText,
            onTap: widget.onTasks,
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
                        widget.logout(); // ✅ now logs out after confirmation
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
  final VoidCallback? onTap;
  final Color? color;
  final bool isActive;
  final bool hovered;
  final ValueChanged<bool> onHover;

  const _SidebarItem({
    required this.imagePath,
    required this.label,
    required this.isOpen,
    this.onTap,
    this.color,
    this.isActive = false,
    this.hovered = false,
    required this.onHover,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final highlightColor = hovered
        ? (color ?? Colors.orangeAccent).withOpacity(0.25)
        : isActive
        ? Colors.orangeAccent.withOpacity(0.2)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
                  color: isActive ? Colors.orangeAccent : color,
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
                      color: isActive
                          ? Colors.orangeAccent
                          : color ?? Colors.white,
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
