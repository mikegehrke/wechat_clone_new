import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatBackupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================================
  // CHAT BACKUP & RESTORE
  // ============================================================================

  /// Backup all chats
  static Future<String> backupChats(String userId) async {
    try {
      // Get all user chats
      final chatsSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();

      final backup = {
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'chats': <Map<String, dynamic>>[],
      };

      for (var chatDoc in chatsSnapshot.docs) {
        final chatData = chatDoc.data();
        chatData['id'] = chatDoc.id;

        // Get messages
        final messagesSnapshot = await _firestore
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .orderBy('timestamp')
            .get();

        chatData['messages'] = messagesSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        backup['chats']!.add(chatData);
      }

      // Upload to Firebase Storage
      final json = jsonEncode(backup);
      final filename = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final ref = _storage.ref().child('backups/$userId/$filename');
      
      await ref.putString(json);
      final downloadUrl = await ref.getDownloadURL();

      // Save backup metadata
      await _firestore.collection('backups').add({
        'userId': userId,
        'url': downloadUrl,
        'filename': filename,
        'size': json.length,
        'chatCount': backup['chats']!.length,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to backup chats: $e');
    }
  }

  /// Get backup history
  static Future<List<Map<String, dynamic>>> getBackupHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('backups')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get backup history: $e');
    }
  }

  /// Restore from backup
  static Future<void> restoreFromBackup(String backupUrl) async {
    try {
      // Download backup
      final ref = _storage.refFromURL(backupUrl);
      final json = await ref.getData();
      
      if (json == null) throw Exception('Backup not found');

      final backup = jsonDecode(String.fromCharCodes(json));
      final userId = backup['userId'];
      final chats = List<Map<String, dynamic>>.from(backup['chats']);

      // Restore chats
      for (var chat in chats) {
        final messages = List<Map<String, dynamic>>.from(chat['messages']);
        chat.remove('messages');
        chat.remove('id');

        // Create chat
        final chatRef = await _firestore.collection('chats').add(chat);

        // Restore messages
        for (var message in messages) {
          message.remove('id');
          await chatRef.collection('messages').add(message);
        }
      }
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  /// Delete backup
  static Future<void> deleteBackup(String backupId, String backupUrl) async {
    try {
      // Delete from storage
      final ref = _storage.refFromURL(backupUrl);
      await ref.delete();

      // Delete metadata
      await _firestore.collection('backups').doc(backupId).delete();
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }
}
