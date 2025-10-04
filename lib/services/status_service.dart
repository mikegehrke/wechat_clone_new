import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/status.dart';

class StatusService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================================
  // STATUS/STORIES
  // ============================================================================

  /// Post a new status (image, video, or text)
  static Future<String> postStatus({
    required String userId,
    required String userName,
    required StatusType type,
    String? content,
    String? mediaUrl,
    String? caption,
    String? backgroundColor,
    String? textColor,
  }) async {
    try {
      final statusData = {
        'userId': userId,
        'userName': userName,
        'type': type.toString().split('.').last,
        'content': content,
        'mediaUrl': mediaUrl,
        'caption': caption,
        'backgroundColor': backgroundColor,
        'textColor': textColor,
        'timestamp': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(hours: 24)),
        'views': [],
      };

      final docRef = await _firestore.collection('statuses').add(statusData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to post status: $e');
    }
  }

  /// Upload status media (image/video)
  static Future<String> uploadStatusMedia(File file, String type) async {
    try {
      final filename = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child('status/$type/$filename');
      
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload status media: $e');
    }
  }

  /// Get all statuses (contacts only)
  static Stream<List<StatusGroup>> getStatusesStream(String userId) {
    return _firestore
        .collection('statuses')
        .where('expiresAt', isGreaterThan: DateTime.now())
        .orderBy('expiresAt', descending: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      // Group statuses by user
      final Map<String, List<Status>> groupedStatuses = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = Status(
          id: doc.id,
          userId: data['userId'],
          userName: data['userName'],
          type: _parseStatusType(data['type']),
          content: data['content'],
          mediaUrl: data['mediaUrl'],
          caption: data['caption'],
          backgroundColor: data['backgroundColor'],
          textColor: data['textColor'],
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          views: List<String>.from(data['views'] ?? []),
        );

        if (groupedStatuses.containsKey(status.userId)) {
          groupedStatuses[status.userId]!.add(status);
        } else {
          groupedStatuses[status.userId] = [status];
        }
      }

      // Convert to StatusGroup list
      final groups = groupedStatuses.entries.map((entry) {
        final statuses = entry.value;
        statuses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        return StatusGroup(
          userId: entry.key,
          userName: statuses.first.userName,
          statuses: statuses,
          isViewed: statuses.every((s) => s.views.contains(userId)),
        );
      }).toList();

      // Sort: unviewed first, then by latest status
      groups.sort((a, b) {
        if (a.isViewed != b.isViewed) {
          return a.isViewed ? 1 : -1;
        }
        return b.statuses.first.timestamp.compareTo(a.statuses.first.timestamp);
      });

      return groups;
    });
  }

  /// Mark status as viewed
  static Future<void> viewStatus(String statusId, String userId) async {
    try {
      await _firestore.collection('statuses').doc(statusId).update({
        'views': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Failed to mark status as viewed: $e');
    }
  }

  /// Delete status
  static Future<void> deleteStatus(String statusId) async {
    try {
      await _firestore.collection('statuses').doc(statusId).delete();
    } catch (e) {
      throw Exception('Failed to delete status: $e');
    }
  }

  /// Get my statuses
  static Stream<List<Status>> getMyStatusesStream(String userId) {
    return _firestore
        .collection('statuses')
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isGreaterThan: DateTime.now())
        .orderBy('expiresAt', descending: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Status(
          id: doc.id,
          userId: data['userId'],
          userName: data['userName'],
          type: _parseStatusType(data['type']),
          content: data['content'],
          mediaUrl: data['mediaUrl'],
          caption: data['caption'],
          backgroundColor: data['backgroundColor'],
          textColor: data['textColor'],
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          views: List<String>.from(data['views'] ?? []),
        );
      }).toList();
    });
  }

  /// Auto-delete expired statuses (call periodically)
  static Future<void> cleanupExpiredStatuses() async {
    try {
      final snapshot = await _firestore
          .collection('statuses')
          .where('expiresAt', isLessThan: DateTime.now())
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Silent fail
    }
  }

  static StatusType _parseStatusType(String? type) {
    switch (type) {
      case 'image':
        return StatusType.image;
      case 'video':
        return StatusType.video;
      case 'text':
        return StatusType.text;
      default:
        return StatusType.text;
    }
  }
}

// ============================================================================
// MODELS
// ============================================================================

enum StatusType { image, video, text }

class Status {
  final String id;
  final String userId;
  final String userName;
  final StatusType type;
  final String? content;
  final String? mediaUrl;
  final String? caption;
  final String? backgroundColor;
  final String? textColor;
  final DateTime timestamp;
  final DateTime expiresAt;
  final List<String> views;

  Status({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    this.content,
    this.mediaUrl,
    this.caption,
    this.backgroundColor,
    this.textColor,
    required this.timestamp,
    required this.expiresAt,
    required this.views,
  });
}

class StatusGroup {
  final String userId;
  final String userName;
  final List<Status> statuses;
  final bool isViewed;

  StatusGroup({
    required this.userId,
    required this.userName,
    required this.statuses,
    required this.isViewed,
  });
}
