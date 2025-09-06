import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dash.dart';
import 'manager_page.dart';
import 'dashboard_page.dart';
import 'admin_dashboard_page.dart';
import 'ui/task_page_ui.dart';

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
  bool _isSidebarOpen = false;

  int? sortColumnIndex;
  bool sortAscending = true;
  final List<String> statusOptions = ['pending', 'ongoing', 'completed'];

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

  void onSort<T>(
    Comparable<T> Function(Map task) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      tasks.sort((a, b) {
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
        builder: (context, setState) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 600,
              maxWidth: 600, // Fixed width
            ),
            child: Dialog(
              backgroundColor: Color.fromARGB(
                255,
                41,
                41,
                41,
              ).withOpacity(0.85),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dialog title
                    Text(
                      task == null ? "Add Task" : "Edit Task",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 22, // Enlarged title
                      ),
                    ),
                    SizedBox(height: 16),
                    // Title input
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
                    // Description input
                    TextField(
                      controller: descriptionController,
                      style: TextStyle(color: Colors.white),
                      minLines: 5,
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
                    // Due Date input with fixed width
                    SizedBox(height: 12),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // align to the right
                      children: [
                        // Due Date field
                        SizedBox(
                          width: 150, // fixed width
                          child: TextField(
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
                                borderSide: BorderSide(
                                  color: Colors.orangeAccent,
                                ),
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
                                initialDate:
                                    task != null && task['due_date'] != null
                                    ? DateTime.tryParse(task['due_date']) ??
                                          DateTime.now()
                                    : DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null)
                                dueDateController.text = pickedDate
                                    .toIso8601String()
                                    .split('T')[0];
                            },
                          ),
                        ),
                        SizedBox(width: 16), // spacing between fields
                        // Status dropdown
                        SizedBox(
                          width: 150, // fixed width
                          child: DropdownButtonFormField<String>(
                            value: status,
                            isExpanded: true,
                            isDense: true,
                            dropdownColor: Colors.black87,
                            decoration: InputDecoration(
                              labelText: "Status",
                              labelStyle: TextStyle(color: Colors.orangeAccent),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.orangeAccent,
                                ),
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
                                    child: Text(
                                      s,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        SizedBox(width: 8),
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
                            if (task == null)
                              body['user_id'] = widget.userId;
                            else
                              body['id'] = task['id'].toString();

                            final res = await http.post(
                              Uri.parse(
                                "$apiBase?action=${task == null ? 'add' : 'update'}",
                              ),
                              body: body,
                            );
                            final data = json.decode(res.body);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(data['message'])),
                            );
                            if (data['success']) {
                              Navigator.pop(context);
                              fetchTasks();
                            }
                          },
                          child: Text("Save"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
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

  void toggleSidebar() => setState(() => _isSidebarOpen = !_isSidebarOpen);
  void onAddTask() => addOrEditTask();
  void onEditTask(Map task) => addOrEditTask(task: task);
  void onDeleteTask(int id) => deleteTask(id);

  void onHome() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => dash()),
    (route) => false,
  );

  @override
  Widget build(BuildContext context) {
    return TaskPageUI(
      isSidebarOpen: _isSidebarOpen,
      toggleSidebar: toggleSidebar,
      username: widget.username,
      role: widget.role,
      userId: widget.userId,
      tasks: tasks,
      loading: loading,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      onSort: onSort,
      onAddTask: onAddTask,
      onEditTask: onEditTask,
      onDeleteTask: onDeleteTask,
      // NEW callback for viewing a task
      onViewTask: (task) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Color.fromARGB(255, 41, 41, 41).withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SizedBox(
              width: 500, // <-- Adjust width here
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "Title:",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      task['title'] ?? '',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 22, // Enlarged title
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Divider(color: Colors.orangeAccent),
                    SizedBox(height: 8),
                    // Description
                    Text(
                      "Description:",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      task['description'] ?? 'No description',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  "Close",
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ),
            ],
          ),
        );
      },

      onHome: onHome,
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
      onAdminDashboard: widget.role.toLowerCase() == "admin"
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AdminDashboardPage(loggedInUsername: widget.username),
              ),
            )
          : null,
      onManagerPage: widget.role.toLowerCase() == "manager"
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ManagerPage(
                  username: widget.username,
                  role: widget.role,
                  userId: widget.userId,
                ),
              ),
            )
          : null,
      onSubModule: widget.role.toLowerCase() == "manager" ? () {} : null,
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
