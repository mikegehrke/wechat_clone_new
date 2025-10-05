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
      final filename =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
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
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              expiresAt:
                  (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
            return b.statuses.first.timestamp.compareTo(
              a.statuses.first.timestamp,
            );
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
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              expiresAt:
                  (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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

  // ============================================================================
  // ADDITIONAL STATUS FEATURES
  // ============================================================================

  /// Post text-only status with custom styling
  static Future<String> postTextStatus({
    required String userId,
    required String userName,
    required String content,
    String? backgroundColor,
    String? textColor,
    String? fontStyle,
  }) async {
    try {
      final statusData = {
        'userId': userId,
        'userName': userName,
        'type': 'text',
        'content': content,
        'backgroundColor': backgroundColor ?? '#4CAF50',
        'textColor': textColor ?? '#FFFFFF',
        'fontStyle': fontStyle ?? 'normal',
        'timestamp': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(hours: 24)),
        'views': [],
      };

      final docRef = await _firestore.collection('statuses').add(statusData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to post text status: $e');
    }
  }

  /// Get status views/viewers
  static Future<List<Map<String, dynamic>>> getStatusViewers(String statusId) async {
    try {
      final statusDoc = await _firestore.collection('statuses').doc(statusId).get();
      
      if (!statusDoc.exists) {
        throw Exception('Status not found');
      }

      final views = List<String>.from(statusDoc.data()?['views'] ?? []);
      final viewers = <Map<String, dynamic>>[];

      // Get viewer details (in batches of 10 due to Firestore limit)
      for (var i = 0; i < views.length; i += 10) {
        final batch = views.skip(i).take(10).toList();
        final usersSnapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (var userDoc in usersSnapshot.docs) {
          final userData = userDoc.data();
          viewers.add({
            'userId': userDoc.id,
            'userName': userData['username'] ?? 'Unknown',
            'avatarUrl': userData['avatarUrl'],
          });
        }
      }

      return viewers;
    } catch (e) {
      throw Exception('Failed to get status viewers: $e');
    }
  }

  /// Get status by ID
  static Future<Status?> getStatusById(String statusId) async {
    try {
      final doc = await _firestore.collection('statuses').doc(statusId).get();
      
      if (!doc.exists) return null;

      final data = doc.data()!;
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
    } catch (e) {
      throw Exception('Failed to get status: $e');
    }
  }

  /// Update status privacy
  static Future<void> updateStatusPrivacy(String statusId, List<String> allowedViewers) async {
    try {
      await _firestore.collection('statuses').doc(statusId).update({
        'allowedViewers': allowedViewers,
        'privacy': 'custom',
      });
    } catch (e) {
      throw Exception('Failed to update status privacy: $e');
    }
  }

  /// Get statuses with privacy filter
  static Stream<List<StatusGroup>> getFilteredStatusesStream(String userId, {String privacy = 'all'}) {
    Query query = _firestore
        .collection('statuses')
        .where('expiresAt', isGreaterThan: DateTime.now());

    // Apply privacy filter
    switch (privacy) {
      case 'contacts':
        // This would need to be implemented with user's contact list
        break;
      case 'close_friends':
        query = query.where('privacy', isEqualTo: 'close_friends');
        break;
      case 'public':
        query = query.where('privacy', isEqualTo: 'public');
        break;
    }

    return query
        .orderBy('expiresAt', descending: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final Map<String, List<Status>> groupedStatuses = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Check if user is allowed to view this status
        final allowedViewers = List<String>.from(data['allowedViewers'] ?? []);
        if (allowedViewers.isNotEmpty && !allowedViewers.contains(userId)) {
          continue; // Skip this status
        }

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

      groups.sort((a, b) {
        if (a.isViewed != b.isViewed) {
          return a.isViewed ? 1 : -1;
        }
        return b.statuses.first.timestamp.compareTo(a.statuses.first.timestamp);
      });

      return groups;
    });
  }

  /// Reply to status (like a comment)
  static Future<void> replyToStatus(String statusId, String userId, String userName, String reply) async {
    try {
      await _firestore
          .collection('statuses')
          .doc(statusId)
          .collection('replies')
          .add({
        'userId': userId,
        'userName': userName,
        'reply': reply,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reply to status: $e');
    }
  }

  /// Get status replies
  static Stream<List<Map<String, dynamic>>> getStatusReplies(String statusId) {
    return _firestore
        .collection('statuses')
        .doc(statusId)
        .collection('replies')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get status analytics (for business accounts)
  static Future<Map<String, dynamic>> getStatusAnalytics(String userId, {int days = 7}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      
      final statusesSnapshot = await _firestore
          .collection('statuses')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(startDate))
          .get();

      int totalViews = 0;
      int totalStatuses = statusesSnapshot.docs.length;
      Map<String, int> typeBreakdown = {'image': 0, 'video': 0, 'text': 0};
      
      for (var doc in statusesSnapshot.docs) {
        final data = doc.data();
        final views = List<String>.from(data['views'] ?? []);
        totalViews += views.length;
        
        final type = data['type'] ?? 'text';
        typeBreakdown[type] = (typeBreakdown[type] ?? 0) + 1;
      }

      return {
        'totalStatuses': totalStatuses,
        'totalViews': totalViews,
        'averageViews': totalStatuses > 0 ? (totalViews / totalStatuses).round() : 0,
        'typeBreakdown': typeBreakdown,
        'period': '$days days',
      };
    } catch (e) {
      throw Exception('Failed to get status analytics: $e');
    }
  }
}
