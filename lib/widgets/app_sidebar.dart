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
          const SizedBox(height: 24),
          Text(
            'No active sessions',
            style: TextStyle(
              fontSize: 17,
              color: Colors.blueGrey.shade300,
              fontStyle: FontStyle.italic,
            ),
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
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _goToProfileSettings,
            child: Row(
              children: [
                Icon(Icons.settings_outlined, color: Colors.blueGrey.shade400),
                const SizedBox(width: 10),
                Text(
                  'Profile Settings',
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF39C5BB),
                    child: Text(
                      _userData?['fullName']?.isNotEmpty == true
                          ? _userData!['fullName']
                                .split(' ')
                                .map((name) => name[0])
                                .join()
                                .toUpperCase()
                                .substring(0, 1)
                          : 'U',
                      style: TextStyle(
                        color: Colors.blueGrey.shade900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userData?['email'] ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
