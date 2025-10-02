import 'dart:math';
import '../models/social.dart';

class SocialService {
  // Toggle like on post
  static Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Posts
  static Future<List<SocialPost>> getFeed(String userId) async {
    try {
      // In real app, make API call to get social feed
      return _createMockPosts();
    } catch (e) {
      throw Exception('Failed to get feed: $e');
    }
  }

  static Future<SocialPost> createPost({
    required String authorId,
    required String authorName,
    required String authorAvatar,
    required String content,
    List<String> images = const [],
    List<String> videos = const [],
    String? location,
    List<String> tags = const [],
    List<String> mentions = const [],
    PostType type = PostType.text,
    PostPrivacy privacy = PostPrivacy.public,
  }) async {
    try {
      final post = SocialPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
        images: images,
        videos: videos,
        location: location,
        tags: tags,
        mentions: mentions,
        type: type,
        privacy: privacy,
        createdAt: DateTime.now(),
      );

      // In real app, save post to database
      await Future.delayed(const Duration(milliseconds: 500));

      return post;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  static Future<void> likePost(String postId, String userId) async {
    try {
      // In real app, make API call to like post
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  static Future<void> unlikePost(String postId, String userId) async {
    try {
      // In real app, make API call to unlike post
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  static Future<void> sharePost(String postId, String userId) async {
    try {
      // In real app, make API call to share post
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to share post: $e');
    }
  }

  static Future<void> bookmarkPost(String postId, String userId) async {
    try {
      // In real app, make API call to bookmark post
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to bookmark post: $e');
    }
  }

  // Comments
  static Future<List<SocialComment>> getPostComments(String postId) async {
    try {
      // In real app, make API call to get comments
      return _createMockComments(postId);
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }

  static Future<SocialComment> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String authorAvatar,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final comment = SocialComment(
        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
        parentCommentId: parentCommentId,
        createdAt: DateTime.now(),
      );

      // In real app, save comment to database
      await Future.delayed(const Duration(milliseconds: 500));

      return comment;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  static Future<void> likeComment(String commentId, String userId) async {
    try {
      // In real app, make API call to like comment
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to like comment: $e');
    }
  }

  // Users
  static Future<List<SocialUser>> searchUsers(String query) async {
    try {
      // In real app, make API call to search users
      final users = _createMockUsers();
      return users.where((user) => 
        user.username.toLowerCase().contains(query.toLowerCase()) ||
        user.displayName.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  static Future<SocialUser?> getUserProfile(String userId) async {
    try {
      // In real app, make API call to get user profile
      final users = _createMockUsers();
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  static Future<void> followUser(String userId, String followerId) async {
    try {
      // In real app, make API call to follow user
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  static Future<void> unfollowUser(String userId, String followerId) async {
    try {
      // In real app, make API call to unfollow user
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  static Future<List<SocialUser>> getFollowers(String userId) async {
    try {
      // In real app, make API call to get followers
      return _createMockUsers().take(20).toList();
    } catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  static Future<List<SocialUser>> getFollowing(String userId) async {
    try {
      // In real app, make API call to get following
      return _createMockUsers().take(20).toList();
    } catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }

  // Messages
  static Future<List<SocialChat>> getUserChats(String userId) async {
    try {
      // In real app, make API call to get user chats
      return _createMockChats();
    } catch (e) {
      throw Exception('Failed to get chats: $e');
    }
  }

  static Future<List<SocialMessage>> getChatMessages(String chatId) async {
    try {
      // In real app, make API call to get chat messages
      return _createMockMessages(chatId);
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  static Future<SocialMessage> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String content,
    MessageType type = MessageType.text,
    List<String> attachments = const [],
    String? replyToMessageId,
  }) async {
    try {
      final message = SocialMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        content: content,
        type: type,
        attachments: attachments,
        replyToMessageId: replyToMessageId,
        createdAt: DateTime.now(),
        isDelivered: true,
      );

      // In real app, save message to database
      await Future.delayed(const Duration(milliseconds: 500));

      return message;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  static Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      // In real app, make API call to mark message as read
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Events
  static Future<List<SocialEvent>> getEvents({
    String? location,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // In real app, make API call to get events
      return _createMockEvents();
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  static Future<SocialEvent> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required String organizerId,
    required String organizerName,
    required String organizerAvatar,
    EventPrivacy privacy = EventPrivacy.public,
    String? imageUrl,
    int maxAttendees = 0,
    bool isOnline = false,
    String? meetingLink,
  }) async {
    try {
      final event = SocialEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        location: location,
        startDate: startDate,
        endDate: endDate,
        organizerId: organizerId,
        organizerName: organizerName,
        organizerAvatar: organizerAvatar,
        privacy: privacy,
        imageUrl: imageUrl,
        maxAttendees: maxAttendees,
        isOnline: isOnline,
        meetingLink: meetingLink,
      );

      // In real app, save event to database
      await Future.delayed(const Duration(milliseconds: 500));

      return event;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  static Future<void> attendEvent(String eventId, String userId) async {
    try {
      // In real app, make API call to attend event
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to attend event: $e');
    }
  }

  static Future<void> interestedInEvent(String eventId, String userId) async {
    try {
      // In real app, make API call to mark as interested
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to mark as interested: $e');
    }
  }

  // Notifications
  static Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    try {
      // In real app, make API call to get notifications
      return _createMockNotifications();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      // In real app, make API call to mark notification as read
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mock data generators
  static List<SocialPost> _createMockPosts() {
    final contents = [
      'Just had an amazing day at the beach! 🏖️',
      'Working on my new project. Excited to share it soon! 💻',
      'Beautiful sunset today. Nature never fails to amaze me 🌅',
      'Coffee and coding - the perfect combination ☕',
      'Weekend vibes! Time to relax and recharge 🎉',
      'New restaurant opened downtown. The food was incredible! 🍽️',
      'Morning run completed. Feeling energized! 🏃‍♂️',
      'Reading a great book. Highly recommend it! 📚',
      'Concert last night was absolutely amazing! 🎵',
      'Working from home today. Productivity mode activated! 🏠',
    ];

    final locations = [
      'New York, NY',
      'Los Angeles, CA',
      'Chicago, IL',
      'Houston, TX',
      'Phoenix, AZ',
      'Philadelphia, PA',
      'San Antonio, TX',
      'San Diego, CA',
      'Dallas, TX',
      'San Jose, CA',
    ];

    return List.generate(20, (index) {
      final content = contents[index % contents.length];
      final location = locations[index % locations.length];
      final likes = 10 + (index * 5);
      final comments = 2 + (index % 5);
      final shares = 1 + (index % 3);

      return SocialPost(
        id: 'post_$index',
        authorId: 'user_${index % 10}',
        authorName: 'User ${index + 1}',
        authorAvatar: 'https://via.placeholder.com/50x50/${_getRandomColor()}/FFFFFF?text=U${index + 1}',
        content: content,
        images: index % 3 == 0 ? ['https://via.placeholder.com/400x300/${_getRandomColor()}/FFFFFF?text=Image'] : [],
        videos: index % 5 == 0 ? ['https://via.placeholder.com/400x300/${_getRandomColor()}/FFFFFF?text=Video'] : [],
        location: index % 4 == 0 ? location : null,
        tags: _getRandomTags(),
        mentions: index % 6 == 0 ? ['@friend1', '@friend2'] : [],
        likesCount: likes,
        commentsCount: comments,
        sharesCount: shares,
        createdAt: DateTime.now().subtract(Duration(hours: index * 2)),
        isLiked: index % 3 == 0,
        isShared: index % 4 == 0,
        isBookmarked: index % 5 == 0,
        type: PostType.values[index % PostType.values.length],
        privacy: PostPrivacy.values[index % PostPrivacy.values.length],
        comments: _createMockComments('post_$index'),
      );
    });
  }

  static List<SocialComment> _createMockComments(String postId) {
    final contents = [
      'Great post! 👍',
      'I totally agree with you!',
      'Thanks for sharing this!',
      'This is amazing! 🔥',
      'Love this! ❤️',
      'So true!',
      'Can\'t wait to see more!',
      'This made my day! 😊',
      'Absolutely beautiful!',
      'Thanks for the inspiration!',
    ];

    return List.generate(5, (index) {
      final content = contents[index % contents.length];

      return SocialComment(
        id: 'comment_${postId}_$index',
        postId: postId,
        authorId: 'user_${index + 10}',
        authorName: 'Commenter ${index + 1}',
        authorAvatar: 'https://via.placeholder.com/40x40/${_getRandomColor()}/FFFFFF?text=C${index + 1}',
        content: content,
        likesCount: 1 + (index % 3),
        isLiked: index % 2 == 0,
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        replies: index % 3 == 0 ? _createMockReplies('comment_${postId}_$index') : [],
      );
    });
  }

  static List<SocialComment> _createMockReplies(String parentCommentId) {
    return List.generate(2, (index) {
      return SocialComment(
        id: 'reply_${parentCommentId}_$index',
        postId: parentCommentId.split('_')[1],
        authorId: 'user_${index + 20}',
        authorName: 'Replier ${index + 1}',
        authorAvatar: 'https://via.placeholder.com/30x30/${_getRandomColor()}/FFFFFF?text=R${index + 1}',
        content: 'Reply ${index + 1}',
        parentCommentId: parentCommentId,
        createdAt: DateTime.now().subtract(Duration(minutes: index * 30)),
      );
    });
  }

  static List<SocialUser> _createMockUsers() {
    final names = [
      'Alice Johnson', 'Bob Smith', 'Carol Williams', 'David Brown', 'Emma Davis',
      'Frank Miller', 'Grace Wilson', 'Henry Moore', 'Ivy Taylor', 'Jack Anderson',
    ];

    return List.generate(30, (index) {
      final name = names[index % names.length];
      final followers = 100 + (index * 50);
      final following = 50 + (index * 25);
      final posts = 10 + (index * 5);

      return SocialUser(
        id: 'user_$index',
        username: 'user${index + 1}',
        displayName: name,
        email: 'user${index + 1}@email.com',
        avatarUrl: 'https://via.placeholder.com/100x100/${_getRandomColor()}/FFFFFF?text=${name[0]}',
        coverImageUrl: 'https://via.placeholder.com/400x200/${_getRandomColor()}/FFFFFF?text=Cover',
        bio: 'This is the bio of $name',
        location: 'City ${index + 1}',
        website: 'https://user${index + 1}.com',
        followersCount: followers,
        followingCount: following,
        postsCount: posts,
        isVerified: index % 5 == 0,
        isPrivate: index % 10 == 0,
        createdAt: DateTime.now().subtract(Duration(days: index * 30)),
        lastActiveAt: DateTime.now().subtract(Duration(hours: index)),
        interests: _getRandomInterests(),
      );
    });
  }

  static List<SocialChat> _createMockChats() {
    final chatNames = [
      'Alice Johnson', 'Bob Smith', 'Carol Williams', 'David Brown', 'Emma Davis',
      'Group Chat 1', 'Group Chat 2', 'Work Team', 'Family Group', 'Friends Circle',
    ];

    return List.generate(15, (index) {
      final name = chatNames[index % chatNames.length];
      final isGroup = index % 3 == 0;
      final unreadCount = index % 4;

      return SocialChat(
        id: 'chat_$index',
        name: name,
        description: isGroup ? 'Group chat description' : null,
        imageUrl: isGroup ? 'https://via.placeholder.com/50x50/${_getRandomColor()}/FFFFFF?text=G' : null,
        participants: isGroup ? ['user_1', 'user_2', 'user_3'] : ['user_$index'],
        lastMessageContent: 'Last message from $name',
        lastMessageAt: DateTime.now().subtract(Duration(hours: index)),
        lastMessageSenderId: 'user_${index % 10}',
        unreadCount: unreadCount,
        type: isGroup ? ChatType.group : ChatType.direct,
        isMuted: index % 5 == 0,
        isArchived: index % 10 == 0,
        createdAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }

  static List<SocialMessage> _createMockMessages(String chatId) {
    final contents = [
      'Hey! How are you?',
      'I\'m doing great, thanks!',
      'What are you up to today?',
      'Just working on some projects',
      'That sounds interesting!',
      'Want to grab coffee later?',
      'Sure, that sounds good!',
      'See you at 3 PM then',
      'Perfect! See you there',
      'Thanks for the great conversation!',
    ];

    return List.generate(20, (index) {
      final content = contents[index % contents.length];
      final isFromCurrentUser = index % 2 == 0;

      return SocialMessage(
        id: 'msg_${chatId}_$index',
        chatId: chatId,
        senderId: isFromCurrentUser ? 'current_user' : 'user_${index % 10}',
        senderName: isFromCurrentUser ? 'You' : 'User ${index % 10 + 1}',
        senderAvatar: 'https://via.placeholder.com/40x40/${_getRandomColor()}/FFFFFF?text=${isFromCurrentUser ? 'Y' : 'U'}',
        content: content,
        type: MessageType.values[index % MessageType.values.length],
        createdAt: DateTime.now().subtract(Duration(minutes: index * 5)),
        isRead: index < 15,
        isDelivered: true,
        attachments: index % 5 == 0 ? ['attachment_$index'] : [],
      );
    });
  }

  static List<SocialEvent> _createMockEvents() {
    final titles = [
      'Tech Meetup', 'Music Concert', 'Art Exhibition', 'Food Festival', 'Sports Game',
      'Book Club Meeting', 'Photography Workshop', 'Dance Class', 'Cooking Class', 'Yoga Session',
    ];

    return List.generate(10, (index) {
      final title = titles[index % titles.length];
      final startDate = DateTime.now().add(Duration(days: index + 1));
      final endDate = startDate.add(const Duration(hours: 2));

      return SocialEvent(
        id: 'event_$index',
        title: title,
        description: 'Join us for an amazing $title event!',
        location: 'Venue ${index + 1}',
        startDate: startDate,
        endDate: endDate,
        organizerId: 'user_${index % 10}',
        organizerName: 'Organizer ${index + 1}',
        organizerAvatar: 'https://via.placeholder.com/50x50/${_getRandomColor()}/FFFFFF?text=O${index + 1}',
        attendees: List.generate(5 + (index % 10), (i) => 'attendee_$i'),
        interested: List.generate(10 + (index % 15), (i) => 'interested_$i'),
        status: EventStatus.upcoming,
        privacy: EventPrivacy.values[index % EventPrivacy.values.length],
        imageUrl: 'https://via.placeholder.com/400x300/${_getRandomColor()}/FFFFFF?text=$title',
        maxAttendees: 50 + (index * 10),
        isOnline: index % 3 == 0,
        meetingLink: index % 3 == 0 ? 'https://meet.example.com/event$index' : null,
      );
    });
  }

  static List<Map<String, dynamic>> _createMockNotifications() {
    return List.generate(10, (index) {
      final types = ['like', 'comment', 'follow', 'mention', 'event'];
      final type = types[index % types.length];

      return {
        'id': 'notification_$index',
        'type': type,
        'title': _getNotificationTitle(type),
        'message': _getNotificationMessage(type, index),
        'userId': 'user_${index % 10}',
        'userName': 'User ${index % 10 + 1}',
        'userAvatar': 'https://via.placeholder.com/40x40/${_getRandomColor()}/FFFFFF?text=U${index % 10 + 1}',
        'isRead': index < 5,
        'createdAt': DateTime.now().subtract(Duration(hours: index)),
        'metadata': {'postId': 'post_$index'},
      };
    });
  }

  static String _getNotificationTitle(String type) {
    switch (type) {
      case 'like':
        return 'New Like';
      case 'comment':
        return 'New Comment';
      case 'follow':
        return 'New Follower';
      case 'mention':
        return 'You were mentioned';
      case 'event':
        return 'Event Reminder';
      default:
        return 'Notification';
    }
  }

  static String _getNotificationMessage(String type, int index) {
    switch (type) {
      case 'like':
        return 'User ${index + 1} liked your post';
      case 'comment':
        return 'User ${index + 1} commented on your post';
      case 'follow':
        return 'User ${index + 1} started following you';
      case 'mention':
        return 'User ${index + 1} mentioned you in a post';
      case 'event':
        return 'Event ${index + 1} is starting soon';
      default:
        return 'You have a new notification';
    }
  }

  static List<String> _getRandomTags() {
    final tags = [
      '#tech', '#life', '#fun', '#work', '#travel', '#food', '#music', '#art',
      '#sports', '#nature', '#love', '#friends', '#family', '#happy', '#motivation',
    ];
    return List.generate(2, (index) => tags[Random().nextInt(tags.length)]);
  }

  static List<String> _getRandomInterests() {
    final interests = [
      'Technology', 'Music', 'Art', 'Sports', 'Travel', 'Food', 'Photography',
      'Reading', 'Gaming', 'Fitness', 'Movies', 'Nature', 'Cooking', 'Dancing',
    ];
    return List.generate(3, (index) => interests[Random().nextInt(interests.length)]);
  }

  static String _getRandomColor() {
    final colors = [
      'FF6B6B', '4ECDC4', '45B7D1', '96CEB4', 'FFEAA7', 'DDA0DD',
      '98D8C8', 'F7DC6F', 'BB8FCE', '85C1E9', 'F8C471', '82E0AA',
    ];
    return colors[Random().nextInt(colors.length)];
  }
}