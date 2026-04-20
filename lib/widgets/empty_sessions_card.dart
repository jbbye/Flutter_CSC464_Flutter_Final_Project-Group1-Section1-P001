import 'package:flutter/material.dart';

class EmptySessionsCard extends StatelessWidget {
  const EmptySessionsCard({
    super.key,
    required this.onCreate,
  });

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4FA),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFFBBC6D8),
              size: 34,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start your first language practice session\nwith our AI tutors!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey.shade500,
              height: 1.4,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onCreate,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF5B63F6),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            ),
            child: const Text('Create New Session'),
          ),
        ],
      ),
    );
  }
}
