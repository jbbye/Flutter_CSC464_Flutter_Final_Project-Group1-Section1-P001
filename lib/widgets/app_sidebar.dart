import 'package:flutter/material.dart';
import 'package:finalassignment/services/auth_service.dart';
import 'package:finalassignment/screens/profile_screen.dart';
import 'package:finalassignment/screens/login_screen.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({
    super.key,
    required this.onNewSession,
    required this.firebaseReady,
    required this.geminiApiKey,
  });

  final VoidCallback onNewSession;
  final bool firebaseReady;
  final String geminiApiKey;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        try {
          final userData = await _authService.getUserData(user.uid);
          if (mounted) {
            setState(() {
              _userData = userData ?? {'email': user.email, 'fullName': 'User'};
            });
          }
        } catch (e) {
          debugPrint('Error loading user data: $e');
          // Set default values if unable to load
          if (mounted) {
            setState(() {
              _userData = {'email': user.email, 'fullName': 'User'};
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error in _loadUserData: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => LoginScreen(
            firebaseReady: widget.firebaseReady,
            geminiApiKey: widget.geminiApiKey,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to logout')));
      }
    }
  }

  void _goToProfileSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileScreen(
          firebaseReady: widget.firebaseReady,
          geminiApiKey: widget.geminiApiKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.blueGrey.shade100;
      final userEmail = _userData?['email'] as String? ?? 'User';
    final fullName = _userData?['fullName'] as String?;
    final displayName =
      (fullName != null && fullName.trim().isNotEmpty) ? fullName : 'User';
      final initials = _userData?['fullName']?.isNotEmpty == true
      ? _userData!['fullName']
        .split(' ')
        .map((name) => name[0])
        .join()
        .toUpperCase()
        .substring(0, 1)
      : 'U';

    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B63F6),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x335B63F6),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'L',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'LingoAI',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4E5AE8),
                  shadows: [
                    Shadow(
                      color: Color(0x334E5AE8),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MY TUTORS',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade500,
                ),
              ),
              IconButton(
                onPressed: widget.onNewSession,
                icon: const Icon(Icons.add),
                color: Colors.blueGrey.shade500,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const Spacer(),
          Divider(color: borderColor),
          const SizedBox(height: 18),
          Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: Colors.blueGrey.shade500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF39C5BB),
                            child: Text(
                              initials,
                              style: TextStyle(
                                color: Colors.blueGrey.shade900,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade900,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade500,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _goToProfileSettings,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDEFFF),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Icon(
                                    Icons.settings_outlined,
                                    size: 18,
                                    color: Color(0xFF5B63F6),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Profile Settings',
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade800,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.blueGrey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE45454),
                      side: const BorderSide(color: Color(0xFFF0B2B2)),
                      backgroundColor: const Color(0xFFFFF6F6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
