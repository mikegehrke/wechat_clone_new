class VideoContent {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String channelName;
  final String channelAvatar;
  final int views;
  final int likes;
  final int dislikes;
  final int comments;
  final DateTime publishedAt;
  final Duration duration;
  final List<String> tags;
  final String category;
  final bool isLive;
  final bool isSubscribed;
  final VideoQuality quality;
  final ContentType type;

  VideoContent({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.channelName,
    required this.channelAvatar,
    this.views = 0,
    this.likes = 0,
    this.dislikes = 0,
    this.comments = 0,
    required this.publishedAt,
    required this.duration,
    this.tags = const [],
    this.category = '',
    this.isLive = false,
    this.isSubscribed = false,
    this.quality = VideoQuality.hd,
    this.type = ContentType.video,
  });

  factory VideoContent.fromJson(Map<String, dynamic> json) {
    return VideoContent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      videoUrl: json['videoUrl'],
      channelName: json['channelName'],
      channelAvatar: json['channelAvatar'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      comments: json['comments'] ?? 0,
      publishedAt: DateTime.parse(json['publishedAt']),
      duration: Duration(seconds: json['duration'] ?? 0),
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] ?? '',
      isLive: json['isLive'] ?? false,
      isSubscribed: json['isSubscribed'] ?? false,
      quality: VideoQuality.values.firstWhere(
        (e) => e.toString() == 'VideoQuality.${json['quality']}',
        orElse: () => VideoQuality.hd,
      ),
      type: ContentType.values.firstWhere(
        (e) => e.toString() == 'ContentType.${json['type']}',
        orElse: () => ContentType.video,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'channelName': channelName,
      'channelAvatar': channelAvatar,
      'views': views,
      'likes': likes,
      'dislikes': dislikes,
      'comments': comments,
      'publishedAt': publishedAt.toIso8601String(),
      'duration': duration.inSeconds,
      'tags': tags,
      'category': category,
      'isLive': isLive,
      'isSubscribed': isSubscribed,
      'quality': quality.toString().split('.').last,
      'type': type.toString().split('.').last,
    };
  }

  String get formattedViews {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  String get formattedLikes {
    if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    } else if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    }
    return likes.toString();
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get formattedPublishedDate {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
  }
}

enum VideoQuality {
  sd,
  hd,
  fullHd,
  ultraHd,
}

enum ContentType {
  video,
  movie,
  series,
  documentary,
  music,
  live,
}

class Movie {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String posterUrl;
  final String trailerUrl;
  final String videoUrl;
  final List<String> genres;
  final int year;
  final String director;
  final List<String> cast;
  final double rating;
  final int ratingCount;
  final Duration duration;
  final String ageRating;
  final String language;
  final List<String> subtitles;
  final bool isNewRelease;
  final bool isTrending;
  final bool isFeatured;
  final bool isWatched;
  final bool isInWatchlist;
  final DateTime addedAt;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.posterUrl,
    this.trailerUrl = '',
    this.videoUrl = '',
    this.genres = const [],
    required this.year,
    this.director = '',
    this.cast = const [],
    this.rating = 0.0,
    this.ratingCount = 0,
    required this.duration,
    this.ageRating = '',
    this.language = 'English',
    this.subtitles = const [],
    this.isNewRelease = false,
    this.isTrending = false,
    this.isFeatured = false,
    this.isWatched = false,
    this.isInWatchlist = false,
    required this.addedAt,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      posterUrl: json['posterUrl'],
      trailerUrl: json['trailerUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      year: json['year'],
      director: json['director'] ?? '',
      cast: List<String>.from(json['cast'] ?? []),
      rating: json['rating']?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] ?? 0,
      duration: Duration(minutes: json['duration'] ?? 0),
      ageRating: json['ageRating'] ?? '',
      language: json['language'] ?? 'English',
      subtitles: List<String>.from(json['subtitles'] ?? []),
      isNewRelease: json['isNewRelease'] ?? false,
      isTrending: json['isTrending'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      isWatched: json['isWatched'] ?? false,
      isInWatchlist: json['isInWatchlist'] ?? false,
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'posterUrl': posterUrl,
      'trailerUrl': trailerUrl,
      'videoUrl': videoUrl,
      'genres': genres,
      'year': year,
      'director': director,
      'cast': cast,
      'rating': rating,
      'ratingCount': ratingCount,
      'duration': duration.inMinutes,
      'ageRating': ageRating,
      'language': language,
      'subtitles': subtitles,
      'isNewRelease': isNewRelease,
      'isTrending': isTrending,
      'isFeatured': isFeatured,
      'isWatched': isWatched,
      'isInWatchlist': isInWatchlist,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get formattedCast {
    return cast.take(3).join(', ');
  }
}

class Series {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String posterUrl;
  final List<String> genres;
  final int year;
  final String creator;
  final List<String> cast;
  final double rating;
  final int ratingCount;
  final int seasons;
  final int episodes;
  final String ageRating;
  final String language;
  final List<String> subtitles;
  final bool isNewRelease;
  final bool isTrending;
  final bool isFeatured;
  final bool isWatched;
  final bool isInWatchlist;
  final DateTime addedAt;
  final List<Season> seasonList;

  Series({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.posterUrl,
    this.genres = const [],
    required this.year,
    this.creator = '',
    this.cast = const [],
    this.rating = 0.0,
    this.ratingCount = 0,
    this.seasons = 0,
    this.episodes = 0,
    this.ageRating = '',
    this.language = 'English',
    this.subtitles = const [],
    this.isNewRelease = false,
    this.isTrending = false,
    this.isFeatured = false,
    this.isWatched = false,
    this.isInWatchlist = false,
    required this.addedAt,
    this.seasonList = const [],
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      posterUrl: json['posterUrl'],
      genres: List<String>.from(json['genres'] ?? []),
      year: json['year'],
      creator: json['creator'] ?? '',
      cast: List<String>.from(json['cast'] ?? []),
      rating: json['rating']?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] ?? 0,
      seasons: json['seasons'] ?? 0,
      episodes: json['episodes'] ?? 0,
      ageRating: json['ageRating'] ?? '',
      language: json['language'] ?? 'English',
      subtitles: List<String>.from(json['subtitles'] ?? []),
      isNewRelease: json['isNewRelease'] ?? false,
      isTrending: json['isTrending'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      isWatched: json['isWatched'] ?? false,
      isInWatchlist: json['isInWatchlist'] ?? false,
      addedAt: DateTime.parse(json['addedAt']),
      seasonList: (json['seasonList'] as List?)
          ?.map((season) => Season.fromJson(season))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'posterUrl': posterUrl,
      'genres': genres,
      'year': year,
      'creator': creator,
      'cast': cast,
      'rating': rating,
      'ratingCount': ratingCount,
      'seasons': seasons,
      'episodes': episodes,
      'ageRating': ageRating,
      'language': language,
      'subtitles': subtitles,
      'isNewRelease': isNewRelease,
      'isTrending': isTrending,
      'isFeatured': isFeatured,
      'isWatched': isWatched,
      'isInWatchlist': isInWatchlist,
      'addedAt': addedAt.toIso8601String(),
      'seasonList': seasonList.map((season) => season.toJson()).toList(),
    };
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  String get formattedCast {
    return cast.take(3).join(', ');
  }
}

class Season {
  final String id;
  final String seriesId;
  final int seasonNumber;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int episodes;
  final DateTime releaseDate;
  final List<Episode> episodeList;

  Season({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.episodes,
    required this.releaseDate,
    this.episodeList = const [],
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'],
      seriesId: json['seriesId'],
      seasonNumber: json['seasonNumber'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      episodes: json['episodes'],
      releaseDate: DateTime.parse(json['releaseDate']),
      episodeList: (json['episodeList'] as List?)
          ?.map((episode) => Episode.fromJson(episode))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seriesId': seriesId,
      'seasonNumber': seasonNumber,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'episodes': episodes,
      'releaseDate': releaseDate.toIso8601String(),
      'episodeList': episodeList.map((episode) => episode.toJson()).toList(),
    };
  }
}

class Episode {
  final String id;
  final String seriesId;
  final String seasonId;
  final int episodeNumber;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final Duration duration;
  final DateTime releaseDate;
  final bool isWatched;
  final Duration? watchProgress;

  Episode({
    required this.id,
    required this.seriesId,
    required this.seasonId,
    required this.episodeNumber,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.releaseDate,
    this.isWatched = false,
    this.watchProgress,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      seriesId: json['seriesId'],
      seasonId: json['seasonId'],
      episodeNumber: json['episodeNumber'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      videoUrl: json['videoUrl'],
      duration: Duration(minutes: json['duration'] ?? 0),
      releaseDate: DateTime.parse(json['releaseDate']),
      isWatched: json['isWatched'] ?? false,
      watchProgress: json['watchProgress'] != null 
          ? Duration(seconds: json['watchProgress']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seriesId': seriesId,
      'seasonId': seasonId,
      'episodeNumber': episodeNumber,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'duration': duration.inMinutes,
      'releaseDate': releaseDate.toIso8601String(),
      'isWatched': isWatched,
      'watchProgress': watchProgress?.inSeconds,
    };
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  double get watchProgressPercentage {
    if (watchProgress == null) return 0.0;
    return (watchProgress!.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
  }
}

class Playlist {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String ownerName;
  final String ownerAvatar;
  final int videoCount;
  final DateTime createdAt;
  final List<VideoContent> videos;
  final bool isPublic;
  final bool isSubscribed;

  Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.ownerName,
    required this.ownerAvatar,
    required this.videoCount,
    required this.createdAt,
    this.videos = const [],
    this.isPublic = true,
    this.isSubscribed = false,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnailUrl'],
      ownerName: json['ownerName'],
      ownerAvatar: json['ownerAvatar'],
      videoCount: json['videoCount'],
      createdAt: DateTime.parse(json['createdAt']),
      videos: (json['videos'] as List?)
          ?.map((video) => VideoContent.fromJson(video))
          .toList() ?? [],
      isPublic: json['isPublic'] ?? true,
      isSubscribed: json['isSubscribed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'ownerName': ownerName,
      'ownerAvatar': ownerAvatar,
      'videoCount': videoCount,
      'createdAt': createdAt.toIso8601String(),
      'videos': videos.map((video) => video.toJson()).toList(),
      'isPublic': isPublic,
      'isSubscribed': isSubscribed,
    };
  }
}