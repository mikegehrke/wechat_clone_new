import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../models/chat.dart';
import '../models/message.dart';
import 'chat_info_page.dart';
import 'package:intl/intl.dart';

class ChatDetailPage extends StatefulWidget {
  final Chat chat;

  const ChatDetailPage({super.key, required this.chat});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatInfoPage(chat: widget.chat),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.chat.avatar != null
                    ? NetworkImage(widget.chat.avatar!)
                    : null,
                backgroundColor: Colors.grey[300],
                child: widget.chat.avatar == null
                    ? Text(
                        (widget.chat.name ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chat.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.chat.isOnline == true ? 'online' : _getLastSeen(),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.chat.isOnline == true
                            ? const Color(0xFF07C160)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video call coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audio call coming soon!')),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'info':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatInfoPage(chat: widget.chat),
                    ),
                  );
                  break;
                case 'mute':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mute notifications')),
                  );
                  break;
                case 'clear':
                  _showClearChatDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 12),
                    Text('Chat Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(Icons.notifications_off_outlined),
                    SizedBox(width: 12),
                    Text('Mute'),
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
          // Messages list
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: ChatService.getMessagesStream(widget.chat.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Say hi! 👋',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                // Mark messages as read
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ChatService.markMessagesAsRead(widget.chat.id, currentUserId);
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;
                    final showDate = index == messages.length - 1 ||
                        !_isSameDay(message.timestamp, messages[index + 1].timestamp);

                    return Column(
                      children: [
                        if (showDate) _buildDateDivider(message.timestamp),
                        _buildMessageBubble(message, isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'typing...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),

          // Input area
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
                // Attach button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF07C160)),
                  onPressed: () => _showAttachmentOptions(),
                ),
                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Message',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          onPressed: () {
                            // TODO: Show emoji picker
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send/Voice button
                _messageController.text.trim().isEmpty
                    ? IconButton(
                        icon: const Icon(Icons.mic, color: Color(0xFF07C160)),
                        onPressed: () => _recordVoiceMessage(),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF07C160)),
                        onPressed: () => _sendMessage(currentUserId),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDate(date),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageOptions(message, isMe),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF07C160) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMessageContent(message, isMe),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(message.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: isMe ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.status == 'read'
                                ? Icons.done_all
                                : message.status == 'delivered'
                                    ? Icons.done_all
                                    : Icons.done,
                            size: 14,
                            color: message.status == 'read'
                                ? Colors.blue[300]
                                : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(Message message, bool isMe) {
    switch (message.type) {
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.content,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  );
                },
              ),
            ),
            if (message.metadata?['caption'] != null) ...[
              const SizedBox(height: 8),
              Text(
                message.metadata!['caption'],
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ],
        );
      case MessageType.video:
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.videocam, size: 48),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            if (message.metadata?['caption'] != null) ...[
              const SizedBox(height: 8),
              Text(
                message.metadata!['caption'],
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ],
        );
      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color: isMe ? Colors.white : const Color(0xFF07C160),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: isMe ? Colors.white24 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              message.metadata?['duration'] ?? '0:00',
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        );
      case MessageType.file:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file,
              color: isMe ? Colors.white : const Color(0xFF07C160),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.metadata?['filename'] ?? 'File',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message.metadata?['size'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: isMe ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return Text(
          message.content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        );
    }
  }

  Future<void> _sendMessage(String currentUserId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {});

    try {
      await ChatService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUserId,
        content: text,
        type: MessageType.text,
      );

      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Future<void> _showAttachmentOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF07C160)),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF07C160)),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFF07C160)),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Color(0xFF07C160)),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                _pickDocument();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF07C160)),
              title: const Text('Location'),
              onTap: () {
                Navigator.pop(context);
                _shareLocation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF07C160)),
              title: const Text('Contact'),
              onTap: () {
                Navigator.pop(context);
                _shareContact();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id ?? '';

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading image...')),
        );
      }

      // Upload to Firebase Storage
      final imageUrl = await ChatService.uploadFile(
        chatId: widget.chat.id,
        userId: currentUserId,
        file: File(image.path),
        fileName: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Send message
      await ChatService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUserId,
        content: imageUrl,
        type: MessageType.image,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: $e')),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUser?.id ?? '';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading video...')),
        );
      }

      final videoUrl = await ChatService.uploadFile(
        chatId: widget.chat.id,
        userId: currentUserId,
        file: File(video.path),
        fileName: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      await ChatService.sendMessage(
        chatId: widget.chat.id,
        senderId: currentUserId,
        content: videoUrl,
        type: MessageType.video,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send video: $e')),
        );
      }
    }
  }

  Future<void> _pickDocument() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document picker coming soon!')),
    );
  }

  Future<void> _shareLocation() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location sharing coming soon!')),
    );
  }

  Future<void> _shareContact() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact sharing coming soon!')),
    );
  }

  Future<void> _recordVoiceMessage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording coming soon!')),
    );
  }

  void _showMessageOptions(Message message, bool isMe) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            if (message.type == MessageType.text)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Copy to clipboard
                },
              ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Reply to message
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward),
              title: const Text('Forward'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Forward message
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_outline),
              title: const Text('Star'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Star message
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete for everyone', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message, forEveryone: true);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete for me', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(message, forEveryone: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMessage(Message message, {required bool forEveryone}) async {
    try {
      await ChatService.deleteMessage(
        chatId: widget.chat.id,
        messageId: message.id,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: $e')),
        );
      }
    }
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await ChatService.clearChat(widget.chat.id, authProvider.user?.id ?? '');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat cleared')),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getLastSeen() {
    if (widget.chat.lastSeen == null) return '';
    
    final now = DateTime.now();
    final diff = now.difference(widget.chat.lastSeen!);
    
    if (diff.inMinutes < 1) return 'last seen just now';
    if (diff.inMinutes < 60) return 'last seen ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'last seen ${diff.inHours}h ago';
    
    return 'last seen ${DateFormat('dd/MM/yyyy').format(widget.chat.lastSeen!)}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
