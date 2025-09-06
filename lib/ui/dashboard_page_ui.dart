import 'package:flutter/material.dart';

class DashboardPageUI extends StatelessWidget {
  final bool isSidebarOpen;
  final VoidCallback toggleSidebar;
  final String currentUsername;
  final String currentRole;
  final String userId;
  final VoidCallback onHome;
  final VoidCallback? onAdminDashboard;
  final VoidCallback? onManagerPage;
  final VoidCallback? onSubModule;
  final VoidCallback onTaskPage;
  final Future<void> Function(BuildContext) onLogout;
  final Future<void> Function(BuildContext) onEditProfile;

  const DashboardPageUI({
    required this.isSidebarOpen,
    required this.toggleSidebar,
    required this.currentUsername,
    required this.currentRole,
    required this.userId,
    required this.onHome,
    this.onAdminDashboard,
    this.onManagerPage,
    this.onSubModule,
    required this.onTaskPage,
    required this.onLogout,
    required this.onEditProfile,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
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
                _Sidebar(
                  isSidebarOpen: isSidebarOpen,
                  onHome: onHome,
                  onAdminDashboard: onAdminDashboard,
                  onManagerPage: onManagerPage,
                  onSubModule: onSubModule,
                  onTaskPage: onTaskPage,
                  onLogout: onLogout,
                  currentRole: currentRole,
                ),
                Expanded(
                  child: Column(
                    children: [
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
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isSidebarOpen
                                        ? Icons.arrow_back_ios
                                        : Icons.menu,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                  onPressed: toggleSidebar,
                                ),
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
                                  await onEditProfile(context);
                                } else if (value == "logout") {
                                  await onLogout(context);
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

// Sidebar with hover support
class _Sidebar extends StatefulWidget {
  final bool isSidebarOpen;
  final VoidCallback onHome;
  final VoidCallback? onAdminDashboard;
  final VoidCallback? onManagerPage;
  final VoidCallback? onSubModule;
  final VoidCallback onTaskPage;
  final Future<void> Function(BuildContext) onLogout;
  final String currentRole;

  const _Sidebar({
    required this.isSidebarOpen,
    required this.onHome,
    this.onAdminDashboard,
    this.onManagerPage,
    this.onSubModule,
    required this.onTaskPage,
    required this.onLogout,
    required this.currentRole,
    Key? key,
  }) : super(key: key);

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  String? hoveredLabel;
  bool showText = false;

  @override
  void didUpdateWidget(covariant _Sidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSidebarOpen && !showText) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && widget.isSidebarOpen) {
          setState(() => showText = true);
        }
      });
    } else if (!widget.isSidebarOpen && showText) {
      setState(() => showText = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      width: widget.isSidebarOpen ? 220 : 60,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border(right: BorderSide(color: Colors.orange, width: 2)),
      ),
      child: Column(
        children: [
          _SidebarItem(
            imagePath: "assets/images/home.png",
            label: "Home",
            isOpen: widget.isSidebarOpen && showText,
            onTap: widget.onHome,
            hovered: hoveredLabel == "Home",
            onHover: (hovering) {
              setState(() => hoveredLabel = hovering ? "Home" : null);
            },
          ),
          _SidebarItem(
            imagePath: "assets/images/dashboard.png",
            label: "Dashboard",
            isOpen: widget.isSidebarOpen && showText,
            onTap: null,
            isActive: true,
            hovered: hoveredLabel == "Dashboard",
            onHover: (hovering) {
              setState(() => hoveredLabel = hovering ? "Dashboard" : null);
            },
          ),
          if (widget.currentRole.toLowerCase() == "admin" &&
              widget.onAdminDashboard != null)
            _SidebarItem(
              imagePath: "assets/images/admin.png",
              label: "Admin Dashboard",
              isOpen: widget.isSidebarOpen && showText,
              onTap: widget.onAdminDashboard,
              hovered: hoveredLabel == "Admin Dashboard",
              onHover: (hovering) {
                setState(
                  () => hoveredLabel = hovering ? "Admin Dashboard" : null,
                );
              },
            ),
          if (widget.currentRole.toLowerCase() == "manager" &&
              widget.onManagerPage != null)
            _SidebarItem(
              imagePath: "assets/images/manager.png",
              label: "Materials Records",
              isOpen: widget.isSidebarOpen && showText,
              onTap: widget.onManagerPage,
              hovered: hoveredLabel == "Materials Records",
              onHover: (hovering) {
                setState(
                  () => hoveredLabel = hovering ? "Materials Records" : null,
                );
              },
            ),
          if (widget.currentRole.toLowerCase() == "manager" &&
              widget.onSubModule != null)
            _SidebarItem(
              imagePath: "assets/images/submodule.png",
              label: "Sub-Module #2",
              isOpen: widget.isSidebarOpen && showText,
              onTap: widget.onSubModule,
              color: Colors.white,
              hovered: hoveredLabel == "Sub-Module #2",
              onHover: (hovering) {
                setState(
                  () => hoveredLabel = hovering ? "Sub-Module #2" : null,
                );
              },
            ),
          _SidebarItem(
            imagePath: "assets/images/task.png",
            label: "Task Page",
            isOpen: widget.isSidebarOpen && showText,
            onTap: widget.onTaskPage,
            hovered: hoveredLabel == "Task Page",
            onHover: (hovering) {
              setState(() => hoveredLabel = hovering ? "Task Page" : null);
            },
          ),
          _SidebarItem(
            imagePath: "assets/images/logout.png",
            label: "Logout",
            isOpen: widget.isSidebarOpen && showText,
            color: Colors.redAccent,
            onTap: () => widget.onLogout(context),
            hovered: hoveredLabel == "Logout",
            onHover: (hovering) {
              setState(() => hoveredLabel = hovering ? "Logout" : null);
            },
          ),
        ],
      ),
    );
  }
}

// Sidebar item with hover effect
class _SidebarItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isOpen;
  final VoidCallback? onTap;
  final Color? color;
  final bool isActive;
  final bool hovered;
  final ValueChanged<bool> onHover;

  const _SidebarItem({
    required this.imagePath,
    required this.label,
    required this.isOpen,
    this.onTap,
    this.color,
    this.isActive = false,
    this.hovered = false,
    required this.onHover,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final highlightColor = hovered
        ? (color ?? Colors.orangeAccent).withOpacity(0.25)
        : isActive
        ? Colors.orangeAccent.withOpacity(0.2)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: highlightColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  color: isActive ? Colors.orangeAccent : color,
                ),
              ),
              if (isOpen) ...[
                SizedBox(width: 12),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 250),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive
                          ? Colors.orangeAccent
                          : color ?? Colors.white,
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
