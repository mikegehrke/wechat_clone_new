import '../services/ai_chat_service.dart';

class TranslationService {
  // ============================================================================
  // IN-CHAT TRANSLATION (using AI)
  // ============================================================================

  /// Translate message
  static Future<String> translateMessage({
    required String text,
    required String targetLanguage,
    AIProvider? provider,
  }) async {
    try {
      return await AIChatService.translate(
        text: text,
        targetLanguage: targetLanguage,
        provider: provider,
      );
    } catch (e) {
      throw Exception('Translation failed: $e');
    }
  }

  /// Auto-detect language
  static Future<String> detectLanguage(String text) async {
    try {
      final response = await AIChatService.chat(
        message: 'What language is this text in? Reply with only the language name: "$text"',
      );
      return response.trim();
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get supported languages
  static List<String> getSupportedLanguages() {
    return [
      'English',
      'German',
      'Spanish',
      'French',
      'Italian',
      'Portuguese',
      'Russian',
      'Chinese',
      'Japanese',
      'Korean',
      'Arabic',
      'Hindi',
      'Turkish',
      'Dutch',
      'Polish',
    ];
  }
}
