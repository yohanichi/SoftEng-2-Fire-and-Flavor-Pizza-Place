import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'register_page.dart';

class dash extends StatefulWidget {
  @override
  _dashState createState() => _dashState();
}

class _dashState extends State<dash> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username");
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      username = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: username != null
          ? _buildDrawer(context)
          : null, // 👈 only show if logged in
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/chalkart.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔝 Top Navigation Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (username != null) // 👈 Only show menu if logged in
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                            ),
                          ),
                        const SizedBox(width: 10),
                        const Text(
                          "Fire and Flavor Pizza",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        NavItem("Home", true),
                        NavItem("Menu", false),
                        NavItem("About Us", false),
                        NavItem("Contacts", false),
                        const SizedBox(width: 20),

                        // 🔥 Conditional rendering
                        if (username == null) ...[
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => LoginPage()),
                              ).then((_) => _loadUser());
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white, // 🔥 text color
                            ),
                            child: const Text("Log in"),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegisterPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Sign up",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Hi, $username 👋",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(221, 235, 235, 235),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Log out",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // 🍕 Hero Section
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "- FRESHLY BAKED DAILY",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "The best way\nto enjoy pizza\nwith flavor.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Delicious pizza with the freshest ingredients. Try us today!",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25,
                                      vertical: 15,
                                    ),
                                  ),
                                  child: const Text(
                                    "Order Now",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ), // 👈 force white
                                  ),
                                ),
                                const SizedBox(width: 15),
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.white,
                                    ), // 👈 white border
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25,
                                      vertical: 15,
                                    ),
                                  ),
                                  child: const Text(
                                    "See our Menu",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ), // 👈 force white
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Right side image
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                "assets/images/fireandflavor.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Footer
                const Center(
                  child: Text(
                    "Trusted by pizza lovers everywhere",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => Text(
                      "🍕 Logo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 Sidebar (Drawer)
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.redAccent),
            child: Text(
              username != null
                  ? "Welcome, $username!"
                  : "Welcome to Fire & Flavor!",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text("Menu"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About Us"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.contact_phone),
            title: const Text("Contacts"),
            onTap: () {},
          ),
          if (username != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log out"),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
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

  const NavItem(this.title, this.isActive);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive
              ? Colors.redAccent
              : const Color.fromARGB(255, 199, 199, 199),
        ),
      ),
    );
  }
}
