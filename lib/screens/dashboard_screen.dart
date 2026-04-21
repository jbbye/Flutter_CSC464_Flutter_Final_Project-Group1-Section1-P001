import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalassignment/models/language_option.dart';
import 'package:finalassignment/screens/chat_screen.dart';
import 'package:finalassignment/widgets/app_sidebar.dart';
import 'package:finalassignment/widgets/empty_sessions_card.dart';
import 'package:finalassignment/widgets/language_selector_card.dart';
import 'package:finalassignment/widgets/session_tile.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.firebaseReady,
    required this.geminiApiKey,
  });

  final bool firebaseReady;
  final String geminiApiKey;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  static const List<LanguageOption> _languageOptions = <LanguageOption>[
    LanguageOption(name: 'Spanish', level: 'BEGINNER', flag: '🇪🇸'),
    LanguageOption(name: 'French', level: 'INTERMEDIATE', flag: '🇫🇷'),
    LanguageOption(name: 'German', level: 'BEGINNER', flag: '🇩🇪'),
    LanguageOption(name: 'Italian', level: 'ADVANCED', flag: '🇮🇹'),
    LanguageOption(name: 'Japanese', level: 'BEGINNER', flag: '🇯🇵'),
    LanguageOption(name: 'Chinese', level: 'INTERMEDIATE', flag: '🇨🇳'),
    LanguageOption(name: 'Korean', level: 'BEGINNER', flag: '🇰🇷'),
    LanguageOption(name: 'Bangla', level: 'BEGINNER', flag: '🇧🇩'),
  ];

  bool _showLanguagePicker = false;
  bool _isCreatingSession = false;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openLanguageTab() {
    _tabController.animateTo(0);
    setState(() {
      _showLanguagePicker = true;
    });
  }

  Future<void> _createSession(LanguageOption option) async {
    if (_isCreatingSession) {
      return;
    }

    if (!widget.firebaseReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firebase not ready. Run FlutterFire configure first.'),
        ),
      );
      return;
    }

    setState(() {
      _isCreatingSession = true;
    });

    try {
      final chatRef = await FirebaseFirestore.instance.collection('chats').add({
        'language': option.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatScreen(
            chatId: chatRef.id,
            language: option.name,
            geminiApiKey: widget.geminiApiKey,
          ),
        ),
      );

      setState(() {
        _showLanguagePicker = false;
      });
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      var message = 'Could not create a new session.';
      if (error.code == 'permission-denied') {
        message =
            'Firestore permission denied. Use test mode for development or adjust your rules.';
      } else if (error.code == 'unavailable') {
        message = 'Firestore unavailable. Check internet and try again.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error while creating session: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingSession = false;
        });
      }
    }
  }

  void _openExistingSession({
    required String chatId,
    required String language,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          chatId: chatId,
          language: language,
          geminiApiKey: widget.geminiApiKey,
        ),
      ),
    );
  }

  Future<void> _deleteSession({
    required String chatId,
    required String language,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session?'),
        content: Text('Delete the $language session and all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final messagesRef = firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages');
      final messagesSnapshot = await messagesRef.get();

      for (final chunk in messagesSnapshot.docs.chunked(400)) {
        final batch = firestore.batch();
        for (final doc in chunk) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      await firestore.collection('chats').doc(chatId).delete();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$language session deleted.')));
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: ${error.message ?? error.code}'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $error')));
    }
  }

  Widget _buildLanguageTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 30 : 16,
        0,
        isDesktop ? 30 : 16,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          if (_showLanguagePicker)
            LanguageSelectorCard(
              options: _languageOptions,
              isBusy: _isCreatingSession,
              onCancel: () {
                setState(() {
                  _showLanguagePicker = false;
                });
              },
              onSelect: _createSession,
            )
          else
            EmptySessionsCard(onCreate: _openLanguageTab),
        ],
      ),
    );
  }

  Widget _buildRecentSessionsTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 30 : 16,
        0,
        isDesktop ? 30 : 16,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF5B63F6)),
              const SizedBox(width: 8),
              Text(
                'RECENT SESSIONS',
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontSize: 21,
                  color: Colors.blueGrey.shade500,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!widget.firebaseReady)
            EmptySessionsCard(onCreate: _openLanguageTab)
          else
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .orderBy('createdAt', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'Could not load sessions: ${snapshot.error}',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return EmptySessionsCard(onCreate: _openLanguageTab);
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data();
                    final language = data['language'] as String? ?? 'Language';
                    final timestamp = data['createdAt'] as Timestamp?;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SessionTile(
                        language: language,
                        createdAt: timestamp,
                        onTap: () => _openExistingSession(
                          chatId: doc.id,
                          language: language,
                        ),
                        onDelete: () =>
                            _deleteSession(chatId: doc.id, language: language),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1050;

    return Scaffold(
      drawer: isDesktop
          ? null
          : Drawer(
              child: AppSidebar(
                onNewSession: () {
                  Navigator.of(context).pop();
                  _openLanguageTab();
                },
              ),
            ),
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text(
                'LingoAI',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4E5AE8),
                  shadows: [
                    Shadow(
                      offset: Offset(0, 6),
                      blurRadius: 14,
                      color: Color(0x335B63F6),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: _openLanguageTab,
                  icon: const Icon(Icons.add, color: Color(0xFF5B63F6)),
                  label: const Text('New Session'),
                ),
                const SizedBox(width: 10),
              ],
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop) AppSidebar(onNewSession: _openLanguageTab),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF6F8FD), Color(0xFFF0F3FA)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isDesktop ? 30 : 16,
                        24,
                        isDesktop ? 30 : 16,
                        14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            showAction: isDesktop,
                            onNewSession: _openLanguageTab,
                          ),
                          if (!widget.firebaseReady)
                            const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Text(
                                'Firebase not initialized. Add Firebase config and restart app.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          if (widget.geminiApiKey.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Missing GEMINI_API_KEY. AI replies are disabled.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 18),
                          TabBar(
                            controller: _tabController,
                            indicatorColor: const Color(0xFF5B63F6),
                            labelColor: const Color(0xFF1F2A44),
                            unselectedLabelColor: Colors.blueGrey.shade400,
                            tabs: const [
                              Tab(text: 'Languages'),
                              Tab(text: 'Recent Sessions'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLanguageTab(isDesktop),
                          _buildRecentSessionsTab(isDesktop),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.showAction, required this.onNewSession});

  final bool showAction;
  final VoidCallback onNewSession;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2A44),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to continue your language journey?',
                style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 18),
              ),
            ],
          ),
        ),
        if (showAction)
          FilledButton.icon(
            onPressed: onNewSession,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF5B63F6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            icon: const Icon(Icons.add),
            label: const Text('New Tutor Session'),
          ),
      ],
    );
  }
}

extension _ListChunkExtension<T> on List<T> {
  Iterable<List<T>> chunked(int size) sync* {
    for (var index = 0; index < length; index += size) {
      yield sublist(index, index + size > length ? length : index + size);
    }
  }
}
