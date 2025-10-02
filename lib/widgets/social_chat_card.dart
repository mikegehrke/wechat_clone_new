import 'package:flutter/material.dart';
import '../models/social.dart';

class SocialChatCard extends StatelessWidget {
  final SocialChat chat;
  final VoidCallback? onTap;

  const SocialChatCard({
    super.key,
    required this.chat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue[100],
              child: Text(
                chat.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // isOnline not in model
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat.name,
                style: TextStyle(
                  fontWeight: chat.unreadCount > 0
                      ? FontWeight.bold
                      : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTime(chat.lastMessageAt ?? DateTime.now()),
              style: TextStyle(
                fontSize: 12,
                color: chat.unreadCount > 0
                    ? const Color(0xFF07C160)
                    : Colors.grey[600],
                fontWeight: chat.unreadCount > 0
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            // lastMessageIsRead not in model
            Expanded(
              child: Text(
                chat.lastMessageContent ?? 'No messages',
                style: TextStyle(
                  color: chat.unreadCount > 0
                      ? Colors.black87
                      : Colors.grey[600],
                  fontWeight: chat.unreadCount > 0
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: chat.unreadCount > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF07C160),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      final hour = time.hour > 12 ? time.hour - 12 : time.hour;
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return days[time.weekday % 7];
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
