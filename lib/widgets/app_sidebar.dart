import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.onNewSession,
  });

  final VoidCallback onNewSession;

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
                onPressed: onNewSession,
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
          Row(
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
          const SizedBox(height: 16),
          Container(
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
                    'J',
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
                    const Text(
                      'Fake Email',
                      style: TextStyle(fontWeight: FontWeight.w700),
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
        ],
      ),
    );
  }
}
