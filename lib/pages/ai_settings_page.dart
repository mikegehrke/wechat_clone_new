import 'package:flutter/material.dart';
import '../services/ai_chat_service.dart';

class AISettingsPage extends StatefulWidget {
  const AISettingsPage({super.key});

  @override
  State<AISettingsPage> createState() => _AISettingsPageState();
}

class _AISettingsPageState extends State<AISettingsPage> {
  AIProvider _selectedProvider = AIProvider.openai;
  final TextEditingController _geminiKeyController = TextEditingController();
  bool _isGeminiConfigured = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final provider = await AIChatService.getCurrentProvider();
    await AIChatService.loadGeminiKey();
    setState(() {
      _selectedProvider = provider;
      _isGeminiConfigured = AIChatService.isGeminiConfigured();
    });
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Settings',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: [
          // Provider selection
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Provider',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose which AI model to use',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // OpenAI option
          RadioListTile<AIProvider>(
            value: AIProvider.openai,
            groupValue: _selectedProvider,
            onChanged: (value) async {
              if (value != null) {
                setState(() {
                  _selectedProvider = value;
                });
                await AIChatService.setProvider(value);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Switched to ChatGPT (OpenAI)')),
                  );
                }
              }
            },
            activeColor: const Color(0xFF07C160),
            title: Row(
              children: [
                const Text('🤖', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                const Text(
                  'ChatGPT (OpenAI)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text('• GPT-4 Model'),
                  Text('• Image generation (DALL-E)'),
                  Text('• Advanced reasoning'),
                  Text('✓ API Key configured'),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Gemini option
          RadioListTile<AIProvider>(
            value: AIProvider.gemini,
            groupValue: _selectedProvider,
            onChanged: _isGeminiConfigured
                ? (value) async {
                    if (value != null) {
                      setState(() {
                        _selectedProvider = value;
                      });
                      await AIChatService.setProvider(value);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Switched to Gemini (Google)')),
                        );
                      }
                    }
                  }
                : null,
            activeColor: const Color(0xFF07C160),
            title: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                const Text(
                  'Gemini (Google)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text('• Gemini Pro Model'),
                  const Text('• Free 60 requests/minute'),
                  const Text('• Multilingual support'),
                  const SizedBox(height: 4),
                  if (!_isGeminiConfigured)
                    Text(
                      '⚠️ API Key not configured',
                      style: TextStyle(color: Colors.orange[700]),
                    )
                  else
                    const Text(
                      '✓ API Key configured',
                      style: TextStyle(color: Colors.green),
                    ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 24),

          // Gemini API Key setup
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gemini API Key',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isGeminiConfigured
                      ? 'Your Gemini API key is configured.'
                      : 'Set up your Google Gemini API key to use Gemini AI.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                if (!_isGeminiConfigured) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'How to get Gemini API Key:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('1. Go to: makersuite.google.com/app/apikey'),
                        const Text('2. Click "Get API Key"'),
                        const Text('3. Create/select a project'),
                        const Text('4. Copy your API key'),
                        const Text('5. Paste it below'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _geminiKeyController,
                  decoration: InputDecoration(
                    labelText: 'Gemini API Key',
                    hintText: _isGeminiConfigured ? '••••••••••••' : 'AIzaSy...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: _saveGeminiKey,
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 8),

                if (_isGeminiConfigured)
                  TextButton.icon(
                    onPressed: () {
                      _geminiKeyController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Change API Key'),
                  )
                else
                  ElevatedButton(
                    onPressed: _saveGeminiKey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF07C160),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Save API Key'),
                  ),
              ],
            ),
          ),

          const Divider(height: 32),

          // Info section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About AI Providers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  '🤖 ChatGPT (OpenAI)',
                  'Most advanced AI model. Includes image generation with DALL-E 3. Great for creative tasks and complex reasoning.',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  '✨ Gemini (Google)',
                  'Free and fast AI model. 60 requests per minute at no cost. Excellent multilingual support. Requires your own API key.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGeminiKey() async {
    final key = _geminiKeyController.text.trim();
    
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an API key')),
      );
      return;
    }

    if (!key.startsWith('AIza')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Gemini API key format')),
      );
      return;
    }

    try {
      await AIChatService.setGeminiKey(key);
      setState(() {
        _isGeminiConfigured = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gemini API key saved successfully! ✓'),
            backgroundColor: Colors.green,
          ),
        );
        _geminiKeyController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save key: $e')),
        );
      }
    }
  }
}
