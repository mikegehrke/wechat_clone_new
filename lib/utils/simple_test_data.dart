import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple test data creator - creates chats directly
class SimpleTestData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create simple test chats for current user
  static Future<String> createQuickTestChats(String currentUserId) async {
    String result = '';
    
    try {
      result += '🚀 Creating test chats...\n\n';

      // Chat 1: Alice
      result += '📝 Creating chat with Alice...\n';
      final chat1 = await _firestore.collection('chats').add({
        'type': 'direct',
        'name': 'Alice Johnson',
        'participants': [currentUserId, 'fake_alice_id'],
        'avatar': null,
        'isOnline': true,
        'lastSeen': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'lastActivity': Timestamp.now(),
        'unreadCount': 2,
        'lastMessage': {
          'content': 'Hey! Are we still meeting at 5pm? ☕',
          'senderId': 'fake_alice_id',
          'type': 'text',
          'status': 'delivered',
          'timestamp': Timestamp.now(),
        },
      });
      
      // Add messages to chat 1
      await chat1.collection('messages').add({
        'content': 'Hey Alice! How are you?',
        'senderId': currentUserId,
        'type': 'text',
        'status': 'read',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
      });
      
      await chat1.collection('messages').add({
        'content': 'I\'m good! Want to grab coffee later?',
        'senderId': 'fake_alice_id',
        'type': 'text',
        'status': 'read',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))),
      });
      
      await chat1.collection('messages').add({
        'content': 'Sure! What time works for you?',
        'senderId': currentUserId,
        'type': 'text',
        'status': 'read',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
      });
      
      await chat1.collection('messages').add({
        'content': 'Hey! Are we still meeting at 5pm? ☕',
        'senderId': 'fake_alice_id',
        'type': 'text',
        'status': 'delivered',
        'timestamp': Timestamp.now(),
      });
      
      result += '  ✅ Chat with Alice created!\n\n';

      // Chat 2: Bob
      result += '📝 Creating chat with Bob...\n';
      final chat2 = await _firestore.collection('chats').add({
        'type': 'direct',
        'name': 'Bob Smith',
        'participants': [currentUserId, 'fake_bob_id'],
        'avatar': null,
        'isOnline': false,
        'lastSeen': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 3))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'lastActivity': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
        'unreadCount': 0,
        'lastMessage': {
          'content': 'Sounds good! See you tomorrow 👍',
          'senderId': currentUserId,
          'type': 'text',
          'status': 'read',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
        },
      });
      
      // Add messages to chat 2
      await chat2.collection('messages').add({
        'content': 'Hey Bob! Did you finish the project?',
        'senderId': currentUserId,
        'type': 'text',
        'status': 'read',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      });
      
      await chat2.collection('messages').add({
        'content': 'Yes! Just submitted it. Want to review it together?',
        'senderId': 'fake_bob_id',
        'type': 'text',
        'status': 'read',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 8))),
      });
      
      await chat2.collection('messages').add({
        'content': 'Sounds good! See you tomorrow 👍',
        'senderId': currentUserId,
        'type': 'text',
        'status': 'read',
        'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 5))),
      });
      
      result += '  ✅ Chat with Bob created!\n\n';

      // Chat 3: Charlie
      result += '📝 Creating chat with Charlie...\n';
      await _firestore.collection('chats').add({
        'type': 'direct',
        'name': 'Charlie Brown',
        'participants': [currentUserId, 'fake_charlie_id'],
        'avatar': null,
        'isOnline': true,
        'lastSeen': Timestamp.now(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
        'lastActivity': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        'unreadCount': 0,
        'lastMessage': {
          'content': 'Thanks! Talk later ✌️',
          'senderId': 'fake_charlie_id',
          'type': 'text',
          'status': 'read',
          'timestamp': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        },
      });
      
      result += '  ✅ Chat with Charlie created!\n\n';

      result += '✅ DONE! Go back to Chats page!\n';
      result += '\n💬 3 test chats created:\n';
      result += '  - Alice Johnson (2 unread messages)\n';
      result += '  - Bob Smith (project discussion)\n';
      result += '  - Charlie Brown (old chat)\n';
      
      return result;
    } catch (e) {
      return '❌ Error: $e';
    }
  }
}
