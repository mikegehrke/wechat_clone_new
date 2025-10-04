import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LiveLocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // LIVE LOCATION SHARING
  // ============================================================================

  /// Start sharing live location in a chat
  static Future<String> startLiveLocationSharing({
    required String chatId,
    required String userId,
    required String userName,
    int durationMinutes = 60,
  }) async {
    try {
      // Get current position
      final position = await _getCurrentPosition();

      final sessionData = {
        'chatId': chatId,
        'userId': userId,
        'userName': userName,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'startedAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(Duration(minutes: durationMinutes)),
        'isActive': true,
      };

      final docRef = await _firestore.collection('live_locations').add(sessionData);
      
      // Start updating location every 10 seconds
      _startLocationUpdates(docRef.id, userId);
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to start live location: $e');
    }
  }

  /// Update live location
  static Future<void> updateLiveLocation(String sessionId) async {
    try {
      final position = await _getCurrentPosition();

      await _firestore.collection('live_locations').doc(sessionId).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  /// Stop sharing live location
  static Future<void> stopLiveLocationSharing(String sessionId) async {
    try {
      await _firestore.collection('live_locations').doc(sessionId).update({
        'isActive': false,
        'stoppedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to stop live location: $e');
    }
  }

  /// Get all active live locations for a chat
  static Stream<List<Map<String, dynamic>>> getLiveLocationsStream(String chatId) {
    return _firestore
        .collection('live_locations')
        .where('chatId', isEqualTo: chatId)
        .where('isActive', isEqualTo: true)
        .where('expiresAt', isGreaterThan: DateTime.now())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Send static location (one-time)
  static Future<Map<String, double>> getCurrentLocation() async {
    try {
      final position = await _getCurrentPosition();
      
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
      };
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  static Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions permanently denied');
    }

    // Get position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static void _startLocationUpdates(String sessionId, String userId) {
    // Update every 10 seconds
    Stream.periodic(const Duration(seconds: 10)).listen((_) async {
      try {
        final doc = await _firestore.collection('live_locations').doc(sessionId).get();
        
        if (!doc.exists || doc.data()?['isActive'] != true) {
          return; // Stop updating
        }

        await updateLiveLocation(sessionId);
      } catch (e) {
        // Silent fail
      }
    });
  }
}
