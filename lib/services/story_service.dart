import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/story.dart';

class StoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload story content
  static Future<String> uploadStoryContent(File file, String userId, StoryType type) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = type == StoryType.image ? 'jpg' : 'mp4';
      final fileName = 'story_${userId}_$timestamp.$extension';
      
      final ref = _storage.ref().child('stories/$fileName');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload story content: $e');
    }
  }

  // Create story
  static Future<String> createStory({
    required String userId,
    required String username,
    required String userAvatar,
    required String contentUrl,
    required StoryType type,
    String? caption,
    Duration duration = const Duration(seconds: 5),
  }) async {
    try {
      final story = Story(
        id: '', // Will be set by Firestore
        userId: userId,
        username: username,
        userAvatar: userAvatar,
        contentUrl: contentUrl,
        type: type,
        caption: caption,
        createdAt: DateTime.now(),
        duration: duration,
      );

      final docRef = await _firestore.collection('stories').add(story.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create story: $e');
    }
  }

  // Get stories for feed
  static Future<List<StoryGroup>> getStoriesFeed() async {
    try {
      final snapshot = await _firestore
          .collection('stories')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      final stories = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Story.fromJson(data);
      }).toList();

      // Group stories by user
      final Map<String, List<Story>> groupedStories = {};
      for (final story in stories) {
        if (!groupedStories.containsKey(story.userId)) {
          groupedStories[story.userId] = [];
        }
        groupedStories[story.userId]!.add(story);
      }

      // Convert to StoryGroup
      final storyGroups = <StoryGroup>[];
      groupedStories.forEach((userId, userStories) {
        final firstStory = userStories.first;
        final hasUnviewed = userStories.any((story) => !story.isViewed);
        
        storyGroups.add(StoryGroup(
          userId: userId,
          username: firstStory.username,
          userAvatar: firstStory.userAvatar,
          stories: userStories,
          hasUnviewedStories: hasUnviewed,
        ));
      });

      return storyGroups;
    } catch (e) {
      throw Exception('Failed to get stories feed: $e');
    }
  }

  // View story
  static Future<void> viewStory(String storyId, String viewerId) async {
    try {
      final storyRef = _firestore.collection('stories').doc(storyId);
      final storyDoc = await storyRef.get();
      
      if (!storyDoc.exists) {
        throw Exception('Story not found');
      }

      final data = storyDoc.data() as Map<String, dynamic>;
      final viewers = List<String>.from(data['viewers'] ?? []);
      
      if (!viewers.contains(viewerId)) {
        viewers.add(viewerId);
        await storyRef.update({
          'viewers': viewers,
          'views': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw Exception('Failed to view story: $e');
    }
  }

  // Get story viewers
  static Future<List<Map<String, dynamic>>> getStoryViewers(String storyId) async {
    try {
      final storyDoc = await _firestore.collection('stories').doc(storyId).get();
      
      if (!storyDoc.exists) {
        throw Exception('Story not found');
      }

      final data = storyDoc.data() as Map<String, dynamic>;
      final viewerIds = List<String>.from(data['viewers'] ?? []);
      
      // Get viewer details
      final viewers = <Map<String, dynamic>>[];
      for (final viewerId in viewerIds) {
        final userDoc = await _firestore.collection('users').doc(viewerId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          viewers.add({
            'id': viewerId,
            'username': userData['username'],
            'avatar': userData['avatar'],
          });
        }
      }

      return viewers;
    } catch (e) {
      throw Exception('Failed to get story viewers: $e');
    }
  }

  // Delete story
  static Future<void> deleteStory(String storyId) async {
    try {
      await _firestore.collection('stories').doc(storyId).update({
        'status': 'deleted',
      });
    } catch (e) {
      throw Exception('Failed to delete story: $e');
    }
  }

  // Archive story
  static Future<void> archiveStory(String storyId) async {
    try {
      await _firestore.collection('stories').doc(storyId).update({
        'status': 'archived',
      });
    } catch (e) {
      throw Exception('Failed to archive story: $e');
    }
  }

  // Get user's stories
  static Future<List<Story>> getUserStories(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('stories')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Story.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user stories: $e');
    }
  }

  // Create text story
  static Future<String> createTextStory({
    required String userId,
    required String username,
    required String userAvatar,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required double fontSize,
  }) async {
    try {
      // In real app, generate image from text
      final textStoryUrl = 'https://via.placeholder.com/400x600/000000/FFFFFF?text=$text';
      
      return await createStory(
        userId: userId,
        username: username,
        userAvatar: userAvatar,
        contentUrl: textStoryUrl,
        type: StoryType.text,
        caption: text,
      );
    } catch (e) {
      throw Exception('Failed to create text story: $e');
    }
  }

  // Create poll story
  static Future<String> createPollStory({
    required String userId,
    required String username,
    required String userAvatar,
    required String question,
    required String option1,
    required String option2,
  }) async {
    try {
      // In real app, generate poll image
      final pollStoryUrl = 'https://via.placeholder.com/400x600/FF0000/FFFFFF?text=Poll:+$question';
      
      return await createStory(
        userId: userId,
        username: username,
        userAvatar: userAvatar,
        contentUrl: pollStoryUrl,
        type: StoryType.poll,
        caption: question,
      );
    } catch (e) {
      throw Exception('Failed to create poll story: $e');
    }
  }

  // Vote on poll
  static Future<void> voteOnPoll(String storyId, String userId, int option) async {
    try {
      await _firestore.collection('stories').doc(storyId).collection('votes').doc(userId).set({
        'userId': userId,
        'option': option,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to vote on poll: $e');
    }
  }

  // Get poll results
  static Future<Map<String, int>> getPollResults(String storyId) async {
    try {
      final snapshot = await _firestore
          .collection('stories')
          .doc(storyId)
          .collection('votes')
          .get();

      final results = <String, int>{'option1': 0, 'option2': 0};
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final option = data['option'] as int;
        if (option == 1) {
          results['option1'] = (results['option1'] ?? 0) + 1;
        } else {
          results['option2'] = (results['option2'] ?? 0) + 1;
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to get poll results: $e');
    }
  }
}