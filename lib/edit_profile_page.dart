import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final String currentUsername;

  EditProfilePage({required this.currentUsername});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  final String apiBase = "http://192.168.254.115/my_application";

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
    _passwordController = TextEditingController();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("userId"); // store this in login

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User ID not found, please log in again.")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$apiBase/my_php_api/users/update_user.php"),
        body: {
          "id": userId,
          "username": _usernameController.text,
          "password": _passwordController.text,
        },
      );

      final result = json.decode(response.body);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));

      if (result['success'] == true) {
        await prefs.setString("username", _usernameController.text);
        Navigator.pop(context); // go back to dashboard
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "New Username"),
                validator: (value) =>
                    value!.isEmpty ? "Enter a username" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "New Password"),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? "Enter a password" : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
