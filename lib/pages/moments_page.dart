import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/moments_service.dart';

class MomentsPage extends StatefulWidget {
  const MomentsPage({super.key});

  @override
  State<MomentsPage> createState() => _MomentsPageState();
}

class _MomentsPageState extends State<MomentsPage> {
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _createMoment() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);

    if (pickedFiles.isEmpty) return;

    final textController = TextEditingController();

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Moment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${pickedFiles.length} photo(s) selected'),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Post'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Upload media
      final files = pickedFiles.map((xFile) => File(xFile.path)).toList();
      final mediaUrls = await MomentsService.uploadMomentMedia(files);

      // Post moment
      final user = FirebaseAuth.instance.currentUser!;
      await MomentsService.postMoment(
        userId: user.uid,
        userName: user.displayName ?? 'User',
        text: textController.text.trim(),
        mediaUrls: mediaUrls,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Moment posted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moments'),
        actions: [
          IconButton(
            onPressed: _createMoment,
            icon: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: MomentsService.getMomentsStream(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final moments = snapshot.data ?? [];

          if (moments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_album, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No moments yet', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _createMoment,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Moment'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: moments.length,
            itemBuilder: (context, index) {
              final moment = moments[index];
              final isLiked = (moment['likes'] as List).contains(_currentUserId);

              return Card(
                margin: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User header
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          moment['userName'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(moment['userName']),
                      subtitle: Text(_getTimeAgo(moment['timestamp'])),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          // Show options
                        },
                      ),
                    ),

                    // Text content
                    if (moment['text'] != null && moment['text'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(moment['text'], style: const TextStyle(fontSize: 15)),
                      ),

                    // Media grid
                    if (moment['mediaUrls'] != null && moment['mediaUrls'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: (moment['mediaUrls'] as List).length,
                          itemBuilder: (context, i) {
                            return Image.network(
                              moment['mediaUrls'][i],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),

                    // Actions
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (isLiked) {
                              await MomentsService.unlikeMoment(moment['id'], _currentUserId);
                            } else {
                              await MomentsService.likeMoment(moment['id'], _currentUserId);
                            }
                          },
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : null,
                          ),
                        ),
                        Text('${(moment['likes'] as List).length}'),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            // Show comments
                          },
                          icon: const Icon(Icons.comment_outlined),
                        ),
                        Text('${(moment['comments'] as List).length}'),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return '';
    
    final DateTime dateTime = (timestamp as dynamic).toDate();
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
