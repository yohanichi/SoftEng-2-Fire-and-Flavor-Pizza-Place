import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dash.dart';
import 'task_page.dart';
import 'dashboard_page.dart';
import 'ui/admin_dashboard_page_ui.dart';

class AdminDashboardPage extends StatefulWidget {
  final String loggedInUsername;

  AdminDashboardPage({required this.loggedInUsername});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final String apiBase = "http://localhost/my_application/my_php_api/user";
  List users = [];
  bool isLoading = true;

  bool _isSidebarOpen = false;
  late String currentUsername;

  int? sortColumnIndex;
  bool sortAscending = true;

  @override
  void initState() {
    super.initState();
    currentUsername = widget.loggedInUsername;
    fetchUsers();
  }

  void toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$apiBase/get_users.php"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            users = List<Map<String, dynamic>>.from(data['users']);
            for (int i = 0; i < users.length; i++) {
              users[i]['display_id'] = i + 1;
              users[i]['status'] = users[i]['status'] ?? 'active';
              users[i]['role'] =
                  ([
                    "admin",
                    "manager",
                    "user",
                  ].contains(users[i]['role']?.toLowerCase()))
                  ? users[i]['role'].toLowerCase()
                  : "user";
              users[i]['status'] =
                  ([
                    "active",
                    "blocked",
                  ].contains(users[i]['status']?.toLowerCase()))
                  ? users[i]['status'].toLowerCase()
                  : "active";
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

  void onSort<T>(
    Comparable<T> Function(Map user) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      users.sort((a, b) {
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

  Future<void> deleteUser(int id, String username, String role) async {
    if (role == "admin" && widget.loggedInUsername != "admin") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only first admin can delete admins")),
      );
      return;
    }
    if (id == 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cannot delete first admin")));
      return;
    }
    if (username == widget.loggedInUsername) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cannot delete yourself")));
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete $username?"),
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
      try {
        final response = await http.post(
          Uri.parse("$apiBase/delete_user.php"),
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
  }

  Future<void> openUserDialog({Map? user}) async {
    TextEditingController usernameController = TextEditingController(
      text: user?['username'] ?? '',
    );
    TextEditingController passwordController = TextEditingController();
    TextEditingController emailController = TextEditingController(
      text: user?['email'] ?? '',
    );

    String role =
        (["admin", "manager", "user"].contains(user?['role']?.toLowerCase()))
        ? user!['role'].toLowerCase()
        : "user";
    String status =
        (["active", "blocked"].contains(user?['status']?.toLowerCase()))
        ? user!['status'].toLowerCase()
        : "active";

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            user == null ? "Add User" : "Edit User",
            style: TextStyle(color: Colors.orangeAccent),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Username",
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final username = usernameController.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text;

                // Username validation
                final usernameValid =
                    username.length >= 5 &&
                    RegExp(r'[0-9]').hasMatch(username) &&
                    !username.contains(' ');

                if (!usernameValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Username must be at least 5 characters, contain at least 1 number, and have no spaces.",
                      ),
                    ),
                  );
                  return;
                }

                // Email validation
                final emailValid = RegExp(
                  r'^[^@]+@[^@]+\.[^@]+',
                ).hasMatch(email);
                if (!emailValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid email.")),
                  );
                  return;
                }

                // Password validation (only if entered)
                if (password.isNotEmpty) {
                  final passwordValid =
                      password.length >= 5 &&
                      RegExp(
                        r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$',
                      ).hasMatch(password) &&
                      !password.contains(' ');
                  if (!passwordValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Password must be at least 5 characters, contain at least 1 letter and 1 number, and have no spaces.",
                        ),
                      ),
                    );
                    return;
                  }
                }

                Map<String, String> formData = {
                  "username": username,
                  "email": email,
                  "role": role,
                  "status": status,
                  "loggedInUsername": widget.loggedInUsername,
                };

                if (password.isNotEmpty) {
                  formData["password"] = password;
                }

                if (user != null) {
                  formData["id"] = user['id'].toString();
                }

                final url = user == null
                    ? "$apiBase/create_user.php"
                    : "$apiBase/update_user.php";

                try {
                  final response = await http.post(
                    Uri.parse(url),
                    body: formData,
                  );
                  final result = json.decode(response.body);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result['message'])));
                  if (result['success'] == true) {
                    fetchUsers();
                    Navigator.pop(ctx);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Operation failed: $e")),
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openProfileDialog(BuildContext context) async {
    TextEditingController usernameController = TextEditingController(
      text: currentUsername,
    );
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
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
              final username = usernameController.text.trim();
              final password = passwordController.text;

              // Username validation
              if (username.isNotEmpty) {
                final usernameValid =
                    username.length >= 5 &&
                    RegExp(r'[0-9]').hasMatch(username) &&
                    !username.contains(' ');
                if (!usernameValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Username must be at least 5 characters, contain at least 1 number, and have no spaces.",
                      ),
                    ),
                  );
                  return;
                }
              }

              // Password validation
              if (password.isNotEmpty) {
                final passwordValid =
                    password.length >= 5 &&
                    RegExp(
                      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$',
                    ).hasMatch(password) &&
                    !password.contains(' ');
                if (!passwordValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Password must be at least 5 characters, contain at least 1 letter and 1 number, and have no spaces.",
                      ),
                    ),
                  );
                  return;
                }
              }

              Map<String, String> body = {"id": "1"}; // first admin ID
              if (username.isNotEmpty) body["username"] = username;
              if (password.isNotEmpty) body["password"] = password;

              if (body.length == 1) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("No changes to save")));
                return;
              }

              try {
                final response = await http.post(
                  Uri.parse("$apiBase/update_user.php"),
                  body: body,
                );
                final data = json.decode(response.body);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(data['message'])));
                if (data['success'] && body.containsKey("username")) {
                  setState(() {
                    currentUsername = body["username"]!;
                  });
                  Navigator.pop(context);
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> logoutAndGoDash(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => dash()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminDashboardPageUI(
      isSidebarOpen: _isSidebarOpen,
      toggleSidebar: toggleSidebar,
      users: users,
      isLoading: isLoading,
      openUserDialog: (user) => openUserDialog(user: user),
      deleteUser: deleteUser,
      logout: () => logoutAndGoDash(context),
      loggedInUsername: widget.loggedInUsername,
      onHome: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => dash()),
          (route) => false,
        );
      },
      onDashboard: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(
              username: widget.loggedInUsername,
              role: "admin",
              userId: "1",
            ),
          ),
        );
      },
      onTasks: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TaskPage(
              userId: "1",
              username: widget.loggedInUsername,
              role: "admin",
            ),
          ),
        );
      },
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      onSort: onSort,
    );
  }
}
