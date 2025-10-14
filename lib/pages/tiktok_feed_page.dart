import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/video_provider.dart';
import '../models/video_post.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/comment_sheet.dart';

class TikTokFeedPage extends StatefulWidget {
  const TikTokFeedPage({super.key});

  @override
  State<TikTokFeedPage> createState() => _TikTokFeedPageState();
}

class _TikTokFeedPageState extends State<TikTokFeedPage> {
  final PageController _pageController = PageController();
  final String _currentUserId = 'demo_user_1'; // In real app, get from auth

  @override
  void initState() {
    super.initState();
    // Load videos when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoProvider>().loadVideos();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<VideoProvider>(
        builder: (context, videoProvider, child) {
          if (videoProvider.isLoading && videoProvider.videos.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          if (videoProvider.error != null && videoProvider.videos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    videoProvider.error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      videoProvider.clearError();
                      videoProvider.loadVideos();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              // Load more videos when reaching the end
              if (index >= videoProvider.videos.length - 2) {
                videoProvider.loadMoreVideos();
              }
            },
            itemCount: videoProvider.videos.length,
            itemBuilder: (context, index) {
              return _buildVideoItem(videoProvider.videos[index], index);
            },
          );
        },
      ),
    );
  }

  Widget _buildVideoItem(VideoPost video, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Real Video Player
        VideoPlayerWidget(
          videoUrl: video.videoUrl,
          thumbnailUrl: video.thumbnailUrl,
        ),

        // Video info overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                Text(
                  video.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  video.description,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildActionButton(
                            icon: video.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            label: video.formattedLikes,
                            color: video.isLiked ? Colors.red : Colors.white,
                            onTap: () {
                              context.read<VideoProvider>().toggleLike(
                                video.id,
                                _currentUserId,
                              );
                            },
                          ),
                          const SizedBox(width: 24),
                          _buildActionButton(
                            icon: Icons.chat_bubble_outline,
                            label: video.formattedComments,
                            onTap: () {
                              _showCommentSheet(video);
                            },
                          ),
                          const SizedBox(width: 24),
                          _buildActionButton(
                            icon: Icons.share,
                            label: video.formattedShares,
                            onTap: () {
                              _shareVideo(video);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Right side action buttons
        Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            children: [
              _buildVerticalActionButton(
                icon: Icons.favorite,
                label: video.formattedLikes,
                color: video.isLiked ? Colors.red : Colors.white,
                onTap: () {
                  context.read<VideoProvider>().toggleLike(
                    video.id,
                    _currentUserId,
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildVerticalActionButton(
                icon: Icons.chat_bubble_outline,
                label: video.formattedComments,
                onTap: () {
                  _showCommentSheet(video);
                },
              ),
              const SizedBox(height: 24),
              _buildVerticalActionButton(
                icon: Icons.share,
                label: video.formattedShares,
                onTap: () {
                  _shareVideo(video);
                },
              ),
              const SizedBox(height: 24),
              _buildVerticalActionButton(
                icon: Icons.bookmark_border,
                label: 'Save',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Save feature coming soon!')),
                  );
                },
              ),
            ],
          ),
        ),

        // Top navigation
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Following',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'For You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.search, color: Colors.white, size: 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Show comment sheet
  void _showCommentSheet(VideoPost video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(video: video),
    );
  }

  // Share video
  void _shareVideo(VideoPost video) async {
    try {
      await Share.share(
        'Check out this video: ${video.description}\n\nShared from WeChat Clone App',
        subject: 'Amazing video from ${video.username}',
      );

      // Update share count
      context.read<VideoProvider>().shareVideo(video.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
