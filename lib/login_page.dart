import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_page.dart';
import 'register_page.dart';

// 👇 Define your API base URL here
// For local testing:
// const String apiBase = "http://192.168.254.114/my_application";
// For InfinityFree:
const String apiBase = "http://3lig2mfs.infinityfree.com";

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true; // toggle visibility

  Future<void> loginUser() async {
    final response = await http.post(
      Uri.parse("${apiBase}/login.php"), // 👈 using apiBase here
      body: {
        "username": usernameController.text,
        "password": passwordController.text,
      },
    );

    final data = json.decode(response.body);

    if (data['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            username: data['username'],
            role: data['role'],
            userId: data['id'].toString(), // Pass the DB ID here
          ),
        ),
      );
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
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
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
