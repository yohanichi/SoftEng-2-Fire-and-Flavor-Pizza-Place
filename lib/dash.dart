import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'dashboard_page.dart';
import 'edit_profile_page.dart';

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
    return Scaffold(
      backgroundColor: Colors.transparent, // 👈 so image shows behind
      body: Stack(
        children: [
          // 🔹 Full Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/backgroundhome.png",
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // 🔹 Page Content
          Column(
            children: [
              // 🔹 Top Navigation Bar with Gradient
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
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
                        // Circular Logo + Text
                        Row(
                          children: [
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

                        // Navigation items and buttons
                        // Navigation items and buttons
                        Row(
                          children: [
                            NavItem("Home", true),
                            NavItem("Menu", false),
                            NavItem("About Us", false),
                            NavItem("Contacts", false),
                            SizedBox(width: 20),

                            if (username == null) ...[
                              // 👤 Guest: Show login + signup
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginPage(),
                                    ),
                                  ).then((_) => _loadUser());
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  "Log in",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RegisterPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ] else ...[
                              // 👋 Logged in: Show popup menu
                              PopupMenuButton<String>(
                                offset: const Offset(0, 35),
                                color: Colors.black.withOpacity(
                                  0.65,
                                ), // 🔹 semi-transparent dark background
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // smooth corners
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ), // subtle border
                                ),
                                onSelected: (value) async {
                                  if (value == "profile") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditProfilePage(
                                          currentUsername: username!,
                                        ),
                                      ),
                                    ).then((_) => _loadUser());
                                  } else if (value == "logout") {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.clear();
                                    setState(() {
                                      username = null;
                                      role = null;
                                      userId = null;
                                    });
                                  }
                                },

                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: "profile",
                                    child: Text(
                                      "Edit Profile",
                                      style: const TextStyle(
                                        color: Colors
                                            .white, // bright text on dark tint
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: "logout",
                                    child: Text(
                                      "Log out",
                                      style: const TextStyle(
                                        color: Colors
                                            .redAccent, // highlight logout
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Hi, $username 👋",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                            221,
                                            235,
                                            235,
                                            235,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DashboardPage(
                                        username: username!,
                                        role: role ?? "",
                                        userId: userId ?? "",
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  "Dashboard",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Orange accent line under the gradient bar
                  Container(height: 3, color: Colors.orange),
                ],
              ),

              // Middle Section...
              Expanded(
                child: Stack(
                  children: [
                    // Black fading shadow
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withOpacity(0.9),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Hero + Content
                    Column(
                      children: [
                        SizedBox(height: 30),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "- FRESHLY BAKED DAILY",
                                        style: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 14,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "The best way\nto enjoy pizza\nwith flavor.",
                                        style: TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        "Delicious pizza with the freshest ingredients. Try us today!",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 25,
                                                vertical: 15,
                                              ),
                                            ),
                                            child: Text("Order Now"),
                                          ),
                                          SizedBox(width: 15),
                                          OutlinedButton(
                                            onPressed: () {},
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 25,
                                                vertical: 15,
                                              ),
                                              side: BorderSide(
                                                color: Colors.white,
                                              ),
                                            ),
                                            child: Text(
                                              "See our Menu",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Divider(color: Colors.black, thickness: 1, height: 1),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 🔗 Navigation Bar Item
class NavItem extends StatelessWidget {
  final String title;
  final bool isActive;
  NavItem(this.title, this.isActive);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.redAccent : Colors.white,
        ),
      ),
    );
  }
}
