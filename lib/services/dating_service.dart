import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dating_profile.dart';

class DatingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get potential matches
  static Future<List<DatingProfile>> getPotentialMatches({
    required String userId,
    required DatingPreferences preferences,
    int limit = 10,
  }) async {
    try {
      // Get user's already swiped profiles
      final swipesSnapshot = await _firestore
          .collection('swipes')
          .where('userId', isEqualTo: userId)
          .get();

      final swipedIds = swipesSnapshot.docs
          .map((doc) => doc.data()['targetUserId'] as String)
          .toList();

      // Get profiles from Firestore, excluding already swiped
      Query query = _firestore.collection('datingProfiles');

      // Filter by preferences
      query = query.where('age', isGreaterThanOrEqualTo: preferences.minAge);
      query = query.where('age', isLessThanOrEqualTo: preferences.maxAge);
      // Note: gender filter removed as DatingPreferences doesn't have gender field

      final snapshot = await query.limit(limit * 2).get();

      final profiles = snapshot.docs
          .where((doc) => !swipedIds.contains(doc.id) && doc.id != userId)
          .take(limit)
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return DatingProfile.fromJson(data);
          })
          .toList();

      return profiles;
    } catch (e) {
      throw Exception('Failed to get potential matches: $e');
    }
  }

  // Swipe on profile
  static Future<bool> swipeProfile({
    required String userId,
    required String targetUserId,
    required DatingSwipeType swipeType,
  }) async {
    try {
      // Record swipe action
      await _firestore.collection('swipes').add({
        'userId': userId,
        'targetUserId': targetUserId,
        'type': swipeType.toString().split('.').last,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Check for mutual like
      if (swipeType == DatingSwipeType.like ||
          swipeType == DatingSwipeType.superLike) {
        final mutualSwipe = await _firestore
            .collection('swipes')
            .where('userId', isEqualTo: targetUserId)
            .where('targetUserId', isEqualTo: userId)
            .where('type', whereIn: ['like', 'superLike'])
            .get();

        if (mutualSwipe.docs.isNotEmpty) {
          // Create match
          await _createMatch(userId, targetUserId);
          return true; // It's a match!
        }
      }

      return false; // No match
    } catch (e) {
      throw Exception('Failed to swipe profile: $e');
    }
  }

  // Create match
  static Future<String> _createMatch(String userId1, String userId2) async {
    try {
      final match = Match(
        id: '', // Will be set by Firestore
        userId1: userId1,
        userId2: userId2,
        matchedAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('matches').add(match.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create match: $e');
    }
  }

  // Get user's matches
  static Future<List<Match>> getUserMatches(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('userId1', isEqualTo: userId)
          .get();

      final snapshot2 = await _firestore
          .collection('matches')
          .where('userId2', isEqualTo: userId)
          .get();

      final matches = <Match>[];

      matches.addAll(
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Match.fromJson(data);
        }),
      );

      matches.addAll(
        snapshot2.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Match.fromJson(data);
        }),
      );

      // Sort by match date
      matches.sort((a, b) => b.matchedAt.compareTo(a.matchedAt));

      return matches;
    } catch (e) {
      throw Exception('Failed to get user matches: $e');
    }
  }

  // Get match profile
  static Future<DatingProfile?> getMatchProfile(
    String matchId,
    String currentUserId,
  ) async {
    try {
      final matchDoc = await _firestore
          .collection('matches')
          .doc(matchId)
          .get();

      if (!matchDoc.exists) {
        throw Exception('Match not found');
      }

      final matchData = matchDoc.data() as Map<String, dynamic>;
      final otherUserId = matchData['userId1'] == currentUserId
          ? matchData['userId2']
          : matchData['userId1'];

      // Get profile
      final profileDoc = await _firestore
          .collection('datingProfiles')
          .doc(otherUserId)
          .get();

      if (!profileDoc.exists) {
        return null;
      }

      final profileData = profileDoc.data() as Map<String, dynamic>;
      profileData['id'] = profileDoc.id;
      return DatingProfile.fromJson(profileData);
    } catch (e) {
      throw Exception('Failed to get match profile: $e');
    }
  }

  // Send message to match
  static Future<void> sendMessageToMatch({
    required String matchId,
    required String senderId,
    required String message,
  }) async {
    try {
      await _firestore
          .collection('matches')
          .doc(matchId)
          .collection('messages')
          .add({
            'senderId': senderId,
            'message': message,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });

      // Update match with last message
      await _firestore.collection('matches').doc(matchId).update({
        'lastMessage': message,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'hasConversation': true,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get match messages
  static Future<List<Map<String, dynamic>>> getMatchMessages(
    String matchId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('matches')
          .doc(matchId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get match messages: $e');
    }
  }

  // Update dating preferences
  static Future<void> updatePreferences(
    String userId,
    DatingPreferences preferences,
  ) async {
    try {
      await _firestore
          .collection('datingPreferences')
          .doc(userId)
          .set(preferences.toJson());
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  // Get dating preferences
  static Future<DatingPreferences> getPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('datingPreferences')
          .doc(userId)
          .get();

      if (doc.exists) {
        return DatingPreferences.fromJson(doc.data()!);
      } else {
        return DatingPreferences(); // Default preferences
      }
    } catch (e) {
      throw Exception('Failed to get preferences: $e');
    }
  }

  // Create dating profile
  static Future<String> createDatingProfile(DatingProfile profile) async {
    try {
      final docRef = await _firestore
          .collection('datingProfiles')
          .add(profile.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create dating profile: $e');
    }
  }

  // Update dating profile
  static Future<void> updateDatingProfile(
    String profileId,
    DatingProfile profile,
  ) async {
    try {
      await _firestore
          .collection('datingProfiles')
          .doc(profileId)
          .update(profile.toJson());
    } catch (e) {
      throw Exception('Failed to update dating profile: $e');
    }
  }

  // Delete dating profile
  static Future<void> deleteDatingProfile(String profileId) async {
    try {
      await _firestore.collection('datingProfiles').doc(profileId).delete();
    } catch (e) {
      throw Exception('Failed to delete dating profile: $e');
    }
  }

  // Create sample profile for demo/testing
  static Future<void> createSampleProfile(DatingProfile profile) async {
    try {
      await _firestore
          .collection('datingProfiles')
          .doc(profile.id)
          .set(profile.toJson());
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  // Legacy mock for fallback only
  static List<DatingProfile> _createMockProfiles() {
    final random = Random();
    final names = [
      'Emma',
      'Liam',
      'Olivia',
      'Noah',
      'Ava',
      'William',
      'Sophia',
      'James',
      'Isabella',
      'Benjamin',
      'Charlotte',
      'Lucas',
      'Amelia',
      'Henry',
      'Mia',
      'Alexander',
      'Harper',
      'Mason',
      'Evelyn',
      'Michael',
      'Abigail',
      'Ethan',
      'Emily',
      'Daniel',
      'Elizabeth',
      'Jacob',
      'Sofia',
      'Logan',
      'Avery',
      'Jackson',
      'Ella',
      'Levi',
      'Madison',
      'Sebastian',
      'Scarlett',
      'Mateo',
      'Victoria',
      'Jack',
      'Aria',
      'Owen',
      'Grace',
      'Theodore',
      'Chloe',
      'Aiden',
      'Camila',
      'Samuel',
      'Penelope',
      'Joseph',
      'Riley',
      'John',
      'Layla',
      'David',
      'Lillian',
      'Wyatt',
      'Nora',
      'Matthew',
      'Zoey',
      'Luke',
      'Mila',
      'Asher',
      'Aubrey',
      'Carter',
      'Hannah',
      'Julian',
      'Lily',
      'Grayson',
      'Addison',
      'Leo',
      'Eleanor',
      'Jayden',
      'Natalie',
      'Gabriel',
      'Luna',
      'Isaac',
      'Savannah',
      'Lincoln',
      'Leah',
      'Anthony',
      'Zoe',
      'Hudson',
      'Stella',
      'Dylan',
      'Hazel',
      'Ezra',
      'Ellie',
      'Thomas',
      'Paisley',
      'Charles',
      'Audrey',
      'Christopher',
      'Skylar',
      'Jaxon',
      'Violet',
      'Maverick',
      'Claire',
      'Josiah',
      'Bella',
      'Isaiah',
      'Aurora',
      'Andrew',
      'Lucy',
      'Elias',
      'Anna',
      'Joshua',
      'Caroline',
      'Nathan',
      'Genesis',
      'Caleb',
      'Aaliyah',
      'Ryan',
      'Kennedy',
      'Adrian',
      'Kinsley',
      'Miles',
      'Allison',
      'Eli',
      'Maya',
      'Aaron',
      'Sarah',
      'Ian',
      'Madelyn',
      'Adam',
      'Adeline',
      'Axel',
      'Alexa',
      'Tyler',
      'Ariana',
      'Justin',
      'Elena',
      'Evan',
      'Gabriella',
      'Landon',
      'Naomi',
      'Jason',
      'Alice',
      'Parker',
      'Sadie',
      'Hunter',
      'Hailey',
      'Nolan',
      'Eva',
      'Zachary',
      'Emilia',
      'Easton',
      'Autumn',
      'Blake',
      'Quinn',
      'Nevaeh',
      'Colton',
      'Piper',
      'Jordan',
      'Ruby',
      'Brayden',
      'Serenity',
      'Nicholas',
      'Willow',
      'Angel',
      'Everly',
      'Dominic',
      'Cora',
      'Austin',
      'Kaylee',
      'Ian',
      'Lydia',
      'Adam',
      'Aubree',
      'Elias',
      'Arianna',
      'Jaxson',
      'Eliana',
      'Greyson',
      'Peyton',
      'Roman',
      'Melanie',
      'Ezekiel',
      'Gianna',
      'Miles',
      'Isabelle',
      'Micah',
      'Julia',
      'Vincent',
      'Valentina',
      'Bryce',
      'Clara',
      'Theo',
      'Vivian',
      'Maximus',
      'Reagan',
      'Max',
      'Mackenzie',
      'Harrison',
      'Madeline',
      'Weston',
      'Brielle',
      'Bryson',
      'Delilah',
      'Antonio',
      'Isla',
      'Beau',
      'Rylee',
      'Damian',
      'Arielle',
      'Bentley',
      'Kendall',
      'Carlos',
      'Jordyn',
      'Ryker',
      'Jocelyn',
      'Tristan',
      'Payton',
      'Declan',
      'Liliana',
      'Knox',
      'Maria',
      'Kaden',
      'Trinity',
      'Kyle',
      'Ximena',
      'Griffin',
      'Jade',
      'Miguel',
      'Josie',
      'Cole',
      'Eden',
      'Tyler',
      'Ayla',
      'Ryder',
      'Raelynn',
      'Ashton',
      'Elise',
      'Brantley',
      'Remi',
      'Felix',
      'Emberly',
      'Bennett',
      'Mya',
      'Preston',
      'Kyla',
      'Silas',
      'Ariyah',
      'Rhett',
      'Arya',
      'Zander',
      'Norah',
      'Andres',
      'Khloe',
      'Jasper',
      'Makenna',
      'Iker',
      'Amara',
      'Calvin',
      'Adriana',
      'Emmett',
      'Cali',
      'Waylon',
      'Esther',
      'Axel',
      'Alyssa',
      'River',
      'Anastasia',
      'Brody',
      'Ryleigh',
      'Luca',
      'Finley',
      'Jude',
      'Makenzie',
      'Lukas',
      'Hope',
      'Enzo',
      'Brianna',
      'Crew',
      'Callie',
      'Koda',
      'Sloane',
      'Paxton',
      'Gracie',
      'Hendrix',
      'Daniella',
      'Rowan',
      'Daphne',
      'Zayden',
      'Harmony',
      'Knox',
      'Alana',
      'Bodhi',
      'Gemma',
      'Cruz',
      'Laila',
      'Rylan',
      'Raegan',
      'Zion',
      'Journee',
      'Maddox',
      'Presley',
      'Ronan',
      'Zara',
      'Cade',
      'Amira',
      'Nash',
      'Aylin',
      'Chance',
      'Catalina',
      'Lennox',
      'Belen',
      'Kash',
      'Lexi',
      'Krew',
      'Myra',
      'Kyrie',
      'Fernanda',
      'Titan',
      'Charlee',
      'Ridge',
      'Dahlia',
      'Sage',
      'Maliyah',
      'Sergio',
      'Amiyah',
      'Travis',
      'Lia',
      'Callum',
      'Nayeli',
      'Kane',
      'Ariah',
      'Royal',
      'Alani',
      'Zayne',
      'Kaia',
      'Crew',
      'Ari',
      'Koda',
      'Luciana',
      'Paxton',
      'Allie',
      'Hendrix',
      'Raelynn',
      'Rowan',
      'Makenna',
      'Zayden',
      'Brielle',
      'Knox',
      'Emberly',
      'Bodhi',
      'Arielle',
      'Cruz',
      'Kendall',
      'Rylan',
      'Jordyn',
      'Maddox',
      'Payton',
      'Ronan',
      'Liliana',
      'Cade',
      'Trinity',
      'Nash',
      'Maria',
      'Chance',
      'Ximena',
      'Lennox',
      'Jade',
      'Kash',
      'Josie',
      'Krew',
      'Eden',
      'Kyrie',
      'Ayla',
      'Titan',
      'Raelynn',
      'Ridge',
      'Elise',
      'Sage',
      'Mya',
      'Sergio',
      'Kyla',
      'Travis',
      'Ariyah',
      'Callum',
      'Norah',
      'Kane',
      'Khloe',
      'Royal',
      'Makenna',
      'Zayne',
      'Amara',
      'Crew',
      'Ari',
      'Koda',
      'Luciana',
      'Paxton',
      'Allie',
      'Hendrix',
      'Raelynn',
      'Rowan',
      'Makenna',
      'Zayden',
      'Brielle',
      'Knox',
      'Emberly',
      'Bodhi',
      'Arielle',
    ];

    final jobs = [
      'Software Engineer',
      'Doctor',
      'Teacher',
      'Artist',
      'Designer',
      'Writer',
      'Photographer',
      'Chef',
      'Musician',
      'Actor',
      'Lawyer',
      'Engineer',
      'Entrepreneur',
      'Consultant',
      'Marketing Manager',
      'Sales Rep',
      'Nurse',
      'Psychologist',
      'Architect',
      'Pilot',
      'Journalist',
      'Scientist',
      'Fitness Trainer',
      'Real Estate Agent',
      'Financial Advisor',
      'Student',
    ];

    final interests = [
      'Travel',
      'Music',
      'Sports',
      'Art',
      'Food',
      'Movies',
      'Books',
      'Fitness',
      'Photography',
      'Dancing',
      'Cooking',
      'Hiking',
      'Yoga',
      'Gaming',
      'Fashion',
      'Nature',
      'Technology',
      'Animals',
      'Volunteering',
      'Wine',
      'Coffee',
      'Beach',
      'Mountains',
      'Concerts',
      'Museums',
      'Theater',
    ];

    final locations = [
      'New York',
      'Los Angeles',
      'Chicago',
      'Houston',
      'Phoenix',
      'Philadelphia',
      'San Antonio',
      'San Diego',
      'Dallas',
      'San Jose',
      'Austin',
      'Jacksonville',
      'Fort Worth',
      'Columbus',
      'Charlotte',
      'San Francisco',
      'Indianapolis',
      'Seattle',
      'Denver',
      'Washington',
      'Boston',
      'El Paso',
      'Nashville',
      'Detroit',
      'Oklahoma City',
      'Portland',
      'Las Vegas',
      'Memphis',
      'Louisville',
      'Baltimore',
      'Milwaukee',
      'Albuquerque',
      'Tucson',
      'Fresno',
      'Sacramento',
      'Mesa',
      'Kansas City',
      'Atlanta',
      'Long Beach',
      'Colorado Springs',
      'Raleigh',
      'Miami',
      'Virginia Beach',
      'Omaha',
      'Oakland',
      'Minneapolis',
      'Tulsa',
      'Arlington',
      'Tampa',
      'New Orleans',
    ];

    return List.generate(50, (index) {
      final name = names[random.nextInt(names.length)];
      final age = 18 + random.nextInt(32); // 18-50
      final distance = random.nextDouble() * 50; // 0-50 km
      final photoCount = 1 + random.nextInt(5); // 1-5 photos
      final interestCount = 3 + random.nextInt(8); // 3-10 interests

      return DatingProfile(
        id: 'profile_$index',
        name: name,
        age: age,
        bio: _generateBio(name, age),
        photos: List.generate(
          photoCount,
          (i) =>
              'https://via.placeholder.com/400x600/${_getRandomColor()}/FFFFFF?text=$name+${i + 1}',
        ),
        location: locations[random.nextInt(locations.length)],
        distance: distance,
        interests: interests
          ..shuffle()
          ..take(interestCount).toList(),
        job: jobs[random.nextInt(jobs.length)],
        education: _getRandomEducation(),
        height: 150 + random.nextInt(50), // 150-200 cm
        lookingFor: _getRandomLookingFor(),
        isVerified: random.nextBool(),
        lastActive: DateTime.now().subtract(
          Duration(hours: random.nextInt(24), minutes: random.nextInt(60)),
        ),
      );
    });
  }

  static String _generateBio(String name, int age) {
    final bios = [
      'Love to travel and explore new places! 🌍',
      'Foodie, fitness enthusiast, and dog lover 🐕',
      'Passionate about music and art 🎵',
      'Always up for an adventure! ⛰️',
      'Coffee addict and bookworm 📚',
      'Looking for someone to share life\'s journey with 💫',
      'Love hiking, photography, and good conversations 📸',
      'Fitness junkie and travel lover 🏃‍♀️',
      'Artist, dreamer, and eternal optimist ✨',
      'Food lover, wine enthusiast, and travel addict 🍷',
      'Music producer and adventure seeker 🎶',
      'Teacher by day, explorer by night 🌙',
      'Dog mom, yoga instructor, and nature lover 🧘‍♀️',
      'Chef, traveler, and hopeless romantic 👨‍🍳',
      'Photographer capturing life\'s beautiful moments 📷',
      'Fitness trainer and healthy living advocate 💪',
      'Artist painting the world in colors 🎨',
      'Writer, reader, and coffee connoisseur ☕',
      'Dancer, traveler, and life enthusiast 💃',
      'Engineer by profession, explorer by passion 🔧',
    ];

    return bios[Random().nextInt(bios.length)];
  }

  static String _getRandomEducation() {
    final educations = [
      'Bachelor\'s Degree',
      'Master\'s Degree',
      'PhD',
      'High School',
      'Associate Degree',
      'Trade School',
      'Some College',
    ];
    return educations[Random().nextInt(educations.length)];
  }

  static String _getRandomLookingFor() {
    final lookingFor = [
      'Long-term relationship',
      'Something casual',
      'Marriage',
      'Friendship',
      'Not sure yet',
      'Adventure partner',
      'Life partner',
    ];
    return lookingFor[Random().nextInt(lookingFor.length)];
  }

  static String _getRandomColor() {
    final colors = [
      'FF6B6B',
      '4ECDC4',
      '45B7D1',
      '96CEB4',
      'FFEAA7',
      'DDA0DD',
      '98D8C8',
      'F7DC6F',
      'BB8FCE',
      '85C1E9',
      'F8C471',
      '82E0AA',
      'F1948A',
      '85C1E9',
      'F7DC6F',
      'D7BDE2',
      'A9DFBF',
      'F9E79F',
    ];
    return colors[Random().nextInt(colors.length)];
  }
}
