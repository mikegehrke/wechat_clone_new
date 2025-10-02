class DatingProfile {
  final String id;
  final String name;
  final int age;
  final String bio;
  final List<String> photos;
  final String location;
  final double distance;
  final List<String> interests;
  final String job;
  final String education;
  final int height; // in cm
  final String lookingFor;
  final bool isVerified;
  final DateTime lastActive;
  final List<String> photos; // Multiple photos for swiping

  DatingProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.photos,
    required this.location,
    required this.distance,
    this.interests = const [],
    this.job = '',
    this.education = '',
    this.height = 0,
    this.lookingFor = '',
    this.isVerified = false,
    required this.lastActive,
  });

  factory DatingProfile.fromJson(Map<String, dynamic> json) {
    return DatingProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      bio: json['bio'],
      photos: List<String>.from(json['photos'] ?? []),
      location: json['location'],
      distance: json['distance']?.toDouble() ?? 0.0,
      interests: List<String>.from(json['interests'] ?? []),
      job: json['job'] ?? '',
      education: json['education'] ?? '',
      height: json['height'] ?? 0,
      lookingFor: json['lookingFor'] ?? '',
      isVerified: json['isVerified'] ?? false,
      lastActive: DateTime.parse(json['lastActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'bio': bio,
      'photos': photos,
      'location': location,
      'distance': distance,
      'interests': interests,
      'job': job,
      'education': education,
      'height': height,
      'lookingFor': lookingFor,
      'isVerified': isVerified,
      'lastActive': lastActive.toIso8601String(),
    };
  }

  DatingProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? bio,
    List<String>? photos,
    String? location,
    double? distance,
    List<String>? interests,
    String? job,
    String? education,
    int? height,
    String? lookingFor,
    bool? isVerified,
    DateTime? lastActive,
  }) {
    return DatingProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      photos: photos ?? this.photos,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      interests: interests ?? this.interests,
      job: job ?? this.job,
      education: education ?? this.education,
      height: height ?? this.height,
      lookingFor: lookingFor ?? this.lookingFor,
      isVerified: isVerified ?? this.isVerified,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  String get formattedDistance {
    if (distance < 1) {
      return 'Less than 1 km away';
    } else if (distance < 10) {
      return '${distance.toStringAsFixed(1)} km away';
    } else {
      return '${distance.toStringAsFixed(0)} km away';
    }
  }

  String get formattedHeight {
    if (height == 0) return '';
    final feet = (height / 30.48).floor();
    final inches = ((height % 30.48) / 2.54).round();
    return '$feet\'$inches"';
  }

  String get formattedLastActive {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours}h ago';
    } else {
      return 'Active ${difference.inDays}d ago';
    }
  }
}

class Match {
  final String id;
  final String userId1;
  final String userId2;
  final DateTime matchedAt;
  final bool hasConversation;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  Match({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.matchedAt,
    this.hasConversation = false,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      userId1: json['userId1'],
      userId2: json['userId2'],
      matchedAt: DateTime.parse(json['matchedAt']),
      hasConversation: json['hasConversation'] ?? false,
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.parse(json['lastMessageAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'matchedAt': matchedAt.toIso8601String(),
      'hasConversation': hasConversation,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
    };
  }
}

class SwipeAction {
  final String targetUserId;
  final SwipeType type;
  final DateTime timestamp;

  SwipeAction({
    required this.targetUserId,
    required this.type,
    required this.timestamp,
  });

  factory SwipeAction.fromJson(Map<String, dynamic> json) {
    return SwipeAction(
      targetUserId: json['targetUserId'],
      type: SwipeType.values.firstWhere(
        (e) => e.toString() == 'SwipeType.${json['type']}',
        orElse: () => SwipeType.like,
      ),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetUserId': targetUserId,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum SwipeType {
  like,
  superLike,
  pass,
}

class DatingPreferences {
  final int minAge;
  final int maxAge;
  final int maxDistance;
  final List<String> interestedIn;
  final bool showOnlyVerified;

  DatingPreferences({
    this.minAge = 18,
    this.maxAge = 50,
    this.maxDistance = 50,
    this.interestedIn = const ['Everyone'],
    this.showOnlyVerified = false,
  });

  factory DatingPreferences.fromJson(Map<String, dynamic> json) {
    return DatingPreferences(
      minAge: json['minAge'] ?? 18,
      maxAge: json['maxAge'] ?? 50,
      maxDistance: json['maxDistance'] ?? 50,
      interestedIn: List<String>.from(json['interestedIn'] ?? ['Everyone']),
      showOnlyVerified: json['showOnlyVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minAge': minAge,
      'maxAge': maxAge,
      'maxDistance': maxDistance,
      'interestedIn': interestedIn,
      'showOnlyVerified': showOnlyVerified,
    };
  }
}