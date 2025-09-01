import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'admin_dashboard_page.dart';
import 'task_page.dart'; // Import the task page

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

  final String apiBase = "http://192.168.254.115/my_application";

  @override
  void initState() {
    super.initState();
    currentUsername = widget.username;
    currentRole = widget.role;
    userId = widget.userId;
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

  Future<void> logout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, $currentUsername!", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => openProfileDialog(context),
              child: Text("Edit Profile"),
            ),

            SizedBox(height: 20),

            // Tasks button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TaskPage(userId: userId, username: currentUsername),
                  ),
                );
              },
              child: Text("My Tasks"),
            ),

            SizedBox(height: 20),

            // Admin dashboard button
            if (currentRole == "admin")
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminDashboardPage(loggedInUsername: currentUsername),
                    ),
                  );
                },
                child: Text("Go to Admin Dashboard"),
              ),

            SizedBox(height: 20),

            ElevatedButton(onPressed: logout, child: Text("Logout")),
          ],
        ),
      ),
    );
  }
}
