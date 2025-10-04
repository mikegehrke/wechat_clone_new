import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatThemeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // CHAT THEMES & WALLPAPERS
  // ============================================================================

  /// Set chat wallpaper
  static Future<void> setChatWallpaper({
    required String chatId,
    required String userId,
    required String wallpaperUrl,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_settings')
          .doc(chatId)
          .set({
        'wallpaper': wallpaperUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to set wallpaper: $e');
    }
  }

  /// Get chat wallpaper
  static Future<String?> getChatWallpaper({
    required String chatId,
    required String userId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_settings')
          .doc(chatId)
          .get();

      return doc.data()?['wallpaper'];
    } catch (e) {
      return null;
    }
  }

  /// Get default wallpapers
  static List<String> getDefaultWallpapers() {
    return [
      'https://picsum.photos/800/1600?random=1',
      'https://picsum.photos/800/1600?random=2',
      'https://picsum.photos/800/1600?random=3',
      'https://picsum.photos/800/1600?random=4',
      'https://picsum.photos/800/1600?random=5',
    ];
  }

  /// Set bubble style
  static Future<void> setBubbleStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bubble_style', style);
  }

  /// Get bubble style
  static Future<String> getBubbleStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bubble_style') ?? 'rounded';
  }

  /// Get bubble styles
  static List<String> getBubbleStyles() {
    return ['rounded', 'square', 'ios', 'material'];
  }
}
