class Game {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final int downloads;
  final String developer;
  final String version;
  final int size; // in MB
  final bool isFree;
  final double? price;
  final List<String> screenshots;
  final List<String> tags;
  final DateTime releaseDate;
  final bool isFeatured;
  final bool isTrending;
  final Map<String, dynamic> requirements; // min requirements
  final List<String> supportedPlatforms;

  Game({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.downloads = 0,
    required this.developer,
    required this.version,
    required this.size,
    this.isFree = true,
    this.price,
    this.screenshots = const [],
    this.tags = const [],
    required this.releaseDate,
    this.isFeatured = false,
    this.isTrending = false,
    this.requirements = const {},
    this.supportedPlatforms = const ['Android', 'iOS'],
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      downloads: json['downloads'] ?? 0,
      developer: json['developer'],
      version: json['version'],
      size: json['size'] ?? 0,
      isFree: json['isFree'] ?? true,
      price: json['price']?.toDouble(),
      screenshots: List<String>.from(json['screenshots'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      releaseDate: DateTime.parse(json['releaseDate']),
      isFeatured: json['isFeatured'] ?? false,
      isTrending: json['isTrending'] ?? false,
      requirements: Map<String, dynamic>.from(json['requirements'] ?? {}),
      supportedPlatforms: List<String>.from(json['supportedPlatforms'] ?? ['Android', 'iOS']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'downloads': downloads,
      'developer': developer,
      'version': version,
      'size': size,
      'isFree': isFree,
      'price': price,
      'screenshots': screenshots,
      'tags': tags,
      'releaseDate': releaseDate.toIso8601String(),
      'isFeatured': isFeatured,
      'isTrending': isTrending,
      'requirements': requirements,
      'supportedPlatforms': supportedPlatforms,
    };
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  String get formattedReviewCount {
    if (reviewCount >= 1000) {
      return '${(reviewCount / 1000).toStringAsFixed(1)}K';
    }
    return reviewCount.toString();
  }

  String get formattedDownloads {
    if (downloads >= 1000000) {
      return '${(downloads / 1000000).toStringAsFixed(1)}M';
    } else if (downloads >= 1000) {
      return '${(downloads / 1000).toStringAsFixed(1)}K';
    }
    return downloads.toString();
  }

  String get formattedSize {
    if (size >= 1024) {
      return '${(size / 1024).toStringAsFixed(1)} GB';
    }
    return '$size MB';
  }

  String get formattedPrice {
    if (isFree) return 'Free';
    return '\$${price!.toStringAsFixed(2)}';
  }

  String get formattedReleaseDate {
    final now = DateTime.now();
    final difference = now.difference(releaseDate);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
}

class GameReview {
  final String id;
  final String gameId;
  final String userId;
  final String username;
  final String? userAvatar;
  final double rating;
  final String review;
  final DateTime createdAt;
  final int helpfulCount;
  final bool isVerified;

  GameReview({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.rating,
    required this.review,
    required this.createdAt,
    this.helpfulCount = 0,
    this.isVerified = false,
  });

  factory GameReview.fromJson(Map<String, dynamic> json) {
    return GameReview(
      id: json['id'],
      gameId: json['gameId'],
      userId: json['userId'],
      username: json['username'],
      userAvatar: json['userAvatar'],
      rating: json['rating']?.toDouble() ?? 0.0,
      review: json['review'],
      createdAt: DateTime.parse(json['createdAt']),
      helpfulCount: json['helpfulCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'rating': rating,
      'review': review,
      'createdAt': createdAt.toIso8601String(),
      'helpfulCount': helpfulCount,
      'isVerified': isVerified,
    };
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}

class GameCategory {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int gameCount;
  final bool isPopular;

  GameCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    this.gameCount = 0,
    this.isPopular = false,
  });

  factory GameCategory.fromJson(Map<String, dynamic> json) {
    return GameCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      gameCount: json['gameCount'] ?? 0,
      isPopular: json['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'gameCount': gameCount,
      'isPopular': isPopular,
    };
  }
}

class GameAchievement {
  final String id;
  final String gameId;
  final String title;
  final String description;
  final String iconUrl;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress; // 0.0 to 1.0

  GameAchievement({
    required this.id,
    required this.gameId,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.points,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
  });

  factory GameAchievement.fromJson(Map<String, dynamic> json) {
    return GameAchievement(
      id: json['id'],
      gameId: json['gameId'],
      title: json['title'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      points: json['points'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      progress: json['progress']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'points': points,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  String get formattedProgress {
    return '${(progress * 100).toInt()}%';
  }
}

class GameLeaderboard {
  final String id;
  final String gameId;
  final String gameTitle;
  final String leaderboardType; // 'daily', 'weekly', 'monthly', 'all_time'
  final List<LeaderboardEntry> entries;
  final DateTime lastUpdated;

  GameLeaderboard({
    required this.id,
    required this.gameId,
    required this.gameTitle,
    required this.leaderboardType,
    required this.entries,
    required this.lastUpdated,
  });

  factory GameLeaderboard.fromJson(Map<String, dynamic> json) {
    return GameLeaderboard(
      id: json['id'],
      gameId: json['gameId'],
      gameTitle: json['gameTitle'],
      leaderboardType: json['leaderboardType'],
      entries: (json['entries'] as List)
          .map((entry) => LeaderboardEntry.fromJson(entry))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'gameTitle': gameTitle,
      'leaderboardType': leaderboardType,
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class LeaderboardEntry {
  final String userId;
  final String username;
  final String? userAvatar;
  final int score;
  final int rank;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.score,
    required this.rank,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      username: json['username'],
      userAvatar: json['userAvatar'],
      score: json['score'],
      rank: json['rank'],
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'score': score,
      'rank': rank,
      'isCurrentUser': isCurrentUser,
    };
  }

  String get formattedScore {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}