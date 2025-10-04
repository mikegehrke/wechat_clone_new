import 'package:cloud_firestore/cloud_firestore.dart';

class VoiceRoomService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // VOICE ROOMS (Clubhouse-style)
  // ============================================================================

  /// Create voice room
  static Future<String> createVoiceRoom({
    required String userId,
    required String userName,
    required String title,
    required String description,
    int maxParticipants = 50,
    bool isPublic = true,
  }) async {
    try {
      final roomData = {
        'hostId': userId,
        'hostName': userName,
        'title': title,
        'description': description,
        'maxParticipants': maxParticipants,
        'isPublic': isPublic,
        'participants': [userId],
        'speakers': [userId],
        'listeners': <String>[],
        'raisedHands': <String>[],
        'participantCount': 1,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('voice_rooms').add(roomData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create voice room: $e');
    }
  }

  /// Join voice room
  static Future<void> joinVoiceRoom(String roomId, String userId) async {
    try {
      await _firestore.collection('voice_rooms').doc(roomId).update({
        'participants': FieldValue.arrayUnion([userId]),
        'listeners': FieldValue.arrayUnion([userId]),
        'participantCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to join voice room: $e');
    }
  }

  /// Leave voice room
  static Future<void> leaveVoiceRoom(String roomId, String userId) async {
    try {
      await _firestore.collection('voice_rooms').doc(roomId).update({
        'participants': FieldValue.arrayRemove([userId]),
        'speakers': FieldValue.arrayRemove([userId]),
        'listeners': FieldValue.arrayRemove([userId]),
        'raisedHands': FieldValue.arrayRemove([userId]),
        'participantCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to leave voice room: $e');
    }
  }

  /// Raise hand
  static Future<void> raiseHand(String roomId, String userId) async {
    try {
      await _firestore.collection('voice_rooms').doc(roomId).update({
        'raisedHands': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Failed to raise hand: $e');
    }
  }

  /// Invite to speak
  static Future<void> inviteToSpeak(String roomId, String userId) async {
    try {
      await _firestore.collection('voice_rooms').doc(roomId).update({
        'speakers': FieldValue.arrayUnion([userId]),
        'listeners': FieldValue.arrayRemove([userId]),
        'raisedHands': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Failed to invite to speak: $e');
    }
  }

  /// Remove speaker
  static Future<void> removeSpeaker(String roomId, String userId) async {
    try {
      await _firestore.collection('voice_rooms').doc(roomId).update({
        'speakers': FieldValue.arrayRemove([userId]),
        'listeners': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Failed to remove speaker: $e');
    }
  }

  /// End voice room
  static Future<void> endVoiceRoom(String roomId) async {
    try {
      await _firestore.collection('voice_rooms').doc(roomId).update({
        'isActive': false,
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to end voice room: $e');
    }
  }

  /// Get active voice rooms
  static Stream<List<Map<String, dynamic>>> getActiveRoomsStream() {
    return _firestore
        .collection('voice_rooms')
        .where('isActive', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .orderBy('participantCount', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get voice room details
  static Stream<Map<String, dynamic>> getVoiceRoomStream(String roomId) {
    return _firestore
        .collection('voice_rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    });
  }
}
