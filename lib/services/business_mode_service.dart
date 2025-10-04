import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessModeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // BUSINESS ACCOUNT MODE
  // ============================================================================

  /// Create business account
  static Future<void> createBusinessAccount({
    required String userId,
    required String businessName,
    required String category,
    required String description,
    String? logo,
    String? address,
    String? phone,
    String? email,
    String? website,
  }) async {
    try {
      await _firestore.collection('business_accounts').doc(userId).set({
        'userId': userId,
        'businessName': businessName,
        'category': category,
        'description': description,
        'logo': logo,
        'address': address,
        'phone': phone,
        'email': email,
        'website': website,
        'followers': [],
        'followerCount': 0,
        'verified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user type
      await _firestore.collection('users').doc(userId).update({
        'accountType': 'business',
      });
    } catch (e) {
      throw Exception('Failed to create business account: $e');
    }
  }

  /// Update business profile
  static Future<void> updateBusinessProfile({
    required String userId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      if (updates != null) {
        await _firestore
            .collection('business_accounts')
            .doc(userId)
            .update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update business profile: $e');
    }
  }

  /// Get business account
  static Future<Map<String, dynamic>?> getBusinessAccount(String userId) async {
    try {
      final doc = await _firestore
          .collection('business_accounts')
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    } catch (e) {
      return null;
    }
  }

  /// Follow business
  static Future<void> followBusiness(String businessId, String userId) async {
    try {
      await _firestore.collection('business_accounts').doc(businessId).update({
        'followers': FieldValue.arrayUnion([userId]),
        'followerCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to follow business: $e');
    }
  }

  /// Unfollow business
  static Future<void> unfollowBusiness(String businessId, String userId) async {
    try {
      await _firestore.collection('business_accounts').doc(businessId).update({
        'followers': FieldValue.arrayRemove([userId]),
        'followerCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to unfollow business: $e');
    }
  }

  /// Search businesses
  static Future<List<Map<String, dynamic>>> searchBusinesses({
    String? query,
    String? category,
  }) async {
    try {
      var queryRef = _firestore.collection('business_accounts').limit(50);

      if (category != null) {
        queryRef = queryRef.where('category', isEqualTo: category) as Query<Map<String, dynamic>>;
      }

      final snapshot = await queryRef.get();

      var results = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        results = results.where((business) {
          final name = (business['businessName'] as String? ?? '').toLowerCase();
          final desc = (business['description'] as String? ?? '').toLowerCase();
          return name.contains(q) || desc.contains(q);
        }).toList();
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search businesses: $e');
    }
  }

  /// Get business categories
  static List<String> getCategories() {
    return [
      'Restaurant',
      'Retail',
      'Services',
      'Health & Beauty',
      'Entertainment',
      'Education',
      'Technology',
      'Finance',
      'Real Estate',
      'Travel',
      'Other',
    ];
  }

  /// Post business update
  static Future<void> postBusinessUpdate({
    required String businessId,
    required String content,
    List<String>? mediaUrls,
  }) async {
    try {
      await _firestore
          .collection('business_accounts')
          .doc(businessId)
          .collection('updates')
          .add({
        'content': content,
        'mediaUrls': mediaUrls ?? [],
        'likes': [],
        'comments': [],
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to post update: $e');
    }
  }

  /// Get business updates
  static Stream<List<Map<String, dynamic>>> getBusinessUpdatesStream(String businessId) {
    return _firestore
        .collection('business_accounts')
        .doc(businessId)
        .collection('updates')
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
}
