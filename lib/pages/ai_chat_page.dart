import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ai_chat_service.dart';
import 'ai_settings_page.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  AIProvider _currentProvider = AIProvider.openai;

  @override
  void initState() {
    super.initState();
    _loadProvider();
    _addWelcomeMessage();
  }

  Future<void> _loadProvider() async {
    final provider = await AIChatService.getCurrentProvider();
    setState(() {
      _currentProvider = provider;
    });
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': 'Hi! I\'m your AI assistant. I can help you with:\n\n'
            '• Writing messages\n'
            '• Translating text\n'
            '• Answering questions\n'
            '• Generating images (OpenAI only)\n\n'
            'What can I help you with?',
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              AIChatService.getProviderIcon(_currentProvider),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  AIChatService.getProviderName(_currentProvider),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AISettingsPage()),
              );
              _loadProvider();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  setState(() {
                    _messages.clear();
                    _addWelcomeMessage();
                  });
                  break;
                case 'examples':
                  _showExamples();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'examples',
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline),
                    SizedBox(width: 12),
                    Text('Examples'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Clear Chat', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.smart_toy, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Start chatting with AI',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';
                      return _buildMessageBubble(
                        message['content']!,
                        isUser,
                      );
                    },
                  ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          // Quick actions
          _buildQuickActions(),

          // Input
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Color(0xFF07C160)),
                  onPressed: _currentProvider == AIProvider.openai
                      ? _showImageGenerationDialog
                      : null,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ask me anything...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF07C160)),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF07C160) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionChip('✍️ Write', () => _showWriteDialog()),
            _buildQuickActionChip('🌍 Translate', () => _showTranslateDialog()),
            _buildQuickActionChip('✨ Improve', () => _showImproveDialog()),
            if (_currentProvider == AIProvider.openai)
              _buildQuickActionChip('🎨 Generate Image', _showImageGenerationDialog),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: Colors.grey[100],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await AIChatService.chat(
        message: text,
        conversationHistory: _messages.length > 10
            ? _messages.sublist(_messages.length - 10)
            : _messages,
        provider: _currentProvider,
      );

      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Sorry, I encountered an error: $e',
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showWriteDialog() {
    final promptController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: promptController,
              decoration: const InputDecoration(
                hintText: 'What should I write?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prompt = promptController.text.trim();
              if (prompt.isNotEmpty) {
                _messageController.text = 'Write: $prompt';
                _sendMessage();
              }
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showTranslateDialog() {
    final textController = TextEditingController();
    String targetLang = 'German';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Translate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Text to translate',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                _messageController.text = 'Translate to $targetLang: $text';
                _sendMessage();
              }
            },
            child: const Text('Translate'),
          ),
        ],
      ),
    );
  }

  void _showImproveDialog() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Improve Text'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Text to improve',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                _messageController.text = 'Improve: $text';
                _sendMessage();
              }
            },
            child: const Text('Improve'),
          ),
        ],
      ),
    );
  }

  void _showImageGenerationDialog() {
    final promptController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Image'),
        content: TextField(
          controller: promptController,
          decoration: const InputDecoration(
            hintText: 'Describe the image...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prompt = promptController.text.trim();
              if (prompt.isNotEmpty) {
                _messageController.text = 'Generate image: $prompt';
                _sendMessage();
              }
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showExamples() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Example Prompts'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildExample('💬 Writing', [
                'Write a birthday message',
                'Write a professional email',
                'Write a funny joke',
              ]),
              _buildExample('🌍 Translation', [
                'Translate "Hello" to Spanish',
                'How do you say "Thank you" in Japanese?',
              ]),
              _buildExample('📚 Learning', [
                'Explain quantum physics simply',
                'Teach me basic Spanish',
              ]),
              _buildExample('🎨 Creative', [
                'Generate image: sunset over mountains',
                'Write a short poem about love',
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildExample(String category, List<String> examples) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...examples.map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $ex', style: TextStyle(color: Colors.grey[700])),
              )),
        ],
      ),
    );
  }
}
