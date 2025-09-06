import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import 'dash.dart';
import 'ui/login_page_ui.dart'; // <-- Import the UI

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
      _redirectUser();
    }
  }

  void _redirectUser() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => dash()),
    );
  }

  Future<void> loginUser() async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost/my_application/my_php_api/login.php"),
        body: {
          "username": usernameController.text,
          "password": passwordController.text,
        },
      );

      final data = json.decode(response.body);

      if (data['success'].toString() == "true" ||
          data['success'].toString() == "1") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("username", data['username']);
        await prefs.setString("role", data['role']);
        await prefs.setString("id", data['id'].toString());
        await prefs.setString("email", data['email']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful! Redirecting...")),
        );

        Future.delayed(Duration(seconds: 1), () {
          _redirectUser();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Login failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginPageUI(
      usernameController: usernameController,
      passwordController: passwordController,
      hidePassword: hidePassword,
      onBack: () => Navigator.pop(context),
      onLogin: loginUser,
      onTogglePassword: () => setState(() => hidePassword = !hidePassword),
      onRegister: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RegisterPage()),
        );
      },
    );
  }
}
