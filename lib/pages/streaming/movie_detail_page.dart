import 'package:flutter/material.dart';
import '../../models/streaming.dart';
import '../../services/streaming_service.dart';
import 'video_player_page.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late Movie _movie;
  bool _isInWatchlist = false;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _isInWatchlist = _movie.isInWatchlist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with backdrop
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.movie, size: 64, color: Colors.white),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Play button overlay
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow, size: 48, color: Colors.white),
                        onPressed: _playMovie,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isInWatchlist ? Icons.bookmark : Icons.bookmark_border),
                onPressed: _toggleWatchlist,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareMovie,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metadata
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildMetaChip(Icons.calendar_today, _movie.year.toString()),
                      _buildMetaChip(Icons.access_time, _formatDuration(_movie.duration)),
                      _buildMetaChip(Icons.star, _movie.rating.toStringAsFixed(1)),
                      ..._movie.genres.take(2).map((genre) => _buildGenreChip(genre)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _playMovie,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF07C160),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Play', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _downloadMovie,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.download, size: 20),
                          label: const Text('Download'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Synopsis
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _movie.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Cast
                  const Text(
                    'Cast',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return _buildCastItem('Actor ${index + 1}');
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Similar movies
                  const Text(
                    'More Like This',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return _buildSimilarMovieItem(index);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String genre) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        genre,
        style: TextStyle(
          fontSize: 13,
          color: Colors.blue[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCastItem(String name) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 35),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarMovieItem(int index) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.movie, size: 40),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Similar Movie ${index + 1}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '${(4.0 + index * 0.2).toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  void _playMovie() {
    // Convert Movie to VideoContent for player
    final video = VideoContent(
      id: _movie.id,
      title: _movie.title,
      description: _movie.description,
      thumbnailUrl: _movie.posterUrl,
      videoUrl: _movie.videoUrl,
      channelName: _movie.director,
      channelAvatar: '',
      views: 0,
      likes: 0,
      dislikes: 0,
      comments: 0,
      publishedAt: DateTime.now(),
      duration: _movie.duration,
      tags: _movie.genres,
      category: _movie.genres.isNotEmpty ? _movie.genres.first : 'Movie',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(video: video),
      ),
    );
  }

  void _toggleWatchlist() {
    setState(() => _isInWatchlist = !_isInWatchlist);
    
    StreamingService.toggleWatchlist(_movie.id, 'demo_user_1');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isInWatchlist ? 'Added to watchlist' : 'Removed from watchlist'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareMovie() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy Link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share to...'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadMovie() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Movie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose quality:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('HD (1080p)'),
              subtitle: const Text('~2.5 GB'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download started')),
                );
              },
            ),
            ListTile(
              title: const Text('SD (720p)'),
              subtitle: const Text('~1.2 GB'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download started')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
