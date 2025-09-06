import 'package:flutter/material.dart';

class TaskPageUI extends StatelessWidget {
  final bool isSidebarOpen;
  final VoidCallback toggleSidebar;
  final String username;
  final String role;
  final String userId;
  final List tasks;
  final bool loading;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(Comparable Function(Map), int, bool) onSort;
  final VoidCallback onAddTask;
  final Function(Map) onEditTask;
  final Function(int) onDeleteTask;
  final VoidCallback onHome;
  final VoidCallback onDashboard;
  final VoidCallback? onAdminDashboard;
  final VoidCallback? onManagerPage;
  final VoidCallback? onSubModule;
  final VoidCallback onLogout;

  const TaskPageUI({
    required this.isSidebarOpen,
    required this.toggleSidebar,
    required this.username,
    required this.role,
    required this.userId,
    required this.tasks,
    required this.loading,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onAddTask,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onHome,
    required this.onDashboard,
    this.onAdminDashboard,
    this.onManagerPage,
    this.onSubModule,
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
              _Sidebar(
                isSidebarOpen: isSidebarOpen,
                onHome: onHome,
                onDashboard: onDashboard,
                onAdminDashboard: onAdminDashboard,
                onManagerPage: onManagerPage,
                onSubModule: onSubModule,
                onLogout: onLogout,
                role: role,
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
                              isSidebarOpen ? Icons.arrow_back_ios : Icons.menu,
                              color: Colors.orange,
                            ),
                            onPressed: toggleSidebar,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "$username's Tasks",
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
                              onTap: onAddTask,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[850]!.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                      "Add Task",
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
                    Expanded(
                      child: loading
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
                                        columns: [
                                          DataColumn(
                                            label: Text(
                                              "ID",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onSort: (columnIndex, ascending) =>
                                                onSort(
                                                  (t) =>
                                                      int.tryParse(
                                                        t['id'].toString(),
                                                      ) ??
                                                      0,
                                                  columnIndex,
                                                  ascending,
                                                ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              "Title",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onSort: (columnIndex, ascending) =>
                                                onSort(
                                                  (t) => t['title'] ?? '',
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
                                            onSort: (columnIndex, ascending) =>
                                                onSort(
                                                  (t) => t['status'] ?? '',
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
                                        rows: tasks.map<DataRow>((task) {
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  task['id'].toString(),
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  task['title'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  task['status'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.white70,
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
                                                          onEditTask(task),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () =>
                                                          onDeleteTask(
                                                            task['id'],
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
    );
  }
}

// Sidebar with hover support
class _Sidebar extends StatefulWidget {
  final bool isSidebarOpen;
  final VoidCallback onHome;
  final VoidCallback onDashboard;
  final VoidCallback? onAdminDashboard;
  final VoidCallback? onManagerPage;
  final VoidCallback? onSubModule;
  final VoidCallback onLogout;
  final String role;

  const _Sidebar({
    required this.isSidebarOpen,
    required this.onHome,
    required this.onDashboard,
    this.onAdminDashboard,
    this.onManagerPage,
    this.onSubModule,
    required this.onLogout,
    required this.role,
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
          if (widget.role.toLowerCase() == "admin" &&
              widget.onAdminDashboard != null)
            _SidebarItem(
              imagePath: "assets/images/admin.png",
              label: "Admin Dashboard",
              isOpen: widget.isSidebarOpen && showText,
              onTap: widget.onAdminDashboard,
              hovered: hoveredLabel == "Admin Dashboard",
              onHover: (hovering) {
                setState(
                  () => hoveredLabel = hovering ? "Admin Dashboard" : null,
                );
              },
            ),
          if (widget.role.toLowerCase() == "manager" &&
              widget.onManagerPage != null)
            _SidebarItem(
              imagePath: "assets/images/manager.png",
              label: "Materials Records",
              isOpen: widget.isSidebarOpen && showText,
              onTap: widget.onManagerPage,
              hovered: hoveredLabel == "Materials Records",
              onHover: (hovering) {
                setState(
                  () => hoveredLabel = hovering ? "Materials Records" : null,
                );
              },
            ),
          if (widget.role.toLowerCase() == "manager" &&
              widget.onSubModule != null)
            _SidebarItem(
              imagePath: "assets/images/submodule.png",
              label: "Sub-Module #2",
              isOpen: widget.isSidebarOpen && showText,
              onTap: widget.onSubModule,
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
            onTap: null, // Disable tap since you're already on this page
            isActive: true, // <-- Highlight when on Task page
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
            onTap: widget.onLogout,
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
        onTap: isActive ? null : onTap,
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
                  color:
                      color ?? (isActive ? Colors.orangeAccent : Colors.white),
                ),
              ),
              if (isOpen) ...[
                SizedBox(width: 12),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 250),
                  child: Text(
                    label,
                    style: TextStyle(
                      color:
                          color ??
                          (isActive ? Colors.orangeAccent : Colors.white),
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
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
