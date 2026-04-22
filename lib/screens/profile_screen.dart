import 'package:flutter/material.dart';
import 'package:finalassignment/services/auth_service.dart';
import 'package:finalassignment/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.firebaseReady,
    required this.geminiApiKey,
  });

  final bool firebaseReady;
  final String geminiApiKey;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  String? _errorMessage;
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
          final resolvedName =
              (userData?['fullName'] as String?)?.trim().isNotEmpty == true
              ? userData!['fullName'] as String
              : 'User';
          final resolvedEmail =
              (userData?['email'] as String?)?.trim().isNotEmpty == true
              ? userData!['email'] as String
              : (user.email ?? '');
          final resolvedBio = userData?['bio'] as String? ?? '';

          if (mounted) {
            setState(() {
              _userData = {
                'email': resolvedEmail,
                'fullName': resolvedName,
                'bio': resolvedBio,
              };
              _fullNameController.text = resolvedName;
              _bioController.text = resolvedBio;
              _isLoading = false;
            });
          }
        } catch (e) {
          debugPrint('Error loading user data: $e');
          // Set default values if unable to load
          if (mounted) {
            setState(() {
              _userData = {'email': user.email, 'fullName': 'User', 'bio': ''};
              _fullNameController.text = '';
              _bioController.text = '';
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error in _loadUserData: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final fullName = _fullNameController.text.trim();
    final bio = _bioController.text.trim();

    if (fullName.isEmpty) {
      setState(() {
        _errorMessage = 'Full name is required.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('You are not logged in. Please sign in again.');
      }

      await _authService.updateUserProfile(
        uid: user.uid,
        fullName: fullName,
        bio: bio,
      );

      setState(() {
        _isEditing = false;
        _userData?['fullName'] = fullName;
        _userData?['bio'] = bio;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            e.toString().replaceFirst('Exception: ', '').replaceFirst('FirebaseException: ', '');
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
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

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final initials = (_userData?['fullName'] ?? 'U')
        .split(' ')
        .map((name) => name[0])
        .join()
        .toUpperCase()
        .substring(0, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: const Color(0xFFF2F4FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: const Color(0xFF4E5AE8),
        ),
        titleTextStyle: const TextStyle(
          color: Color(0xFF4E5AE8),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF4E5AE8)),
      ),
      backgroundColor: const Color(0xFFF2F4FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueGrey.shade100),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 14,
                          offset: Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF5B63F6).withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xFF5B63F6),
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fullNameController.text.trim().isEmpty
                                        ? 'User Profile'
                                        : _fullNameController.text.trim(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1F2A44),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Manage your account details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F8FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 18,
                                color: Colors.blueGrey.shade500,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  user?.email ?? _userData?['email'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4E5AE8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (_errorMessage != null) const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.blueGrey.shade100),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _fullNameController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            filled: true,
                            fillColor: _isEditing
                                ? Colors.white
                                : const Color(0xFFF5F7FC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade100,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade100,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade100,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF5B63F6),
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.person_outline),
                            prefixIconColor: Colors.blueGrey.shade400,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _bioController,
                          enabled: _isEditing,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Bio',
                            filled: true,
                            fillColor: _isEditing
                                ? Colors.white
                                : const Color(0xFFF5F7FC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade100,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade100,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade100,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF5B63F6),
                                width: 2,
                              ),
                            ),
                            hintText: 'Tell us about yourself...',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Icon(Icons.description_outlined),
                            ),
                            prefixIconColor: Colors.blueGrey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Edit/Save buttons
                  if (!_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('EDIT PROFILE'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF5B63F6),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isSaving ? null : _saveProfile,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('SAVE CHANGES'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF5B63F6),
                              disabledBackgroundColor: const Color(
                                0xFF5B63F6,
                              ).withValues(alpha: 0.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _loadUserData();
                              });
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('CANCEL'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blueGrey.shade700,
                              side: BorderSide(color: Colors.blueGrey.shade200),
                              backgroundColor: const Color(0xFFF7F9FE),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('LOGOUT'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE45454),
                        backgroundColor: const Color(0xFFFFF6F6),
                        side: const BorderSide(color: Color(0xFFF0B2B2)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
