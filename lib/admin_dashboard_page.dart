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
    bool isEditingUsername = user == null;
    bool isEditingEmail = user == null;
    bool isEditingPassword = user == null;
    bool showPassword = false;
    String? usernameError;
    String? emailError;
    String? passwordError;

    final TextEditingController usernameController = TextEditingController(
      text: user?['username'] ?? '',
    );
    final TextEditingController emailController = TextEditingController(
      text: user?['email'] ?? '',
    );
    final TextEditingController passwordController = TextEditingController();

    String role = user?['role'] ?? 'user';
    String status = user?['status'] ?? 'active';
    List<String> roles = ["admin", "manager", "user"];
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Username
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: usernameController,
                          enabled: user == null ? true : isEditingUsername,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 54, 54, 54),
                            labelText: "Username",
                            labelStyle: TextStyle(color: Colors.orangeAccent),
                            errorText: usernameError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      if (user != null) // show edit button only when editing
                        IconButton(
                          icon: Icon(
                            isEditingUsername ? Icons.check : Icons.edit,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: () {
                            setState(
                              () => isEditingUsername = !isEditingUsername,
                            );
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Email
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: emailController,
                          enabled: user == null ? true : isEditingEmail,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 54, 54, 54),
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.orangeAccent),
                            errorText: emailError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      if (user != null) // show edit button only when editing
                        IconButton(
                          icon: Icon(
                            isEditingEmail ? Icons.check : Icons.edit,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: () {
                            setState(() => isEditingEmail = !isEditingEmail);
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Password
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: passwordController,
                          obscureText: !showPassword,
                          style: TextStyle(color: Colors.white),
                          enabled: user == null ? true : isEditingPassword,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 54, 54, 54),
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.orangeAccent),
                            errorText: passwordError,
                            hintText: user == null
                                ? "Enter password"
                                : isEditingPassword
                                ? "Enter new password"
                                : "********",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() => showPassword = !showPassword);
                              },
                            ),
                          ),
                        ),
                      ),
                      if (user != null) // show edit button only when editing
                        IconButton(
                          icon: Icon(
                            isEditingPassword ? Icons.check : Icons.edit,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              isEditingPassword = !isEditingPassword;
                              if (isEditingPassword) {
                                passwordController.clear();
                              } else {
                                showPassword = false;
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Role & Status (unchanged)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: role,
                          dropdownColor: Colors.grey[900],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 54, 54, 54),
                            labelText: "Role",
                            labelStyle: TextStyle(color: Colors.orangeAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
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
                      SizedBox(height: 12),
                      Container(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: status,
                          dropdownColor: Colors.grey[900],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 54, 54, 54),
                            labelText: "Status",
                            labelStyle: TextStyle(color: Colors.orangeAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
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
                setState(() {
                  usernameError = null;
                  emailError = null;
                  passwordError = null;
                });

                final username = usernameController.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text;

                bool hasError = false;

                // Username validation
                if (username.length < 5) {
                  setState(
                    () => usernameError =
                        "Username must be at least 5 characters.",
                  );
                  hasError = true;
                }

                // Email validation
                final emailValid = RegExp(
                  r'^[^@]+@[^@]+\.[^@]+',
                ).hasMatch(email);
                if (!emailValid) {
                  setState(
                    () => emailError = "Please enter a valid email address.",
                  );
                  hasError = true;
                }

                // Password validation (only when new user OR editing with new password)
                if (user == null || password.isNotEmpty) {
                  final passwordValid = RegExp(
                    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{5,}$',
                  ).hasMatch(password);
                  if (!passwordValid) {
                    setState(
                      () => passwordError =
                          "Password must be at least 5 characters, contain 1 letter and 1 number.",
                    );
                    hasError = true;
                  }
                }

                if (hasError) return;

                // Build form data
                Map<String, String> formData = {
                  "username": username,
                  "email": email,
                  "role": role,
                  "status": status,
                };
                if (password.isNotEmpty) {
                  formData["password"] = password;
                }

                try {
                  final response = await http.post(
                    Uri.parse(
                      user == null
                          ? "$apiBase/create_user.php"
                          : "$apiBase/update_user.php",
                    ),
                    body: user == null
                        ? formData
                        : {"id": user['id'].toString(), ...formData},
                  );

                  final result = json.decode(response.body);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result['message'])));

                  fetchUsers();
                  Navigator.pop(ctx);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Save failed: $e")));
                }
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
