import 'package:cloud_firestore/cloud_firestore.dart';

class StickerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // STICKER PACKS
  // ============================================================================

  /// Get all available sticker packs
  static Future<List<Map<String, dynamic>>> getStickerPacks() async {
    try {
      final snapshot = await _firestore
          .collection('sticker_packs')
          .orderBy('popularity', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get sticker packs: $e');
    }
  }

  /// Get user's purchased/owned sticker packs
  static Future<List<Map<String, dynamic>>> getUserStickerPacks(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final ownedPackIds = List<String>.from(userDoc.data()?['ownedStickerPacks'] ?? []);

      if (ownedPackIds.isEmpty) return [];

      final packs = await _firestore
          .collection('sticker_packs')
          .where(FieldPath.documentId, whereIn: ownedPackIds)
          .get();

      return packs.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get stickers in a pack
  static Future<List<Map<String, dynamic>>> getStickersInPack(String packId) async {
    try {
      final snapshot = await _firestore
          .collection('sticker_packs')
          .doc(packId)
          .collection('stickers')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get stickers: $e');
    }
  }

  /// Purchase/Download sticker pack
  static Future<void> downloadStickerPack(String packId, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'ownedStickerPacks': FieldValue.arrayUnion([packId]),
      });

      // Increment download count
      await _firestore.collection('sticker_packs').doc(packId).update({
        'downloads': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to download sticker pack: $e');
    }
  }

  /// Send sticker in chat
  static Future<void> sendSticker({
    required String chatId,
    required String userId,
    required String stickerUrl,
    required String stickerPackId,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': userId,
        'type': 'sticker',
        'content': stickerUrl,
        'metadata': {
          'packId': stickerPackId,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent',
        'readBy': [],
      });

      // Update last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': '🎭 Sticker',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': userId,
      });
    } catch (e) {
      throw Exception('Failed to send sticker: $e');
    }
  }

  // ============================================================================
  // SEED DEFAULT STICKERS
  // ============================================================================

  static Future<void> seedDefaultStickerPacks() async {
    try {
      final packs = [
        {
          'name': 'Emotions',
          'description': 'Express your feelings',
          'thumbnail': '😀',
          'price': 0.0,
          'isFree': true,
          'popularity': 1000,
          'downloads': 0,
        },
        {
          'name': 'Animals',
          'description': 'Cute animal stickers',
          'thumbnail': '🐶',
          'price': 1.99,
          'isFree': false,
          'popularity': 800,
          'downloads': 0,
        },
        {
          'name': 'Food',
          'description': 'Yummy food stickers',
          'thumbnail': '🍕',
          'price': 1.99,
          'isFree': false,
          'popularity': 700,
          'downloads': 0,
        },
      ];

      for (var pack in packs) {
        final packRef = await _firestore.collection('sticker_packs').add(pack);
        
        // Add sample stickers
        final sampleStickers = ['😀', '😂', '🥰', '😎', '🤔', '😴', '🎉', '👍'];
        for (var emoji in sampleStickers) {
          await packRef.collection('stickers').add({
            'url': emoji,
            'name': emoji,
          });
        }
      }
    } catch (e) {
      // Silent fail if already seeded
    }
  }
}
