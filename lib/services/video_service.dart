import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/video_post.dart';

class VideoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload video with thumbnail
  static Future<String> uploadVideo(File videoFile, String userId) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'video_${userId}_$timestamp.mp4';
      
      // Upload video to Firebase Storage
      final videoRef = _storage.ref().child('videos/$fileName');
      final uploadTask = videoRef.putFile(videoFile);
      final snapshot = await uploadTask;
      final videoUrl = await snapshot.ref.getDownloadURL();

      // Generate thumbnail
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: (await Directory.systemTemp.createTemp()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );

      // Upload thumbnail
      String? thumbnailUrl;
      if (thumbnailPath != null) {
        final thumbnailFile = File(thumbnailPath);
        final thumbnailRef = _storage.ref().child('thumbnails/${fileName}_thumb.jpg');
        final thumbnailUploadTask = thumbnailRef.putFile(thumbnailFile);
        final thumbnailSnapshot = await thumbnailUploadTask;
        thumbnailUrl = await thumbnailSnapshot.ref.getDownloadURL();
      }

      return videoUrl;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  // Create video post
  static Future<String> createVideoPost({
    required String userId,
    required String username,
    required String userAvatar,
    required String videoUrl,
    required String thumbnailUrl,
    required String description,
    List<String> hashtags = const [],
    String musicTitle = '',
    String musicArtist = '',
  }) async {
    try {
      final videoPost = VideoPost(
        id: '', // Will be set by Firestore
        userId: userId,
        username: username,
        userAvatar: userAvatar,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        description: description,
        hashtags: hashtags,
        createdAt: DateTime.now(),
        musicTitle: musicTitle,
        musicArtist: musicArtist,
      );

      final docRef = await _firestore.collection('videoPosts').add(videoPost.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create video post: $e');
    }
  }

  // Get video posts (paginated)
  static Future<List<VideoPost>> getVideoPosts({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('videoPosts')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return VideoPost.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get video posts: $e');
    }
  }

  // Like/Unlike video
  static Future<void> toggleLike(String videoId, String userId) async {
    try {
      final docRef = _firestore.collection('videoPosts').doc(videoId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        throw Exception('Video post not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final likes = data['likes'] ?? 0;
      final likedUsers = List<String>.from(data['likedUsers'] ?? []);

      if (likedUsers.contains(userId)) {
        // Unlike
        likedUsers.remove(userId);
        await docRef.update({
          'likes': likes - 1,
          'likedUsers': likedUsers,
        });
      } else {
        // Like
        likedUsers.add(userId);
        await docRef.update({
          'likes': likes + 1,
          'likedUsers': likedUsers,
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Add comment
  static Future<void> addComment(String videoId, String userId, String username, String comment) async {
    try {
      await _firestore.collection('videoPosts').doc(videoId).collection('comments').add({
        'userId': userId,
        'username': username,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update comment count
      await _firestore.collection('videoPosts').doc(videoId).update({
        'comments': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Get comments
  static Future<List<Map<String, dynamic>>> getComments(String videoId) async {
    try {
      final snapshot = await _firestore
          .collection('videoPosts')
          .doc(videoId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }

  // Share video
  static Future<void> shareVideo(String videoId) async {
    try {
      await _firestore.collection('videoPosts').doc(videoId).update({
        'shares': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to share video: $e');
    }
  }

  // Follow/Unfollow user
  static Future<void> toggleFollow(String userId, String targetUserId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final targetUserRef = _firestore.collection('users').doc(targetUserId);

      final userDoc = await userRef.get();
      final following = List<String>.from(userDoc.data()?['following'] ?? []);

      if (following.contains(targetUserId)) {
        // Unfollow
        following.remove(targetUserId);
        await userRef.update({'following': following});
        await targetUserRef.update({
          'followers': FieldValue.increment(-1),
        });
      } else {
        // Follow
        following.add(targetUserId);
        await userRef.update({'following': following});
        await targetUserRef.update({
          'followers': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle follow: $e');
    }
  }

  // Get user's videos
  static Future<List<VideoPost>> getUserVideos(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('videoPosts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return VideoPost.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user videos: $e');
    }
  }

  // Search videos by hashtag
  static Future<List<VideoPost>> searchVideosByHashtag(String hashtag) async {
    try {
      final snapshot = await _firestore
          .collection('videoPosts')
          .where('hashtags', arrayContains: hashtag)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return VideoPost.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search videos: $e');
    }
  }
}