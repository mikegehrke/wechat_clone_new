class SocialPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final List<String> images;
  final List<String> videos;
  final String? location;
  final List<String> tags;
  final List<String> mentions;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isLiked;
  final bool isShared;
  final bool isBookmarked;
  final PostType type;
  final PostPrivacy privacy;
  final List<SocialComment> comments;
  final Map<String, dynamic>? metadata;

  SocialPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    this.images = const [],
    this.videos = const [],
    this.location,
    this.tags = const [],
    this.mentions = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.isLiked = false,
    this.isShared = false,
    this.isBookmarked = false,
    this.type = PostType.text,
    this.privacy = PostPrivacy.public,
    this.comments = const [],
    this.metadata,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'],
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      location: json['location'],
      tags: List<String>.from(json['tags'] ?? []),
      mentions: List<String>.from(json['mentions'] ?? []),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isLiked: json['isLiked'] ?? false,
      isShared: json['isShared'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      type: PostType.values.firstWhere(
        (e) => e.toString() == 'PostType.${json['type']}',
        orElse: () => PostType.text,
      ),
      privacy: PostPrivacy.values.firstWhere(
        (e) => e.toString() == 'PostPrivacy.${json['privacy']}',
        orElse: () => PostPrivacy.public,
      ),
      comments: (json['comments'] as List?)
          ?.map((comment) => SocialComment.fromJson(comment))
          .toList() ?? [],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'images': images,
      'videos': videos,
      'location': location,
      'tags': tags,
      'mentions': mentions,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isLiked': isLiked,
      'isShared': isShared,
      'isBookmarked': isBookmarked,
      'type': type.toString().split('.').last,
      'privacy': privacy.toString().split('.').last,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'metadata': metadata,
    };
  }

  String get formattedTimeAgo {
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

  String get formattedLikesCount {
    if (likesCount >= 1000000) {
      return '${(likesCount / 1000000).toStringAsFixed(1)}M';
    } else if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}K';
    }
    return likesCount.toString();
  }
}

enum PostType {
  text,
  image,
  video,
  link,
  poll,
  event,
  checkIn,
}

enum PostPrivacy {
  public,
  friends,
  friendsOfFriends,
  custom,
  onlyMe,
}

class SocialComment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  final List<SocialComment> replies;
  final String? parentCommentId;

  SocialComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
    this.replies = const [],
    this.parentCommentId,
  });

  factory SocialComment.fromJson(Map<String, dynamic> json) {
    return SocialComment(
      id: json['id'],
      postId: json['postId'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      replies: (json['replies'] as List?)
          ?.map((reply) => SocialComment.fromJson(reply))
          .toList() ?? [],
      parentCommentId: json['parentCommentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likesCount': likesCount,
      'isLiked': isLiked,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'parentCommentId': parentCommentId,
    };
  }

  String get formattedTimeAgo {
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

class SocialUser {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String avatarUrl;
  final String? coverImageUrl;
  final String? bio;
  final String? location;
  final String? website;
  final DateTime? birthDate;
  final String? phoneNumber;
  final bool isVerified;
  final bool isPrivate;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final List<String> interests;
  final Map<String, dynamic>? metadata;

  SocialUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    this.coverImageUrl,
    this.bio,
    this.location,
    this.website,
    this.birthDate,
    this.phoneNumber,
    this.isVerified = false,
    this.isPrivate = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    required this.createdAt,
    this.lastActiveAt,
    this.interests = const [],
    this.metadata,
  });

  factory SocialUser.fromJson(Map<String, dynamic> json) {
    return SocialUser(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      coverImageUrl: json['coverImageUrl'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      phoneNumber: json['phoneNumber'],
      isVerified: json['isVerified'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt']) : null,
      interests: List<String>.from(json['interests'] ?? []),
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'coverImageUrl': coverImageUrl,
      'bio': bio,
      'location': location,
      'website': website,
      'birthDate': birthDate?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'isPrivate': isPrivate,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'interests': interests,
      'metadata': metadata,
    };
  }

  String get formattedFollowersCount {
    if (followersCount >= 1000000) {
      return '${(followersCount / 1000000).toStringAsFixed(1)}M';
    } else if (followersCount >= 1000) {
      return '${(followersCount / 1000).toStringAsFixed(1)}K';
    }
    return followersCount.toString();
  }

  String get formattedFollowingCount {
    if (followingCount >= 1000000) {
      return '${(followingCount / 1000000).toStringAsFixed(1)}M';
    } else if (followingCount >= 1000) {
      return '${(followingCount / 1000).toStringAsFixed(1)}K';
    }
    return followingCount.toString();
  }

  String get formattedPostsCount {
    if (postsCount >= 1000000) {
      return '${(postsCount / 1000000).toStringAsFixed(1)}M';
    } else if (postsCount >= 1000) {
      return '${(postsCount / 1000).toStringAsFixed(1)}K';
    }
    return postsCount.toString();
  }
}

class SocialMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final bool isDelivered;
  final String? replyToMessageId;
  final List<String> attachments;
  final Map<String, dynamic>? metadata;

  SocialMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    this.type = MessageType.text,
    required this.createdAt,
    this.readAt,
    this.isRead = false,
    this.isDelivered = false,
    this.replyToMessageId,
    this.attachments = const [],
    this.metadata,
  });

  factory SocialMessage.fromJson(Map<String, dynamic> json) {
    return SocialMessage(
      id: json['id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderAvatar: json['senderAvatar'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      isRead: json['isRead'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
      replyToMessageId: json['replyToMessageId'],
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isRead': isRead,
      'isDelivered': isDelivered,
      'replyToMessageId': replyToMessageId,
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${createdAt.day}/${createdAt.month}';
    } else if (difference.inHours > 0) {
      return '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  sticker,
  gif,
}

class SocialChat {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String> participants;
  final String? lastMessageId;
  final String? lastMessageContent;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final int unreadCount;
  final ChatType type;
  final bool isMuted;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SocialChat({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.participants,
    this.lastMessageId,
    this.lastMessageContent,
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.unreadCount = 0,
    this.type = ChatType.direct,
    this.isMuted = false,
    this.isArchived = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory SocialChat.fromJson(Map<String, dynamic> json) {
    return SocialChat(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      participants: List<String>.from(json['participants'] ?? []),
      lastMessageId: json['lastMessageId'],
      lastMessageContent: json['lastMessageContent'],
      lastMessageAt: json['lastMessageAt'] != null ? DateTime.parse(json['lastMessageAt']) : null,
      lastMessageSenderId: json['lastMessageSenderId'],
      unreadCount: json['unreadCount'] ?? 0,
      type: ChatType.values.firstWhere(
        (e) => e.toString() == 'ChatType.${json['type']}',
        orElse: () => ChatType.direct,
      ),
      isMuted: json['isMuted'] ?? false,
      isArchived: json['isArchived'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'participants': participants,
      'lastMessageId': lastMessageId,
      'lastMessageContent': lastMessageContent,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'type': type.toString().split('.').last,
      'isMuted': isMuted,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get formattedLastMessageTime {
    if (lastMessageAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt!);
    
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

enum ChatType {
  direct,
  group,
  channel,
}

class SocialEvent {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String organizerId;
  final String organizerName;
  final String organizerAvatar;
  final List<String> attendees;
  final List<String> interested;
  final EventStatus status;
  final EventPrivacy privacy;
  final String? imageUrl;
  final int maxAttendees;
  final bool isOnline;
  final String? meetingLink;
  final Map<String, dynamic>? metadata;

  SocialEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.organizerId,
    required this.organizerName,
    required this.organizerAvatar,
    this.attendees = const [],
    this.interested = const [],
    this.status = EventStatus.upcoming,
    this.privacy = EventPrivacy.public,
    this.imageUrl,
    this.maxAttendees = 0,
    this.isOnline = false,
    this.meetingLink,
    this.metadata,
  });

  factory SocialEvent.fromJson(Map<String, dynamic> json) {
    return SocialEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      organizerAvatar: json['organizerAvatar'],
      attendees: List<String>.from(json['attendees'] ?? []),
      interested: List<String>.from(json['interested'] ?? []),
      status: EventStatus.values.firstWhere(
        (e) => e.toString() == 'EventStatus.${json['status']}',
        orElse: () => EventStatus.upcoming,
      ),
      privacy: EventPrivacy.values.firstWhere(
        (e) => e.toString() == 'EventPrivacy.${json['privacy']}',
        orElse: () => EventPrivacy.public,
      ),
      imageUrl: json['imageUrl'],
      maxAttendees: json['maxAttendees'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      meetingLink: json['meetingLink'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerAvatar': organizerAvatar,
      'attendees': attendees,
      'interested': interested,
      'status': status.toString().split('.').last,
      'privacy': privacy.toString().split('.').last,
      'imageUrl': imageUrl,
      'maxAttendees': maxAttendees,
      'isOnline': isOnline,
      'meetingLink': meetingLink,
      'metadata': metadata,
    };
  }

  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String get formattedStartTime {
    return '${startDate.hour}:${startDate.minute.toString().padLeft(2, '0')}';
  }

  bool get isFull {
    return maxAttendees > 0 && attendees.length >= maxAttendees;
  }
}

enum EventStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}

enum EventPrivacy {
  public,
  friends,
  private,
}