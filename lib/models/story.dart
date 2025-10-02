class Story {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String contentUrl;
  final StoryType type;
  final String? caption;
  final DateTime createdAt;
  final Duration duration;
  final bool isViewed;
  final int views;
  final List<String> viewers;
  final StoryStatus status;

  Story({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.contentUrl,
    required this.type,
    this.caption,
    required this.createdAt,
    this.duration = const Duration(seconds: 5),
    this.isViewed = false,
    this.views = 0,
    this.viewers = const [],
    this.status = StoryStatus.active,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      userAvatar: json['userAvatar'],
      contentUrl: json['contentUrl'],
      type: StoryType.values.firstWhere(
        (e) => e.toString() == 'StoryType.${json['type']}',
        orElse: () => StoryType.image,
      ),
      caption: json['caption'],
      createdAt: DateTime.parse(json['createdAt']),
      duration: Duration(seconds: json['duration'] ?? 5),
      isViewed: json['isViewed'] ?? false,
      views: json['views'] ?? 0,
      viewers: List<String>.from(json['viewers'] ?? []),
      status: StoryStatus.values.firstWhere(
        (e) => e.toString() == 'StoryStatus.${json['status']}',
        orElse: () => StoryStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'contentUrl': contentUrl,
      'type': type.toString().split('.').last,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration.inSeconds,
      'isViewed': isViewed,
      'views': views,
      'viewers': viewers,
      'status': status.toString().split('.').last,
    };
  }

  Story copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? contentUrl,
    StoryType? type,
    String? caption,
    DateTime? createdAt,
    Duration? duration,
    bool? isViewed,
    int? views,
    List<String>? viewers,
    StoryStatus? status,
  }) {
    return Story(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      contentUrl: contentUrl ?? this.contentUrl,
      type: type ?? this.type,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      isViewed: isViewed ?? this.isViewed,
      views: views ?? this.views,
      viewers: viewers ?? this.viewers,
      status: status ?? this.status,
    );
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

  bool get isExpired {
    final now = DateTime.now();
    final expiryTime = createdAt.add(const Duration(hours: 24));
    return now.isAfter(expiryTime);
  }
}

enum StoryType {
  image,
  video,
  text,
  poll,
  question,
  music,
}

enum StoryStatus {
  active,
  archived,
  deleted,
}

class StoryGroup {
  final String userId;
  final String username;
  final String userAvatar;
  final List<Story> stories;
  final bool hasUnviewedStories;

  StoryGroup({
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.stories,
    this.hasUnviewedStories = false,
  });

  factory StoryGroup.fromJson(Map<String, dynamic> json) {
    return StoryGroup(
      userId: json['userId'],
      username: json['username'],
      userAvatar: json['userAvatar'],
      stories: (json['stories'] as List)
          .map((story) => Story.fromJson(story))
          .toList(),
      hasUnviewedStories: json['hasUnviewedStories'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'stories': stories.map((story) => story.toJson()).toList(),
      'hasUnviewedStories': hasUnviewedStories,
    };
  }
}