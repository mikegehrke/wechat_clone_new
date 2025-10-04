import 'package:cloud_firestore/cloud_firestore.dart';

class DisappearingMessagesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // DISAPPEARING MESSAGES (Self-destruct)
  // ============================================================================

  /// Enable disappearing messages for chat
  static Future<void> enableDisappearingMessages({
    required String chatId,
    required int durationHours,
  }) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'disappearingMessagesEnabled': true,
        'disappearingMessagesDuration': durationHours,
      });
    } catch (e) {
      throw Exception('Failed to enable disappearing messages: $e');
    }
  }

  /// Disable disappearing messages for chat
  static Future<void> disableDisappearingMessages(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'disappearingMessagesEnabled': false,
        'disappearingMessagesDuration': null,
      });
    } catch (e) {
      throw Exception('Failed to disable disappearing messages: $e');
    }
  }

  /// Check and delete expired messages
  static Future<void> cleanupExpiredMessages() async {
    try {
      // Get chats with disappearing messages enabled
      final chatsSnapshot = await _firestore
          .collection('chats')
          .where('disappearingMessagesEnabled', isEqualTo: true)
          .get();

      for (var chatDoc in chatsSnapshot.docs) {
        final duration = chatDoc.data()['disappearingMessagesDuration'] as int;
        final expiryTime = DateTime.now().subtract(Duration(hours: duration));

        // Get expired messages
        final messagesSnapshot = await _firestore
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .where('timestamp', isLessThan: Timestamp.fromDate(expiryTime))
            .get();

        // Delete expired messages
        for (var messageDoc in messagesSnapshot.docs) {
          await messageDoc.reference.delete();
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Get disappearing message durations
  static List<Map<String, dynamic>> getDurationOptions() {
    return [
      {'label': '1 hour', 'hours': 1},
      {'label': '24 hours', 'hours': 24},
      {'label': '7 days', 'hours': 168},
      {'label': '90 days', 'hours': 2160},
    ];
  }
}
