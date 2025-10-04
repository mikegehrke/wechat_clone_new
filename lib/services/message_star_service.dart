import 'package:cloud_firestore/cloud_firestore.dart';

class MessageStarService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // STARRED MESSAGES
  // ============================================================================

  /// Star a message
  static Future<void> starMessage({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('starred_messages')
          .doc('${chatId}_$messageId')
          .set({
        'chatId': chatId,
        'messageId': messageId,
        'starredAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to star message: $e');
    }
  }

  /// Unstar a message
  static Future<void> unstarMessage({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('starred_messages')
          .doc('${chatId}_$messageId')
          .delete();
    } catch (e) {
      throw Exception('Failed to unstar message: $e');
    }
  }

  /// Get starred messages
  static Stream<List<Map<String, dynamic>>> getStarredMessagesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('starred_messages')
        .orderBy('starredAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final results = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final chatId = data['chatId'];
        final messageId = data['messageId'];

        // Get actual message
        final messageDoc = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(messageId)
            .get();

        if (messageDoc.exists) {
          final messageData = messageDoc.data()!;
          messageData['id'] = messageId;
          messageData['chatId'] = chatId;
          messageData['starredAt'] = data['starredAt'];
          results.add(messageData);
        }
      }

      return results;
    });
  }

  /// Check if message is starred
  static Future<bool> isMessageStarred({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('starred_messages')
          .doc('${chatId}_$messageId')
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
