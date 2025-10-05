import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wechat_clone_new/models/message.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../models/chat.dart';
import 'chat_detail_page.dart';
import 'create_group_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search chats...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text(
                'Chats',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'new_group':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateGroupPage()),
                  );
                  break;
                case 'new_chat':
                  // TODO: Show contacts to start new chat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select contact feature coming soon!')),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_chat',
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Color(0xFF07C160)),
                    SizedBox(width: 12),
                    Text('New Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'new_group',
                child: Row(
                  children: [
                    Icon(Icons.group_add, color: Color(0xFF07C160)),
                    SizedBox(width: 12),
                    Text('New Group'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Chat>>(
        stream: ChatService.getUserChatsStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final chats = snapshot.data ?? [];
          
          // Filter chats based on search
          final filteredChats = _searchController.text.isEmpty
              ? chats
              : chats.where((chat) {
                  final name = chat.name ?? 'Unknown';
                  return name.toLowerCase().contains(_searchController.text.toLowerCase());
                }).toList();

          if (filteredChats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchController.text.isEmpty
                        ? Icons.chat_bubble_outline
                        : Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'No chats yet'
                        : 'No chats found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchController.text.isEmpty
                        ? 'Start a conversation!'
                        : 'Try a different search term',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredChats.length,
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              final hasUnread = (chat.unreadCount ?? 0) > 0;
              final unreadCount = chat.unreadCount ?? 0;
              
              return Dismissible(
                key: Key(chat.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Chat'),
                      content: const Text('Are you sure you want to delete this chat?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  await ChatService.deleteChat(chat.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chat deleted')),
                    );
                  }
                },
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailPage(chat: chat),
                      ),
                    );
                  },
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: chat.avatar != null 
                            ? NetworkImage(chat.avatar!) 
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: chat.avatar == null
                            ? Text(
                                (chat.name ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      // Online indicator
                      if (chat.isOnline == true)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF07C160),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(chat.lastActivity),
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread ? const Color(0xFF07C160) : Colors.grey[600],
                          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      // Message status icons (for sent messages)
                      if (chat.lastMessage?.senderId == currentUserId)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            chat.lastMessage?.status == 'read'
                                ? Icons.done_all
                                : chat.lastMessage?.status == 'delivered'
                                    ? Icons.done_all
                                    : Icons.done,
                            size: 16,
                            color: chat.lastMessage?.status == 'read'
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          _getLastMessageText(chat),
                          style: TextStyle(
                            fontSize: 14,
                            color: hasUnread ? Colors.black87 : Colors.grey[600],
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF07C160),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show contacts to start new chat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select contact feature coming soon!')),
          );
        },
        backgroundColor: const Color(0xFF07C160),
        child: const Icon(Icons.chat),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][time.weekday - 1];
      return weekday;
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  String _getLastMessageText(Chat chat) {
    if (chat.lastMessage == null) return 'No messages yet';
    
    final message = chat.lastMessage!;
    
    switch (message.type) {
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.voice:
        return '🎤 Voice message';
      case MessageType.file:
        return '📎 File';
      case MessageType.location:
        return '📍 Location';
      default:
        return message.content ?? 'Message';
    }
  }
}
