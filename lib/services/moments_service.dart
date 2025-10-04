import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MomentsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================================
  // MOMENTS (WeChat Social Feed)
  // ============================================================================

  /// Post a moment
  static Future<String> postMoment({
    required String userId,
    required String userName,
    String? text,
    List<String>? mediaUrls,
    String? location,
    List<String>? visibleTo,
  }) async {
    try {
      final momentData = {
        'userId': userId,
        'userName': userName,
        'text': text,
        'mediaUrls': mediaUrls ?? [],
        'location': location,
        'visibleTo': visibleTo ?? [], // Empty = visible to all contacts
        'likes': [],
        'comments': [],
        'timestamp': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('moments').add(momentData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to post moment: $e');
    }
  }

  /// Upload moment media
  static Future<List<String>> uploadMomentMedia(List<File> files) async {
    try {
      final urls = <String>[];
      
      for (var file in files) {
        final filename = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final ref = _storage.ref().child('moments/$filename');
        
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      throw Exception('Failed to upload moment media: $e');
    }
  }

  /// Get moments feed (contacts only)
  static Stream<List<Map<String, dynamic>>> getMomentsStream(String userId) {
    return _firestore
        .collection('moments')
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

  /// Like a moment
  static Future<void> likeMoment(String momentId, String userId) async {
    try {
      await _firestore.collection('moments').doc(momentId).update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Failed to like moment: $e');
    }
  }

  /// Unlike a moment
  static Future<void> unlikeMoment(String momentId, String userId) async {
    try {
      await _firestore.collection('moments').doc(momentId).update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Failed to unlike moment: $e');
    }
  }

  /// Comment on moment
  static Future<void> commentOnMoment({
    required String momentId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    try {
      await _firestore.collection('moments').doc(momentId).update({
        'comments': FieldValue.arrayUnion([
          {
            'userId': userId,
            'userName': userName,
            'comment': comment,
            'timestamp': FieldValue.serverTimestamp(),
          }
        ]),
      });
    } catch (e) {
      throw Exception('Failed to comment: $e');
    }
  }

  /// Delete moment
  static Future<void> deleteMoment(String momentId, String userId) async {
    try {
      final doc = await _firestore.collection('moments').doc(momentId).get();
      
      if (!doc.exists) {
        throw Exception('Moment not found');
      }

      if (doc.data()?['userId'] != userId) {
        throw Exception('Not authorized');
      }

      await _firestore.collection('moments').doc(momentId).delete();
    } catch (e) {
      throw Exception('Failed to delete moment: $e');
    }
  }
}
