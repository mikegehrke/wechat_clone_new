import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class DriftBottleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // DRIFT BOTTLE (Message in a bottle to random people)
  // ============================================================================

  /// Throw a bottle
  static Future<String> throwBottle({
    required String userId,
    required String userName,
    required String message,
    String? mediaUrl,
  }) async {
    try {
      final bottleData = {
        'userId': userId,
        'userName': userName,
        'message': message,
        'mediaUrl': mediaUrl,
        'thrownAt': FieldValue.serverTimestamp(),
        'pickedUpBy': <String>[],
        'pickCount': 0,
        'maxPicks': 10, // Can be picked up max 10 times
      };

      final docRef = await _firestore.collection('drift_bottles').add(bottleData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to throw bottle: $e');
    }
  }

  /// Pick a random bottle
  static Future<Map<String, dynamic>?> pickBottle(String userId) async {
    try {
      // Get bottles not picked by this user
      final snapshot = await _firestore
          .collection('drift_bottles')
          .where('pickCount', isLessThan: 10)
          .limit(50)
          .get();

      final availableBottles = snapshot.docs.where((doc) {
        final pickedUpBy = List<String>.from(doc.data()['pickedUpBy'] ?? []);
        return !pickedUpBy.contains(userId) && doc.data()['userId'] != userId;
      }).toList();

      if (availableBottles.isEmpty) {
        return null;
      }

      // Pick random bottle
      final random = Random();
      final bottleDoc = availableBottles[random.nextInt(availableBottles.length)];

      // Mark as picked
      await bottleDoc.reference.update({
        'pickedUpBy': FieldValue.arrayUnion([userId]),
        'pickCount': FieldValue.increment(1),
      });

      final data = bottleDoc.data();
      data['id'] = bottleDoc.id;
      return data;
    } catch (e) {
      throw Exception('Failed to pick bottle: $e');
    }
  }

  /// Reply to bottle
  static Future<void> replyToBottle({
    required String bottleId,
    required String fromUserId,
    required String toUserId,
    required String message,
  }) async {
    try {
      // Create or get direct chat
      final chats = await _firestore
          .collection('chats')
          .where('type', isEqualTo: 'direct')
          .where('participants', arrayContains: fromUserId)
          .get();

      String? chatId;
      for (var chatDoc in chats.docs) {
        final participants = List<String>.from(chatDoc.data()['participants']);
        if (participants.contains(toUserId)) {
          chatId = chatDoc.id;
          break;
        }
      }

      if (chatId == null) {
        final chatDoc = await _firestore.collection('chats').add({
          'type': 'direct',
          'participants': [fromUserId, toUserId],
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
        'senderId': fromUserId,
        'type': 'text',
        'content': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
        'metadata': {
          'isDriftBottleReply': true,
          'bottleId': bottleId,
        },
      });

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': fromUserId,
      });
    } catch (e) {
      throw Exception('Failed to reply to bottle: $e');
    }
  }

  /// Get my thrown bottles
  static Stream<List<Map<String, dynamic>>> getMyBottlesStream(String userId) {
    return _firestore
        .collection('drift_bottles')
        .where('userId', isEqualTo: userId)
        .orderBy('thrownAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
