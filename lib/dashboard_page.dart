import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'admin_dashboard_page.dart';

class DashboardPage extends StatelessWidget {
  final String username;
  final String role;
  final String userId; // Database ID

  DashboardPage({
    required this.username,
    required this.role,
    required this.userId,
  });

  // ✅ Use your InfinityFree domain here
  final String apiBase = "http://3lig2mfs.infinityfreeapp.com";

  Future<void> openProfileDialog(BuildContext context) async {
    String currentUsername = username;
    String currentPasswordMask = "******";

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var field in [
                {
                  "label": "Username",
                  "value": currentUsername,
                  "key": "username",
                },
                {
                  "label": "Password",
                  "value": currentPasswordMask,
                  "key": "password",
                },
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text("${field['label']}: ${field['value']}"),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              TextEditingController controller =
                                  TextEditingController(
                                    text: field['key'] == "username"
                                        ? currentUsername
                                        : "",
                                  );
                              bool hideFieldPassword = true;

                              await showDialog(
                                context: context,
                                builder: (_) => StatefulBuilder(
                                  builder: (context, setState) => AlertDialog(
                                    title: Text("Edit ${field['label']}"),
                                    content: TextField(
                                      controller: controller,
                                      obscureText: field['key'] == "password"
                                          ? hideFieldPassword
                                          : false,
                                      decoration: InputDecoration(
                                        labelText: field['label'],
                                        suffixIcon: field['key'] == "password"
                                            ? IconButton(
                                                icon: Icon(
                                                  hideFieldPassword
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    hideFieldPassword =
                                                        !hideFieldPassword;
                                                  });
                                                },
                                              )
                                            : null,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (field['key'] == "username" &&
                                              controller.text ==
                                                  currentUsername) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Username is unchanged!",
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          if (field['key'] == "password" &&
                                              controller.text.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Password cannot be empty!",
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          Map<String, String> body = {
                                            "id": userId,
                                          };
                                          if (field['key'] == "username") {
                                            body["username"] = controller.text;
                                          } else {
                                            body["password"] = controller.text;
                                          }

                                          try {
                                            final response = await http.post(
                                              Uri.parse(
                                                "$apiBase/update_user.php",
                                              ),
                                              body: body,
                                            );
                                            final data = json.decode(
                                              response.body,
                                            );

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(data['message']),
                                              ),
                                            );

                                            if (data['success']) {
                                              if (field['key'] == "username") {
                                                setState(() {
                                                  currentUsername =
                                                      controller.text;
                                                });
                                              }
                                              Navigator.pop(context);
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Update failed: $e",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text("Save"),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: Text("Edit"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, $username!", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => openProfileDialog(context),
              child: Text("Edit Profile"),
            ),

            SizedBox(height: 20),

            if (role == "admin")
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AdminDashboardPage(loggedInUsername: username),
                    ),
                  );
                },
                child: Text("Go to Admin Dashboard"),
              ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
