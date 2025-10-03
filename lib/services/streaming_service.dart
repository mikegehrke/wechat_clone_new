import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/streaming.dart';

class StreamingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _videosCollection = 'videos';
  static const String _moviesCollection = 'movies';
  static const String _seriesCollection = 'series';
  static const String _playlistsCollection = 'playlists';
  static const String _usersCollection = 'users';
  static const String _channelsCollection = 'channels';
  static const String _likesSubcollection = 'likes';
  static const String _subscriptionsSubcollection = 'subscriptions';
  static const String _watchlistSubcollection = 'watchlist';
  static const String _historySubcollection = 'watchHistory';
  // Toggle watchlist
  static Future<void> toggleWatchlist(String videoId, String userId) async {
    try {
      final watchlistItemRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_watchlistSubcollection)
          .doc(videoId);
      final existing = await watchlistItemRef.get();
      if (existing.exists) {
        await watchlistItemRef.delete();
      } else {
        await watchlistItemRef.set({
          'contentId': videoId,
          'type': 'video',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle watchlist: $e');
    }
  }

  // Get trending videos
  static Future<List<VideoContent>> getTrendingVideos() async {
    try {
      final snapshot = await _firestore
          .collection(_videosCollection)
          .where('isTrending', isEqualTo: true)
          .orderBy('publishedAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return VideoContent.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get trending videos: $e');
    }
  }

  // Get live videos
  static Future<List<VideoContent>> getLiveVideos() async {
    try {
      final snapshot = await _firestore
          .collection(_videosCollection)
          .where('isLive', isEqualTo: true)
          .orderBy('publishedAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return VideoContent.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get live videos: $e');
    }
  }

  // Get videos by category
  static Future<List<VideoContent>> getVideosByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_videosCollection)
          .where('category', isEqualTo: category)
          .orderBy('publishedAt', descending: true)
          .limit(100)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return VideoContent.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get videos by category: $e');
    }
  }

  // Search videos
  static Future<List<VideoContent>> searchVideos(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_videosCollection)
          .orderBy('publishedAt', descending: true)
          .limit(200)
          .get();
      final normalized = query.toLowerCase();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return VideoContent.fromJson(data);
      }).where((v) => v.title.toLowerCase().contains(normalized)
          || v.description.toLowerCase().contains(normalized)
          || v.tags.any((t) => t.toLowerCase().contains(normalized))
      ).toList();
    } catch (e) {
      throw Exception('Failed to search videos: $e');
    }
  }

  // Get video details
  static Future<VideoContent?> getVideoDetails(String videoId) async {
    try {
      final doc = await _firestore.collection(_videosCollection).doc(videoId).get();
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return VideoContent.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get video details: $e');
    }
  }

  // Get recommended videos
  static Future<List<VideoContent>> getRecommendedVideos(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_videosCollection)
          .orderBy('views', descending: true)
          .limit(10)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return VideoContent.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get recommended videos: $e');
    }
  }

  // Get user's watch history
  static Future<List<VideoContent>> getWatchHistory(String userId) async {
    try {
      final history = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_historySubcollection)
          .orderBy('lastWatchedAt', descending: true)
          .limit(50)
          .get();
      final ids = history.docs.map((d) => d.id).toList();
      if (ids.isEmpty) return [];
      final List<VideoContent> videos = [];
      for (var i = 0; i < ids.length; i += 10) {
        final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
        final snap = await _firestore
            .collection(_videosCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        videos.addAll(snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return VideoContent.fromJson(data);
        }));
      }
      return videos;
    } catch (e) {
      throw Exception('Failed to get watch history: $e');
    }
  }

  // Get user's subscriptions
  static Future<List<VideoContent>> getSubscriptions(String userId) async {
    try {
      final subsSnap = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_subscriptionsSubcollection)
          .get();
      final channelIds = subsSnap.docs.map((d) => d.id).toList();
      if (channelIds.isEmpty) return [];
      final List<VideoContent> videos = [];
      for (var i = 0; i < channelIds.length; i += 10) {
        final chunk = channelIds.sublist(i, i + 10 > channelIds.length ? channelIds.length : i + 10);
        final snap = await _firestore
            .collection(_videosCollection)
            .where('channelId', whereIn: chunk)
            .orderBy('publishedAt', descending: true)
            .get();
        videos.addAll(snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          data['isSubscribed'] = true;
          return VideoContent.fromJson(data);
        }));
      }
      return videos;
    } catch (e) {
      throw Exception('Failed to get subscriptions: $e');
    }
  }

  // Subscribe to channel
  static Future<void> subscribeToChannel(String channelId, String userId) async {
    try {
      final subRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_subscriptionsSubcollection)
          .doc(channelId);
      await subRef.set({'channelId': channelId, 'createdAt': DateTime.now().toIso8601String()});
    } catch (e) {
      throw Exception('Failed to subscribe to channel: $e');
    }
  }

  // Like video
  static Future<void> likeVideo(String videoId, String userId) async {
    try {
      final videoRef = _firestore.collection(_videosCollection).doc(videoId);
      final likeRef = videoRef.collection(_likesSubcollection).doc(userId);
      await _firestore.runTransaction((tx) async {
        final likeSnap = await tx.get(likeRef);
        if (!likeSnap.exists) {
          tx.set(likeRef, {'userId': userId, 'createdAt': DateTime.now().toIso8601String()});
          tx.update(videoRef, {'likes': FieldValue.increment(1)});
        }
      });
    } catch (e) {
      throw Exception('Failed to like video: $e');
    }
  }

  // Get movies
  static Future<List<Movie>> getMovies({
    String? genre,
    String? year,
    bool? isNewRelease,
    bool? isTrending,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _firestore.collection(_moviesCollection).orderBy('addedAt', descending: true).limit(100);
      if (genre != null && genre.isNotEmpty) {
        q = q.where('genres', arrayContains: genre);
      }
      if (year != null && year.isNotEmpty) {
        q = q.where('year', isEqualTo: int.tryParse(year));
      }
      if (isNewRelease != null) {
        q = q.where('isNewRelease', isEqualTo: isNewRelease);
      }
      if (isTrending != null) {
        q = q.where('isTrending', isEqualTo: isTrending);
      }
      final snapshot = await q.get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Movie.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get movies: $e');
    }
  }

  // Get series
  static Future<List<Series>> getSeries({
    String? genre,
    String? year,
    bool? isNewRelease,
    bool? isTrending,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _firestore.collection(_seriesCollection).orderBy('addedAt', descending: true).limit(100);
      if (genre != null && genre.isNotEmpty) {
        q = q.where('genres', arrayContains: genre);
      }
      if (year != null && year.isNotEmpty) {
        q = q.where('year', isEqualTo: int.tryParse(year));
      }
      if (isNewRelease != null) {
        q = q.where('isNewRelease', isEqualTo: isNewRelease);
      }
      if (isTrending != null) {
        q = q.where('isTrending', isEqualTo: isTrending);
      }
      final snapshot = await q.get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Series.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get series: $e');
    }
  }

  // Get movie details
  static Future<Movie?> getMovieDetails(String movieId) async {
    try {
      final doc = await _firestore.collection(_moviesCollection).doc(movieId).get();
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return Movie.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get movie details: $e');
    }
  }

  // Get series details
  static Future<Series?> getSeriesDetails(String seriesId) async {
    try {
      final doc = await _firestore.collection(_seriesCollection).doc(seriesId).get();
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return Series.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get series details: $e');
    }
  }

  // Add to watchlist
  static Future<void> addToWatchlist(String contentId, String userId, String type) async {
    try {
      final wlRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_watchlistSubcollection)
          .doc(contentId);
      await wlRef.set({
        'contentId': contentId,
        'type': type,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add to watchlist: $e');
    }
  }

  // Remove from watchlist
  static Future<void> removeFromWatchlist(String contentId, String userId) async {
    try {
      final wlRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_watchlistSubcollection)
          .doc(contentId);
      await wlRef.delete();
    } catch (e) {
      throw Exception('Failed to remove from watchlist: $e');
    }
  }

  // Get user's watchlist
  static Future<List<dynamic>> getUserWatchlist(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_watchlistSubcollection)
          .get();
      final items = snapshot.docs.map((d) => d.data()).toList();
      final List<dynamic> results = [];
      for (final item in items) {
        final type = item['type'] as String? ?? 'video';
        final id = item['contentId'] ?? item['videoId'];
        if (id == null) continue;
        if (type == 'movie') {
          final doc = await _firestore.collection(_moviesCollection).doc(id).get();
          if (doc.exists) {
            final data = Map<String, dynamic>.from(doc.data()!);
            data['id'] = doc.id;
            results.add(Movie.fromJson(data));
          }
        } else if (type == 'series') {
          final doc = await _firestore.collection(_seriesCollection).doc(id).get();
          if (doc.exists) {
            final data = Map<String, dynamic>.from(doc.data()!);
            data['id'] = doc.id;
            results.add(Series.fromJson(data));
          }
        } else {
          final doc = await _firestore.collection(_videosCollection).doc(id).get();
          if (doc.exists) {
            final data = Map<String, dynamic>.from(doc.data()!);
            data['id'] = doc.id;
            results.add(VideoContent.fromJson(data));
          }
        }
      }
      return results;
    } catch (e) {
      throw Exception('Failed to get watchlist: $e');
    }
  }

  // Get playlists
  static Future<List<Playlist>> getPlaylists(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_playlistsCollection)
          .where('ownerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return Playlist.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get playlists: $e');
    }
  }

  // Create playlist
  static Future<Playlist> createPlaylist({
    required String title,
    required String description,
    required String userId,
  }) async {
    try {
      final docRef = _firestore.collection(_playlistsCollection).doc();
      final playlist = Playlist(
        id: docRef.id,
        title: title,
        description: description,
        thumbnailUrl: '',
        ownerName: '',
        ownerAvatar: '',
        videoCount: 0,
        createdAt: DateTime.now(),
      );
      final data = playlist.toJson();
      data['ownerId'] = userId;
      await docRef.set(data);
      return playlist;
    } catch (e) {
      throw Exception('Failed to create playlist: $e');
    }
  }

  // Get categories
  static Future<List<String>> getCategories() async {
    try {
      final snap = await _firestore.collection('streamingCategories').orderBy('name').get();
      if (snap.docs.isEmpty) return [];
      return snap.docs.map((d) => (d.data()['name'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  // Get genres
  static Future<List<String>> getGenres() async {
    try {
      final snap = await _firestore.collection('genres').orderBy('name').get();
      if (snap.docs.isEmpty) return [];
      return snap.docs.map((d) => (d.data()['name'] as String?) ?? '').where((s) => s.isNotEmpty).toList();
    } catch (e) {
      throw Exception('Failed to get genres: $e');
    }
  }

  // Mock data generators
  static List<VideoContent> _createMockVideos() {
    final categories = ['Music', 'Gaming', 'Entertainment', 'Education', 'Science & Technology'];
    final channels = [
      'Tech Channel', 'Music Hub', 'Gaming World', 'Educational TV', 'Science Lab',
      'Entertainment Plus', 'News Network', 'Sports Central', 'Comedy Club', 'Travel Guide',
    ];
    final titles = [
      'Amazing Flutter Tutorial', 'Best Mobile Games 2024', 'Learn Programming', 'Tech News Today',
      'Music Mix 2024', 'Gaming Highlights', 'Educational Content', 'Science Experiments',
      'Entertainment News', 'Sports Highlights', 'Comedy Skits', 'Travel Vlogs',
    ];
    
    return List.generate(50, (index) {
      final category = categories[index % categories.length];
      final channel = channels[index % channels.length];
      final title = titles[index % titles.length];
      final views = 1000 + (index * 10000);
      final likes = 100 + (index * 500);
      final duration = Duration(minutes: 5 + (index % 30));
      
      return VideoContent(
        id: 'video_$index',
        title: title,
        description: 'This is an amazing $category video that you will love!',
        thumbnailUrl: 'https://via.placeholder.com/320x180/${_getRandomColor()}/FFFFFF?text=$title',
        videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        channelName: channel,
        channelAvatar: 'https://via.placeholder.com/50x50/${_getRandomColor()}/FFFFFF?text=${channel[0]}',
        views: views,
        likes: likes,
        dislikes: likes ~/ 10,
        comments: likes ~/ 5,
        publishedAt: DateTime.now().subtract(Duration(days: index)),
        duration: duration,
        tags: _getRandomTags(),
        category: category,
        isLive: index % 10 == 0,
        isSubscribed: index % 5 == 0,
        quality: VideoQuality.values[index % VideoQuality.values.length],
        type: ContentType.values[index % ContentType.values.length],
      );
    });
  }

  static List<Movie> _createMockMovies() {
    final genres = ['Action', 'Comedy', 'Drama', 'Horror', 'Sci-Fi', 'Romance', 'Thriller'];
    final titles = [
      'The Matrix', 'Inception', 'Interstellar', 'Avatar', 'Titanic',
      'The Dark Knight', 'Pulp Fiction', 'Forrest Gump', 'The Godfather', 'Schindler\'s List',
      'The Lord of the Rings', 'Star Wars', 'Jurassic Park', 'Back to the Future', 'Terminator',
    ];
    final directors = [
      'Christopher Nolan', 'Steven Spielberg', 'Martin Scorsese', 'Quentin Tarantino', 'James Cameron',
      'Ridley Scott', 'Stanley Kubrick', 'Alfred Hitchcock', 'Francis Ford Coppola', 'Peter Jackson',
    ];
    
    return List.generate(30, (index) {
      final title = titles[index % titles.length];
      final genre = genres[index % genres.length];
      final director = directors[index % directors.length];
      final year = 1990 + (index % 30);
      final rating = 3.0 + (index % 3) + (index % 2 == 0 ? 0.5 : 0.0);
      final duration = Duration(minutes: 90 + (index * 10));
      
      return Movie(
        id: 'movie_$index',
        title: title,
        description: 'An epic $genre movie that will keep you on the edge of your seat.',
        thumbnailUrl: 'https://via.placeholder.com/300x450/${_getRandomColor()}/FFFFFF?text=$title',
        posterUrl: 'https://via.placeholder.com/400x600/${_getRandomColor()}/FFFFFF?text=$title',
        trailerUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        genres: [genre, genres[(index + 1) % genres.length]],
        year: year,
        director: director,
        cast: ['Actor 1', 'Actor 2', 'Actor 3'],
        rating: rating,
        ratingCount: 1000 + (index * 100),
        duration: duration,
        ageRating: 'PG-13',
        language: 'English',
        subtitles: ['English', 'Spanish', 'French'],
        isNewRelease: index % 5 == 0,
        isTrending: index % 7 == 0,
        isFeatured: index % 10 == 0,
        isWatched: index % 3 == 0,
        isInWatchlist: index % 4 == 0,
        addedAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }

  static List<Series> _createMockSeries() {
    final genres = ['Drama', 'Comedy', 'Action', 'Sci-Fi', 'Thriller', 'Crime', 'Fantasy'];
    final titles = [
      'Breaking Bad', 'Game of Thrones', 'Stranger Things', 'The Office', 'Friends',
      'The Walking Dead', 'House of Cards', 'Narcos', 'Black Mirror', 'The Crown',
      'Ozark', 'Money Heist', 'The Witcher', 'Bridgerton', 'The Mandalorian',
    ];
    final creators = [
      'Vince Gilligan', 'David Benioff', 'The Duffer Brothers', 'Greg Daniels', 'David Crane',
      'Frank Darabont', 'Beau Willimon', 'Carlo Bernard', 'Charlie Brooker', 'Peter Morgan',
    ];
    
    return List.generate(20, (index) {
      final title = titles[index % titles.length];
      final genre = genres[index % genres.length];
      final creator = creators[index % creators.length];
      final year = 2010 + (index % 10);
      final rating = 3.0 + (index % 3) + (index % 2 == 0 ? 0.5 : 0.0);
      final seasons = 1 + (index % 8);
      final episodes = seasons * (8 + (index % 5));
      
      return Series(
        id: 'series_$index',
        title: title,
        description: 'An amazing $genre series that will keep you hooked.',
        thumbnailUrl: 'https://via.placeholder.com/300x450/${_getRandomColor()}/FFFFFF?text=$title',
        posterUrl: 'https://via.placeholder.com/400x600/${_getRandomColor()}/FFFFFF?text=$title',
        genres: [genre, genres[(index + 1) % genres.length]],
        year: year,
        creator: creator,
        cast: ['Actor 1', 'Actor 2', 'Actor 3'],
        rating: rating,
        ratingCount: 1000 + (index * 100),
        seasons: seasons,
        episodes: episodes,
        ageRating: 'TV-MA',
        language: 'English',
        subtitles: ['English', 'Spanish', 'French'],
        isNewRelease: index % 5 == 0,
        isTrending: index % 7 == 0,
        isFeatured: index % 10 == 0,
        isWatched: index % 3 == 0,
        isInWatchlist: index % 4 == 0,
        addedAt: DateTime.now().subtract(Duration(days: index)),
        seasonList: _createMockSeasons('series_$index', seasons),
      );
    });
  }

  static List<Season> _createMockSeasons(String seriesId, int seasonCount) {
    return List.generate(seasonCount, (index) {
      return Season(
        id: 'season_${seriesId}_${index + 1}',
        seriesId: seriesId,
        seasonNumber: index + 1,
        title: 'Season ${index + 1}',
        description: 'Season ${index + 1} of the series',
        thumbnailUrl: 'https://via.placeholder.com/300x450/${_getRandomColor()}/FFFFFF?text=Season+${index + 1}',
        episodes: 8 + (index % 5),
        releaseDate: DateTime.now().subtract(Duration(days: index * 365)),
        episodeList: _createMockEpisodes(seriesId, 'season_${seriesId}_${index + 1}', 8 + (index % 5)),
      );
    });
  }

  static List<Episode> _createMockEpisodes(String seriesId, String seasonId, int episodeCount) {
    return List.generate(episodeCount, (index) {
      return Episode(
        id: 'episode_${seriesId}_${seasonId}_${index + 1}',
        seriesId: seriesId,
        seasonId: seasonId,
        episodeNumber: index + 1,
        title: 'Episode ${index + 1}',
        description: 'Episode ${index + 1} description',
        thumbnailUrl: 'https://via.placeholder.com/320x180/${_getRandomColor()}/FFFFFF?text=Episode+${index + 1}',
        videoUrl: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        duration: Duration(minutes: 45 + (index % 15)),
        releaseDate: DateTime.now().subtract(Duration(days: index * 7)),
        isWatched: index % 3 == 0,
        watchProgress: index % 2 == 0 ? Duration(minutes: 20 + (index % 10)) : null,
      );
    });
  }

  static List<Playlist> _createMockPlaylists() {
    final titles = [
      'My Favorites', 'Watch Later', 'Music Videos', 'Educational Content',
      'Gaming Highlights', 'Tech Reviews', 'Comedy Skits', 'Travel Vlogs',
    ];
    
    return List.generate(8, (index) {
      final title = titles[index % titles.length];
      final videoCount = 5 + (index * 3);
      
      return Playlist(
        id: 'playlist_$index',
        title: title,
        description: 'A collection of $title',
        thumbnailUrl: 'https://via.placeholder.com/300x200/${_getRandomColor()}/FFFFFF?text=$title',
        ownerName: 'User',
        ownerAvatar: 'https://via.placeholder.com/50x50/${_getRandomColor()}/FFFFFF?text=U',
        videoCount: videoCount,
        createdAt: DateTime.now().subtract(Duration(days: index * 30)),
        videos: _createMockVideos().take(videoCount).toList(),
        isPublic: index % 2 == 0,
        isSubscribed: index % 3 == 0,
      );
    });
  }

  static List<String> _getRandomTags() {
    final tags = [
      'Flutter', 'Mobile', 'Tech', 'Programming', 'Tutorial',
      'Gaming', 'Music', 'Entertainment', 'Education', 'Science',
    ];
    return List.generate(3, (index) => tags[Random().nextInt(tags.length)]);
  }

  static String _getRandomColor() {
    final colors = [
      'FF6B6B', '4ECDC4', '45B7D1', '96CEB4', 'FFEAA7', 'DDA0DD',
      '98D8C8', 'F7DC6F', 'BB8FCE', '85C1E9', 'F8C471', '82E0AA',
    ];
    return colors[Random().nextInt(colors.length)];
  }
}