import 'package:cloud_firestore/cloud_firestore.dart';

class MessageReactionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // MESSAGE REACTIONS (Like WhatsApp)
  // ============================================================================

  /// Add reaction to message
  static Future<void> addReaction({
    required String chatId,
    required String messageId,
    required String userId,
    required String reaction,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reactions.$userId': reaction,
      });
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  /// Remove reaction from message
  static Future<void> removeReaction({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reactions.$userId': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  /// Get popular reactions
  static List<String> getPopularReactions() {
    return ['👍', '❤️', '😂', '😮', '😢', '🙏', '🔥', '🎉'];
  }
}
