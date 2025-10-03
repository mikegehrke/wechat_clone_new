import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/professional.dart';

class ProfessionalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _profilesCollection = 'professionalProfiles';
  static const String _postsCollection = 'professionalPosts';
  static const String _jobsCollection = 'jobPostings';
  static const String _connectionsSubcollection = 'connections';
  static const String _requestsSubcollection = 'connectionRequests';
  static const String _usersCollection = 'users';
  // Toggle save job
  static Future<void> toggleSaveJob(String jobId, String userId) async {
    try {
      final savedRef = _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('savedJobs')
          .doc(jobId);
      final snap = await savedRef.get();
      if (snap.exists) {
        await savedRef.delete();
      } else {
        await savedRef.set({'savedAt': DateTime.now().toIso8601String()});
      }
    } catch (e) {
      throw Exception('Failed to toggle save job: $e');
    }
  }

  // Get connection suggestions
  static Future<List<ProfessionalProfile>> getConnectionSuggestions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_profilesCollection)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return ProfessionalProfile.fromJson(data);
      }).where((p) => p.userId != userId).toList();
    } catch (e) {
      throw Exception('Failed to get connection suggestions: $e');
    }
  }

  // Toggle connection
  static Future<void> toggleConnect(String profileId, String userId) async {
    try {
      final meRef = _firestore.collection(_profilesCollection).doc(userId).collection(_connectionsSubcollection).doc(profileId);
      final otherRef = _firestore.collection(_profilesCollection).doc(profileId).collection(_connectionsSubcollection).doc(userId);
      final snap = await meRef.get();
      if (snap.exists) {
        await meRef.delete();
        await otherRef.delete();
      } else {
        await meRef.set({'connectedAt': DateTime.now().toIso8601String()});
        await otherRef.set({'connectedAt': DateTime.now().toIso8601String()});
      }
    } catch (e) {
      throw Exception('Failed to toggle connection: $e');
    }
  }

  // Get professional profile
  static Future<ProfessionalProfile?> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection(_profilesCollection).doc(userId).get();
      if (!doc.exists) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return ProfessionalProfile.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  // Update professional profile
  static Future<void> updateProfile(ProfessionalProfile profile) async {
    try {
      await _firestore.collection(_profilesCollection).doc(profile.userId).set(profile.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get professional feed
  static Future<List<ProfessionalPost>> getFeed(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_postsCollection)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return ProfessionalPost.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get feed: $e');
    }
  }

  // Create professional post
  static Future<ProfessionalPost> createPost({
    required String authorId,
    required String content,
    List<String> images = const [],
    List<String> videos = const [],
    List<String> hashtags = const [],
  }) async {
    try {
      final docRef = _firestore.collection(_postsCollection).doc();
      final post = ProfessionalPost(
        id: docRef.id,
        authorId: authorId,
        authorName: '',
        authorTitle: '',
        authorCompany: '',
        authorImageUrl: '',
        content: content,
        images: images,
        videos: videos,
        hashtags: hashtags,
        createdAt: DateTime.now(),
      );
      await docRef.set(post.toJson());
      return post;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Like/unlike post
  static Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection(_postsCollection).doc(postId);
      final likeRef = postRef.collection('likes').doc(userId);
      await _firestore.runTransaction((tx) async {
        final likeSnap = await tx.get(likeRef);
        if (likeSnap.exists) {
          tx.delete(likeRef);
          tx.update(postRef, {'likesCount': FieldValue.increment(-1)});
        } else {
          tx.set(likeRef, {'userId': userId, 'createdAt': DateTime.now().toIso8601String()});
          tx.update(postRef, {'likesCount': FieldValue.increment(1)});
        }
      });
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Share post
  static Future<void> sharePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection(_postsCollection).doc(postId);
      final shareRef = postRef.collection('shares').doc(userId);
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

  // Get job postings
  static Future<List<JobPosting>> getJobPostings({
    String? location,
    String? jobType,
    String? experienceLevel,
    String? keyword,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _firestore.collection(_jobsCollection).orderBy('postedDate', descending: true).limit(50);
      if (location != null && location.isNotEmpty) {
        q = q.where('location', isEqualTo: location);
      }
      if (jobType != null && jobType.isNotEmpty) {
        q = q.where('jobType', isEqualTo: jobType);
      }
      if (experienceLevel != null && experienceLevel.isNotEmpty) {
        q = q.where('experienceLevel', isEqualTo: experienceLevel);
      }
      final snapshot = await q.get();
      var jobs = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return JobPosting.fromJson(data);
      }).toList();
      if (keyword != null && keyword.isNotEmpty) {
        final norm = keyword.toLowerCase();
        jobs = jobs.where((j) =>
          j.title.toLowerCase().contains(norm) ||
          j.companyName.toLowerCase().contains(norm) ||
          j.description.toLowerCase().contains(norm)
        ).toList();
      }
      return jobs;
    } catch (e) {
      throw Exception('Failed to get job postings: $e');
    }
  }

  // Apply for job
  static Future<void> applyForJob(String jobId, String userId) async {
    try {
      final applicationRef = _firestore.collection(_jobsCollection).doc(jobId).collection('applications').doc(userId);
      await applicationRef.set({
        'userId': userId,
        'appliedAt': DateTime.now().toIso8601String(),
        'status': 'submitted',
      });
    } catch (e) {
      throw Exception('Failed to apply for job: $e');
    }
  }

  // Get connections
  static Future<List<ProfessionalProfile>> getConnections(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_profilesCollection)
          .doc(userId)
          .collection(_connectionsSubcollection)
          .get();
      final ids = snapshot.docs.map((d) => d.id).toList();
      if (ids.isEmpty) return [];
      final List<ProfessionalProfile> profiles = [];
      for (var i = 0; i < ids.length; i += 10) {
        final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
        final snap = await _firestore
            .collection(_profilesCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        profiles.addAll(snap.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return ProfessionalProfile.fromJson(data);
        }));
      }
      return profiles;
    } catch (e) {
      throw Exception('Failed to get connections: $e');
    }
  }

  // Send connection request
  static Future<void> sendConnectionRequest(String fromUserId, String toUserId) async {
    try {
      final requestRef = _firestore
          .collection(_profilesCollection)
          .doc(toUserId)
          .collection(_requestsSubcollection)
          .doc(fromUserId);
      await requestRef.set({
        'from': fromUserId,
        'to': toUserId,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to send connection request: $e');
    }
  }

  // Accept connection request
  static Future<void> acceptConnectionRequest(String requestId) async {
    try {
      // requestId format: fromUserId->toUserId or simply fromUserId; here we just mark accepted globally
      final q = await _firestore.collectionGroup(_requestsSubcollection)
          .where(FieldPath.documentId, isEqualTo: requestId)
          .get();
      for (final doc in q.docs) {
        await doc.reference.update({'status': 'accepted', 'acceptedAt': DateTime.now().toIso8601String()});
      }
    } catch (e) {
      throw Exception('Failed to accept connection request: $e');
    }
  }

  // Get network suggestions
  static Future<List<ProfessionalProfile>> getNetworkSuggestions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_profilesCollection)
          .orderBy('connectionsCount', descending: true)
          .limit(20)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return ProfessionalProfile.fromJson(data);
      }).where((p) => p.userId != userId).toList();
    } catch (e) {
      throw Exception('Failed to get network suggestions: $e');
    }
  }

  // Search professionals
  static Future<List<ProfessionalProfile>> searchProfessionals(String query) async {
    try {
      final snapshot = await _firestore.collection(_profilesCollection).limit(100).get();
      final normalized = query.toLowerCase();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return ProfessionalProfile.fromJson(data);
      }).where((p) =>
        p.fullName.toLowerCase().contains(normalized) ||
        p.headline.toLowerCase().contains(normalized) ||
        p.currentCompany.toLowerCase().contains(normalized)
      ).toList();
    } catch (e) {
      throw Exception('Failed to search professionals: $e');
    }
  }

  // Get industries
  static Future<List<String>> getIndustries() async {
    try {
      return [
        'Technology',
        'Healthcare',
        'Finance',
        'Education',
        'Marketing',
        'Sales',
        'Consulting',
        'Manufacturing',
        'Retail',
        'Real Estate',
        'Media',
        'Government',
        'Non-profit',
        'Transportation',
        'Energy',
        'Agriculture',
        'Construction',
        'Hospitality',
        'Legal',
        'Sports',
      ];
    } catch (e) {
      throw Exception('Failed to get industries: $e');
    }
  }

  // Mock data generators (kept for reference)
  static ProfessionalProfile _createMockProfile(String userId) {
    return ProfessionalProfile(
      id: 'profile_$userId',
      userId: userId,
      firstName: 'John',
      lastName: 'Doe',
      headline: 'Software Engineer | Mobile App Developer | Flutter Expert',
      summary: 'Passionate software engineer with 5+ years of experience in mobile app development. Specialized in Flutter, React Native, and native iOS/Android development. Always eager to learn new technologies and contribute to innovative projects.',
      profileImageUrl: 'https://via.placeholder.com/200x200/4ECDC4/FFFFFF?text=JD',
      coverImageUrl: 'https://via.placeholder.com/800x200/45B7D1/FFFFFF?text=Cover+Image',
      location: 'San Francisco, CA',
      industry: 'Technology',
      currentPosition: 'Senior Software Engineer',
      currentCompany: 'Tech Corp',
      email: 'john.doe@email.com',
      phone: '+1-555-0123',
      website: 'https://johndoe.dev',
      skills: ['Flutter', 'Dart', 'React Native', 'JavaScript', 'TypeScript', 'iOS', 'Android', 'Firebase', 'AWS'],
      workExperience: _createMockWorkExperience(),
      education: _createMockEducation(),
      certifications: _createMockCertifications(),
      languages: ['English', 'Spanish', 'French'],
      interests: ['Mobile Development', 'AI/ML', 'Blockchain', 'Open Source'],
      connectionsCount: 500,
      followersCount: 1200,
      isVerified: true,
      isPremium: false,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );
  }

  static List<ProfessionalProfile> _createMockProfiles() {
    final names = [
      {'first': 'Alice', 'last': 'Johnson', 'title': 'Product Manager', 'company': 'Google'},
      {'first': 'Bob', 'last': 'Smith', 'title': 'Data Scientist', 'company': 'Microsoft'},
      {'first': 'Carol', 'last': 'Williams', 'title': 'UX Designer', 'company': 'Apple'},
      {'first': 'David', 'last': 'Brown', 'title': 'Marketing Director', 'company': 'Meta'},
      {'first': 'Emma', 'last': 'Davis', 'title': 'Software Architect', 'company': 'Amazon'},
      {'first': 'Frank', 'last': 'Miller', 'title': 'DevOps Engineer', 'company': 'Netflix'},
      {'first': 'Grace', 'last': 'Wilson', 'title': 'Business Analyst', 'company': 'Uber'},
      {'first': 'Henry', 'last': 'Moore', 'title': 'Sales Manager', 'company': 'Salesforce'},
    ];

    return List.generate(20, (index) {
      final name = names[index % names.length];
      final connections = 100 + (index * 50);
      final followers = 200 + (index * 100);

      return ProfessionalProfile(
        id: 'profile_$index',
        userId: 'user_$index',
        firstName: name['first']!,
        lastName: name['last']!,
        headline: '${name['title']} at ${name['company']}',
        summary: 'Experienced professional in ${name['title']!.toLowerCase()} with a passion for innovation.',
        profileImageUrl: 'https://via.placeholder.com/200x200/${_getRandomColor()}/FFFFFF?text=${name['first']![0]}${name['last']![0]}',
        location: _getRandomLocation(),
        industry: _getRandomIndustry(),
        currentPosition: name['title']!,
        currentCompany: name['company']!,
        connectionsCount: connections,
        followersCount: followers,
        isVerified: index % 3 == 0,
        isPremium: index % 5 == 0,
        createdAt: DateTime.now().subtract(Duration(days: index * 30)),
        updatedAt: DateTime.now().subtract(Duration(days: index * 7)),
      );
    });
  }

  static List<ProfessionalPost> _createMockPosts() {
    final contents = [
      'Excited to share that our team just launched a new feature! 🚀 The response has been incredible.',
      'Just finished reading "Clean Code" by Robert Martin. Highly recommend it to all developers! 📚',
      'Looking for talented Flutter developers to join our team. DM me if you\'re interested! 💼',
      'Attended an amazing tech conference today. The future of AI is truly exciting! 🤖',
      'Proud to announce that our app has reached 1M downloads! Thank you to all our users! 🎉',
      'Sharing some insights from my recent project. What challenges have you faced in mobile development?',
      'Just completed a challenging project using Flutter and Firebase. The learning curve was worth it!',
      'Networking is key in our industry. Always happy to connect with fellow professionals! 🤝',
    ];

    final companies = ['Google', 'Microsoft', 'Apple', 'Meta', 'Amazon', 'Netflix', 'Uber', 'Salesforce'];
    final titles = ['Software Engineer', 'Product Manager', 'UX Designer', 'Data Scientist', 'Marketing Director'];

    return List.generate(15, (index) {
      final content = contents[index % contents.length];
      final company = companies[index % companies.length];
      final title = titles[index % titles.length];
      final authorName = 'User ${index + 1}';

      return ProfessionalPost(
        id: 'post_$index',
        authorId: 'user_$index',
        authorName: authorName,
        authorTitle: title,
        authorCompany: company,
        authorImageUrl: 'https://via.placeholder.com/50x50/${_getRandomColor()}/FFFFFF?text=${authorName[0]}',
        content: content,
        hashtags: _getRandomHashtags(),
        likesCount: 10 + (index * 5),
        commentsCount: 2 + (index % 5),
        sharesCount: 1 + (index % 3),
        createdAt: DateTime.now().subtract(Duration(hours: index * 2)),
        isLiked: index % 3 == 0,
        isShared: index % 4 == 0,
        type: PostType.values[index % PostType.values.length],
      );
    });
  }

  static List<JobPosting> _createMockJobPostings() {
    final companies = ['Google', 'Microsoft', 'Apple', 'Meta', 'Amazon', 'Netflix', 'Uber', 'Salesforce'];
    final titles = [
      'Senior Flutter Developer',
      'Product Manager',
      'UX Designer',
      'Data Scientist',
      'Marketing Manager',
      'DevOps Engineer',
      'Business Analyst',
      'Sales Representative',
    ];
    final locations = ['San Francisco, CA', 'New York, NY', 'Seattle, WA', 'Austin, TX', 'Remote'];
    final jobTypes = ['Full-time', 'Part-time', 'Contract', 'Internship'];
    final experienceLevels = ['Entry', 'Mid', 'Senior', 'Executive'];

    return List.generate(20, (index) {
      final company = companies[index % companies.length];
      final title = titles[index % titles.length];
      final location = locations[index % locations.length];
      final jobType = jobTypes[index % jobTypes.length];
      final experienceLevel = experienceLevels[index % experienceLevels.length];

      return JobPosting(
        id: 'job_$index',
        companyId: 'company_$index',
        companyName: company,
        companyLogoUrl: 'https://via.placeholder.com/100x100/${_getRandomColor()}/FFFFFF?text=${company[0]}',
        title: title,
        location: location,
        jobType: jobType,
        experienceLevel: experienceLevel,
        description: 'We are looking for a talented $title to join our team. This is an exciting opportunity to work on cutting-edge projects.',
        requirements: _getRandomRequirements(),
        benefits: _getRandomBenefits(),
        salaryMin: 80000 + (index * 10000),
        salaryMax: 120000 + (index * 15000),
        isRemote: index % 3 == 0,
        postedDate: DateTime.now().subtract(Duration(days: index)),
        applicantsCount: 10 + (index * 5),
        isApplied: index % 4 == 0,
      );
    });
  }

  static List<WorkExperience> _createMockWorkExperience() {
    return [
      WorkExperience(
        id: 'exp_1',
        title: 'Senior Software Engineer',
        company: 'Tech Corp',
        location: 'San Francisco, CA',
        description: 'Led development of mobile applications using Flutter and React Native. Managed a team of 5 developers.',
        startDate: DateTime(2020, 1),
        isCurrent: true,
        companyLogoUrl: 'https://via.placeholder.com/100x100/4ECDC4/FFFFFF?text=TC',
      ),
      WorkExperience(
        id: 'exp_2',
        title: 'Software Engineer',
        company: 'StartupXYZ',
        location: 'Palo Alto, CA',
        description: 'Developed iOS and Android applications from scratch. Collaborated with design team to create user-friendly interfaces.',
        startDate: DateTime(2018, 6),
        endDate: DateTime(2019, 12),
        companyLogoUrl: 'https://via.placeholder.com/100x100/45B7D1/FFFFFF?text=SX',
      ),
    ];
  }

  static List<Education> _createMockEducation() {
    return [
      Education(
        id: 'edu_1',
        school: 'Stanford University',
        degree: 'Bachelor of Science',
        fieldOfStudy: 'Computer Science',
        startDate: DateTime(2014, 9),
        endDate: DateTime(2018, 6),
        gpa: 3.8,
        schoolLogoUrl: 'https://via.placeholder.com/100x100/96CEB4/FFFFFF?text=SU',
      ),
    ];
  }

  static List<Certification> _createMockCertifications() {
    return [
      Certification(
        id: 'cert_1',
        name: 'AWS Certified Solutions Architect',
        issuingOrganization: 'Amazon Web Services',
        issueDate: DateTime(2021, 3),
        expirationDate: DateTime(2024, 3),
        credentialId: 'AWS-CSA-123456',
      ),
      Certification(
        id: 'cert_2',
        name: 'Google Cloud Professional Developer',
        issuingOrganization: 'Google Cloud',
        issueDate: DateTime(2022, 1),
        expirationDate: DateTime(2025, 1),
        credentialId: 'GCP-PD-789012',
      ),
    ];
  }

  static List<String> _getRandomHashtags() {
    final hashtags = [
      '#Flutter', '#MobileDev', '#Tech', '#Innovation', '#Career',
      '#SoftwareEngineering', '#AI', '#MachineLearning', '#Startup',
      '#Networking', '#ProfessionalDevelopment', '#TechTrends',
    ];
    return List.generate(3, (index) => hashtags[Random().nextInt(hashtags.length)]);
  }

  static List<String> _getRandomRequirements() {
    return [
      'Bachelor\'s degree in Computer Science or related field',
      '3+ years of experience in mobile development',
      'Strong knowledge of Flutter/Dart',
      'Experience with REST APIs',
      'Excellent problem-solving skills',
    ];
  }

  static List<String> _getRandomBenefits() {
    return [
      'Competitive salary',
      'Health insurance',
      '401(k) matching',
      'Flexible work hours',
      'Remote work options',
      'Professional development budget',
    ];
  }

  static String _getRandomLocation() {
    final locations = [
      'San Francisco, CA',
      'New York, NY',
      'Seattle, WA',
      'Austin, TX',
      'Boston, MA',
      'Chicago, IL',
      'Los Angeles, CA',
      'Denver, CO',
    ];
    return locations[Random().nextInt(locations.length)];
  }

  static String _getRandomIndustry() {
    final industries = [
      'Technology',
      'Healthcare',
      'Finance',
      'Education',
      'Marketing',
      'Consulting',
      'Manufacturing',
      'Retail',
    ];
    return industries[Random().nextInt(industries.length)];
  }

  static String _getRandomColor() {
    final colors = [
      'FF6B6B', '4ECDC4', '45B7D1', '96CEB4', 'FFEAA7', 'DDA0DD',
      '98D8C8', 'F7DC6F', 'BB8FCE', '85C1E9', 'F8C471', '82E0AA',
    ];
    return colors[Random().nextInt(colors.length)];
  }
}