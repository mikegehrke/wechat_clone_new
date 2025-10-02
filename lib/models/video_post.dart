class VideoPost {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String videoUrl;
  final String thumbnailUrl;
  final String description;
  final List<String> hashtags;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final DateTime createdAt;
  final bool isLiked;
  final bool isFollowing;
  final String musicTitle;
  final String musicArtist;

  VideoPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.description,
    this.hashtags = const [],
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    required this.createdAt,
    this.isLiked = false,
    this.isFollowing = false,
    this.musicTitle = '',
    this.musicArtist = '',
  });

  factory VideoPost.fromJson(Map<String, dynamic> json) {
    return VideoPost(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      userAvatar: json['userAvatar'],
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      description: json['description'],
      hashtags: List<String>.from(json['hashtags'] ?? []),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      views: json['views'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      isLiked: json['isLiked'] ?? false,
      isFollowing: json['isFollowing'] ?? false,
      musicTitle: json['musicTitle'] ?? '',
      musicArtist: json['musicArtist'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'hashtags': hashtags,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
      'isFollowing': isFollowing,
      'musicTitle': musicTitle,
      'musicArtist': musicArtist,
    };
  }

  VideoPost copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? videoUrl,
    String? thumbnailUrl,
    String? description,
    List<String>? hashtags,
    int? likes,
    int? comments,
    int? shares,
    int? views,
    DateTime? createdAt,
    bool? isLiked,
    bool? isFollowing,
    String? musicTitle,
    String? musicArtist,
  }) {
    return VideoPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      hashtags: hashtags ?? this.hashtags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isFollowing: isFollowing ?? this.isFollowing,
      musicTitle: musicTitle ?? this.musicTitle,
      musicArtist: musicArtist ?? this.musicArtist,
    );
  }

  String get formattedLikes {
    if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    }
    return likes.toString();
  }

  String get formattedComments {
    if (comments >= 1000000) {
      return '${(comments / 1000000).toStringAsFixed(1)}M';
    } else if (comments >= 1000) {
      return '${(comments / 1000).toStringAsFixed(1)}K';
    }
    return comments.toString();
  }

  String get formattedShares {
    if (shares >= 1000000) {
      return '${(shares / 1000000).toStringAsFixed(1)}M';
    } else if (shares >= 1000) {
      return '${(shares / 1000).toStringAsFixed(1)}K';
    }
    return shares.toString();
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}