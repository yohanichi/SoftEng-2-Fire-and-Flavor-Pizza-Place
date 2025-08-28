import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminDashboardPage extends StatefulWidget {
  final String loggedInUsername; // pass from login
  AdminDashboardPage({required this.loggedInUsername});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final String apiBase = "http://3lig2mfs.infinityfree.com";

  List users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("${apiBase}/get_users.php"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            users = List<Map<String, dynamic>>.from(data['users']);
            for (int i = 0; i < users.length; i++) {
              users[i]['display_id'] = i + 1;
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching users: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await http.post(
        Uri.parse("${apiBase}/delete_user.php"),
        body: {"id": id.toString()},
      );
      final result = json.decode(response.body);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  Future<void> openUserDialog({Map? user}) async {
    await showDialog(
      context: context,
      builder: (_) => UserDialog(
        user: user,
        loggedInUsername: widget.loggedInUsername,
        onSave: (formData) async {
          final url = user == null
              ? "${apiBase}/create_user.php"
              : "${apiBase}/update_user.php";

          final body = user == null
              ? formData
              : {...formData, "id": user['id'].toString()};

          try {
            final response = await http.post(Uri.parse(url), body: body);
            final result = json.decode(response.body);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(result['message'])));
            fetchUsers();
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Operation failed: $e")));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            tooltip: "Add User",
            onPressed: () => openUserDialog(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: DataTable(
                  columns: const [
                    DataColumn(
                      label: Text("ID"),
                    ), // now shows actual database ID
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Role")),
                    DataColumn(label: Text("Action")),
                  ],
                  rows: users.map((user) {
                    int userId = int.tryParse(user['id'].toString()) ?? 0;
                    bool isFirstAdmin = userId == 1;
                    bool isLoggedInFirstAdmin =
                        widget.loggedInUsername == "yohan";

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(user['id'].toString()),
                        ), // show DB ID directly
                        DataCell(Text(user['username'])),
                        DataCell(Text(user['role'])),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  if (isFirstAdmin && !isLoggedInFirstAdmin) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "You cannot edit the first admin!",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  openUserDialog(user: user);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  if (isFirstAdmin) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "The first admin cannot be deleted!",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (user['username'] ==
                                      widget.loggedInUsername) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "You cannot delete your own account!",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (user['role'] == "admin") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "You cannot delete other admins!",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // Confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text("Confirm Delete"),
                                      content: Text(
                                        "Are you sure you want to delete ${user['username']}?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            deleteUser(userId);
                                          },
                                          child: Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
    );
  }
}

// ------------------ User Dialog ------------------

class UserDialog extends StatefulWidget {
  final Map? user;
  final String loggedInUsername;
  final Function(Map<String, String>) onSave;

  UserDialog({this.user, required this.loggedInUsername, required this.onSave});

  @override
  _UserDialogState createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  String role = "user";
  bool isFirstAdmin = false;
  bool isLoggedInFirstAdmin = false;
  bool hidePassword = true; // <- toggle

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(
      text: widget.user?['username'] ?? "",
    );
    passwordController = TextEditingController();
    role = widget.user?['role'] ?? "user";

    int userId = int.tryParse(widget.user?['id'].toString() ?? '0') ?? 0;
    isFirstAdmin = userId == 1;
    isLoggedInFirstAdmin = widget.loggedInUsername == "yohan";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.user == null
            ? "Create User"
            : isFirstAdmin
            ? "Edit First Admin"
            : "Edit User",
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: usernameController,
            decoration: InputDecoration(labelText: "Username"),
            enabled: !isFirstAdmin || isLoggedInFirstAdmin,
          ),
          TextField(
            controller: passwordController,
            obscureText: hidePassword,
            decoration: InputDecoration(
              labelText: widget.user == null
                  ? "Password"
                  : "Password (leave blank to keep)",
              suffixIcon: IconButton(
                icon: Icon(
                  hidePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
              ),
            ),
            enabled: true, // first admin can change password
          ),
          DropdownButton<String>(
            value: role,
            items: [
              "user",
              "admin",
            ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: isFirstAdmin
                ? null
                : (val) => setState(() => role = val!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave({
              "username": usernameController.text,
              "password": passwordController.text,
              "role": role,
            });
            Navigator.pop(context);
          },
          child: Text("Save"),
        ),
      ],
    );
  }
}
