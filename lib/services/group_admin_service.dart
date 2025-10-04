import 'package:cloud_firestore/cloud_firestore.dart';

class GroupAdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // GROUP ADMIN FUNCTIONS
  // ============================================================================

  /// Add admin
  static Future<void> addAdmin({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('chats').doc(groupId).update({
        'admins': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Failed to add admin: $e');
    }
  }

  /// Remove admin
  static Future<void> removeAdmin({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('chats').doc(groupId).update({
        'admins': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Failed to remove admin: $e');
    }
  }

  /// Remove participant
  static Future<void> removeParticipant({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('chats').doc(groupId).update({
        'participants': FieldValue.arrayRemove([userId]),
        'admins': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Failed to remove participant: $e');
    }
  }

  /// Change group name
  static Future<void> changeGroupName({
    required String groupId,
    required String newName,
  }) async {
    try {
      await _firestore.collection('chats').doc(groupId).update({
        'name': newName,
      });
    } catch (e) {
      throw Exception('Failed to change group name: $e');
    }
  }

  /// Change group description
  static Future<void> changeGroupDescription({
    required String groupId,
    required String description,
  }) async {
    try {
      await _firestore.collection('chats').doc(groupId).update({
        'description': description,
      });
    } catch (e) {
      throw Exception('Failed to change group description: $e');
    }
  }

  /// Change group avatar
  static Future<void> changeGroupAvatar({
    required String groupId,
    required String avatarUrl,
  }) async {
    try {
      await _firestore.collection('chats').doc(groupId).update({
        'avatar': avatarUrl,
      });
    } catch (e) {
      throw Exception('Failed to change group avatar: $e');
    }
  }

  /// Toggle group settings
  static Future<void> toggleGroupSetting({
    required String groupId,
    required String setting,
    required bool value,
  }) async {
    try {
      await _firestore.collection('chats').doc(groupId).update({
        'settings.$setting': value,
      });
    } catch (e) {
      throw Exception('Failed to toggle setting: $e');
    }
  }

  /// Mute participant
  static Future<void> muteParticipant({
    required String groupId,
    required String userId,
    required int durationMinutes,
  }) async {
    try {
      final muteUntil = DateTime.now().add(Duration(minutes: durationMinutes));

      await _firestore.collection('chats').doc(groupId).update({
        'mutedParticipants.$userId': muteUntil.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to mute participant: $e');
    }
  }

  /// Unmute participant
  static Future<void> unmuteParticipant({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('chats').doc(groupId).update({
        'mutedParticipants.$userId': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Failed to unmute participant: $e');
    }
  }

  /// Pin chat
  static Future<void> pinChat({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'pinnedChats': FieldValue.arrayUnion([chatId]),
      });
    } catch (e) {
      throw Exception('Failed to pin chat: $e');
    }
  }

  /// Unpin chat
  static Future<void> unpinChat({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'pinnedChats': FieldValue.arrayRemove([chatId]),
      });
    } catch (e) {
      throw Exception('Failed to unpin chat: $e');
    }
  }

  /// Archive chat
  static Future<void> archiveChat({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'archivedChats': FieldValue.arrayUnion([chatId]),
      });
    } catch (e) {
      throw Exception('Failed to archive chat: $e');
    }
  }

  /// Unarchive chat
  static Future<void> unarchiveChat({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'archivedChats': FieldValue.arrayRemove([chatId]),
      });
    } catch (e) {
      throw Exception('Failed to unarchive chat: $e');
    }
  }
}
