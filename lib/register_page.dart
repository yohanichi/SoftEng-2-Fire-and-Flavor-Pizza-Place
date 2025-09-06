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

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://localhost/my_application/my_php_api/register.php"),
        body: {
          "username": usernameController.text,
          "password": passwordController.text,
        },
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
