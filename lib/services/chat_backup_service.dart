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

      final chats = <Map<String, dynamic>>[];

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

        chats.add(chatData);
      }

      final backup = {
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'chats': chats,
      };

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
        'chatCount': chats.length,
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

  /// Backup specific chat
  static Future<String> backupSpecificChat(String userId, String chatId) async {
    try {
      // Get specific chat
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      if (!chatDoc.exists) {
        throw Exception('Chat not found');
      }

      final chatData = chatDoc.data()!;
      chatData['id'] = chatDoc.id;

      // Get messages
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      chatData['messages'] = messagesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      final backup = {
        'userId': userId,
        'chatId': chatId,
        'timestamp': DateTime.now().toIso8601String(),
        'chat': chatData,
      };

      // Upload to Firebase Storage
      final json = jsonEncode(backup);
      final filename = 'chat_backup_${chatId}_${DateTime.now().millisecondsSinceEpoch}.json';
      final ref = _storage.ref().child('backups/$userId/chats/$filename');
      
      await ref.putString(json);
      final downloadUrl = await ref.getDownloadURL();

      // Save backup metadata
      await _firestore.collection('chat_backups').add({
        'userId': userId,
        'chatId': chatId,
        'url': downloadUrl,
        'filename': filename,
        'size': json.length,
        'messageCount': (chatData['messages'] as List).length,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to backup chat: $e');
    }
  }

  /// Schedule automatic backup
  static Future<void> scheduleAutoBackup(String userId, int intervalHours) async {
    try {
      await _firestore.collection('backup_schedules').doc(userId).set({
        'userId': userId,
        'intervalHours': intervalHours,
        'enabled': true,
        'lastBackup': null,
        'nextBackup': DateTime.now().add(Duration(hours: intervalHours)),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to schedule auto backup: $e');
    }
  }

  /// Get backup settings
  static Future<Map<String, dynamic>?> getBackupSettings(String userId) async {
    try {
      final doc = await _firestore.collection('backup_schedules').doc(userId).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      throw Exception('Failed to get backup settings: $e');
    }
  }

  /// Export chat as text
  static Future<String> exportChatAsText(String chatId) async {
    try {
      // Get chat info
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      if (!chatDoc.exists) {
        throw Exception('Chat not found');
      }

      final chatData = chatDoc.data()!;
      
      // Get messages
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      final messages = messagesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Build text export
      final buffer = StringBuffer();
      buffer.writeln('Chat Export');
      buffer.writeln('Chat Name: ${chatData['name'] ?? 'Unknown'}');
      buffer.writeln('Export Date: ${DateTime.now().toString()}');
      buffer.writeln('Total Messages: ${messages.length}');
      buffer.writeln('=' * 50);
      buffer.writeln();

      for (var message in messages) {
        final timestamp = message['timestamp'] != null 
            ? (message['timestamp'] as Timestamp).toDate()
            : DateTime.now();
        final sender = message['senderId'] ?? 'Unknown';
        final content = message['content'] ?? '';
        final type = message['type'] ?? 'text';

        buffer.writeln('[${timestamp.toString()}] $sender:');
        
        if (type == 'text') {
          buffer.writeln('  $content');
        } else {
          buffer.writeln('  [$type message]');
        }
        buffer.writeln();
      }

      // Upload text export
      final filename = 'chat_export_${chatId}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final ref = _storage.ref().child('exports/$filename');
      
      await ref.putString(buffer.toString());
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to export chat: $e');
    }
  }

  /// Get storage usage
  static Future<Map<String, dynamic>> getStorageUsage(String userId) async {
    try {
      // Get all backups for user
      final backupsSnapshot = await _firestore
          .collection('backups')
          .where('userId', isEqualTo: userId)
          .get();

      final chatBackupsSnapshot = await _firestore
          .collection('chat_backups')
          .where('userId', isEqualTo: userId)
          .get();

      int totalSize = 0;
      int backupCount = 0;

      // Calculate full backups size
      for (var doc in backupsSnapshot.docs) {
        final data = doc.data();
        totalSize += (data['size'] as int? ?? 0);
        backupCount++;
      }

      // Calculate chat backups size
      for (var doc in chatBackupsSnapshot.docs) {
        final data = doc.data();
        totalSize += (data['size'] as int? ?? 0);
        backupCount++;
      }

      return {
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / 1024 / 1024).round(),
        'backupCount': backupCount,
        'fullBackups': backupsSnapshot.docs.length,
        'chatBackups': chatBackupsSnapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Failed to get storage usage: $e');
    }
  }

  /// Cleanup old backups
  static Future<void> cleanupOldBackups(String userId, {int keepDays = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      
      // Get old full backups
      final oldBackupsSnapshot = await _firestore
          .collection('backups')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      // Get old chat backups
      final oldChatBackupsSnapshot = await _firestore
          .collection('chat_backups')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      // Delete old full backups
      for (var doc in oldBackupsSnapshot.docs) {
        final data = doc.data();
        try {
          final ref = _storage.refFromURL(data['url']);
          await ref.delete();
          await doc.reference.delete();
        } catch (e) {
          // Continue if file already deleted
          await doc.reference.delete();
        }
      }

      // Delete old chat backups
      for (var doc in oldChatBackupsSnapshot.docs) {
        final data = doc.data();
        try {
          final ref = _storage.refFromURL(data['url']);
          await ref.delete();
          await doc.reference.delete();
        } catch (e) {
          // Continue if file already deleted
          await doc.reference.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to cleanup old backups: $e');
    }
  }
}
