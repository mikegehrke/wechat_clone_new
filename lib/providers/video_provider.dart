import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_post.dart';
import '../services/video_service.dart';

class VideoProvider with ChangeNotifier {
  List<VideoPost> _videos = [];
  bool _isLoading = false;
  String? _error;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  List<VideoPost> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Load initial videos
  Future<void> loadVideos() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newVideos = await VideoService.getVideoPosts(
        limit: 10,
        lastDocument: _lastDocument,
      );

      if (newVideos.isEmpty) {
        _hasMore = false;
      } else {
        _videos.addAll(newVideos);
        _lastDocument = await _getLastDocument();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more videos (pagination)
  Future<void> loadMoreVideos() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newVideos = await VideoService.getVideoPosts(
        limit: 10,
        lastDocument: _lastDocument,
      );

      if (newVideos.isEmpty) {
        _hasMore = false;
      } else {
        _videos.addAll(newVideos);
        _lastDocument = await _getLastDocument();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Like/Unlike video
  Future<void> toggleLike(String videoId, String userId) async {
    try {
      await VideoService.toggleLike(videoId, userId);
      
      // Update local state
      final index = _videos.indexWhere((video) => video.id == videoId);
      if (index != -1) {
        final video = _videos[index];
        _videos[index] = video.copyWith(
          isLiked: !video.isLiked,
          likes: video.isLiked ? video.likes - 1 : video.likes + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add comment
  Future<void> addComment(String videoId, String userId, String username, String comment) async {
    try {
      await VideoService.addComment(videoId, userId, username, comment);
      
      // Update local state
      final index = _videos.indexWhere((video) => video.id == videoId);
      if (index != -1) {
        final video = _videos[index];
        _videos[index] = video.copyWith(comments: video.comments + 1);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Share video
  Future<void> shareVideo(String videoId) async {
    try {
      await VideoService.shareVideo(videoId);
      
      // Update local state
      final index = _videos.indexWhere((video) => video.id == videoId);
      if (index != -1) {
        final video = _videos[index];
        _videos[index] = video.copyWith(shares: video.shares + 1);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Follow/Unfollow user
  Future<void> toggleFollow(String userId, String targetUserId) async {
    try {
      await VideoService.toggleFollow(userId, targetUserId);
      
      // Update local state for all videos of this user
      for (int i = 0; i < _videos.length; i++) {
        if (_videos[i].userId == targetUserId) {
          _videos[i] = _videos[i].copyWith(isFollowing: !_videos[i].isFollowing);
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Upload new video
  Future<String?> uploadVideo({
    required String userId,
    required String username,
    required String userAvatar,
    required String videoPath,
    required String description,
    List<String> hashtags = const [],
    String musicTitle = '',
    String musicArtist = '',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Upload video file
      final videoUrl = await VideoService.uploadVideo(
        File(videoPath),
        userId,
      );

      // Create video post
      final videoId = await VideoService.createVideoPost(
        userId: userId,
        username: username,
        userAvatar: userAvatar,
        videoUrl: videoUrl,
        thumbnailUrl: '', // Will be generated
        description: description,
        hashtags: hashtags,
        musicTitle: musicTitle,
        musicArtist: musicArtist,
      );

      // Refresh videos list
      await loadVideos();

      return videoId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Search videos by hashtag
  Future<void> searchVideosByHashtag(String hashtag) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _videos = await VideoService.searchVideosByHashtag(hashtag);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user's videos
  Future<List<VideoPost>> getUserVideos(String userId) async {
    try {
      return await VideoService.getUserVideos(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh videos
  Future<void> refreshVideos() async {
    _videos.clear();
    _lastDocument = null;
    _hasMore = true;
    await loadVideos();
  }

  // Helper method to get last document
  Future<DocumentSnapshot?> _getLastDocument() async {
    if (_videos.isEmpty) return null;
    
    try {
      final lastVideo = _videos.last;
      final snapshot = await FirebaseFirestore.instance
          .collection('videoPosts')
          .doc(lastVideo.id)
          .get();
      return snapshot;
    } catch (e) {
      return null;
    }
  }
}