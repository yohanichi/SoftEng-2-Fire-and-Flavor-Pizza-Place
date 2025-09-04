import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dash.dart';
import 'manager_page.dart';
import 'dashboard_page.dart';
import 'admin_dashboard_page.dart';

class TaskPage extends StatefulWidget {
  final String userId;
  final String username;
  final String role;

  TaskPage({required this.userId, required this.username, required this.role});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final String apiBase =
      "http://192.168.254.115/my_application/my_php_api/tasks/tasks.php";
  List tasks = [];
  bool loading = true;

  String sortBy = 'ID';
  bool ascending = true;
  final List<String> statusOptions = ['pending', 'completed'];

  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => loading = true);
    try {
      final res = await http.get(
        Uri.parse("$apiBase?action=get&user_id=${widget.userId}"),
      );
      final data = json.decode(res.body);
      if (data['success']) tasks = data['tasks'];
    } catch (e) {
      print("Error fetching tasks: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  void sortTasks(String column) {
    setState(() {
      if (sortBy == column) ascending = !ascending;
      sortBy = column;

      tasks.sort((a, b) {
        dynamic aVal;
        dynamic bVal;

        switch (column) {
          case 'ID':
            aVal = int.tryParse(a['id'].toString()) ?? 0;
            bVal = int.tryParse(b['id'].toString()) ?? 0;
            break;
          case 'Title':
            aVal = a['title'] ?? '';
            bVal = b['title'] ?? '';
            break;
          case 'Due Date':
            aVal = a['due_date'] ?? '';
            bVal = b['due_date'] ?? '';
            break;
          case 'Status':
            aVal = a['status'] ?? '';
            bVal = b['status'] ?? '';
            break;
        }

        if (aVal is int && bVal is int) {
          return ascending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
        } else {
          return ascending
              ? aVal.toString().compareTo(bVal.toString())
              : bVal.toString().compareTo(aVal.toString());
        }
      });
    });
  }

  Future<void> addOrEditTask({Map? task}) async {
    TextEditingController titleController = TextEditingController(
      text: task?['title'] ?? '',
    );
    TextEditingController descriptionController = TextEditingController(
      text: task?['description'] ?? '',
    );
    TextEditingController dueDateController = TextEditingController(
      text: task?['due_date'] ?? '',
    );

    String status = task != null && statusOptions.contains(task['status'])
        ? task['status']
        : statusOptions[0];

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Color.fromARGB(255, 41, 41, 41).withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            task == null ? "Add Task" : "Edit Task",
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
                  controller: titleController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Title",
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
                  controller: descriptionController,
                  style: TextStyle(color: Colors.white),
                  minLines: 3,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: "Description",
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
                  controller: dueDateController,
                  readOnly: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Due Date",
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orangeAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: task != null && task['due_date'] != null
                          ? DateTime.tryParse(task['due_date']) ??
                                DateTime.now()
                          : DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dueDateController.text = pickedDate
                            .toIso8601String()
                            .split('T')[0];
                      });
                    }
                  },
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  dropdownColor: Colors.black87,
                  decoration: InputDecoration(
                    labelText: "Status",
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
                  onChanged: (val) => setState(() => status = val!),
                  items: statusOptions
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: TextStyle(color: Colors.white)),
                        ),
                      )
                      .toList(),
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
                if (titleController.text.isEmpty) return;
                var body = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'due_date': dueDateController.text,
                  'status': status,
                };
                if (task == null) {
                  body['user_id'] = widget.userId;
                } else {
                  body['id'] = task['id'].toString();
                }
                final res = await http.post(
                  Uri.parse(
                    "$apiBase?action=${task == null ? 'add' : 'update'}",
                  ),
                  body: body,
                );
                final data = json.decode(res.body);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(data['message'])));
                if (data['success']) {
                  Navigator.pop(context);
                  fetchTasks();
                }
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteTask(int id) async {
    final res = await http.post(
      Uri.parse("$apiBase?action=delete"),
      body: {'id': id.toString()},
    );
    final data = json.decode(res.body);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data['message'])));
    if (data['success']) fetchTasks();
  }

  Widget _buildSortableColumn(String label) {
    bool isSorted = sortBy == label;
    return InkWell(
      onTap: () => sortTasks(label),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isSorted ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
          ),
          if (isSorted)
            Text(
              ascending ? " ▲" : " ▼",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
        ],
      ),
    );
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
                    _SidebarItem(
                      imagePath: "assets/images/home.png",
                      label: "Home",
                      isOpen: _isSidebarOpen,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => dash()),
                        );
                      },
                    ),
                    _SidebarItem(
                      imagePath: "assets/images/dashboard.png",
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
                    if (widget.role.toLowerCase() == "admin")
                      _SidebarItem(
                        imagePath: "assets/images/admin.png",
                        label: "Admin Dashboard",
                        isOpen: _isSidebarOpen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminDashboardPage(
                                loggedInUsername: widget.username,
                              ),
                            ),
                          );
                        },
                      ),
                    if (widget.role.toLowerCase() == "manager")
                      _SidebarItem(
                        imagePath: "assets/images/manager.png",
                        label: "Materials Records",
                        isOpen: _isSidebarOpen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ManagerPage(
                                username: widget.username,
                                role: widget.role,
                                userId: widget.userId,
                              ),
                            ),
                          );
                        },
                      ),
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
                    _SidebarItem(
                      imagePath: "assets/images/task.png",
                      label: "Tasks",
                      isOpen: _isSidebarOpen,
                      isActive: true, // Current page
                      onTap: null,
                    ),
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
                              color: Colors.orange,
                            ),
                            onPressed: toggleSidebar,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "${widget.username}'s Tasks",
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
                              onTap: () => addOrEditTask(),
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
                                        sortAscending: ascending,
                                        columnSpacing: 40,
                                        headingRowHeight: 56,
                                        dataRowHeight: 56,
                                        columns: [
                                          DataColumn(
                                            label: _buildSortableColumn("ID"),
                                          ),
                                          DataColumn(
                                            label: _buildSortableColumn(
                                              "Title",
                                            ),
                                          ),
                                          DataColumn(
                                            label: _buildSortableColumn(
                                              "Due Date",
                                            ),
                                          ),
                                          DataColumn(
                                            label: _buildSortableColumn(
                                              "Status",
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
                                        rows: tasks.map((t) {
                                          int taskId =
                                              int.tryParse(
                                                t['id'].toString(),
                                              ) ??
                                              0;
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  taskId.toString(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  t['title'],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  t['due_date'] ?? "-",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  t['status'],
                                                  style: TextStyle(
                                                    color: Colors.white,
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
                                                          addOrEditTask(
                                                            task: t,
                                                          ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () =>
                                                          deleteTask(taskId),
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

class _SidebarItem extends StatefulWidget {
  final String imagePath;
  final String label;
  final bool isOpen;
  final VoidCallback? onTap;
  final Color? color;
  final bool isActive;

  const _SidebarItem({
    required this.imagePath,
    required this.label,
    required this.isOpen,
    this.onTap,
    this.color,
    this.isActive = false,
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
      onEnter: (_) {
        if (!widget.isActive) setState(() => _isHovering = true);
      },
      onExit: (_) {
        if (!widget.isActive) setState(() => _isHovering = false);
      },
      child: InkWell(
        onTap: widget.isActive ? null : widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.orange.withOpacity(0.3)
                : _isHovering
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
                  color:
                      widget.color ??
                      (widget.isActive ? Colors.orangeAccent : Colors.white),
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
                      color:
                          widget.color ??
                          (widget.isActive
                              ? Colors.orangeAccent
                              : Colors.white),
                      fontSize: 16,
                      fontWeight: widget.isActive
                          ? FontWeight.bold
                          : FontWeight.w500,
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
