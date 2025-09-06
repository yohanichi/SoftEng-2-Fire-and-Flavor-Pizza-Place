import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'ui/register_page_ui.dart'; // <-- import the UI

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailController = TextEditingController(); // <-- Add this

  Future<void> registerUser() async {
    final username = usernameController.text;
    final password = passwordController.text;
    final email = emailController.text;

    // Username restrictions
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

    if (password != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Passwords do not match")));
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://localhost/my_application/my_php_api/register.php"),
        body: {"username": username, "password": password, "email": email},
      );

      final data = json.decode(response.body);

      if (data['success'].toString() == "true" ||
          data['success'].toString() == "1") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration successful! Redirecting...")),
        );

        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Registration failed")),
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
    return RegisterPageUI(
      usernameController: usernameController,
      passwordController: passwordController,
      confirmPasswordController: confirmPasswordController,
      emailController: emailController, // <-- Add this
      onRegister: registerUser,
      onLogin: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      },
    );
  }
}
