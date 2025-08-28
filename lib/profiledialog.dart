import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileDialog extends StatefulWidget {
  final String username;

  ProfileDialog({required this.username});

  @override
  _ProfileDialogState createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  // ✅ Change to your InfinityFree domain
  final String apiBase = "http://3lig2mfs.infinityfree.com";

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.username);
    passwordController = TextEditingController();
  }

  Future<void> updateProfile() async {
    try {
      final response = await http.post(
        Uri.parse("$apiBase/update_user.php"),
        body: {
          "username": widget.username, // current username
          "new_username": usernameController.text,
          "password": passwordController.text,
        },
      );

      final data = json.decode(response.body);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'])));

      if (data['success'] == true) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Profile"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: usernameController,
            decoration: InputDecoration(labelText: "Username"),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: "New Password"),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(onPressed: updateProfile, child: Text("Save")),
      ],
    );
  }
}
