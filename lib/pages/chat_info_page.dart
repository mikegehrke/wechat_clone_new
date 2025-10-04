import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../models/chat.dart';
import '../models/message.dart';

class ChatInfoPage extends StatefulWidget {
  final Chat chat;

  const ChatInfoPage({super.key, required this.chat});

  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.id ?? '';
    final isGroup = widget.chat.type == 'group';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isGroup ? 'Group Info' : 'Contact Info',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: widget.chat.avatar != null
                      ? NetworkImage(widget.chat.avatar!)
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: widget.chat.avatar == null
                      ? Text(
                          (widget.chat.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.chat.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isGroup) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.chat.isOnline == true ? 'online' : 'offline',
                    style: TextStyle(
                      color: widget.chat.isOnline == true
                          ? const Color(0xFF07C160)
                          : Colors.grey[600],
                    ),
                  ),
                ],
                if (isGroup) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${widget.chat.participants.length} members',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.call,
                      label: 'Audio',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Audio call coming soon!')),
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.videocam,
                      label: 'Video',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Video call coming soon!')),
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.search,
                      label: 'Search',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Search in chat coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF07C160),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF07C160),
            tabs: const [
              Tab(text: 'Media'),
              Tab(text: 'Links'),
              Tab(text: 'Files'),
            ],
          ),
          
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMediaTab(),
                _buildLinksTab(),
                _buildFilesTab(),
              ],
            ),
          ),
          
          // Settings
          Container(
            color: Colors.grey[100],
            child: Column(
              children: [
                if (isGroup) ...[
                  _buildSettingsTile(
                    icon: Icons.group,
                    title: 'Members',
                    subtitle: '${widget.chat.participants.length} members',
                    onTap: () {
                      // TODO: Show members page
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.person_add,
                    title: 'Add Member',
                    onTap: () {
                      // TODO: Add member
                    },
                  ),
                ],
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'On',
                  onTap: () {
                    // TODO: Toggle notifications
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.wallpaper_outlined,
                  title: 'Wallpaper',
                  onTap: () {
                    // TODO: Change wallpaper
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Encryption',
                  subtitle: 'Messages are end-to-end encrypted',
                  onTap: () {
                    _showEncryptionInfo();
                  },
                ),
                const Divider(height: 1),
                if (isGroup)
                  _buildSettingsTile(
                    icon: Icons.exit_to_app,
                    title: 'Exit Group',
                    titleColor: Colors.red,
                    onTap: () {
                      _showExitGroupDialog(currentUserId);
                    },
                  ),
                if (!isGroup)
                  _buildSettingsTile(
                    icon: Icons.block,
                    title: 'Block Contact',
                    titleColor: Colors.red,
                    onTap: () {
                      _showBlockDialog(currentUserId);
                    },
                  ),
                _buildSettingsTile(
                  icon: Icons.thumb_down_outlined,
                  title: 'Report',
                  titleColor: Colors.red,
                  onTap: () {
                    _showReportDialog();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF07C160)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTab() {
    return StreamBuilder<List<Message>>(
      stream: ChatService.getMediaMessages(widget.chat.id, MessageType.image),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final media = snapshot.data ?? [];

        if (media.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No media',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: media.length,
          itemBuilder: (context, index) {
            final message = media[index];
            return InkWell(
              onTap: () {
                // TODO: Open image viewer
              },
              child: Image.network(
                message.content,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLinksTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.link, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No links',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesTab() {
    return StreamBuilder<List<Message>>(
      stream: ChatService.getMediaMessages(widget.chat.id, MessageType.file),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final files = snapshot.data ?? [];

        if (files.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_drive_file, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No files',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            final message = files[index];
            return ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Color(0xFF07C160)),
              title: Text(message.metadata?['filename'] ?? 'File'),
              subtitle: Text(message.metadata?['size'] ?? ''),
              onTap: () {
                // TODO: Download/open file
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showEncryptionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.grey[600]),
            const SizedBox(width: 12),
            const Text('Encryption'),
          ],
        ),
        content: const Text(
          'Messages are end-to-end encrypted. No one outside of this chat, not even us, can read or listen to them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExitGroupDialog(String currentUserId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Group'),
        content: const Text('Are you sure you want to exit this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ChatService.leaveGroup(widget.chat.id, currentUserId);
              if (mounted) {
                Navigator.pop(context); // Go back to chat list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Left group')),
                );
              }
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(String currentUserId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Contact'),
        content: Text('Block ${widget.chat.name}? They won\'t be able to call or message you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Block contact
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Blocked ${widget.chat.name}')),
              );
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report'),
        content: const Text('Report this chat for spam or abuse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Report chat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reported')),
              );
            },
            child: const Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
