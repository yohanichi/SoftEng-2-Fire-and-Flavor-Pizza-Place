import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dash.dart';
import 'user_dialog.dart';
import 'task_page.dart';
import 'dashboard_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final String loggedInUsername;

  AdminDashboardPage({required this.loggedInUsername});

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final String apiBase =
      "http://192.168.254.115/my_application/my_php_api/user";
  List users = [];
  bool isLoading = true;

  bool _isSidebarOpen = false;
  late String currentUsername;

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
              // normalize role and status to match dropdown items
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

    // Ensure dropdown values are valid
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
                // Username
                TextField(
                  controller: usernameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Username",
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

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Password",
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

                // Role Dropdown
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.black87,
                  value: role,
                  items: ["admin", "manager", "user"]
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r, style: TextStyle(color: Colors.white)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      if (v == "admin" && widget.loggedInUsername != "admin") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Only the first admin can assign admin role",
                            ),
                          ),
                        );
                        return;
                      }
                      role = v!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Role",
                    labelStyle: TextStyle(color: Colors.orangeAccent),
                  ),
                ),
                SizedBox(height: 12),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.black87,
                  value: status,
                  items: ["active", "blocked"]
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: TextStyle(color: Colors.white)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      status = v!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Status",
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
                if (usernameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Username cannot be empty")),
                  );
                  return;
                }

                Map<String, String> formData = {
                  "username": usernameController.text,
                  "role": role,
                  "status": status,
                  "loggedInUsername": widget.loggedInUsername,
                };

                if (passwordController.text.isNotEmpty) {
                  formData["password"] = passwordController.text;
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
              Map<String, String> body = {"id": "1"}; // first admin ID
              if (usernameController.text.isNotEmpty) {
                body["username"] = usernameController.text;
              }
              if (passwordController.text.isNotEmpty) {
                body["password"] = passwordController.text;
              }

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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => dash()),
          (route) => false,
        );
        return false;
      },
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
                                username: widget.loggedInUsername,
                                role: "admin", // or dynamic
                                userId: "1", // pass real userId
                              ),
                            ),
                          );
                        },
                      ),
                      _SidebarItem(
                        imagePath: "assets/images/admin.png",
                        label: "Admin Dashboard",
                        isOpen: _isSidebarOpen,
                        isActive: true, // current page highlight
                        onTap: null,
                      ),
                      _SidebarItem(
                        imagePath: "assets/images/task.png",
                        label: "Tasks",
                        isOpen: _isSidebarOpen,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskPage(
                                userId: "1", // real userId
                                username: widget.loggedInUsername,
                                role: "admin",
                              ),
                            ),
                          );
                        },
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => dash()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Main Content
                // Only showing the main content section replacement
                // Keep the sidebar and topbar code as in previous AdminDashboardPage
                Expanded(
                  child: Column(
                    children: [
                      // Top Bar (unchanged)
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
                                onTap: () => openUserDialog(),
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
                      // Main container like TaskPage
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
                                          columnSpacing: 40,
                                          headingRowHeight: 56,
                                          dataRowHeight: 56,
                                          columns: const [
                                            DataColumn(
                                              label: Text(
                                                "ID",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Username",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Role",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                "Status",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
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
                                          rows: users.map((user) {
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
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    user['username'],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    user['role'],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    user['status'] ?? 'active',
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
                                                            openUserDialog(
                                                              user: user,
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
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.orangeAccent.withOpacity(0.2)
                : (_isHovering
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.transparent),
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
                  color: widget.isActive ? Colors.orangeAccent : widget.color,
                ),
              ),
              if (widget.isOpen) ...[
                SizedBox(width: 12),
                AnimatedOpacity(
                  opacity: widget.isOpen ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 250),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isActive
                          ? Colors.orangeAccent
                          : widget.color ?? Colors.white,
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
