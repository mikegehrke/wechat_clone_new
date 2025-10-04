import 'package:cloud_firestore/cloud_firestore.dart';

class ContactService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // CONTACT MANAGEMENT
  // ============================================================================

  /// Add contact
  static Future<void> addContact({
    required String userId,
    required String contactId,
    String? customName,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .set({
        'contactId': contactId,
        'customName': customName,
        'addedAt': FieldValue.serverTimestamp(),
        'isFavorite': false,
        'isBlocked': false,
      });
    } catch (e) {
      throw Exception('Failed to add contact: $e');
    }
  }

  /// Remove contact
  static Future<void> removeContact(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove contact: $e');
    }
  }

  /// Block contact
  static Future<void> blockContact(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .update({'isBlocked': true});
    } catch (e) {
      throw Exception('Failed to block contact: $e');
    }
  }

  /// Unblock contact
  static Future<void> unblockContact(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .update({'isBlocked': false});
    } catch (e) {
      throw Exception('Failed to unblock contact: $e');
    }
  }

  /// Add to favorites
  static Future<void> addToFavorites(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .update({'isFavorite': true});
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  /// Remove from favorites
  static Future<void> removeFromFavorites(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .update({'isFavorite': false});
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  /// Get all contacts
  static Stream<List<Map<String, dynamic>>> getContactsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .where('isBlocked', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get favorite contacts
  static Stream<List<Map<String, dynamic>>> getFavoriteContactsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .where('isFavorite', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Get blocked contacts
  static Stream<List<Map<String, dynamic>>> getBlockedContactsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .where('isBlocked', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Search contacts
  static Future<List<Map<String, dynamic>>> searchContacts({
    required String userId,
    required String query,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('contacts')
          .get();

      final results = snapshot.docs.where((doc) {
        final customName = (doc.data()['customName'] as String? ?? '').toLowerCase();
        return customName.contains(query.toLowerCase());
      }).toList();

      return results.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search contacts: $e');
    }
  }
}
