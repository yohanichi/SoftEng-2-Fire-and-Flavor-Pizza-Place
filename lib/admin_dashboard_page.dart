// admin_dashboard_page.dart
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

  /// Check if the logged-in user is the first admin
  bool loggedInIsFirstAdmin() {
    final current = users.firstWhere(
      (u) => u['username'] == widget.loggedInUsername,
      orElse: () => null,
    );
    if (current != null &&
        (current['id'] == 1 || current['id'].toString() == "1")) {
      return true;
    }
    return false;
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
              users[i]['role'] =
                  [
                    "admin",
                    "manager",
                    "user",
                  ].contains(users[i]['role']?.toLowerCase())
                  ? users[i]['role'].toLowerCase()
                  : "user";
              users[i]['status'] =
                  [
                    "active",
                    "blocked",
                  ].contains(users[i]['status']?.toLowerCase())
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
    if (role == "admin" && !loggedInIsFirstAdmin()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only first admin can delete other admins")),
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
    // Precompute if logged-in user is first admin
    final bool isFirstAdminLoggedIn = users.any(
      (u) =>
          u['username'] == widget.loggedInUsername &&
          (u['id'] == 1 || u['id'].toString() == "1"),
    );

    // Controllers (created once)
    final TextEditingController usernameController = TextEditingController(
      text: user?['username'] ?? '',
    );
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController emailController = TextEditingController(
      text: user?['email'] ?? '',
    );

    // Precompute role and status
    String role = user?['role']?.toLowerCase() ?? 'user';
    String status = user?['status']?.toLowerCase() ?? 'active';

    List<String> roles = ["manager", "user"];

    if (user != null) {
      // Editing user
      if (user['id'] == 1) {
        // First admin: only admin role and active status
        roles = ["admin"];
        role = "admin";
        status = "active";
      } else if (isFirstAdminLoggedIn) {
        // Logged-in first admin can assign admin
        roles.insert(0, "admin");
      }
    } else {
      // Adding new user
      if (isFirstAdminLoggedIn) roles.insert(0, "admin");
    }

    List<String> statuses = ["active", "blocked"];

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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 350,
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // full-width fields
                children: [
                  // Username
                  TextField(
                    controller: usernameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(color: Colors.orangeAccent),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Email
                  TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.orangeAccent),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.orangeAccent),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Role & Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // right align
                    children: [
                      // Role Dropdown
                      Container(
                        width: 150, // narrower width
                        child: DropdownButtonFormField<String>(
                          value: roles.contains(role) ? role : roles[0],
                          dropdownColor: Colors.grey[900],
                          decoration: InputDecoration(
                            labelText: "Role",
                            labelStyle: TextStyle(color: Colors.orangeAccent),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          items: roles
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => role = val);
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      // Status Dropdown
                      Container(
                        width: 150, // narrower width
                        child: DropdownButtonFormField<String>(
                          value: status,
                          dropdownColor: Colors.grey[900],
                          decoration: InputDecoration(
                            labelText: "Status",
                            labelStyle: TextStyle(color: Colors.orangeAccent),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          items: statuses
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
                          onChanged: (val) {
                            if (val != null) setState(() => status = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                // Save logic unchanged
              },
              child: Text("Save"),
            ),
          ],
        ),
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
