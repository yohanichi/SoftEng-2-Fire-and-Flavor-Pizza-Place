import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'admin_dashboard_page.dart';
import 'manager_page.dart';
import 'task_page.dart';
import 'dash.dart'; // 👈 Your landing page

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

  final String apiBase =
      "http://192.168.254.115/my_application/my_php_api/user";

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

  Future<void> _logoutAndGoToDash(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => dash()),
      (route) => false,
    );
  }

  Future<void> openProfileDialog(BuildContext context) async {
    TextEditingController usernameController = TextEditingController(
      text: currentUsername,
    );
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Map<String, String> body = {"id": userId};
              if (usernameController.text.isNotEmpty) {
                body["username"] = usernameController.text;
              }
              if (passwordController.text.isNotEmpty) {
                body["password"] = passwordController.text;
              }

              if (body.length == 1) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("No changes to save")));
                return;
              }

              try {
                final response = await http.post(
                  Uri.parse("$apiBase/update_user.php"),
                  body: body,
                );
                final data = json.decode(response.body);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(data['message'])));

                if (data['success']) {
                  if (body.containsKey("username")) {
                    setState(() {
                      currentUsername = body["username"]!;
                    });
                  }
                  Navigator.pop(context);
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => dash()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 🔹 Dark tinted background instead of image
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.95), Colors.grey[900]!],
                  ),
                ),
              ),
            ),

            Row(
              children: [
                // 🔹 Sidebar
                AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  width: _isSidebarOpen ? 220 : 60,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    border: Border(
                      right: BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _SidebarItem(
                        imagePath: "assets/images/home.png",
                        label: "Home",
                        isOpen: _isSidebarOpen,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => dash()),
                          );
                        },
                      ),

                      // Dashboard button (current page)
                      _SidebarItem(
                        imagePath: "assets/images/dashboard.png",
                        label: "Dashboard",
                        isOpen: _isSidebarOpen,
                        onTap: null, // disables tap
                        isActive: true, // highlight
                      ),

                      if (currentRole.toLowerCase() == "admin")
                        _SidebarItem(
                          imagePath: "assets/images/admin.png",
                          label: "Admin Dashboard",
                          isOpen: _isSidebarOpen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminDashboardPage(
                                  loggedInUsername: currentUsername,
                                ),
                              ),
                            );
                          },
                        ),

                      if (currentRole.toLowerCase() == "manager")
                        _SidebarItem(
                          imagePath: "assets/images/manager.png",
                          label: "Manager Dashboard",
                          isOpen: _isSidebarOpen,
                          onTap: () {
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
                          },
                        ),

                      _SidebarItem(
                        imagePath: "assets/images/task.png",
                        label: "Task Page",
                        isOpen: _isSidebarOpen,
                        onTap: () {
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
                      ),

                      _SidebarItem(
                        imagePath: "assets/images/logout.png",
                        label: "Logout",
                        isOpen: _isSidebarOpen,
                        color: Colors.redAccent,
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => dash()),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 🔹 Main Content
                Expanded(
                  child: Column(
                    children: [
                      // Top bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.grey[900]!],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Toggle + Logo
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isSidebarOpen
                                        ? Icons.arrow_back_ios
                                        : Icons.menu,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                  onPressed: toggleSidebar,
                                ),

                                // 🔹 Logo always visible
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.orange,
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      "assets/images/logo.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),

                                // 🔹 Fire and Flavor Pizza text always visible
                                Text(
                                  "Fire and Flavor Pizza",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            // Hi, username dropdown
                            PopupMenuButton<String>(
                              offset: const Offset(0, 35),
                              color: Colors.black.withOpacity(0.65),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              onSelected: (value) async {
                                if (value == "profile") {
                                  openProfileDialog(context);
                                } else if (value == "logout") {
                                  _logoutAndGoToDash(context);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: "profile",
                                  child: Text(
                                    "Edit Profile",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "logout",
                                  child: Text(
                                    "Log out",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              child: Row(
                                children: [
                                  Text(
                                    "Hi, $currentUsername 👋",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(221, 235, 235, 235),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 3, color: Colors.orange),

                      // Page body
                      Expanded(
                        child: Center(
                          child: Text(
                            "Welcome, $currentUsername!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Sidebar item widget
class _SidebarItem extends StatefulWidget {
  final String imagePath;
  final String label;
  final bool isOpen;
  final VoidCallback? onTap; // allow null to disable
  final Color? color;
  final bool isActive; // <-- new

  const _SidebarItem({
    required this.imagePath,
    required this.label,
    required this.isOpen,
    this.onTap,
    this.color,
    this.isActive = false, // default false
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovering = false;
  bool _showText = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.isActive) setState(() => _isHovering = true);
      },
      onExit: (_) {
        if (!widget.isActive) setState(() => _isHovering = false);
      },
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.orangeAccent.withOpacity(0.2)
                : (_isHovering
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.contain,
                  color: widget.isActive ? Colors.orangeAccent : widget.color,
                ),
              ),
              if (widget.isOpen) ...[
                SizedBox(width: 12),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 250),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isActive
                          ? Colors.orangeAccent
                          : widget.color ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
