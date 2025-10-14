import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wechat_clone_new/models/message.dart';
import 'package:wechat_clone_new/pages/contacts_page.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../models/chat.dart';
import 'chat_detail_page.dart';
import 'create_group_page.dart';
import 'debug_test_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showArchived = false;
  bool _showOnlyUnread = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.id ?? '';

    // If not logged in, show message
    if (currentUserId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please login to see chats')),
      );
    }

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
          if (!_isSearching)
            IconButton(
              icon: Icon(
                _showOnlyUnread ? Icons.mark_chat_read : Icons.mark_chat_unread,
                color: _showOnlyUnread ? const Color(0xFF07C160) : null,
              ),
              onPressed: () {
                setState(() {
                  _showOnlyUnread = !_showOnlyUnread;
                });
              },
              tooltip: _showOnlyUnread ? 'Show all chats' : 'Show only unread',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'new_group':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGroupPage(),
                    ),
                  );
                  break;
                case 'new_chat':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactsPage(),
                    ),
                  );
                  break;
                case 'debug':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DebugTestPage(),
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
              const PopupMenuItem(
                value: 'debug',
                child: Row(
                  children: [
                    Icon(Icons.bug_report, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('🧪 Debug & Test'),
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];

          // Separate chats by type
          final pinnedChats = chats
              .where((c) => c.isPinned && !c.isArchived)
              .toList();
          final normalChats = chats
              .where((c) => !c.isPinned && !c.isArchived)
              .toList();
          final archivedChats = chats.where((c) => c.isArchived).toList();

          // Combine for display
          final displayChats = _showArchived
              ? archivedChats
              : [...pinnedChats, ...normalChats];

          // Filter chats based on search and unread filter
          final filteredChats = displayChats.where((chat) {
            // Search filter
            if (_searchController.text.isNotEmpty) {
              if (!chat.name.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              )) {
                return false;
              }
            }
            // Unread filter
            if (_showOnlyUnread && chat.unreadCount == 0) {
              return false;
            }
            return true;
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
                        ? (_showOnlyUnread ? 'No unread chats' : 'No chats yet')
                        : 'No chats found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchController.text.isEmpty
                        ? 'Start a conversation!'
                        : 'Try a different search term',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Archive header
              if (!_showArchived && archivedChats.isNotEmpty)
                InkWell(
                  onTap: () => setState(() => _showArchived = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        const Icon(Icons.archive, color: Colors.grey, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Archived',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${archivedChats.length}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

              // Back from archive button
              if (_showArchived)
                InkWell(
                  onTap: () => setState(() => _showArchived = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Back to chats',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Chat list
              Expanded(
                child: ListView.builder(
                  itemCount: filteredChats.length,
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    final hasUnread = chat.unreadCount > 0;
                    final unreadCount = chat.unreadCount;
                    final isPinned = chat.isPinned;
                    final isMuted = chat.isMuted;

                    return Dismissible(
                      key: Key(chat.id),
                      background: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.archive, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.horizontal,
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // Delete
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Chat'),
                              content: const Text(
                                'Are you sure you want to delete this chat?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Archive/Unarchive (swipe right)
                          try {
                            await ChatService.toggleArchive(
                              chat.id,
                              chat.isArchived,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    chat.isArchived
                                        ? 'Chat unarchived'
                                        : 'Chat archived',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                          return false; // Don't dismiss the card
                        }
                      },
                      onDismissed: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          // Delete
                          await ChatService.deleteChat(chat.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chat deleted')),
                            );
                          }
                        } else {
                          // This won't be called since we return false for archive
                        }
                      },
                      child: Container(
                        color: isPinned ? Colors.grey[50] : Colors.white,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailPage(
                                  chatId: chat.id,
                                  chatName: chat.name,
                                  chatAvatar: chat.avatar,
                                  isGroup: chat.type == ChatType.group,
                                ),
                              ),
                            );
                          },
                          onLongPress: () =>
                              _showChatOptions(context, chat, currentUserId),
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
                                        chat.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              // Online indicator
                              if (chat.isOnline)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF07C160),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              // Verified badge
                              if (chat.isVerified)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      size: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Row(
                            children: [
                              if (isPinned)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.push_pin,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (isMuted)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.volume_off,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  chat.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: hasUnread
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatTime(chat.lastActivity),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasUnread
                                      ? const Color(0xFF07C160)
                                      : Colors.grey[600],
                                  fontWeight: hasUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              // Draft indicator
                              if (chat.draftMessage != null &&
                                  chat.draftMessage!.isNotEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Text(
                                    'Draft:',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              // Typing indicator
                              else if (chat.isTyping)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Text(
                                    'typing...',
                                    style: TextStyle(
                                      color: Color(0xFF07C160),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              // Message status icons (for sent messages)
                              else if (chat.lastMessage?.senderId ==
                                  currentUserId)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Icon(
                                    chat.lastMessage?.status ==
                                            MessageStatus.read
                                        ? Icons.done_all
                                        : chat.lastMessage?.status ==
                                              MessageStatus.delivered
                                        ? Icons.done_all
                                        : Icons.done,
                                    size: 16,
                                    color:
                                        chat.lastMessage?.status ==
                                            MessageStatus.read
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  chat.draftMessage ??
                                      _getLastMessageText(chat),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: hasUnread
                                        ? Colors.black87
                                        : Colors.grey[600],
                                    fontWeight: hasUnread
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (chat.hasDisappearingMessages)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.timer,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  if (isMuted && !hasUnread)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.volume_off,
                                        size: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  if (hasUnread)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMuted
                                            ? Colors.grey
                                            : const Color(0xFF07C160),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        unreadCount > 99
                                            ? '99+'
                                            : unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactsPage()),
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
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      final weekday = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ][time.weekday - 1];
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

  void _showChatOptions(BuildContext context, Chat chat, String currentUserId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                chat.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(chat.isPinned ? 'Unpin Chat' : 'Pin Chat'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ChatService.togglePin(chat.id, chat.isPinned);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          chat.isPinned ? 'Chat unpinned' : 'Chat pinned',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(chat.isMuted ? Icons.volume_up : Icons.volume_off),
              title: Text(chat.isMuted ? 'Unmute' : 'Mute'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ChatService.toggleMute(chat.id, chat.isMuted);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          chat.isMuted ? 'Chat unmuted' : 'Chat muted',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: Text(chat.isArchived ? 'Unarchive Chat' : 'Archive Chat'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ChatService.toggleArchive(chat.id, chat.isArchived);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          chat.isArchived ? 'Chat unarchived' : 'Chat archived',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.mark_chat_read),
              title: const Text('Mark as Read'),
              onTap: () async {
                Navigator.pop(context);
                await ChatService.markMessagesAsRead(
                  chatId: chat.id,
                  userId: currentUserId,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marked as read')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Chat',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Chat'),
                    content: const Text(
                      'Are you sure you want to delete this chat?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ChatService.deleteChat(chat.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chat deleted')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
