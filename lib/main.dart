import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'admin_dashboard_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Root of the app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashDecider(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashDecider extends StatefulWidget {
  @override
  _SplashDeciderState createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  String? username;
  String? role;
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username");
      role = prefs.getString("role");
      userId = prefs.getString("userId");
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If not logged in
    if (username == null || role == null || userId == null) {
      return LoginPage();
    }

    // Redirect logic
    if (role == "admin" && username != "admin") {
      // Non-first admins go to Admin Panel
      return AdminDashboardPage(loggedInUsername: username!);
    } else {
      // First admin or other roles go to DashboardPage
      return DashboardPage(username: username!, role: role!, userId: userId!);
    }
  }
}
