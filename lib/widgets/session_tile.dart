import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SessionTile extends StatelessWidget {
  const SessionTile({
    super.key,
    required this.language,
    required this.createdAt,
    required this.onTap,
    this.onDelete,
  });

  final String language;
  final Timestamp? createdAt;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  String _timeLabel() {
    if (createdAt == null) {
      return 'Just now';
    }
    final date = createdAt!.toDate();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueGrey.shade100),
        ),
        child: Row(
          children: [
            const Icon(Icons.record_voice_over_rounded, color: Color(0xFF5B63F6)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$language Tutor Session',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1F2A44),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeLabel(),
                    style: TextStyle(color: Colors.blueGrey.shade500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade400,
                tooltip: 'Delete session',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
