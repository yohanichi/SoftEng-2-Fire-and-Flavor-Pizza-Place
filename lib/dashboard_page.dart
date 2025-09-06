import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard_page.dart';
import 'manager_page.dart';
import 'task_page.dart';
import 'dash.dart';
import 'ui/dashboard_page_ui.dart'; // <-- Import the UI
import 'edit_profile_page.dart'; // <-- Add this import

class DashboardPage extends StatefulWidget {
  final String username;
  final String role;
  final String userId;

  DashboardPage({
    required this.username,
    required this.role,
    required this.userId,
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late String currentUsername;
  late String currentRole;
  late String userId;

  final String apiBase = "http://localhost/my_application/my_php_api/user";

  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    currentUsername = widget.username;
    currentRole = widget.role;
    userId = widget.userId;
  }

  void toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _logoutAndGoToDash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => dash()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardPageUI(
      isSidebarOpen: _isSidebarOpen,
      toggleSidebar: toggleSidebar,
      currentUsername: currentUsername,
      currentRole: currentRole,
      userId: userId,
      onHome: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => dash()),
        );
      },
      onAdminDashboard:
          (currentRole.toLowerCase() == "admin" ||
              currentRole.toLowerCase() == "root_admin")
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminDashboardPage(
                    loggedInUsername: currentUsername,
                    loggedInRole: currentRole, // <-- Pass the role too
                  ),
                ),
              );
            }
          : null,

      onManagerPage: currentRole.toLowerCase() == "manager"
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManagerPage(
                    username: currentUsername,
                    role: currentRole,
                    userId: userId,
                  ),
                ),
              );
            }
          : null,
      onSubModule: widget.role.toLowerCase() == "manager"
          ? () {
              // does nothing for now
            }
          : null,
      onTaskPage: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskPage(
              userId: userId,
              username: currentUsername,
              role: widget.role,
            ),
          ),
        );
      },
      onLogout: _logoutAndGoToDash,
      onEditProfile: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditProfilePage(currentUsername: currentUsername),
          ),
        );
      }, // <-- Go to EditProfilePage instead of dialog
    );
  }
}
