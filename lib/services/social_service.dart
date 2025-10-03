import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/social.dart';

class SocialService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _postsCollection = 'socialPosts';
  static const String _commentsCollection = 'socialComments';
  static const String _likesSubcollection = 'likes';
  static const String _sharesSubcollection = 'shares';
  static const String _bookmarksSubcollection = 'bookmarks';
  static const String _usersCollection = 'socialUsers';
  static const String _chatsCollection = 'socialChats';
  static const String _messagesSubcollection = 'messages';
  static const String _eventsCollection = 'socialEvents';
  static const String _notificationsCollection = 'socialNotifications';
  // Toggle like on post
  static Future<void> toggleLikePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection(_postsCollection).doc(postId);
      final likeRef = postRef.collection(_likesSubcollection).doc(userId);
      await _firestore.runTransaction((tx) async {
        final likeSnap = await tx.get(likeRef);
        final postSnap = await tx.get(postRef);
        if (!postSnap.exists) {
          throw Exception('Post not found');
        }
        if (likeSnap.exists) {
          tx.delete(likeRef);
          tx.update(postRef, {'likesCount': FieldValue.increment(-1)});
        } else {
          tx.set(likeRef, {
            'userId': userId,
            'createdAt': DateTime.now().toIso8601String(),
          });
          tx.update(postRef, {'likesCount': FieldValue.increment(1)});
        }
      });
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Post comment
  static Future<SocialComment> postComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String authorAvatar,
    required String content,
  }) async {
    try {
      return await addComment(
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
      );
    } catch (e) {
      throw Exception('Failed to post comment: $e');
    }
  }

  // Get user posts
  static Future<List<SocialPost>> getUserPosts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_postsCollection)
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return SocialPost.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user posts: $e');
    }
  }

  // Toggle follow user
  static Future<void> toggleFollowUser(String userId, String currentUserId) async {
    try {
      final followerRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('followers')
          .doc(currentUserId);
      final followingRef = _firestore
          .collection(_usersCollection)
          .doc(currentUserId)
          .collection('following')
          .doc(userId);
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      final currentUserRef = _firestore.collection(_usersCollection).doc(currentUserId);
      await _firestore.runTransaction((tx) async {
        final followerSnap = await tx.get(followerRef);
        if (followerSnap.exists) {
          tx.delete(followerRef);
          tx.delete(followingRef);
          tx.update(userRef, {'followersCount': FieldValue.increment(-1)});
          tx.update(currentUserRef, {'followingCount': FieldValue.increment(-1)});
        } else {
          tx.set(followerRef, {'userId': currentUserId, 'createdAt': DateTime.now().toIso8601String()});
          tx.set(followingRef, {'userId': userId, 'createdAt': DateTime.now().toIso8601String()});
          tx.update(userRef, {'followersCount': FieldValue.increment(1)});
          tx.update(currentUserRef, {'followingCount': FieldValue.increment(1)});
        }
      });
    } catch (e) {
      throw Exception('Failed to toggle follow: $e');
    }
  }

  // Posts
  static Future<List<SocialPost>> getFeed(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_postsCollection)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return SocialPost.fromJson(data);
      }).toList();
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
      final posts = _firestore.collection(_postsCollection);
      final docRef = posts.doc();
      final post = SocialPost(
        id: docRef.id,
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
        likesCount: 0,
        commentsCount: 0,
        sharesCount: 0,
      );
      await docRef.set(post.toJson());
      return post;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  static Future<void> likePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection(_postsCollection).doc(postId);
      final likeRef = postRef.collection(_likesSubcollection).doc(userId);
      await _firestore.runTransaction((tx) async {
        final likeSnap = await tx.get(likeRef);
        if (!likeSnap.exists) {
          tx.set(likeRef, {'userId': userId, 'createdAt': DateTime.now().toIso8601String()});
          tx.update(postRef, {'likesCount': FieldValue.increment(1)});
        }
      });
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  static Future<void> unlikePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection(_postsCollection).doc(postId);
      final likeRef = postRef.collection(_likesSubcollection).doc(userId);
      await _firestore.runTransaction((tx) async {
        final likeSnap = await tx.get(likeRef);
        if (likeSnap.exists) {
          tx.delete(likeRef);
          tx.update(postRef, {'likesCount': FieldValue.increment(-1)});
        }
      });
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  static Future<void> sharePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection(_postsCollection).doc(postId);
      final shareRef = postRef.collection(_sharesSubcollection).doc(userId);
      await _firestore.runTransaction((tx) async {
        final shareSnap = await tx.get(shareRef);
        if (!shareSnap.exists) {
          tx.set(shareRef, {'userId': userId, 'createdAt': DateTime.now().toIso8601String()});
          tx.update(postRef, {'sharesCount': FieldValue.increment(1)});
        }
      });
    } catch (e) {
      throw Exception('Failed to share post: $e');
    }
  }

  static Future<void> bookmarkPost(String postId, String userId) async {
    try {
      final bookmarkRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_bookmarksSubcollection)
          .doc(postId);
      await bookmarkRef.set({
        'postId': postId,
        'userId': userId,
        'createdAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to bookmark post: $e');
    }
  }

  // Comments
  static Future<List<SocialComment>> getPostComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection(_commentsCollection)
          .where('postId', isEqualTo: postId)
          .where('parentCommentId', isNull: true)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        data['replies'] = [];
        return SocialComment.fromJson(data);
      }).toList();
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
      final comments = _firestore.collection(_commentsCollection);
      final docRef = comments.doc();
      final comment = SocialComment(
        id: docRef.id,
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
        parentCommentId: parentCommentId,
        createdAt: DateTime.now(),
      );
      await _firestore.runTransaction((tx) async {
        tx.set(docRef, comment.toJson());
        final postRef = _firestore.collection(_postsCollection).doc(postId);
        tx.update(postRef, {'commentsCount': FieldValue.increment(1)});
      });
      return comment;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  static Future<void> likeComment(String commentId, String userId) async {
    try {
      final commentRef = _firestore.collection(_commentsCollection).doc(commentId);
      final likeRef = commentRef.collection(_likesSubcollection).doc(userId);
      await _firestore.runTransaction((tx) async {
        final likeSnap = await tx.get(likeRef);
        if (!likeSnap.exists) {
          tx.set(likeRef, {'userId': userId, 'createdAt': DateTime.now().toIso8601String()});
          tx.update(commentRef, {'likesCount': FieldValue.increment(1)});
        }
      });
    } catch (e) {
      throw Exception('Failed to like comment: $e');
    }
  }

  // Users
  static Future<List<SocialUser>> searchUsers(String query) async {
    try {
      final normalized = query.toLowerCase();
      final snapshot = await _firestore.collection(_usersCollection).limit(100).get();
      final users = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return SocialUser.fromJson(data);
      }).where((u) =>
          u.username.toLowerCase().contains(normalized) ||
          u.displayName.toLowerCase().contains(normalized))
        .toList();
      return users;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  static Future<SocialUser?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return SocialUser.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  static Future<void> followUser(String userId, String followerId) async {
    try {
      final followerRef = _firestore.collection(_usersCollection).doc(userId).collection('followers').doc(followerId);
      final followingRef = _firestore.collection(_usersCollection).doc(followerId).collection('following').doc(userId);
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      final followerUserRef = _firestore.collection(_usersCollection).doc(followerId);
      await _firestore.runTransaction((tx) async {
        tx.set(followerRef, {'userId': followerId, 'createdAt': DateTime.now().toIso8601String()});
        tx.set(followingRef, {'userId': userId, 'createdAt': DateTime.now().toIso8601String()});
        tx.update(userRef, {'followersCount': FieldValue.increment(1)});
        tx.update(followerUserRef, {'followingCount': FieldValue.increment(1)});
      });
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  static Future<void> unfollowUser(String userId, String followerId) async {
    try {
      final followerRef = _firestore.collection(_usersCollection).doc(userId).collection('followers').doc(followerId);
      final followingRef = _firestore.collection(_usersCollection).doc(followerId).collection('following').doc(userId);
      final userRef = _firestore.collection(_usersCollection).doc(userId);
      final followerUserRef = _firestore.collection(_usersCollection).doc(followerId);
      await _firestore.runTransaction((tx) async {
        tx.delete(followerRef);
        tx.delete(followingRef);
        tx.update(userRef, {'followersCount': FieldValue.increment(-1)});
        tx.update(followerUserRef, {'followingCount': FieldValue.increment(-1)});
      });
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  static Future<List<SocialUser>> getFollowers(String userId) async {
    try {
      final followersSnap = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('followers')
          .limit(100)
          .get();
      final followerIds = followersSnap.docs.map((d) => d.id).toList();
      if (followerIds.isEmpty) return [];
      final List<SocialUser> users = [];
      // Batch in chunks of 10 for whereIn
      for (var i = 0; i < followerIds.length; i += 10) {
        final chunk = followerIds.sublist(i, i + 10 > followerIds.length ? followerIds.length : i + 10);
        final snap = await _firestore
            .collection(_usersCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        users.addAll(snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return SocialUser.fromJson(data);
        }));
      }
      return users;
    } catch (e) {
      throw Exception('Failed to get followers: $e');
    }
  }

  static Future<List<SocialUser>> getFollowing(String userId) async {
    try {
      final followingSnap = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('following')
          .limit(100)
          .get();
      final followingIds = followingSnap.docs.map((d) => d.id).toList();
      if (followingIds.isEmpty) return [];
      final List<SocialUser> users = [];
      for (var i = 0; i < followingIds.length; i += 10) {
        final chunk = followingIds.sublist(i, i + 10 > followingIds.length ? followingIds.length : i + 10);
        final snap = await _firestore
            .collection(_usersCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        users.addAll(snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return SocialUser.fromJson(data);
        }));
      }
      return users;
    } catch (e) {
      throw Exception('Failed to get following: $e');
    }
  }

  // Messages
  static Future<List<SocialChat>> getUserChats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_chatsCollection)
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return SocialChat.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get chats: $e');
    }
  }

  static Future<List<SocialMessage>> getChatMessages(String chatId) async {
    try {
      final snapshot = await _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .collection(_messagesSubcollection)
          .orderBy('createdAt', descending: false)
          .limit(200)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return SocialMessage.fromJson(data);
      }).toList();
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
      final messages = _firestore.collection(_chatsCollection).doc(chatId).collection(_messagesSubcollection);
      final docRef = messages.doc();
      final message = SocialMessage(
        id: docRef.id,
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
      await _firestore.runTransaction((tx) async {
        tx.set(docRef, message.toJson());
        final chatRef = _firestore.collection(_chatsCollection).doc(chatId);
        tx.set(chatRef, {
          'id': chatId,
          'name': '',
          'participants': [senderId],
          'lastMessageId': message.id,
          'lastMessageContent': content,
          'lastMessageAt': message.createdAt.toIso8601String(),
          'lastMessageSenderId': senderId,
          'unreadCount': 0,
          'type': 'direct',
          'isMuted': false,
          'isArchived': false,
          'createdAt': message.createdAt.toIso8601String(),
          'updatedAt': message.createdAt.toIso8601String(),
        }, SetOptions(merge: true));
      });
      return message;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  static Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      // Without chatId, we cannot address a specific message path.
      // Store read status in a top-level collection keyed by messageId for simplicity.
      final readRef = _firestore.collection('messageReads').doc('$messageId-$userId');
      await readRef.set({
        'messageId': messageId,
        'userId': userId,
        'readAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
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
      Query query = _firestore.collection(_eventsCollection).orderBy('startDate', descending: false).limit(100);
      final snapshot = await query.get();
      var events = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return SocialEvent.fromJson(data);
      }).toList();
      if (location != null && location.isNotEmpty) {
        events = events.where((e) => e.location.toLowerCase().contains(location.toLowerCase())).toList();
      }
      if (startDate != null) {
        events = events.where((e) => !e.startDate.isBefore(startDate)).toList();
      }
      if (endDate != null) {
        events = events.where((e) => !e.endDate.isAfter(endDate)).toList();
      }
      return events;
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
      final events = _firestore.collection(_eventsCollection);
      final docRef = events.doc();
      final event = SocialEvent(
        id: docRef.id,
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
      await docRef.set(event.toJson());
      return event;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  static Future<void> attendEvent(String eventId, String userId) async {
    try {
      final eventRef = _firestore.collection(_eventsCollection).doc(eventId);
      await eventRef.update({'attendees': FieldValue.arrayUnion([userId])});
    } catch (e) {
      throw Exception('Failed to attend event: $e');
    }
  }

  static Future<void> interestedInEvent(String eventId, String userId) async {
    try {
      final eventRef = _firestore.collection(_eventsCollection).doc(eventId);
      await eventRef.update({'interested': FieldValue.arrayUnion([userId])});
    } catch (e) {
      throw Exception('Failed to mark as interested: $e');
    }
  }

  // Notifications
  static Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final notiRef = _firestore.collection(_notificationsCollection).doc(notificationId);
      await notiRef.update({'isRead': true, 'readAt': DateTime.now().toIso8601String()});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}