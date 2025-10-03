import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart';

class GameService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _gamesCollection = 'games';
  static const String _reviewsCollection = 'gameReviews';
  static const String _categoriesCollection = 'gameCategories';
  static const String _leaderboardsCollection = 'gameLeaderboards';
  static const String _usersCollection = 'users';
  // Get featured games
  static Future<List<Game>> getFeaturedGames() async {
    try {
      final snapshot = await _firestore
          .collection(_gamesCollection)
          .where('isFeatured', isEqualTo: true)
          .orderBy('releaseDate', descending: true)
          .limit(20)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Game.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get featured games: $e');
    }
  }

  // Get trending games
  static Future<List<Game>> getTrendingGames() async {
    try {
      final snapshot = await _firestore
          .collection(_gamesCollection)
          .where('isTrending', isEqualTo: true)
          .orderBy('releaseDate', descending: true)
          .limit(20)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Game.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get trending games: $e');
    }
  }

  // Get games by category
  static Future<List<Game>> getGamesByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_gamesCollection)
          .where('category', isEqualTo: category)
          .orderBy('releaseDate', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Game.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get games by category: $e');
    }
  }

  // Search games
  static Future<List<Game>> searchGames(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_gamesCollection)
          .orderBy('releaseDate', descending: true)
          .limit(100)
          .get();
      final normalized = query.toLowerCase();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Game.fromJson(data);
      }).where((g) => g.title.toLowerCase().contains(normalized)
          || g.description.toLowerCase().contains(normalized)
          || g.tags.any((t) => t.toLowerCase().contains(normalized))
      ).toList();
    } catch (e) {
      throw Exception('Failed to search games: $e');
    }
  }

  // Get game details
  static Future<Game?> getGameDetails(String gameId) async {
    try {
      final doc = await _firestore.collection(_gamesCollection).doc(gameId).get();
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return Game.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get game details: $e');
    }
  }

  // Get game reviews
  static Future<List<GameReview>> getGameReviews(String gameId) async {
    try {
      final snapshot = await _firestore
          .collection(_reviewsCollection)
          .where('gameId', isEqualTo: gameId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return GameReview.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get game reviews: $e');
    }
  }

  // Add game review
  static Future<void> addGameReview({
    required String gameId,
    required String userId,
    required String username,
    required double rating,
    required String review,
  }) async {
    try {
      final docRef = _firestore.collection(_reviewsCollection).doc();
      await docRef.set({
        'id': docRef.id,
        'gameId': gameId,
        'userId': userId,
        'username': username,
        'rating': rating,
        'review': review,
        'createdAt': DateTime.now().toIso8601String(),
        'helpfulCount': 0,
        'isVerified': false,
      });
      // Optionally update aggregate rating on game document
      await _firestore.collection(_gamesCollection).doc(gameId).set({
        'reviewCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add game review: $e');
    }
  }

  // Get game categories
  static Future<List<GameCategory>> getGameCategories() async {
    try {
      final snapshot = await _firestore.collection(_categoriesCollection).orderBy('name').get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return GameCategory.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get game categories: $e');
    }
  }

  // Get game achievements
  static Future<List<GameAchievement>> getGameAchievements(String gameId) async {
    try {
      final snapshot = await _firestore
          .collection(_gamesCollection)
          .doc(gameId)
          .collection('achievements')
          .orderBy('points', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        data['gameId'] = gameId;
        return GameAchievement.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get game achievements: $e');
    }
  }

  // Get game leaderboard
  static Future<GameLeaderboard> getGameLeaderboard({
    required String gameId,
    required String leaderboardType,
  }) async {
    try {
      final doc = await _firestore
          .collection(_leaderboardsCollection)
          .doc('${gameId}_$leaderboardType')
          .get();
      if (!doc.exists) {
        return GameLeaderboard(
          id: 'leaderboard_${gameId}_$leaderboardType',
          gameId: gameId,
          gameTitle: '',
          leaderboardType: leaderboardType,
          entries: const [],
          lastUpdated: DateTime.now(),
        );
      }
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return GameLeaderboard.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get game leaderboard: $e');
    }
  }

  // Download game
  static Future<void> downloadGame(String gameId) async {
    try {
      await _firestore.collection(_usersCollection).doc('current').collection('downloads').doc(gameId).set({
        'gameId': gameId,
        'status': 'downloaded',
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to download game: $e');
    }
  }

  // Install game
  static Future<void> installGame(String gameId) async {
    try {
      await _firestore.collection(_usersCollection).doc('current').collection('installs').doc(gameId).set({
        'gameId': gameId,
        'status': 'installed',
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to install game: $e');
    }
  }

  // Launch game
  static Future<void> launchGame(String gameId) async {
    try {
      await _firestore.collection(_usersCollection).doc('current').collection('launches').doc(gameId).set({
        'gameId': gameId,
        'launchedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to launch game: $e');
    }
  }

  // Get user's installed games
  static Future<List<Game>> getUserInstalledGames(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('installs')
          .get();
      final ids = snapshot.docs.map((d) => d.id).toList();
      if (ids.isEmpty) return [];
      final List<Game> games = [];
      for (var i = 0; i < ids.length; i += 10) {
        final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
        final snap = await _firestore
            .collection(_gamesCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        games.addAll(snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return Game.fromJson(data);
        }));
      }
      return games;
    } catch (e) {
      throw Exception('Failed to get user installed games: $e');
    }
  }

  // Get user's favorite games
  static Future<List<Game>> getUserFavoriteGames(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('favoriteGames')
          .get();
      final ids = snapshot.docs.map((d) => d.id).toList();
      if (ids.isEmpty) return [];
      final List<Game> games = [];
      for (var i = 0; i < ids.length; i += 10) {
        final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
        final snap = await _firestore
            .collection(_gamesCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        games.addAll(snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return Game.fromJson(data);
        }));
      }
      return games;
    } catch (e) {
      throw Exception('Failed to get user favorite games: $e');
    }
  }

  // Add game to favorites
  static Future<void> addGameToFavorites(String gameId, String userId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('favoriteGames')
          .doc(gameId)
          .set({'addedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      throw Exception('Failed to add game to favorites: $e');
    }
  }

  // Remove game from favorites
  static Future<void> removeGameFromFavorites(String gameId, String userId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('favoriteGames')
          .doc(gameId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove game from favorites: $e');
    }
  }
  
  // Mock data generators (kept for reference)
  static List<Game> _createMockGames() {
    final categories = ['Action', 'Adventure', 'Puzzle', 'Racing', 'Sports', 'Strategy', 'RPG', 'Simulation'];
    final developers = ['Epic Games', 'Supercell', 'King', 'Niantic', 'Riot Games', 'Blizzard', 'Ubisoft', 'EA'];
    final titles = [
      'Fortnite Battle Royale', 'Clash of Clans', 'Candy Crush Saga', 'Pokemon GO',
      'League of Legends', 'Call of Duty Mobile', 'PUBG Mobile', 'Among Us',
      'Minecraft', 'Roblox', 'Genshin Impact', 'Free Fire',
      'Subway Surfers', 'Temple Run', 'Angry Birds', 'Plants vs Zombies',
      'FIFA Mobile', 'NBA 2K Mobile', 'Asphalt 9', 'Real Racing 3',
    ];
    
    return List.generate(50, (index) {
      final category = categories[index % categories.length];
      final developer = developers[index % developers.length];
      final title = titles[index % titles.length];
      final rating = 3.0 + (index % 3) + (index % 2 == 0 ? 0.5 : 0.0);
      final downloads = 100000 + (index * 50000);
      final size = 50 + (index * 10);
      final isFree = index % 4 != 0;
      final price = isFree ? null : 2.99 + (index * 0.99);
      
      return Game(
        id: 'game_$index',
        title: title,
        description: _generateGameDescription(title, category),
        imageUrl: 'https://via.placeholder.com/300x400/${_getRandomColor()}/FFFFFF?text=$title',
        category: category,
        rating: rating,
        reviewCount: 1000 + (index * 100),
        downloads: downloads,
        developer: developer,
        version: '${1 + (index % 10)}.${index % 10}.${index % 10}',
        size: size,
        isFree: isFree,
        price: price,
        screenshots: _generateScreenshots(),
        tags: _getGameTags(category),
        releaseDate: DateTime.now().subtract(Duration(days: index * 30)),
        isFeatured: index % 10 == 0,
        isTrending: index % 15 == 0,
        requirements: _getGameRequirements(),
        supportedPlatforms: ['Android', 'iOS'],
      );
    });
  }

  static List<GameCategory> _createMockCategories() {
    final categories = [
      {'name': 'Action', 'description': 'Fast-paced action games', 'icon': '🎮'},
      {'name': 'Adventure', 'description': 'Explore new worlds', 'icon': '🗺️'},
      {'name': 'Puzzle', 'description': 'Challenge your mind', 'icon': '🧩'},
      {'name': 'Racing', 'description': 'Speed and competition', 'icon': '🏎️'},
      {'name': 'Sports', 'description': 'Play your favorite sports', 'icon': '⚽'},
      {'name': 'Strategy', 'description': 'Plan and conquer', 'icon': '♟️'},
      {'name': 'RPG', 'description': 'Role-playing adventures', 'icon': '⚔️'},
      {'name': 'Simulation', 'description': 'Simulate real life', 'icon': '🏠'},
    ];
    
    return categories.map((cat) => GameCategory(
      id: cat['name']!.toLowerCase(),
      name: cat['name']!,
      description: cat['description']!,
      iconUrl: 'https://via.placeholder.com/100x100/${_getRandomColor()}/FFFFFF?text=${cat['icon']}',
      gameCount: 50 + Random().nextInt(200),
      isPopular: Random().nextBool(),
    )).toList();
  }

  static List<GameReview> _createMockReviews(String gameId) {
    final usernames = ['GamerPro', 'GameMaster', 'PlayerOne', 'GameFan', 'MobileGamer'];
    final reviews = [
      'Amazing game! Love the graphics and gameplay.',
      'Great game but needs more content updates.',
      'Perfect for mobile gaming. Highly recommended!',
      'Good game but has some bugs that need fixing.',
      'Best mobile game I\'ve played this year!',
    ];
    
    return List.generate(10, (index) {
      final rating = 3.0 + (index % 3) + (index % 2 == 0 ? 0.5 : 0.0);
      
      return GameReview(
        id: 'review_$index',
        gameId: gameId,
        userId: 'user_$index',
        username: usernames[index % usernames.length],
        userAvatar: 'https://via.placeholder.com/50x50/${_getRandomColor()}/FFFFFF?text=${usernames[index % usernames.length][0]}',
        rating: rating,
        review: reviews[index % reviews.length],
        createdAt: DateTime.now().subtract(Duration(days: index * 7)),
        helpfulCount: Random().nextInt(50),
        isVerified: index % 3 == 0,
      );
    });
  }

  static List<GameAchievement> _createMockAchievements(String gameId) {
    final achievements = <Map<String, dynamic>>[
      {'title': 'First Steps', 'description': 'Complete the tutorial', 'points': 10},
      {'title': 'Speed Demon', 'description': 'Complete a level in under 30 seconds', 'points': 25},
      {'title': 'Perfectionist', 'description': 'Get 3 stars on all levels', 'points': 50},
      {'title': 'Social Butterfly', 'description': 'Play with 10 different friends', 'points': 30},
      {'title': 'Collector', 'description': 'Collect 100 items', 'points': 40},
    ];
    
    return achievements.map((ach) => GameAchievement(
      id: 'achievement_${(ach['title'] as String).toLowerCase().replaceAll(' ', '_')}',
      gameId: gameId,
      title: ach['title'] as String,
      description: ach['description'] as String,
      iconUrl: 'https://via.placeholder.com/64x64/${_getRandomColor()}/FFFFFF?text=🏆',
      points: ach['points'] as int,
      isUnlocked: Random().nextBool(),
      unlockedAt: Random().nextBool() ? DateTime.now().subtract(Duration(days: Random().nextInt(30))) : null,
      progress: Random().nextDouble(),
    )).toList();
  }

  static GameLeaderboard _createMockLeaderboard(String gameId, String leaderboardType) {
    final usernames = ['ProGamer', 'GameMaster', 'PlayerOne', 'GameFan', 'MobileGamer', 'GameKing', 'GameQueen', 'GameLord'];
    final entries = List.generate(10, (index) => LeaderboardEntry(
      userId: 'user_$index',
      username: usernames[index % usernames.length],
      userAvatar: 'https://via.placeholder.com/40x40/${_getRandomColor()}/FFFFFF?text=${usernames[index % usernames.length][0]}',
      score: 10000 - (index * 500),
      rank: index + 1,
      isCurrentUser: index == 2, // Mock: current user is rank 3
    ));
    
    return GameLeaderboard(
      id: 'leaderboard_${gameId}_$leaderboardType',
      gameId: gameId,
      gameTitle: 'Sample Game',
      leaderboardType: leaderboardType,
      entries: entries,
      lastUpdated: DateTime.now(),
    );
  }

  static String _generateGameDescription(String title, String category) {
    return 'Experience the ultimate $category gaming with $title. Immerse yourself in stunning graphics, engaging gameplay, and endless entertainment. Perfect for mobile gaming on the go!';
  }

  static List<String> _generateScreenshots() {
    return List.generate(5, (index) => 
      'https://via.placeholder.com/400x600/${_getRandomColor()}/FFFFFF?text=Screenshot+${index + 1}'
    );
  }

  static List<String> _getGameTags(String category) {
    final tags = {
      'Action': ['Fast-paced', 'Combat', 'Adrenaline'],
      'Adventure': ['Exploration', 'Story', 'Mystery'],
      'Puzzle': ['Brain teaser', 'Logic', 'Challenge'],
      'Racing': ['Speed', 'Competition', 'Cars'],
      'Sports': ['Competition', 'Team', 'Athletic'],
      'Strategy': ['Planning', 'Tactics', 'War'],
      'RPG': ['Character', 'Quest', 'Fantasy'],
      'Simulation': ['Realistic', 'Management', 'Life'],
    };
    return tags[category] ?? ['Popular', 'Fun'];
  }

  static Map<String, dynamic> _getGameRequirements() {
    return {
      'minAndroidVersion': '5.0',
      'minIOSVersion': '12.0',
      'ram': '2GB',
      'storage': '1GB',
      'internet': 'Required',
    };
  }

  static String _getRandomColor() {
    final colors = [
      'FF6B6B', '4ECDC4', '45B7D1', '96CEB4', 'FFEAA7', 'DDA0DD',
      '98D8C8', 'F7DC6F', 'BB8FCE', '85C1E9', 'F8C471', '82E0AA',
    ];
    return colors[Random().nextInt(colors.length)];
  }
}