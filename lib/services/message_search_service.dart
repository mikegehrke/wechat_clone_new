import 'package:cloud_firestore/cloud_firestore.dart';

class MessageSearchService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // MESSAGE SEARCH
  // ============================================================================

  /// Search messages in a chat
  static Future<List<Map<String, dynamic>>> searchInChat({
    required String chatId,
    required String query,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('type', isEqualTo: 'text')
          .orderBy('timestamp', descending: true)
          .limit(500)
          .get();

      final results = snapshot.docs.where((doc) {
        final content = (doc.data()['content'] as String? ?? '').toLowerCase();
        return content.contains(query.toLowerCase());
      }).toList();

      return results.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }

  /// Search messages across all chats
  static Future<List<Map<String, dynamic>>> searchAllChats({
    required String userId,
    required String query,
  }) async {
    try {
      // Get user's chats
      final chatsSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();

      final allResults = <Map<String, dynamic>>[];

      for (var chatDoc in chatsSnapshot.docs) {
        final messagesSnapshot = await _firestore
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .where('type', isEqualTo: 'text')
            .orderBy('timestamp', descending: true)
            .limit(100)
            .get();

        final results = messagesSnapshot.docs.where((doc) {
          final content = (doc.data()['content'] as String? ?? '').toLowerCase();
          return content.contains(query.toLowerCase());
        }).map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          data['chatId'] = chatDoc.id;
          data['chatName'] = chatDoc.data()['name'];
          return data;
        }).toList();

        allResults.addAll(results);
      }

      // Sort by timestamp
      allResults.sort((a, b) {
        final aTime = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });

      return allResults;
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }
}
