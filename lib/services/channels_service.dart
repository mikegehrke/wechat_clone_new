import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChannelsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================================
  // CHANNEL MANAGEMENT (Broadcast Channels like WhatsApp)
  // ============================================================================

  /// Create a channel
  static Future<String> createChannel({
    required String adminId,
    required String adminName,
    required String channelName,
    required String description,
    String? channelImage,
    bool isPublic = true,
  }) async {
    try {
      final channelData = {
        'adminId': adminId,
        'adminName': adminName,
        'name': channelName,
        'description': description,
        'image': channelImage,
        'isPublic': isPublic,
        'followers': [],
        'followerCount': 0,
        'postCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('channels').add(channelData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create channel: $e');
    }
  }

  /// Post to channel (admin only)
  static Future<String> postToChannel({
    required String channelId,
    required String adminId,
    String? text,
    String? mediaUrl,
    String? mediaType,
  }) async {
    try {
      // Verify admin
      final channel = await _firestore.collection('channels').doc(channelId).get();
      if (channel.data()?['adminId'] != adminId) {
        throw Exception('Only admin can post');
      }

      final postData = {
        'channelId': channelId,
        'adminId': adminId,
        'text': text,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'reactions': {},
        'views': 0,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('channels')
          .doc(channelId)
          .collection('posts')
          .add(postData);

      // Update post count
      await _firestore.collection('channels').doc(channelId).update({
        'postCount': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to post to channel: $e');
    }
  }

  /// Follow channel
  static Future<void> followChannel(String channelId, String userId) async {
    try {
      await _firestore.collection('channels').doc(channelId).update({
        'followers': FieldValue.arrayUnion([userId]),
        'followerCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to follow channel: $e');
    }
  }

  /// Unfollow channel
  static Future<void> unfollowChannel(String channelId, String userId) async {
    try {
      await _firestore.collection('channels').doc(channelId).update({
        'followers': FieldValue.arrayRemove([userId]),
        'followerCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to unfollow channel: $e');
    }
  }

  /// React to channel post
  static Future<void> reactToPost({
    required String channelId,
    required String postId,
    required String userId,
    required String reaction,
  }) async {
    try {
      await _firestore
          .collection('channels')
          .doc(channelId)
          .collection('posts')
          .doc(postId)
          .update({
        'reactions.$userId': reaction,
      });
    } catch (e) {
      throw Exception('Failed to react: $e');
    }
  }

  /// Get user's followed channels
  static Stream<List<Map<String, dynamic>>> getFollowedChannelsStream(String userId) {
    return _firestore
        .collection('channels')
        .where('followers', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Discover public channels
  static Future<List<Map<String, dynamic>>> discoverChannels() async {
    try {
      final snapshot = await _firestore
          .collection('channels')
          .where('isPublic', isEqualTo: true)
          .orderBy('followerCount', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to discover channels: $e');
    }
  }

  /// Get channel posts
  static Stream<List<Map<String, dynamic>>> getChannelPostsStream(String channelId) {
    return _firestore
        .collection('channels')
        .doc(channelId)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Upload channel media
  static Future<String> uploadChannelMedia(File file, String type) async {
    try {
      final filename = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child('channels/$type/$filename');
      
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload channel media: $e');
    }
  }
}
