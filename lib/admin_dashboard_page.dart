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
  final String loggedInRole;

  AdminDashboardPage({
    required this.loggedInUsername,
    required this.loggedInRole,
  });

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _PasswordFields extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController verifyPasswordController;

  const _PasswordFields({
    Key? key,
    required this.passwordController,
    required this.verifyPasswordController,
  }) : super(key: key);

  @override
  State<_PasswordFields> createState() => _PasswordFieldsState();
}

class _PasswordFieldsState extends State<_PasswordFields> {
  bool showPassword = false;
  bool showVerifyPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.passwordController,
          obscureText: !showPassword,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Password",
            labelStyle: TextStyle(color: Colors.white70),
            filled: true, // <-- this enables background fill
            fillColor: Colors.grey[800]!.withAlpha(179),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orangeAccent),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  showPassword = !showPassword;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: widget.verifyPasswordController,
          obscureText: !showVerifyPassword,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Verify Password",
            labelStyle: TextStyle(color: Colors.white70),
            filled: true, // <-- this enables background fill
            fillColor: Colors.grey[800]!.withAlpha(179),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orangeAccent),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                showVerifyPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  showVerifyPassword = !showVerifyPassword;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }
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

  bool loggedInIsRootAdmin() {
    return widget.loggedInRole.trim().toLowerCase() == 'root_admin';
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
                    "root_admin",
                    "admin",
                    "manager",
                    "user",
                  ].contains(users[i]['role']?.toLowerCase())
                  ? users[i]['role'].toLowerCase()
                  : "user";
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
    if (role == "root_admin") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cannot delete root admin")));
      return;
    }

    if ((role == "admin") && !loggedInIsRootAdmin()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only root admin can delete admins")),
      );
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
    Map<String, dynamic>? userMap = user != null
        ? Map<String, dynamic>.from(user)
        : null;

    bool isEdit = userMap != null;
    bool isCurrentUser =
        userMap != null && userMap['username'] == widget.loggedInUsername;
    bool userIsRootAdmin =
        userMap != null && (userMap['role']?.toLowerCase() == 'root_admin');
    bool isRootAdmin = loggedInIsRootAdmin();

    if (isEdit && userIsRootAdmin && !isRootAdmin) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Access Denied", style: TextStyle(color: Colors.white)),
          content: Text(
            "You cannot edit a root admin account.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("OK", style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );
      return;
    }

    final usernameController = TextEditingController(
      text: userMap?['username'] ?? '',
    );
    final emailController = TextEditingController(
      text: userMap?['email'] ?? '',
    );
    final passwordController = TextEditingController();
    final verifyPasswordController = TextEditingController();

    // Role logic
    String initialRole = userMap?['role'] ?? 'user';
    List<String> roleOptions = ['manager', 'user'];
    if (isRootAdmin) roleOptions.insert(0, 'admin');
    String selectedRole = initialRole.isNotEmpty ? initialRole : roleOptions[0];

    bool isRoleEditable = true;
    if (isEdit && !roleOptions.contains(initialRole)) {
      roleOptions.insert(0, initialRole);
      isRoleEditable = false;
    }

    // Status logic
    String selectedStatus = userMap?['status'] ?? 'active';
    List<String> statusOptions = ['active', 'blocked'];
    bool isStatusEditable = true;
    if (!isRootAdmin) {
      // Admin cannot block other admins or root admins
      if (userMap != null &&
          (userMap['role']?.toLowerCase() == 'admin' ||
              userMap['role']?.toLowerCase() == 'root_admin')) {
        isStatusEditable = false;
      }
    }

    bool? saved = await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              // Center the dialog
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 350, // <-- Adjust this value for width
                  minWidth: 350, // optional minimum
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[850]!.withAlpha(
                          217,
                        ), // 217 / 255 ≈ 0.85 opacity
                        Colors.grey[900]!.withAlpha(217),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEdit ? "Edit User" : "Add User",
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: usernameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Username",
                            labelStyle: TextStyle(color: Colors.white70),
                            filled: true, // <-- this enables background fill
                            fillColor: Colors.grey[800]!.withAlpha(179),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white70),
                            filled: true, // <-- this enables background fill
                            fillColor: Colors.grey[800]!.withAlpha(179),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: !userIsRootAdmin || isRootAdmin,
                        ),
                        SizedBox(height: 12),
                        if (!isEdit || isCurrentUser || isRootAdmin)
                          _PasswordFields(
                            passwordController: passwordController,
                            verifyPasswordController: verifyPasswordController,
                          ),
                        SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: InputDecoration(
                            labelText: "Role",
                            labelStyle: TextStyle(color: Colors.white70),
                            filled: true, // <-- this enables background fill
                            fillColor: Colors.grey[800]!.withAlpha(179),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          dropdownColor: Colors.grey[800],
                          items: roleOptions
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
                          onChanged: (!isEdit || isRoleEditable)
                              ? (val) => setState(
                                  () => selectedRole = val ?? selectedRole,
                                )
                              : null,
                        ),
                        SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: InputDecoration(
                            labelText: "Status",
                            labelStyle: TextStyle(color: Colors.white70),
                            filled: true, // <-- this enables background fill
                            fillColor: Colors.grey[800]!.withAlpha(179),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          dropdownColor: Colors.grey[800],
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
                          onChanged: isStatusEditable
                              ? (val) => setState(
                                  () => selectedStatus = val ?? selectedStatus,
                                )
                              : null,
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () async {
                                // your save logic here...
                              },
                              child: Text(
                                "Save",
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    if (saved == true) fetchUsers();
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
      onHome: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => dash()),
        (route) => false,
      ),
      onDashboard: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            username: widget.loggedInUsername,
            role: loggedInIsRootAdmin() ? 'root_admin' : 'admin',
            userId: loggedInIsRootAdmin()
                ? 'root_admin'
                : widget.loggedInUsername,
          ),
        ),
      ),
      onTasks: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TaskPage(
            username: widget.loggedInUsername,
            role: loggedInIsRootAdmin() ? 'root_admin' : 'admin',
            userId: loggedInIsRootAdmin()
                ? 'root_admin'
                : widget.loggedInUsername,
          ),
        ),
      ),
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      onSort: onSort,
    );
  }
}
