import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/status_service.dart';
import 'create_status_page.dart';
import 'view_status_page.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.id ?? '';
    final currentUserName = authProvider.user?.username ?? 'You';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Status',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              _showStatusOptions();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<StatusGroup>>(
        stream: StatusService.getStatusesStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final statusGroups = snapshot.data ?? [];

          return ListView(
            children: [
              // My Status
              StreamBuilder<List<Status>>(
                stream: StatusService.getMyStatusesStream(currentUserId),
                builder: (context, myStatusSnapshot) {
                  final myStatuses = myStatusSnapshot.data ?? [];
                  final hasStatus = myStatuses.isNotEmpty;

                  return ListTile(
                    onTap: () {
                      if (hasStatus) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewStatusPage(
                              statusGroup: StatusGroup(
                                userId: currentUserId,
                                userName: currentUserName,
                                statuses: myStatuses,
                                isViewed: true,
                              ),
                              isMyStatus: true,
                            ),
                          ),
                        );
                      } else {
                        _showAddStatusOptions();
                      }
                    },
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: authProvider.user?.avatarUrl != null
                              ? NetworkImage(authProvider.user!.avatarUrl!)
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: authProvider.user?.avatarUrl == null
                              ? Text(
                                  currentUserName[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        if (!hasStatus)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF07C160),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: const Text(
                      'My Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      hasStatus
                          ? 'Tap to view'
                          : 'Tap to add status update',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                },
              ),

              if (statusGroups.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Recent updates',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                ...statusGroups.map((group) => _buildStatusItem(group)),
              ] else
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recent updates',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Share photos and videos with your contacts',
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'text_status',
            mini: true,
            backgroundColor: Colors.grey[300],
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateStatusPage(type: StatusType.text),
                ),
              );
            },
            child: const Icon(Icons.edit, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'camera_status',
            backgroundColor: const Color(0xFF07C160),
            onPressed: () => _showAddStatusOptions(),
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(StatusGroup group) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id ?? '';
    
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewStatusPage(
              statusGroup: group,
              isMyStatus: group.userId == currentUserId,
            ),
          ),
        );
      },
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: group.isViewed ? Colors.grey[300]! : const Color(0xFF07C160),
            width: 2.5,
          ),
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[300],
          child: Text(
            group.userName[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      title: Text(
        group.userName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        _getTimeAgo(group.statuses.first.timestamp),
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  void _showAddStatusOptions() {
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
                _pickMedia(ImageSource.gallery, isVideo: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF07C160)),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera, isVideo: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Color(0xFF07C160)),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery, isVideo: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF07C160)),
              title: const Text('Text Status'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateStatusPage(type: StatusType.text),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);
      
      if (file != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateStatusPage(
              type: isVideo ? StatusType.video : StatusType.image,
              mediaFile: File(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick media: $e')),
        );
      }
    }
  }

  void _showStatusOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Status Privacy'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status privacy settings coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                _showStatusHelp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Status'),
        content: const Text(
          'Status allows you to share photos, videos and text updates that disappear after 24 hours.\n\n'
          'Your contacts can see your status updates.',
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

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return 'Yesterday';
  }
}
