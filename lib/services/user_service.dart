import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_foundations.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user by ID
  static Future<UserAccount?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;

      return UserAccount.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Search users by query
  static Future<List<UserAccount>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserAccount.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Get multiple users by IDs
  static Future<List<UserAccount>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      final users = <UserAccount>[];

      // Firestore 'in' query supports max 10 items
      for (var i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        users.addAll(
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return UserAccount.fromJson(data);
          }),
        );
      }

      return users;
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? status,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (displayName != null) updates['displayName'] = displayName;
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      if (status != null) updates['status'] = status;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Set user online status
  static Future<void> setUserOnlineStatus({
    required String userId,
    required bool isOnline,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeenAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update online status: $e');
    }
  }

  /// Get user contacts
  static Future<List<UserAccount>> getUserContacts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .get();

      if (snapshot.docs.isEmpty) return [];

      final contactIds = snapshot.docs.map((doc) => doc.id).toList();
      return getUsersByIds(contactIds);
    } catch (e) {
      throw Exception('Failed to get contacts: $e');
    }
  }

  /// Get all users (for development/demo purposes)
  static Future<List<UserAccount>> getUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .limit(100) // Limit to prevent large data loads
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserAccount.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }
}
