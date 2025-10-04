import 'package:cloud_firestore/cloud_firestore.dart';

class MessageForwardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // MESSAGE FORWARDING
  // ============================================================================

  /// Forward message to multiple chats
  static Future<void> forwardMessage({
    required String fromChatId,
    required String messageId,
    required List<String> toChatIds,
    required String userId,
  }) async {
    try {
      // Get original message
      final messageDoc = await _firestore
          .collection('chats')
          .doc(fromChatId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final originalData = messageDoc.data()!;

      // Forward to each chat
      for (var chatId in toChatIds) {
        final forwardedMessage = {
          'senderId': userId,
          'type': originalData['type'],
          'content': originalData['content'],
          'metadata': originalData['metadata'],
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'sent',
          'isForwarded': true,
          'forwardedFrom': fromChatId,
          'originalSenderId': originalData['senderId'],
        };

        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add(forwardedMessage);

        // Update last message
        String lastMessagePreview = originalData['content'] ?? '';
        if (originalData['type'] == 'image') lastMessagePreview = '📷 Photo';
        if (originalData['type'] == 'video') lastMessagePreview = '🎥 Video';
        if (originalData['type'] == 'audio') lastMessagePreview = '🎵 Audio';

        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': '↗️ Forwarded: $lastMessagePreview',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageSenderId': userId,
        });
      }
    } catch (e) {
      throw Exception('Failed to forward message: $e');
    }
  }
}
