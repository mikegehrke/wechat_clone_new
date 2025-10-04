import 'package:cloud_firestore/cloud_firestore.dart';

class BroadcastService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // BROADCAST LISTS (Send to multiple people)
  // ============================================================================

  /// Create broadcast list
  static Future<String> createBroadcastList({
    required String userId,
    required String name,
    required List<String> recipients,
  }) async {
    try {
      final listData = {
        'userId': userId,
        'name': name,
        'recipients': recipients,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('broadcast_lists').add(listData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create broadcast list: $e');
    }
  }

  /// Get user's broadcast lists
  static Stream<List<Map<String, dynamic>>> getBroadcastListsStream(String userId) {
    return _firestore
        .collection('broadcast_lists')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Send broadcast message
  static Future<void> sendBroadcastMessage({
    required String broadcastListId,
    required String userId,
    required String message,
  }) async {
    try {
      final listDoc = await _firestore
          .collection('broadcast_lists')
          .doc(broadcastListId)
          .get();

      final recipients = List<String>.from(listDoc.data()?['recipients'] ?? []);

      // Send individual message to each recipient
      for (var recipientId in recipients) {
        // Get or create direct chat
        final chats = await _firestore
            .collection('chats')
            .where('type', isEqualTo: 'direct')
            .where('participants', arrayContains: userId)
            .get();

        String? chatId;
        for (var chatDoc in chats.docs) {
          final participants = List<String>.from(chatDoc.data()['participants']);
          if (participants.contains(recipientId)) {
            chatId = chatDoc.id;
            break;
          }
        }

        // Create chat if doesn't exist
        if (chatId == null) {
          final chatDoc = await _firestore.collection('chats').add({
            'type': 'direct',
            'participants': [userId, recipientId],
            'createdAt': FieldValue.serverTimestamp(),
          });
          chatId = chatDoc.id;
        }

        // Send message
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add({
          'senderId': userId,
          'type': 'text',
          'content': message,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'sent',
          'isBroadcast': true,
        });

        // Update last message
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': message,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'lastMessageSenderId': userId,
        });
      }
    } catch (e) {
      throw Exception('Failed to send broadcast: $e');
    }
  }
}
