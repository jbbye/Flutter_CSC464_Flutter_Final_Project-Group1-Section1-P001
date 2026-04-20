import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalassignment/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.language,
    required this.geminiApiKey,
  });

  final String chatId;
  final String language;
  final String geminiApiKey;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  CollectionReference<Map<String, dynamic>> get _messagesRef {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    if (widget.geminiApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GEMINI_API_KEY is missing.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });
    _controller.clear();

    try {
      await _messagesRef.add({
        'sender': 'user',
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: widget.geminiApiKey,
      );

      final messagesSnapshot = await _messagesRef
          .orderBy('timestamp', descending: true)
          .limit(12)
          .get();

      final history = messagesSnapshot.docs.reversed
          .map((doc) {
            final data = doc.data();
            final sender = data['sender'] as String? ?? 'user';
            final message = data['message'] as String? ?? '';
            return '$sender: $message';
          })
          .join('\n');

      final prompt = '''
You are a helpful ${widget.language} tutor.
Keep answers concise, practical, and beginner friendly.
Give corrections where useful and include short examples.

Conversation:
$history
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final aiText = response.text?.trim();

      await _messagesRef.add({
        'sender': 'ai',
        'message': (aiText == null || aiText.isEmpty)
            ? 'I could not generate a response. Please try again.'
            : aiText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.language} Tutor Session'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF6F8FD), Color(0xFFF0F3FA)],
                ),
              ),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _messagesRef.orderBy('timestamp').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Failed to load messages: ${snapshot.error}'),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Say hello to start your practice session.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final sender = data['sender'] as String? ?? 'user';
                      final message = data['message'] as String? ?? '';

                      return MessageBubble(
                        isUser: sender == 'user',
                        text: message,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(minHeight: 2.5),
            ),
          SafeArea(
            top: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        fillColor: const Color(0xFFF4F6FC),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF5B63F6),
                    ),
                    icon: const Icon(Icons.send_rounded),
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
