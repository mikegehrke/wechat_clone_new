class ProfessionalProfile {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String headline;
  final String summary;
  final String profileImageUrl;
  final String coverImageUrl;
  final String location;
  final String industry;
  final String currentPosition;
  final String currentCompany;
  final String email;
  final String phone;
  final String website;
  final List<String> skills;
  final List<WorkExperience> workExperience;
  final List<Education> education;
  final List<Certification> certifications;
  final List<String> languages;
  final List<String> interests;
  final int connectionsCount;
  final int followersCount;
  final bool isVerified;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfessionalProfile({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.headline,
    this.summary = '',
    this.profileImageUrl = '',
    this.coverImageUrl = '',
    this.location = '',
    this.industry = '',
    this.currentPosition = '',
    this.currentCompany = '',
    this.email = '',
    this.phone = '',
    this.website = '',
    this.skills = const [],
    this.workExperience = const [],
    this.education = const [],
    this.certifications = const [],
    this.languages = const [],
    this.interests = const [],
    this.connectionsCount = 0,
    this.followersCount = 0,
    this.isVerified = false,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfessionalProfile.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfile(
      id: json['id'],
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      headline: json['headline'],
      summary: json['summary'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      location: json['location'] ?? '',
      industry: json['industry'] ?? '',
      currentPosition: json['currentPosition'] ?? '',
      currentCompany: json['currentCompany'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      workExperience:
          (json['workExperience'] as List?)
              ?.map((exp) => WorkExperience.fromJson(exp))
              .toList() ??
          [],
      education:
          (json['education'] as List?)
              ?.map((edu) => Education.fromJson(edu))
              .toList() ??
          [],
      certifications:
          (json['certifications'] as List?)
              ?.map((cert) => Certification.fromJson(cert))
              .toList() ??
          [],
      languages: List<String>.from(json['languages'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      connectionsCount: json['connectionsCount'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isPremium: json['isPremium'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'headline': headline,
      'summary': summary,
      'profileImageUrl': profileImageUrl,
      'coverImageUrl': coverImageUrl,
      'location': location,
      'industry': industry,
      'currentPosition': currentPosition,
      'currentCompany': currentCompany,
      'email': email,
      'phone': phone,
      'website': website,
      'skills': skills,
      'workExperience': workExperience.map((exp) => exp.toJson()).toList(),
      'education': education.map((edu) => edu.toJson()).toList(),
      'certifications': certifications.map((cert) => cert.toJson()).toList(),
      'languages': languages,
      'interests': interests,
      'connectionsCount': connectionsCount,
      'followersCount': followersCount,
      'isVerified': isVerified,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName {
    return '$firstName $lastName';
  }

  String get formattedConnectionsCount {
    if (connectionsCount >= 1000) {
      return '${(connectionsCount / 1000).toStringAsFixed(1)}K';
    }
    return connectionsCount.toString();
  }

  String get formattedFollowersCount {
    if (followersCount >= 1000) {
      return '${(followersCount / 1000).toStringAsFixed(1)}K';
    }
    return followersCount.toString();
  }
}

class WorkExperience {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String companyLogoUrl;

  WorkExperience({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.companyLogoUrl = '',
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      id: json['id'],
      title: json['title'],
      company: json['company'],
      location: json['location'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isCurrent: json['isCurrent'] ?? false,
      companyLogoUrl: json['companyLogoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isCurrent': isCurrent,
      'companyLogoUrl': companyLogoUrl,
    };
  }

  String get duration {
    final end = endDate ?? DateTime.now();
    final years = end.year - startDate.year;
    final months = end.month - startDate.month;

    if (years > 0) {
      return months > 0 ? '$years yr $months mo' : '$years yr';
    } else {
      return '$months mo';
    }
  }

  String get formattedDateRange {
    final start = '${startDate.month}/${startDate.year}';
    final end = isCurrent ? 'Present' : '${endDate!.month}/${endDate!.year}';
    return '$start - $end';
  }
}

class Education {
  final String id;
  final String school;
  final String degree;
  final String fieldOfStudy;
  final DateTime startDate;
  final DateTime? endDate;
  final double? gpa;
  final String description;
  final String schoolLogoUrl;

  Education({
    required this.id,
    required this.school,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.gpa,
    this.description = '',
    this.schoolLogoUrl = '',
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'],
      school: json['school'],
      degree: json['degree'],
      fieldOfStudy: json['fieldOfStudy'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      gpa: json['gpa']?.toDouble(),
      description: json['description'] ?? '',
      schoolLogoUrl: json['schoolLogoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school': school,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'gpa': gpa,
      'description': description,
      'schoolLogoUrl': schoolLogoUrl,
    };
  }

  String get formattedDateRange {
    final start = startDate.year;
    final end = endDate?.year ?? 'Present';
    return '$start - $end';
  }
}

class Certification {
  final String id;
  final String name;
  final String issuingOrganization;
  final DateTime issueDate;
  final DateTime? expirationDate;
  final String credentialId;
  final String credentialUrl;

  Certification({
    required this.id,
    required this.name,
    required this.issuingOrganization,
    required this.issueDate,
    this.expirationDate,
    this.credentialId = '',
    this.credentialUrl = '',
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['id'],
      name: json['name'],
      issuingOrganization: json['issuingOrganization'],
      issueDate: DateTime.parse(json['issueDate']),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      credentialId: json['credentialId'] ?? '',
      credentialUrl: json['credentialUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuingOrganization': issuingOrganization,
      'issueDate': issueDate.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'credentialId': credentialId,
      'credentialUrl': credentialUrl,
    };
  }

  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  String get formattedIssueDate {
    return '${issueDate.month}/${issueDate.year}';
  }

  String get formattedExpirationDate {
    if (expirationDate == null) return 'No expiration';
    return '${expirationDate!.month}/${expirationDate!.year}';
  }
}

class ProfessionalPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorTitle;
  final String authorCompany;
  final String authorImageUrl;
  final String content;
  final List<String> images;
  final List<String> videos;
  final List<String> hashtags;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  final bool isLiked;
  final bool isShared;
  final PostType type;

  ProfessionalPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorTitle,
    required this.authorCompany,
    required this.authorImageUrl,
    required this.content,
    this.images = const [],
    this.videos = const [],
    this.hashtags = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    required this.createdAt,
    this.isLiked = false,
    this.isShared = false,
    this.type = PostType.text,
  });

  factory ProfessionalPost.fromJson(Map<String, dynamic> json) {
    return ProfessionalPost(
      id: json['id'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorTitle: json['authorTitle'],
      authorCompany: json['authorCompany'],
      authorImageUrl: json['authorImageUrl'],
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      sharesCount: json['sharesCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      isLiked: json['isLiked'] ?? false,
      isShared: json['isShared'] ?? false,
      type: PostType.values.firstWhere(
        (e) => e.toString() == 'PostType.${json['type']}',
        orElse: () => PostType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorTitle': authorTitle,
      'authorCompany': authorCompany,
      'authorImageUrl': authorImageUrl,
      'content': content,
      'images': images,
      'videos': videos,
      'hashtags': hashtags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
      'isShared': isShared,
      'type': type.toString().split('.').last,
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

enum PostType { text, image, video, article, job, event }

class JobPosting {
  final String id;
  final String companyId;
  final String companyName;
  final String companyLogoUrl;
  final String title;
  final String location;
  final String jobType; // Full-time, Part-time, Contract, etc.
  final String experienceLevel; // Entry, Mid, Senior, etc.
  final String description;
  final List<String> requirements;
  final List<String> benefits;
  final double? salaryMin;
  final double? salaryMax;
  final String salaryCurrency;
  final bool isRemote;
  final DateTime postedDate;
  final DateTime? applicationDeadline;
  final int applicantsCount;
  final bool isApplied;

  JobPosting({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.companyLogoUrl,
    required this.title,
    required this.location,
    required this.jobType,
    required this.experienceLevel,
    required this.description,
    this.requirements = const [],
    this.benefits = const [],
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency = 'USD',
    this.isRemote = false,
    required this.postedDate,
    this.applicationDeadline,
    this.applicantsCount = 0,
    this.isApplied = false,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      id: json['id'],
      companyId: json['companyId'],
      companyName: json['companyName'],
      companyLogoUrl: json['companyLogoUrl'],
      title: json['title'],
      location: json['location'],
      jobType: json['jobType'],
      experienceLevel: json['experienceLevel'],
      description: json['description'],
      requirements: List<String>.from(json['requirements'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      salaryMin: json['salaryMin']?.toDouble(),
      salaryMax: json['salaryMax']?.toDouble(),
      salaryCurrency: json['salaryCurrency'] ?? 'USD',
      isRemote: json['isRemote'] ?? false,
      postedDate: DateTime.parse(json['postedDate']),
      applicationDeadline: json['applicationDeadline'] != null
          ? DateTime.parse(json['applicationDeadline'])
          : null,
      applicantsCount: json['applicantsCount'] ?? 0,
      isApplied: json['isApplied'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'companyLogoUrl': companyLogoUrl,
      'title': title,
      'location': location,
      'jobType': jobType,
      'experienceLevel': experienceLevel,
      'description': description,
      'requirements': requirements,
      'benefits': benefits,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'salaryCurrency': salaryCurrency,
      'isRemote': isRemote,
      'postedDate': postedDate.toIso8601String(),
      'applicationDeadline': applicationDeadline?.toIso8601String(),
      'applicantsCount': applicantsCount,
      'isApplied': isApplied,
    };
  }

  String get formattedSalary {
    if (salaryMin == null || salaryMax == null) return 'Salary not specified';
    return '\$${salaryMin!.toStringAsFixed(0)} - \$${salaryMax!.toStringAsFixed(0)} $salaryCurrency';
  }

  String get formattedPostedDate {
    final now = DateTime.now();
    final difference = now.difference(postedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }
}
