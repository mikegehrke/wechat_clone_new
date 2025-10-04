import 'package:cloud_firestore/cloud_firestore.dart';

class MiniProgramsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // MINI PROGRAMS (Apps within WeChat)
  // ============================================================================

  /// Get all available mini programs
  static Future<List<Map<String, dynamic>>> getMiniPrograms() async {
    try {
      final snapshot = await _firestore
          .collection('mini_programs')
          .orderBy('popularity', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get mini programs: $e');
    }
  }

  /// Get recently used mini programs
  static Future<List<Map<String, dynamic>>> getRecentMiniPrograms(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recent_mini_programs')
          .orderBy('lastUsed', descending: true)
          .limit(10)
          .get();

      final programIds = snapshot.docs.map((doc) => doc.id).toList();
      
      if (programIds.isEmpty) return [];

      final programs = await _firestore
          .collection('mini_programs')
          .where(FieldPath.documentId, whereIn: programIds)
          .get();

      return programs.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Launch mini program
  static Future<void> launchMiniProgram({
    required String programId,
    required String userId,
  }) async {
    try {
      // Update recent
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recent_mini_programs')
          .doc(programId)
          .set({
        'lastUsed': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Increment usage count
      await _firestore.collection('mini_programs').doc(programId).update({
        'usageCount': FieldValue.increment(1),
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Search mini programs
  static Future<List<Map<String, dynamic>>> searchMiniPrograms(String query) async {
    try {
      final snapshot = await _firestore
          .collection('mini_programs')
          .orderBy('name')
          .get();

      final results = snapshot.docs.where((doc) {
        final name = (doc.data()['name'] as String? ?? '').toLowerCase();
        final description = (doc.data()['description'] as String? ?? '').toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q) || description.contains(q);
      }).toList();

      return results.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to search mini programs: $e');
    }
  }

  /// Share mini program in chat
  static Future<void> shareMiniProgramInChat({
    required String programId,
    required String chatId,
    required String userId,
  }) async {
    try {
      final program = await _firestore.collection('mini_programs').doc(programId).get();
      
      if (!program.exists) {
        throw Exception('Mini program not found');
      }

      // Send as special message type
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': userId,
        'type': 'mini_program',
        'content': program.data()?['name'],
        'metadata': {
          'programId': programId,
          'name': program.data()?['name'],
          'icon': program.data()?['icon'],
          'description': program.data()?['description'],
        },
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
      });
    } catch (e) {
      throw Exception('Failed to share mini program: $e');
    }
  }

  // ============================================================================
  // SEED DEFAULT MINI PROGRAMS (call once to populate)
  // ============================================================================

  static Future<void> seedDefaultMiniPrograms() async {
    try {
      final programs = [
        {
          'name': 'Food Delivery',
          'description': 'Order food from nearby restaurants',
          'icon': '🍔',
          'category': 'Food',
          'url': '/mini-programs/food-delivery',
          'popularity': 1000,
          'usageCount': 0,
        },
        {
          'name': 'Ride Hailing',
          'description': 'Book a taxi or ride',
          'icon': '🚗',
          'category': 'Transport',
          'url': '/mini-programs/ride-hailing',
          'popularity': 900,
          'usageCount': 0,
        },
        {
          'name': 'Shopping',
          'description': 'Browse and buy products',
          'icon': '🛍️',
          'category': 'E-commerce',
          'url': '/mini-programs/shopping',
          'popularity': 800,
          'usageCount': 0,
        },
        {
          'name': 'Games',
          'description': 'Play mini games with friends',
          'icon': '🎮',
          'category': 'Entertainment',
          'url': '/mini-programs/games',
          'popularity': 700,
          'usageCount': 0,
        },
        {
          'name': 'Bill Payment',
          'description': 'Pay utility bills',
          'icon': '💡',
          'category': 'Utilities',
          'url': '/mini-programs/bill-payment',
          'popularity': 600,
          'usageCount': 0,
        },
        {
          'name': 'Movie Tickets',
          'description': 'Book cinema tickets',
          'icon': '🎬',
          'category': 'Entertainment',
          'url': '/mini-programs/movies',
          'popularity': 500,
          'usageCount': 0,
        },
      ];

      for (var program in programs) {
        await _firestore.collection('mini_programs').add(program);
      }
    } catch (e) {
      // Silent fail if already seeded
    }
  }
}
