import 'package:flutter/material.dart';
import '../models/streaming.dart';
import '../services/streaming_service.dart';
import '../widgets/video_content_card.dart';
import '../widgets/movie_card.dart';
import '../widgets/series_card.dart';
import '../widgets/streaming_search_bar.dart';
import 'video_player_page.dart';
import 'movie_detail_page.dart';
import 'series_detail_page.dart';

class StreamingPage extends StatefulWidget {
  const StreamingPage({super.key});

  @override
  State<StreamingPage> createState() => _StreamingPageState();
}

class _StreamingPageState extends State<StreamingPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<VideoContent> _trendingVideos = [];
  List<VideoContent> _liveVideos = [];
  List<Movie> _movies = [];
  List<Series> _series = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  final String _currentUserId = 'demo_user_1'; // In real app, get from auth

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final futures = await Future.wait([
        StreamingService.getTrendingVideos(),
        StreamingService.getLiveVideos(),
        StreamingService.getMovies(),
        StreamingService.getSeries(),
        StreamingService.getCategories(),
      ]);

      setState(() {
        _trendingVideos = futures[0] as List<VideoContent>;
        _liveVideos = futures[1] as List<VideoContent>;
        _movies = futures[2] as List<Movie>;
        _series = futures[3] as List<Series>;
        _categories = futures[4] as List<String>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Streaming',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile feature coming soon!')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(text: 'Trending'),
            Tab(text: 'Live'),
            Tab(text: 'Movies'),
            Tab(text: 'Series'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrendingTab(),
          _buildLiveTab(),
          _buildMoviesTab(),
          _buildSeriesTab(),
        ],
      ),
    );
  }

  Widget _buildTrendingTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trendingVideos.length,
      itemBuilder: (context, index) {
        final video = _trendingVideos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: VideoContentCard(
            video: video,
            onTap: () => _navigateToVideo(video),
            onSubscribe: () => _subscribeToChannel(video),
          ),
        );
      },
    );
  }

  Widget _buildLiveTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_liveVideos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No live streams available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _liveVideos.length,
      itemBuilder: (context, index) {
        final video = _liveVideos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: VideoContentCard(
            video: video,
            onTap: () => _navigateToVideo(video),
            onSubscribe: () => _subscribeToChannel(video),
          ),
        );
      },
    );
  }

  Widget _buildMoviesTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return MovieCard(
          movie: movie,
          onTap: () => _navigateToMovie(movie),
          onAddToWatchlist: () => _addToWatchlist(movie),
        );
      },
    );
  }

  Widget _buildSeriesTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: _series.length,
      itemBuilder: (context, index) {
        final series = _series[index];
        return SeriesCard(
          series: series,
          onTap: () => _navigateToSeries(series),
          onAddToWatchlist: () => _addToWatchlist(series),
        );
      },
    );
  }

  void _navigateToVideo(VideoContent video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(video: video),
      ),
    );
  }

  void _navigateToMovie(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailPage(movie: movie),
      ),
    );
  }

  void _navigateToSeries(Series series) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeriesDetailPage(series: series),
      ),
    );
  }

  void _subscribeToChannel(VideoContent video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Subscribed to ${video.channelName}')),
    );
  }

  void _addToWatchlist(dynamic content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${content.title} to watchlist')),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
        content: const TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search videos, movies, series...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature coming soon!')),
              );
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}