import 'package:flutter/material.dart';
import '../../models/streaming.dart';
import '../../services/streaming_service.dart';
import 'video_player_page.dart';

class SeriesDetailPage extends StatefulWidget {
  final Series series;

  const SeriesDetailPage({super.key, required this.series});

  @override
  State<SeriesDetailPage> createState() => _SeriesDetailPageState();
}

class _SeriesDetailPageState extends State<SeriesDetailPage> with SingleTickerProviderStateMixin {
  late Series _series;
  late TabController _tabController;
  bool _isInWatchlist = false;
  int _selectedSeason = 1;

  @override
  void initState() {
    super.initState();
    _series = widget.series;
    _isInWatchlist = _series.isInWatchlist;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    _series.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.tv, size: 64, color: Colors.white),
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
                onPressed: _shareSeries,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          _series.title,
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
                            _buildMetaChip(Icons.calendar_today, '${_series.releaseYear}'),
                            _buildMetaChip(Icons.live_tv, '${_series.seasons} Seasons'),
                            _buildMetaChip(Icons.star, _series.rating.toStringAsFixed(1)),
                            ..._series.genres.take(2).map((genre) => _buildGenreChip(genre)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Continue watching / Start watching button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _playNextEpisode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF07C160),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text(
                              'Continue Watching - S1 E3',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
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
                          _series.description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tabs: Episodes & More Info
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF07C160),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFF07C160),
                    tabs: const [
                      Tab(text: 'Episodes'),
                      Tab(text: 'More Info'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEpisodesTab(),
                _buildMoreInfoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesTab() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Season selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                const Text(
                  'Season',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _selectedSeason,
                  items: List.generate(_series.seasons, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text('Season ${index + 1}'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() => _selectedSeason = value!);
                  },
                ),
              ],
            ),
          ),

          // Episodes list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: 10, // Episodes per season
              itemBuilder: (context, index) {
                return _buildEpisodeItem(index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreInfoTab() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          // Cast
          const Text(
            'Cast',
            style: TextStyle(
              fontSize: 18,
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

          // Details
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Creator', 'John Doe'),
          _buildDetailRow('Genres', _series.genres.join(', ')),
          _buildDetailRow('Release Year', _series.releaseYear.toString()),
          _buildDetailRow('Seasons', _series.seasons.toString()),
          _buildDetailRow('Status', 'Ongoing'),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Similar series
          const Text(
            'More Like This',
            style: TextStyle(
              fontSize: 18,
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
                return _buildSimilarSeriesItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeItem(int episodeNumber) {
    final isWatched = episodeNumber < 3; // Mock watched status
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _playEpisode(episodeNumber),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode thumbnail
            Stack(
              children: [
                Container(
                  width: 140,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.play_circle_outline, size: 40),
                ),
                if (isWatched)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF07C160),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Episode info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Episode $episodeNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Episode Title Goes Here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '45 min',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: () => _downloadEpisode(episodeNumber),
            ),
          ],
        ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarSeriesItem(int index) {
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
              child: Icon(Icons.tv, size: 40),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Similar Series ${index + 1}',
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

  void _playNextEpisode() {
    _playEpisode(3); // Continue from episode 3
  }

  void _playEpisode(int episodeNumber) {
    final video = StreamingVideo(
      id: '${_series.id}_s${_selectedSeason}_e$episodeNumber',
      title: '${_series.title} - S$_selectedSeason E$episodeNumber',
      description: 'Episode $episodeNumber description',
      thumbnailUrl: _series.posterUrl,
      videoUrl: '',
      duration: const Duration(minutes: 45),
      views: 0,
      rating: _series.rating,
      uploadDate: DateTime.now(),
      isLiked: false,
      isInWatchlist: _isInWatchlist,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(video: video),
      ),
    );
  }

  void _downloadEpisode(int episodeNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading Episode $episodeNumber...')),
    );
  }

  void _toggleWatchlist() {
    setState(() => _isInWatchlist = !_isInWatchlist);
    
    StreamingService.toggleWatchlist(_series.id, 'demo_user_1');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isInWatchlist ? 'Added to watchlist' : 'Removed from watchlist'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareSeries() {
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
}
