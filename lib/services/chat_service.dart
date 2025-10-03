import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat.dart';
import '../models/message.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================================
  // CHAT MANAGEMENT
  // ============================================================================

  /// Create or get direct chat between two users
  static Future<String> getOrCreateDirectChat({
    required String userId1,
    required String userId2,
  }) async {
    try {
      // Check if chat already exists
      final existingChats = await _firestore
          .collection('chats')
          .where('type', isEqualTo: 'direct')
          .where('participants', arrayContains: userId1)
          .get();

      for (var doc in existingChats.docs) {
        final participants = List<String>.from(doc.data()['participants']);
        if (participants.contains(userId2)) {
          return doc.id;
        }
      }

      // Create new chat
      final chatData = {
        'type': 'direct',
        'participants': [userId1, userId2],
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
        'unreadCount': {userId1: 0, userId2: 0},
      };

      final docRef = await _firestore.collection('chats').add(chatData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  /// Create group chat
  static Future<String> createGroupChat({
    required String groupName,
    required List<String> participants,
    required String creatorId,
    String? groupAvatar,
  }) async {
    try {
      final chatData = {
        'type': 'group',
        'name': groupName,
        'participants': participants,
        'creatorId': creatorId,
        'avatar': groupAvatar,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
        'unreadCount': {for (var id in participants) id: 0},
      };

      final docRef = await _firestore.collection('chats').add(chatData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create group chat: $e');
    }
  }

  /// Get user's chats
  static Future<List<Chat>> getUserChats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastActivity', descending: true)
          .get();

      final chats = <Chat>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Get last message
        final lastMessageSnapshot = await _firestore
            .collection('chats')
            .doc(doc.id)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        Message? lastMessage;
        if (lastMessageSnapshot.docs.isNotEmpty) {
          final msgData = lastMessageSnapshot.docs.first.data();
          msgData['id'] = lastMessageSnapshot.docs.first.id;
          lastMessage = Message.fromJson(msgData);
        }

        final unreadCount = (data['unreadCount'] as Map<String, dynamic>?)?[userId] ?? 0;

        chats.add(Chat(
          id: doc.id,
          name: data['name'] ?? '',
          type: data['type'] == 'group' ? ChatType.group : ChatType.direct,
          participants: List<String>.from(data['participants']),
          lastMessage: lastMessage,
          unreadCount: unreadCount,
          lastActivity: (data['lastActivity'] as Timestamp?)?.toDate() ?? DateTime.now(),
          avatar: data['avatar'],
          metadata: data['metadata'],
        ));
      }

      return chats;
    } catch (e) {
      throw Exception('Failed to get user chats: $e');
    }
  }

  /// Get chat by ID
  static Future<Chat?> getChatById(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      
      if (!doc.exists) return null;

      final data = doc.data()!;
      
      // Get last message
      final lastMessageSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      Message? lastMessage;
      if (lastMessageSnapshot.docs.isNotEmpty) {
        final msgData = lastMessageSnapshot.docs.first.data();
        msgData['id'] = lastMessageSnapshot.docs.first.id;
        lastMessage = Message.fromJson(msgData);
      }

      return Chat(
        id: doc.id,
        name: data['name'] ?? '',
        type: data['type'] == 'group' ? ChatType.group : ChatType.direct,
        participants: List<String>.from(data['participants']),
        lastMessage: lastMessage,
        unreadCount: 0,
        lastActivity: (data['lastActivity'] as Timestamp?)?.toDate() ?? DateTime.now(),
        avatar: data['avatar'],
        metadata: data['metadata'],
      );
    } catch (e) {
      throw Exception('Failed to get chat: $e');
    }
  }

  /// Delete chat
  static Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete chat
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  // ============================================================================
  // MESSAGE MANAGEMENT
  // ============================================================================

  /// Send text message
  static Future<String> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final messageData = {
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
        'type': type.toString().split('.').last,
        'status': 'sent',
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': metadata,
      };

      final docRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);

      // Update chat's last activity and unread counts
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      final unreadCount = Map<String, dynamic>.from(chatDoc.data()?['unreadCount'] ?? {});

      // Increment unread count for all participants except sender
      for (var participantId in participants) {
        if (participantId != senderId) {
          unreadCount[participantId] = (unreadCount[participantId] ?? 0) + 1;
        }
      }

      await _firestore.collection('chats').doc(chatId).update({
        'lastActivity': FieldValue.serverTimestamp(),
        'unreadCount': unreadCount,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Send image message
  static Future<String> sendImageMessage({
    required String chatId,
    required String senderId,
    required File imageFile,
    String? caption,
  }) async {
    try {
      // Upload image to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'chat_${chatId}_$timestamp.jpg';
      final ref = _storage.ref().child('chat_images/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Send message with image URL
      return await sendMessage(
        chatId: chatId,
        senderId: senderId,
        content: caption ?? '',
        type: MessageType.image,
        metadata: {
          'imageUrl': imageUrl,
          'fileName': fileName,
        },
      );
    } catch (e) {
      throw Exception('Failed to send image: $e');
    }
  }

  /// Send voice message
  static Future<String> sendVoiceMessage({
    required String chatId,
    required String senderId,
    required File voiceFile,
    required int duration,
  }) async {
    try {
      // Upload voice to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'voice_${chatId}_$timestamp.m4a';
      final ref = _storage.ref().child('voice_messages/$fileName');
      
      final uploadTask = ref.putFile(voiceFile);
      final snapshot = await uploadTask;
      final voiceUrl = await snapshot.ref.getDownloadURL();

      // Send message with voice URL
      return await sendMessage(
        chatId: chatId,
        senderId: senderId,
        content: 'Voice message',
        type: MessageType.voice,
        metadata: {
          'voiceUrl': voiceUrl,
          'duration': duration,
          'fileName': fileName,
        },
      );
    } catch (e) {
      throw Exception('Failed to send voice message: $e');
    }
  }

  /// Send file message
  static Future<String> sendFileMessage({
    required String chatId,
    required String senderId,
    required File file,
    required String fileName,
  }) async {
    try {
      // Upload file to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageFileName = 'file_${chatId}_$timestamp';
      final ref = _storage.ref().child('chat_files/$storageFileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final fileUrl = await snapshot.ref.getDownloadURL();
      final fileSize = await file.length();

      // Send message with file URL
      return await sendMessage(
        chatId: chatId,
        senderId: senderId,
        content: fileName,
        type: MessageType.file,
        metadata: {
          'fileUrl': fileUrl,
          'fileName': fileName,
          'fileSize': fileSize,
        },
      );
    } catch (e) {
      throw Exception('Failed to send file: $e');
    }
  }

  /// Get messages for a chat (with pagination)
  static Future<List<Message>> getMessages({
    required String chatId,
    int limit = 50,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['timestamp'] = (data['timestamp'] as Timestamp?)?.toDate().toIso8601String() 
            ?? DateTime.now().toIso8601String();
        return Message.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  /// Stream messages for real-time updates
  static Stream<List<Message>> streamMessages(String chatId, {int limit = 50}) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['timestamp'] = (data['timestamp'] as Timestamp?)?.toDate().toIso8601String() 
            ?? DateTime.now().toIso8601String();
        return Message.fromJson(data);
      }).toList();
    });
  }

  /// Mark messages as read
  static Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      // Reset unread count for this user
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });

      // Update message status to read
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('status', isNotEqualTo: 'read')
          .get();

      for (var doc in unreadMessages.docs) {
        await doc.reference.update({'status': 'read'});
      }
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Delete message
  static Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  /// Delete message for everyone
  static Future<void> deleteMessageForEveryone({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    try {
      // Check if user is the sender
      final messageDoc = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final senderId = messageDoc.data()?['senderId'];
      if (senderId != userId) {
        throw Exception('Only sender can delete message for everyone');
      }

      // Update message content to deleted
      await messageDoc.reference.update({
        'content': 'This message was deleted',
        'type': 'system',
        'metadata': {'deleted': true},
      });
    } catch (e) {
      throw Exception('Failed to delete message for everyone: $e');
    }
  }

  // ============================================================================
  // GROUP CHAT MANAGEMENT
  // ============================================================================

  /// Add participants to group chat
  static Future<void> addParticipants({
    required String chatId,
    required List<String> userIds,
  }) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      if (!chatDoc.exists) {
        throw Exception('Chat not found');
      }

      if (chatDoc.data()?['type'] != 'group') {
        throw Exception('Can only add participants to group chats');
      }

      final currentParticipants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      final unreadCount = Map<String, dynamic>.from(chatDoc.data()?['unreadCount'] ?? {});

      // Add new participants
      for (var userId in userIds) {
        if (!currentParticipants.contains(userId)) {
          currentParticipants.add(userId);
          unreadCount[userId] = 0;
        }
      }

      await _firestore.collection('chats').doc(chatId).update({
        'participants': currentParticipants,
        'unreadCount': unreadCount,
      });
    } catch (e) {
      throw Exception('Failed to add participants: $e');
    }
  }

  /// Remove participant from group chat
  static Future<void> removeParticipant({
    required String chatId,
    required String userId,
  }) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      if (!chatDoc.exists) {
        throw Exception('Chat not found');
      }

      if (chatDoc.data()?['type'] != 'group') {
        throw Exception('Can only remove participants from group chats');
      }

      final currentParticipants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      final unreadCount = Map<String, dynamic>.from(chatDoc.data()?['unreadCount'] ?? {});

      currentParticipants.remove(userId);
      unreadCount.remove(userId);

      await _firestore.collection('chats').doc(chatId).update({
        'participants': currentParticipants,
        'unreadCount': unreadCount,
      });
    } catch (e) {
      throw Exception('Failed to remove participant: $e');
    }
  }

  /// Update group chat info
  static Future<void> updateGroupInfo({
    required String chatId,
    String? name,
    String? avatar,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (name != null) updates['name'] = name;
      if (avatar != null) updates['avatar'] = avatar;

      if (updates.isNotEmpty) {
        await _firestore.collection('chats').doc(chatId).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update group info: $e');
    }
  }

  // ============================================================================
  // TYPING INDICATORS
  // ============================================================================

  /// Set user typing status
  static Future<void> setTyping({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('typing')
          .doc(userId)
          .set({
        'isTyping': isTyping,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to set typing status: $e');
    }
  }

  /// Stream typing status
  static Stream<Map<String, bool>> streamTypingStatus(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .snapshots()
        .map((snapshot) {
      final typingStatus = <String, bool>{};
      for (var doc in snapshot.docs) {
        typingStatus[doc.id] = doc.data()['isTyping'] ?? false;
      }
      return typingStatus;
    });
  }

  // ============================================================================
  // SEARCH & FILTER
  // ============================================================================

  /// Search messages in chat
  static Future<List<Message>> searchMessages({
    required String chatId,
    required String query,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThanOrEqualTo: query + '\uf8ff')
          .orderBy('content')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['timestamp'] = (data['timestamp'] as Timestamp?)?.toDate().toIso8601String() 
            ?? DateTime.now().toIso8601String();
        return Message.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }
}
