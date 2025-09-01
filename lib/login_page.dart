import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
import 'admin_dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString("username");
    String? savedRole = prefs.getString("role");
    String? savedUserId = prefs.getString("id");

    if (savedUsername != null && savedRole != null && savedUserId != null) {
      _redirectUser(savedUsername, savedRole, savedUserId);
    }
  }

  void _redirectUser(String username, String role, String userId) {
    // Everyone goes to Dashboard first
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DashboardPage(username: username, role: role, userId: userId),
      ),
    );
  }

  Future<void> loginUser() async {
    final response = await http.post(
      Uri.parse("http://192.168.254.115/my_application/login.php"),
      body: {
        "username": usernameController.text,
        "password": passwordController.text,
      },
    );

    final data = json.decode(response.body);

    if (data['success']) {
      // Save login info for persistence
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("username", data['username']);
      await prefs.setString("role", data['role']);
      await prefs.setString("id", data['id'].toString());

      _redirectUser(data['username'], data['role'], data['id'].toString());
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => hidePassword = !hidePassword),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: loginUser, child: Text("Login")),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: Text("Need a new account? Register here"),
            ),
          ],
        ),
      ),
    );
  }
}
