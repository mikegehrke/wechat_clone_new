import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import 'chat_detail_page.dart';
import 'contacts_page_real.dart';
import 'package:intl/intl.dart';

class ChatListPageReal extends StatefulWidget {
  const ChatListPageReal({super.key});

  @override
  State<ChatListPageReal> createState() => _ChatListPageRealState();
}

class _ChatListPageRealState extends State<ChatListPageReal> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF07C160),
        foregroundColor: Colors.white,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text(
                'Chats',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            icon: const Icon(Icons.add),
            onSelected: (value) {
              switch (value) {
                case 'new_chat':
                  _navigateToContacts();
                  break;
                case 'new_group':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New group feature coming soon!'),
                    ),
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
        stream: ChatService.getUserChatsStream(currentUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07C160)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Trigger rebuild
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final allChats = snapshot.data ?? [];

          // Filter chats based on search query
          final chats = _searchController.text.isEmpty
              ? allChats
              : allChats.where((chat) {
                  return chat.name.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  );
                }).toList();

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchController.text.isEmpty
                        ? Icons.chat_bubble_outline
                        : Icons.search_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'No chats yet'
                        : 'No chats found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchController.text.isEmpty
                        ? 'Tap + to start a conversation'
                        : 'Try a different search term',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  if (_searchController.text.isEmpty) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _navigateToContacts,
                      icon: const Icon(Icons.person_add),
                      label: const Text('New Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF07C160),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final hasUnread = chat.unreadCount > 0;

              return _buildChatTile(chat, hasUnread, currentUser.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatTile(Chat chat, bool hasUnread, String currentUserId) {
    // Get chat name (for direct chats, show other user's name)
    String chatName = chat.name;
    if (chat.type == ChatType.direct && chat.participants.length == 2) {
      // For direct chats, we'd need to fetch the other user's name
      // For now, use the chat name as is
      chatName = chat.name.isNotEmpty ? chat.name : 'User';
    }

    // Format last message time
    String timeString = '';
    final now = DateTime.now();
    final diff = now.difference(chat.lastActivity);

    if (diff.inDays > 0) {
      if (diff.inDays == 1) {
        timeString = 'Yesterday';
      } else if (diff.inDays < 7) {
        timeString = DateFormat('EEEE').format(chat.lastActivity);
      } else {
        timeString = DateFormat('dd/MM/yy').format(chat.lastActivity);
      }
    } else if (diff.inHours > 0) {
      timeString = '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      timeString = '${diff.inMinutes}m ago';
    } else {
      timeString = 'Just now';
    }

    // Format last message preview
    String lastMessagePreview = '';
    if (chat.lastMessage != null) {
      if (chat.lastMessage!.type == MessageType.text) {
        lastMessagePreview = chat.lastMessage!.content ?? '';
      } else if (chat.lastMessage!.type == MessageType.image) {
        lastMessagePreview = '📷 Photo';
      } else if (chat.lastMessage!.type == MessageType.voice) {
        lastMessagePreview = '🎤 Voice message';
      } else if (chat.lastMessage!.type == MessageType.file) {
        lastMessagePreview = '📎 File';
      }
    }

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              chatId: chat.id,
              chatName: chatName,
              chatAvatar: chat.avatar,
              isGroup: chat.type == ChatType.group,
            ),
          ),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF07C160),
            backgroundImage: chat.avatar != null
                ? NetworkImage(chat.avatar!)
                : null,
            child: chat.avatar == null
                ? Text(
                    chatName.isNotEmpty ? chatName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          if (chat.type == ChatType.group)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group,
                  size: 16,
                  color: Color(0xFF07C160),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chatName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            timeString,
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
          Expanded(
            child: Text(
              lastMessagePreview,
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xFF07C160),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Text(
                chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
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
    );
  }

  void _navigateToContacts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactsPageReal()),
    );
  }
}
