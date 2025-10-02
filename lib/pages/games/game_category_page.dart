import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../services/game_service.dart';
import '../../widgets/game_card.dart';
import '../game_detail_page.dart';

class GameCategoryPage extends StatefulWidget {
  final String category;

  const GameCategoryPage({super.key, required this.category});

  @override
  State<GameCategoryPage> createState() => _GameCategoryPageState();
}

class _GameCategoryPageState extends State<GameCategoryPage> {
  List<Game> _games = [];
  bool _isLoading = false;
  String _sortBy = 'popular'; // popular, rating, new

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    
    try {
      final games = await GameService.getGamesByCategory(widget.category);
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _sortGames(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      
      switch (sortBy) {
        case 'rating':
          _games.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'new':
          _games.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
          break;
        case 'popular':
        default:
          _games.sort((a, b) => b.downloads.compareTo(a.downloads));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _sortGames,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'popular',
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: _sortBy == 'popular' ? const Color(0xFF07C160) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Most Popular',
                      style: TextStyle(
                        color: _sortBy == 'popular' ? const Color(0xFF07C160) : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'rating',
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: _sortBy == 'rating' ? const Color(0xFF07C160) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Highest Rated',
                      style: TextStyle(
                        color: _sortBy == 'rating' ? const Color(0xFF07C160) : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(
                      Icons.new_releases,
                      color: _sortBy == 'new' ? const Color(0xFF07C160) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Newest',
                      style: TextStyle(
                        color: _sortBy == 'new' ? const Color(0xFF07C160) : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.games, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No games found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGames,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _games.length,
                    itemBuilder: (context, index) {
                      final game = _games[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GameCard(
                          game: game,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameDetailPage(game: game),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
