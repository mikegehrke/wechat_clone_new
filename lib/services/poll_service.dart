import 'package:cloud_firestore/cloud_firestore.dart';

class PollService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // POLLS IN CHAT
  // ============================================================================

  /// Create a poll in chat
  static Future<String> createPoll({
    required String chatId,
    required String userId,
    required String question,
    required List<String> options,
    bool multipleAnswers = false,
  }) async {
    try {
      final pollData = {
        'question': question,
        'options': options.map((opt) => {
          'text': opt,
          'votes': <String>[],
        }).toList(),
        'multipleAnswers': multipleAnswers,
        'createdBy': userId,
        'totalVotes': 0,
      };

      // Add poll message
      final messageRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': userId,
        'type': 'poll',
        'content': question,
        'metadata': pollData,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
      });

      // Update last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': '📊 Poll: $question',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': userId,
      });

      return messageRef.id;
    } catch (e) {
      throw Exception('Failed to create poll: $e');
    }
  }

  /// Vote in a poll
  static Future<void> voteInPoll({
    required String chatId,
    required String messageId,
    required String userId,
    required int optionIndex,
  }) async {
    try {
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(messageRef);
        final data = snapshot.data()!;
        final metadata = Map<String, dynamic>.from(data['metadata']);
        final options = List<Map<String, dynamic>>.from(metadata['options']);
        final multipleAnswers = metadata['multipleAnswers'] as bool;

        // Remove previous votes if single answer
        if (!multipleAnswers) {
          for (var i = 0; i < options.length; i++) {
            final votes = List<String>.from(options[i]['votes']);
            votes.remove(userId);
            options[i]['votes'] = votes;
          }
        }

        // Add new vote
        final votes = List<String>.from(options[optionIndex]['votes']);
        if (votes.contains(userId)) {
          votes.remove(userId); // Toggle off
        } else {
          votes.add(userId); // Toggle on
        }
        options[optionIndex]['votes'] = votes;

        // Update total votes
        final totalVotes = options.fold<int>(
          0,
          (sum, opt) => sum + (opt['votes'] as List).length,
        );

        metadata['options'] = options;
        metadata['totalVotes'] = totalVotes;

        transaction.update(messageRef, {'metadata': metadata});
      });
    } catch (e) {
      throw Exception('Failed to vote: $e');
    }
  }
}
