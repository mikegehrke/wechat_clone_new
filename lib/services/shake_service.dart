import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class ShakeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const double _shakeThreshold = 15.0;
  static StreamSubscription? _accelerometerSubscription;

  // ============================================================================
  // SHAKE TO FIND NEARBY PEOPLE
  // ============================================================================

  /// Start listening for shake
  static void startShakeDetection(Function onShake) {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final force = event.x.abs() + event.y.abs() + event.z.abs();
      
      if (force > _shakeThreshold) {
        onShake();
      }
    });
  }

  /// Stop shake detection
  static void stopShakeDetection() {
    _accelerometerSubscription?.cancel();
  }

  /// Register user as shaking (active for 30 seconds)
  static Future<void> registerShake({
    required String userId,
    required String userName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('shake_users').doc(userId).set({
        'userId': userId,
        'userName': userName,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(seconds: 30)),
      });
    } catch (e) {
      throw Exception('Failed to register shake: $e');
    }
  }

  /// Get nearby shaking users
  static Stream<List<Map<String, dynamic>>> getNearbyShakingUsers({
    required double latitude,
    required double longitude,
    required String currentUserId,
  }) {
    return _firestore
        .collection('shake_users')
        .where('expiresAt', isGreaterThan: DateTime.now())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            
            // Calculate distance (simple approximation)
            final lat = data['latitude'] as double;
            final lon = data['longitude'] as double;
            final distance = _calculateDistance(latitude, longitude, lat, lon);
            data['distance'] = distance;
            
            return data;
          })
          .where((data) => data['distance'] < 1000) // Within 1km
          .toList()
        ..sort((a, b) => a['distance'].compareTo(b['distance']));
    });
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - 
        (lat2 - lat1) * p / 2 + 
        (1 - (lat2 - lat1) * p) * (1 - (lon2 - lon1) * p) / 4;
    return 12742 * 1000 * (a < 0 ? 0 : (a > 1 ? 1 : a)); // in meters
  }
}
