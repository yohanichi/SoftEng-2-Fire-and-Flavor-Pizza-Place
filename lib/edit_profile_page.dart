import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dash.dart';
import 'ui/edit_profile_page_ui.dart'; // <-- Import the UI

class EditProfilePage extends StatefulWidget {
  final String currentUsername;

  EditProfilePage({required this.currentUsername});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.currentUsername);
    passwordController = TextEditingController();
  }

  Future<void> saveProfile() async {
    if (usernameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Username cannot be empty")));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("id"); // fetch userId from shared prefs

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not found")));
      return;
    }

    Map<String, String> body = {
      "id": userId,
      "username": usernameController.text,
    };

    if (passwordController.text.isNotEmpty) {
      body["password"] = passwordController.text;
    }

    try {
      final response = await http.post(
        Uri.parse(
          "http://localhost/my_application/my_php_api/user/update_user.php",
        ),
        body: body,
      );

      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "Profile updated")),
      );

      if (data['success']) {
        await prefs.setString("username", usernameController.text);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => dash()),
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
    return EditProfilePageUI(
      usernameController: usernameController,
      passwordController: passwordController,
      hidePassword: hidePassword,
      onBack: () => Navigator.pop(context),
      onSave: saveProfile,
      onTogglePassword: () => setState(() => hidePassword = !hidePassword),
    );
  }
}
