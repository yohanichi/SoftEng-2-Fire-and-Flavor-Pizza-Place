import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'admin_dashboard_page.dart';
import 'manager_page.dart';
import 'task_page.dart';
import 'dash.dart';
import 'ui/dashboard_page_ui.dart'; // <-- Import the UI

class DashboardPage extends StatefulWidget {
  final String username;
  final String role;
  final String userId;

  DashboardPage({
    required this.username,
    required this.role,
    required this.userId,
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late String currentUsername;
  late String currentRole;
  late String userId;

  final String apiBase = "http://localhost/my_application/my_php_api/user";

  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    currentUsername = widget.username;
    currentRole = widget.role;
    userId = widget.userId;
  }

  void toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  Future<void> _logoutAndGoToDash(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => dash()),
      (route) => false,
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
              Map<String, String> body = {"id": userId};
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

                if (data['success']) {
                  if (body.containsKey("username")) {
                    setState(() {
                      currentUsername = body["username"]!;
                    });
                  }
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

  @override
  Widget build(BuildContext context) {
    return DashboardPageUI(
      isSidebarOpen: _isSidebarOpen,
      toggleSidebar: toggleSidebar,
      currentUsername: currentUsername,
      currentRole: currentRole,
      userId: userId,
      onHome: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => dash()),
        );
      },
      onAdminDashboard: currentRole.toLowerCase() == "admin"
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AdminDashboardPage(loggedInUsername: currentUsername),
                ),
              );
            }
          : null,
      onManagerPage: currentRole.toLowerCase() == "manager"
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManagerPage(
                    username: currentUsername,
                    role: currentRole,
                    userId: userId,
                  ),
                ),
              );
            }
          : null,
      onSubModule: widget.role.toLowerCase() == "manager"
          ? () {
              // does nothing for now
            }
          : null,
      onTaskPage: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskPage(
              userId: userId,
              username: currentUsername,
              role: widget.role,
            ),
          ),
        );
      },
      onLogout: _logoutAndGoToDash,
      onEditProfile: openProfileDialog,
    );
  }
}
