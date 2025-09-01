import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true; // toggle

  Future<void> registerUser() async {
    final response = await http.post(
      Uri.parse(
        "http://192.168.254.115/my_application/my_php_api/users/register.php",
      ),
      body: {
        "username": usernameController.text,
        "password": passwordController.text,
      },
    );

    final data = json.decode(response.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data['message'])));

    if (data['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
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
                    setState(() => hidePassword = !hidePassword);
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: registerUser, child: Text("Register")),
          ],
        ),
      ),
    );
  }
}
