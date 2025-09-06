import 'package:flutter/material.dart';

class UserDialog extends StatefulWidget {
  final Map? user;
  final String loggedInUsername;
  final Function(Map<String, String>) onSave;

  UserDialog({this.user, required this.loggedInUsername, required this.onSave});

  @override
  _UserDialogState createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController emailController;
  String role = "user";
  String status = "active";
  bool isFirstAdmin = false;
  bool isLoggedInFirstAdmin = false;
  bool isEditingOtherAdmin = false;
  bool isEditingSelf = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(
      text: widget.user?['username'] ?? "",
    );
    passwordController = TextEditingController();
    emailController = TextEditingController(
      text: widget.user?['email'] ?? "",
    );

    role = ["admin", "manager", "user"].contains(widget.user?['role'])
        ? widget.user!['role']
        : "user";
    status = ["active", "blocked"].contains(widget.user?['status'])
        ? widget.user!['status']
        : "active";

    int userId = int.tryParse(widget.user?['id']?.toString() ?? '0') ?? 0;
    isFirstAdmin = userId == 1;
    isLoggedInFirstAdmin = widget.loggedInUsername == "admin";

    isEditingSelf = widget.loggedInUsername == widget.user?['username'];
    isEditingOtherAdmin = role == "admin" && !isEditingSelf;

    // Ensure role is valid for current editor
    List<String> allowedRoles = [];
    if (isLoggedInFirstAdmin) allowedRoles.add("admin");
    allowedRoles.addAll(["manager", "user"]);
    if (!allowedRoles.contains(role)) role = allowedRoles.last;

    List<String> allowedStatus = ["active", "blocked"];
    if (!allowedStatus.contains(status)) status = allowedStatus.first;
  }

  Future<void> _editField(String field, String currentValue) async {
    // Normal admins cannot edit other admins at all
    if (!isLoggedInFirstAdmin && isEditingOtherAdmin) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("You cannot edit another admin")));
      return;
    }

    // Normal admins cannot edit their own role/status via text field
    if (!isLoggedInFirstAdmin &&
        isEditingSelf &&
        (field == "role" || field == "status")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You cannot edit your own $field")),
      );
      return;
    }

    TextEditingController controller = TextEditingController(
      text: currentValue,
    );
    bool hidePassword = field == "password";

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Edit $field"),
          content: TextField(
            controller: controller,
            obscureText: hidePassword,
            decoration: InputDecoration(
              labelText: field,
              suffixIcon: field == "password"
                  ? IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
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
              onPressed: () {
                if ((field == "username" && controller.text.isEmpty) ||
                    (field == "password" && controller.text.isEmpty))
                  return;

                Map<String, String> body = {
                  "id": widget.user?['id'].toString() ?? "",
                  "loggedInUsername": widget.loggedInUsername,
                };

                if (field == "username") body["username"] = controller.text;
                if (field == "password") body["password"] = controller.text;
                if (field == "role") body["role"] = role;
                if (field == "status") body["status"] = status;

                widget.onSave(body);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _saveDropdown(String field) {
    // Restrict saving roles/statuses for normal admins
    if (!isLoggedInFirstAdmin &&
        isEditingSelf &&
        (field == "role" || field == "status")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You cannot edit your own $field")),
      );
      return;
    }

    // Normal admins cannot edit other admins
    if (!isLoggedInFirstAdmin && isEditingOtherAdmin) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("You cannot edit another admin")));
      return;
    }

    Map<String, String> body = {
      "id": widget.user?['id'].toString() ?? "",
      "loggedInUsername": widget.loggedInUsername,
    };
    if (field == "role") body["role"] = role;
    if (field == "status") body["status"] = status;

    widget.onSave(body);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$field updated successfully")));
  }

  @override
  Widget build(BuildContext context) {
    List<String> availableRoles = [
      if (isLoggedInFirstAdmin) "admin",
      "manager",
      "user",
    ];
    List<String> availableStatus = ["active", "blocked"];

    return AlertDialog(
      title: Text(
        widget.user == null
            ? "Create User"
            : isFirstAdmin
            ? "Edit First Admin"
            : "Edit User",
      ),

      content: SizedBox(
        width: 400, // Adjust this width as needed
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Username
            Row(
              children: [
                Expanded(
                  child: Text("Username: ${widget.user?['username'] ?? ''}"),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed:
                      (!isFirstAdmin || isLoggedInFirstAdmin) &&
                          !(isEditingOtherAdmin && !isLoggedInFirstAdmin)
                      ? () => _editField(
                          "username",
                          widget.user?['username'] ?? "",
                        )
                      : null,
                ),
              ],
            ),
            // Password
            Row(
              children: [
                Expanded(child: Text("Password: ******")),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: !(isEditingOtherAdmin && !isLoggedInFirstAdmin)
                      ? () => _editField("password", "")
                      : null,
                ),
              ],
            ),
            // Email
            Row(
              children: [
                Expanded(child: Text("Email: ${widget.user?['email'] ?? ''}")),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed:
                      (!isFirstAdmin || isLoggedInFirstAdmin) &&
                          !(isEditingOtherAdmin && !isLoggedInFirstAdmin)
                      ? () => _editField(
                          "email",
                          widget.user?['email'] ?? "",
                        )
                      : null,
                ),
              ],
            ),
            // Role
            Row(
              children: [
                Expanded(child: Text("Role: $role")),
                DropdownButton<String>(
                  value: role,
                  items: availableRoles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged:
                      (isLoggedInFirstAdmin ||
                          (!isEditingOtherAdmin && !isEditingSelf))
                      ? (val) => setState(() => role = val!)
                      : null,
                ),
                TextButton(
                  onPressed:
                      (isLoggedInFirstAdmin ||
                          (!isEditingOtherAdmin && !isEditingSelf))
                      ? () => _saveDropdown("role")
                      : null,
                  child: Text("Save"),
                ),
              ],
            ),

            // Status
            Row(
              children: [
                Expanded(child: Text("Status: $status")),
                DropdownButton<String>(
                  value: status,
                  items: availableStatus
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged:
                      (isLoggedInFirstAdmin ||
                          (!isEditingOtherAdmin && !isEditingSelf))
                      ? (val) => setState(() => status = val!)
                      : null,
                ),
                TextButton(
                  onPressed:
                      (isLoggedInFirstAdmin ||
                          (!isEditingOtherAdmin && !isEditingSelf))
                      ? () => _saveDropdown("status")
                      : null,
                  child: Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
        if (widget.user == null)
          ElevatedButton(
            onPressed: () {
              widget.onSave({
                "username": widget.user?['username'] ?? "",
                "password": "",
                "role": role,
                "status": status,
                "email": emailController.text,
                "loggedInUsername": widget.loggedInUsername,
              });
              Navigator.pop(context);
            },
            child: Text("Create"),
          ),
      ],
    );
  }
}
