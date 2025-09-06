import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'dashboard_page.dart';
import 'edit_profile_page.dart';
import 'ui/dash_page_ui.dart'; // <-- Import the UI

class dash extends StatefulWidget {
  @override
  _dashState createState() => _dashState();
}

class _dashState extends State<dash> {
  String? username;
  String? role;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username");
      role = prefs.getString("role");
      userId = prefs.getString("id");
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashPageUI(
      username: username,
      role: role,
      userId: userId,
      onLogin: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        ).then((_) => _loadUser());
      },
      onRegister: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RegisterPage()),
        );
      },
      onDashboard: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(
              username: username ?? "",
              role: role ?? "",
              userId: userId ?? "",
            ),
          ),
        );
      },
      onMenuSelected: (value) async {
        if (value == "profile") {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfilePage(currentUsername: username ?? ""),
            ),
          );
          _loadUser();
        } else if (value == "logout") {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          setState(() {
            username = null;
            role = null;
            userId = null;
          });
        }
      },
    );
  }
}
