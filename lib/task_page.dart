import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TaskPage extends StatefulWidget {
  final String userId;
  final String username;

  TaskPage({required this.userId, required this.username});

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

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => loading = true);
    try {
      // ✅ Replace this:
      // final res = await http.get(
      //   Uri.parse("$apiBase?action=get&user_id=${widget.userId}"),
      // );

      // With this:
      final userIdInt = int.tryParse(widget.userId) ?? 0;
      final res = await http.get(
        Uri.parse("$apiBase?action=get&user_id=$userIdInt"),
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
      text: task != null ? task['title'] : '',
    );
    TextEditingController descriptionController = TextEditingController(
      text: task != null ? task['description'] ?? '' : '',
    );
    TextEditingController dueDateController = TextEditingController(
      text: task != null ? task['due_date'] ?? '' : '',
    );

    String status = task != null && statusOptions.contains(task['status'])
        ? task['status']
        : statusOptions[0];

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(task == null ? "Add Task" : "Edit Task"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 400, maxWidth: 500),
                child: TextField(
                  controller: titleController,
                  maxLength: 255,
                  minLines: 2,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Description
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 400, maxWidth: 500),
                child: TextField(
                  controller: descriptionController,
                  maxLength: 65535,
                  minLines: 3,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Due Date
              TextField(
                controller: dueDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Due Date",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                  contentPadding: EdgeInsets.all(12),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: task != null && task['due_date'] != null
                        ? DateTime.tryParse(task['due_date']) ?? DateTime.now()
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
              // Status Dropdown
              DropdownButton<String>(
                value: status,
                onChanged: (val) => setState(() => status = val!),
                items: statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
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
                Uri.parse("$apiBase?action=${task == null ? 'add' : 'update'}"),
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
              color: isSorted ? Colors.blue : Colors.black,
            ),
          ),
          if (isSorted)
            Text(
              ascending ? " ▲" : " ▼",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.username}'s Tasks"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<String>(
              value: sortBy,
              dropdownColor: Colors.grey[200],
              underline: Container(),
              onChanged: (val) => sortTasks(val!),
              items: [
                'ID',
                'Title',
                'Due Date',
                'Status',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => addOrEditTask(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[200],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(120, 40),
              ),
              icon: Icon(Icons.add, size: 20),
              label: Center(
                child: Text(
                  "Add Task",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent, width: 1),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: DataTable(
                    columnSpacing: 40,
                    columns: [
                      DataColumn(label: _buildSortableColumn("ID")),
                      DataColumn(label: _buildSortableColumn("Title")),
                      DataColumn(label: _buildSortableColumn("Due Date")),
                      DataColumn(label: _buildSortableColumn("Status")),
                      DataColumn(label: Text("Actions")),
                    ],
                    rows: tasks.map((t) {
                      int taskId = int.tryParse(t['id'].toString()) ?? 0;
                      return DataRow(
                        cells: [
                          // ID
                          DataCell(
                            Container(
                              width: 60,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.centerLeft,
                              child: Text(taskId.toString()),
                            ),
                          ),
                          // Title clickable
                          DataCell(
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    content: SizedBox(
                                      width: 400, // fixed width
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Title label
                                            Text(
                                              "Title:",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            // Title value
                                            Text(
                                              t['title'],
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            SizedBox(height: 8),
                                            Divider(), // line separator
                                            SizedBox(height: 8),
                                            // Description label
                                            Text(
                                              "Description:",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            // Description value
                                            Text(
                                              t['description'] ??
                                                  "No description",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Close"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                width: 300, // fixed width for table cell
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  t['title'],
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Due Date
                          DataCell(
                            Container(
                              width: 120,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                t['due_date'] ?? "-",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          // Status
                          DataCell(
                            Container(
                              width: 100,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                t['status'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          // Actions
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => addOrEditTask(task: t),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteTask(taskId),
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
    );
  }
}
