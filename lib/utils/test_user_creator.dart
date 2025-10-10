import 'package:cloud_firestore/cloud_firestore.dart';

/// Script to create test users in Firebase
/// Run this from Debug page or main.dart
class TestUserCreator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create fake users directly in Firestore (no auth)
  static Future<List<Map<String, String>>> createTestUsers() async {
    final List<Map<String, String>> createdUsers = [];

    final testUsers = [
      {
        'username': 'Alice',
        'displayName': 'Alice Johnson',
        'email': 'alice@test.com',
        'bio': '👋 Hey there! I am using WeChat',
      },
      {
        'username': 'Bob',
        'displayName': 'Bob Smith',
        'email': 'bob@test.com',
        'bio': '🎮 Gaming enthusiast',
      },
      {
        'username': 'Charlie',
        'displayName': 'Charlie Brown',
        'email': 'charlie@test.com',
        'bio': '☕ Coffee lover',
      },
    ];

    for (var userData in testUsers) {
      try {
        // Check if user already exists
        final existingUsers = await _firestore
            .collection('users')
            .where('email', isEqualTo: userData['email'])
            .get();

        if (existingUsers.docs.isNotEmpty) {
          print('✓ User ${userData['email']} already exists');
          createdUsers.add({
            'email': userData['email']!,
            'status': 'exists',
            'id': existingUsers.docs.first.id,
          });
          continue;
        }

        // Create Firestore document directly (no auth)
        final docRef = await _firestore.collection('users').add({
          'email': userData['email'],
          'username': userData['username'],
          'displayName': userData['displayName'],
          'avatarUrl': null,
          'phoneNumber': null,
          'bio': userData['bio'],
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
          'isOnline': false,
        });

        print('✓ Created fake user: ${userData['email']}');
        createdUsers.add({
          'email': userData['email']!,
          'status': 'created',
          'id': docRef.id,
        });
      } catch (e) {
        print('✗ Error creating ${userData['email']}: $e');
        createdUsers.add({
          'email': userData['email']!,
          'status': 'error: $e',
          'id': '',
        });
      }
    }

    return createdUsers;
  }

  /// Create a test chat with messages
  static Future<String> createTestChat({
    required String userId1,
    required String userId2,
  }) async {
    try {
      // Create chat
      final chatDoc = await _firestore.collection('chats').add({
        'type': 'direct',
        'participants': [userId1, userId2],
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
        'unreadCount': {userId1: 0, userId2: 0},
        'lastMessage': null,
      });

      // Add some test messages
      final messages = [
        {
          'content': 'Hey! How are you? 👋',
          'senderId': userId1,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          'content': 'I\'m good! How about you?',
          'senderId': userId2,
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        },
        {
          'content': 'Great! Want to meet up later? ☕',
          'senderId': userId1,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        },
        {
          'content': 'Sure! Where?',
          'senderId': userId2,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
        },
        {
          'content': 'How about the coffee shop on Main St?',
          'senderId': userId1,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        },
      ];

      for (var msgData in messages) {
        await _firestore
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .add({
          'content': msgData['content'],
          'senderId': msgData['senderId'],
          'type': 'text',
          'status': 'read',
          'timestamp': Timestamp.fromDate(msgData['timestamp'] as DateTime),
          'metadata': {},
        });
      }

      // Update last message
      await chatDoc.update({
        'lastMessage': {
          'content': messages.last['content'],
          'senderId': messages.last['senderId'],
          'type': 'text',
          'timestamp': Timestamp.fromDate(messages.last['timestamp'] as DateTime),
        },
        'lastActivity': Timestamp.fromDate(messages.last['timestamp'] as DateTime),
      });

      print('✓ Created test chat with ${messages.length} messages');
      return chatDoc.id;
    } catch (e) {
      print('✗ Error creating test chat: $e');
      rethrow;
    }
  }
}
