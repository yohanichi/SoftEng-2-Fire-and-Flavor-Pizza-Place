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
  late TextEditingController emailController;
  bool hidePassword = true;
  bool isSaving = false; // <-- For loading state

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.currentUsername);
    passwordController = TextEditingController();
    emailController = TextEditingController();
    loadEmail();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString("email") ?? "";
  }

  Future<void> saveProfile() async {
    if (usernameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Username cannot be empty")));
      return;
    }
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Email cannot be empty")));
      return;
    }

    // 🔒 Password validation (only if provided)
    if (passwordController.text.isNotEmpty) {
      final password = passwordController.text;
      final passwordValid = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d).{5,}$',
      ).hasMatch(password);

      if (!passwordValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Password must be at least 5 characters, contain at least 1 letter and 1 number.",
            ),
          ),
        );
        return;
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("id");

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not found")));
      return;
    }

    Map<String, String> body = {
      "id": userId,
      "username": usernameController.text,
      "email": emailController.text,
    };

    if (passwordController.text.isNotEmpty) {
      body["password"] = passwordController.text;
    }

    setState(() => isSaving = true);

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
        await prefs.setString("email", emailController.text);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => dash()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditProfilePageUI(
      usernameController: usernameController,
      passwordController: passwordController,
      emailController: emailController,
      hidePassword: hidePassword,
      isSaving: isSaving, // <-- Pass loading state
      onBack: () => Navigator.pop(context),
      onSave: saveProfile,
      onTogglePassword: () => setState(() => hidePassword = !hidePassword),
    );
  }
}
