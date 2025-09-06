import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'admin_dashboard_page.dart';
import 'dash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fire and Flavor Pizza',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
      ),
      home: dash(), // 👈 Always show pizza homepage first
      routes: {
        // Instead of going directly to LoginPage,
        // send user into SplashDecider so it can check login status
        '/login': (context) => SplashDecider(),
        '/dashboard': (context) =>
            DashboardPage(username: "Guest", role: "user", userId: "0"),
        '/admin': (context) {
          // Load current logged-in user from SharedPreferences
          return FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              final prefs = snapshot.data!;
              final username = prefs.getString('username') ?? 'guest';
              final role = prefs.getString('role') ?? 'user';
              return AdminDashboardPage(
                loggedInUsername: username,
                loggedInRole: role,
              );
            },
          );
        },
      },
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
    if (role == "root_admin" || (role == "admin" && username != "admin")) {
      // Root admin and normal admins go to AdminDashboard
      return AdminDashboardPage(
        loggedInUsername: username!,
        loggedInRole: role!,
      );
    } else {
      // Other users go to their dashboard
      return DashboardPage(username: username!, role: role!, userId: userId!);
    }
  }
}
