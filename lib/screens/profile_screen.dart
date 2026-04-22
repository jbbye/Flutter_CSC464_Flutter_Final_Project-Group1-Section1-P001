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
          if (mounted) {
            setState(() {
              _userData =
                  userData ??
                  {'email': user.email, 'fullName': 'User', 'bio': ''};
              _fullNameController.text = userData?['fullName'] ?? '';
              _bioController.text = userData?['bio'] ?? '';
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
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final user = _authService.currentUser;
      if (user != null) {
        await _authService.updateUserProfile(
          uid: user.uid,
          fullName: _fullNameController.text.trim(),
          bio: _bioController.text.trim(),
        );

        setState(() {
          _isEditing = false;
          _userData?['fullName'] = _fullNameController.text.trim();
          _userData?['bio'] = _bioController.text.trim();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile';
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
                  // Profile Avatar
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
                      radius: 50,
                      backgroundColor: const Color(0xFF5B63F6),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Email
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: Colors.blueGrey.shade400,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey.shade400,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4E5AE8),
                              ),
                            ),
                          ],
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
                  // Full Name
                  TextField(
                    controller: _fullNameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      filled: true,
                      fillColor: _isEditing
                          ? Colors.white
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueGrey.shade100),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueGrey.shade100),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueGrey.shade100),
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
                  const SizedBox(height: 16),
                  // Bio
                  TextField(
                    controller: _bioController,
                    enabled: _isEditing,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      filled: true,
                      fillColor: _isEditing
                          ? Colors.white
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueGrey.shade100),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueGrey.shade100),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueGrey.shade100),
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
                  const SizedBox(height: 24),
                  // Edit/Save buttons
                  if (!_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('EDIT PROFILE'),
                        style: ElevatedButton.styleFrom(
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
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveProfile,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('SAVE CHANGES'),
                            style: ElevatedButton.styleFrom(
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
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _loadUserData();
                              });
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('CANCEL'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade400,
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
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('LOGOUT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
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
