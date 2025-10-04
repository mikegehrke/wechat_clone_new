import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum AIProvider { openai, gemini }

class AIChatService {
  // API Keys
  static const String _openAIKey = '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';
  static String _geminiKey = 'AIzaSyD9hJuD7Tw3NI0wssQkC9PUqdTZ0yymGwo'; // Gemini API Key
  
  static const String _openAIBaseUrl = 'https://api.openai.com/v1';
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // ============================================================================
  // SETTINGS
  // ============================================================================

  /// Get current AI provider
  static Future<AIProvider> getCurrentProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final providerString = prefs.getString('ai_provider') ?? 'openai';
    return providerString == 'gemini' ? AIProvider.gemini : AIProvider.openai;
  }

  /// Set AI provider
  static Future<void> setProvider(AIProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_provider', provider.toString().split('.').last);
  }

  /// Set Gemini API Key
  static Future<void> setGeminiKey(String key) async {
    _geminiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
  }

  /// Load Gemini Key
  static Future<void> loadGeminiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _geminiKey = prefs.getString('gemini_api_key') ?? '';
  }

  /// Check if Gemini is configured
  static bool isGeminiConfigured() {
    return _geminiKey.isNotEmpty;
  }

  // ============================================================================
  // CHAT - TEXT GENERATION
  // ============================================================================

  /// Generate text response (uses selected provider)
  static Future<String> chat({
    required String message,
    List<Map<String, String>>? conversationHistory,
    AIProvider? provider,
  }) async {
    await loadGeminiKey();
    provider ??= await getCurrentProvider();

    if (provider == AIProvider.openai) {
      return _chatOpenAI(message, conversationHistory);
    } else {
      return _chatGemini(message, conversationHistory);
    }
  }

  /// OpenAI Chat
  static Future<String> _chatOpenAI(
    String message,
    List<Map<String, String>>? history,
  ) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content': 'You are a helpful AI assistant. Be concise and friendly.',
        },
        if (history != null) ...history,
        {'role': 'user', 'content': message},
      ];

      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_openAIKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('OpenAI failed: $e');
    }
  }

  /// Gemini Chat
  static Future<String> _chatGemini(
    String message,
    List<Map<String, String>>? history,
  ) async {
    if (_geminiKey.isEmpty) {
      throw Exception('Gemini API key not set');
    }

    try {
      // Build conversation history for Gemini
      final contents = <Map<String, dynamic>>[];
      
      if (history != null) {
        for (var msg in history) {
          contents.add({
            'role': msg['role'] == 'user' ? 'user' : 'model',
            'parts': [
              {'text': msg['content']}
            ],
          });
        }
      }
      
      contents.add({
        'role': 'user',
        'parts': [
          {'text': message}
        ],
      });

      final response = await http.post(
        Uri.parse('$_geminiBaseUrl/models/gemini-pro:generateContent?key=$_geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Gemini API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gemini failed: $e');
    }
  }

  // ============================================================================
  // SMART REPLIES
  // ============================================================================

  /// Suggest 3 quick replies
  static Future<List<String>> suggestReplies({
    required String lastMessage,
    AIProvider? provider,
  }) async {
    try {
      final prompt = 'Given this message: "$lastMessage"\nSuggest 3 short, natural reply options (max 10 words each). Format: one per line.';
      
      final response = await chat(
        message: prompt,
        provider: provider,
      );

      return response
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .take(3)
          .map((line) => line.replaceAll(RegExp(r'^[\d\.\-\*]\s*'), '').trim())
          .toList();
    } catch (e) {
      // Fallback replies
      return [
        'Thanks! 👍',
        'Sounds good!',
        'Tell me more',
      ];
    }
  }

  // ============================================================================
  // TEXT WRITING ASSISTANT
  // ============================================================================

  /// Write message for user
  static Future<String> writeMessage({
    required String prompt,
    String tone = 'friendly',
    String length = 'medium',
    AIProvider? provider,
  }) async {
    final instruction = 'Write a $tone, $length message: $prompt';
    return await chat(message: instruction, provider: provider);
  }

  /// Improve text
  static Future<String> improveText({
    required String text,
    AIProvider? provider,
  }) async {
    final prompt = 'Improve this text (fix grammar, make it clearer): "$text"';
    return await chat(message: prompt, provider: provider);
  }

  /// Translate
  static Future<String> translate({
    required String text,
    required String targetLanguage,
    AIProvider? provider,
  }) async {
    final prompt = 'Translate to $targetLanguage: "$text"';
    return await chat(message: prompt, provider: provider);
  }

  /// Summarize
  static Future<String> summarize({
    required String text,
    AIProvider? provider,
  }) async {
    final prompt = 'Summarize this: "$text"';
    return await chat(message: prompt, provider: provider);
  }

  // ============================================================================
  // IMAGE GENERATION (OpenAI only)
  // ============================================================================

  /// Generate image from text (DALL-E)
  static Future<String> generateImage({
    required String prompt,
    String size = '1024x1024',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_openAIBaseUrl/images/generations'),
        headers: {
          'Authorization': 'Bearer $_openAIKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': prompt,
          'n': 1,
          'size': size,
          'quality': 'standard',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'][0]['url'];
      } else {
        throw Exception('Image generation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to generate image: $e');
    }
  }

  // ============================================================================
  // CONTEXT-AWARE CHAT SUGGESTIONS
  // ============================================================================

  /// Analyze chat and suggest actions
  static Future<Map<String, dynamic>> analyzeChatContext({
    required List<Map<String, String>> messages,
    AIProvider? provider,
  }) async {
    try {
      final chatHistory = messages
          .map((m) => '${m['role']}: ${m['content']}')
          .join('\n');

      final prompt = '''Analyze this conversation and suggest:
1. A smart reply
2. A follow-up question
3. An action (if needed)

Conversation:
$chatHistory

Format your response as:
Reply: [suggestion]
Question: [suggestion]
Action: [suggestion or "none"]''';

      final response = await chat(message: prompt, provider: provider);

      // Parse response
      final lines = response.split('\n');
      return {
        'reply': _extractValue(lines, 'Reply:'),
        'question': _extractValue(lines, 'Question:'),
        'action': _extractValue(lines, 'Action:'),
      };
    } catch (e) {
      return {
        'reply': 'Thanks for sharing!',
        'question': 'What do you think?',
        'action': 'none',
      };
    }
  }

  static String _extractValue(List<String> lines, String prefix) {
    for (var line in lines) {
      if (line.startsWith(prefix)) {
        return line.substring(prefix.length).trim();
      }
    }
    return '';
  }

  // ============================================================================
  // PROVIDER INFO
  // ============================================================================

  static String getProviderName(AIProvider provider) {
    return provider == AIProvider.openai ? 'ChatGPT (OpenAI)' : 'Gemini (Google)';
  }

  static String getProviderIcon(AIProvider provider) {
    return provider == AIProvider.openai ? '🤖' : '✨';
  }
}
