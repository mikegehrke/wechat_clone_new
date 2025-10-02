import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/game_service.dart';
import '../widgets/game_card.dart';
import '../widgets/game_category_card.dart';
import '../widgets/game_search_bar.dart';
import 'game_detail_page.dart';
import 'games/game_category_page.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Game> _featuredGames = [];
  List<Game> _trendingGames = [];
  List<GameCategory> _categories = [];
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
        GameService.getFeaturedGames(),
        GameService.getTrendingGames(),
        GameService.getGameCategories(),
      ]);

      setState(() {
        _featuredGames = futures[0] as List<Game>;
        _trendingGames = futures[1] as List<Game>;
        _categories = futures[2] as List<GameCategory>;
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Games',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              _tabController.animateTo(3); // Switch to search tab
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Featured'),
            Tab(text: 'Trending'),
            Tab(text: 'Categories'),
            Tab(text: 'Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeaturedTab(),
          _buildTrendingTab(),
          _buildCategoriesTab(),
          _buildSearchTab(),
        ],
      ),
    );
  }

  Widget _buildFeaturedTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: GameSearchBar(
            onSearch: (query) {
              _tabController.animateTo(3);
            },
          ),
        ),
        
        // Featured games
        Expanded(
          child: _buildGamesList(_featuredGames, 'Featured Games'),
        ),
      ],
    );
  }

  Widget _buildTrendingTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: GameSearchBar(
            onSearch: (query) {
              _tabController.animateTo(3);
            },
          ),
        ),
        
        // Trending games
        Expanded(
          child: _buildGamesList(_trendingGames, 'Trending Games'),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return GameCategoryCard(
          category: category,
          onTap: () => _navigateToCategory(category),
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GameSearchBar(
            onSearch: (query) {
              _performSearch(query);
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList(List<Game> games, String title) {
    if (games.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.games, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No games found',
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GameCard(
            game: game,
            onTap: () => _navigateToGame(game),
            onDownload: () => _downloadGame(game),
            onAddToFavorites: () => _addToFavorites(game),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    // In real app, show search results
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Search for games',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enter a game name or category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToGame(Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailPage(game: game),
      ),
    );
  }

  void _navigateToCategory(GameCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameCategoryPage(category: category.name),
      ),
    );
  }

  void _downloadGame(Game game) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${game.title}...'),
        action: SnackBarAction(
          label: 'Cancel',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Download cancelled')),
            );
          },
        ),
      ),
    );
  }

  void _addToFavorites(Game game) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${game.title} added to favorites')),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Searching for "$query"...')),
    );
  }
}