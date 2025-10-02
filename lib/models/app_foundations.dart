// App-weite Grundlagen Models

class UserAccount {
  final String id;
  final String phoneNumber;
  final String? email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? status;
  final String? bio;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isVerified;
  final bool isActive;
  final List<ConnectedDevice> devices;
  final List<SocialLogin> socialLogins;
  final PrivacySettings privacy;
  final SecuritySettings security;
  final Map<String, dynamic>? metadata;

  UserAccount({
    required this.id,
    required this.phoneNumber,
    this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.status,
    this.bio,
    required this.createdAt,
    this.lastActiveAt,
    this.isVerified = false,
    this.isActive = true,
    this.devices = const [],
    this.socialLogins = const [],
    required this.privacy,
    required this.security,
    this.metadata,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      username: json['username'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      status: json['status'],
      bio: json['bio'],
      createdAt: DateTime.parse(json['createdAt']),
      lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt']) : null,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      devices: (json['devices'] as List?)
          ?.map((device) => ConnectedDevice.fromJson(device))
          .toList() ?? [],
      socialLogins: (json['socialLogins'] as List?)
          ?.map((login) => SocialLogin.fromJson(login))
          .toList() ?? [],
      privacy: PrivacySettings.fromJson(json['privacy']),
      security: SecuritySettings.fromJson(json['security']),
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'email': email,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'status': status,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isVerified': isVerified,
      'isActive': isActive,
      'devices': devices.map((device) => device.toJson()).toList(),
      'socialLogins': socialLogins.map((login) => login.toJson()).toList(),
      'privacy': privacy.toJson(),
      'security': security.toJson(),
      'metadata': metadata,
    };
  }
}

class ConnectedDevice {
  final String id;
  final String name;
  final String type; // 'mobile', 'tablet', 'desktop', 'web'
  final String platform; // 'ios', 'android', 'windows', 'macos', 'web'
  final String? model;
  final String? osVersion;
  final String? appVersion;
  final DateTime lastSeenAt;
  final bool isPrimary;
  final bool isActive;
  final String? pushToken;
  final Map<String, dynamic>? metadata;

  ConnectedDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.platform,
    this.model,
    this.osVersion,
    this.appVersion,
    required this.lastSeenAt,
    this.isPrimary = false,
    this.isActive = true,
    this.pushToken,
    this.metadata,
  });

  factory ConnectedDevice.fromJson(Map<String, dynamic> json) {
    return ConnectedDevice(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      platform: json['platform'],
      model: json['model'],
      osVersion: json['osVersion'],
      appVersion: json['appVersion'],
      lastSeenAt: DateTime.parse(json['lastSeenAt']),
      isPrimary: json['isPrimary'] ?? false,
      isActive: json['isActive'] ?? true,
      pushToken: json['pushToken'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'platform': platform,
      'model': model,
      'osVersion': osVersion,
      'appVersion': appVersion,
      'lastSeenAt': lastSeenAt.toIso8601String(),
      'isPrimary': isPrimary,
      'isActive': isActive,
      'pushToken': pushToken,
      'metadata': metadata,
    };
  }
}

class SocialLogin {
  final String provider; // 'google', 'apple', 'facebook', 'twitter'
  final String providerId;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final DateTime connectedAt;
  final bool isActive;

  SocialLogin({
    required this.provider,
    required this.providerId,
    this.email,
    this.name,
    this.avatarUrl,
    required this.connectedAt,
    this.isActive = true,
  });

  factory SocialLogin.fromJson(Map<String, dynamic> json) {
    return SocialLogin(
      provider: json['provider'],
      providerId: json['providerId'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      connectedAt: DateTime.parse(json['connectedAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'providerId': providerId,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'connectedAt': connectedAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class PrivacySettings {
  final PrivacyLevel profileVisibility;
  final PrivacyLevel lastSeenVisibility;
  final PrivacyLevel statusVisibility;
  final bool showReadReceipts;
  final bool showTypingIndicator;
  final bool allowGroupInvites;
  final bool allowFriendRequests;
  final bool allowLocationSharing;
  final bool allowDataCollection;
  final List<String> blockedUsers;
  final List<String> mutedUsers;
  final Map<String, dynamic>? customSettings;

  PrivacySettings({
    this.profileVisibility = PrivacyLevel.contacts,
    this.lastSeenVisibility = PrivacyLevel.contacts,
    this.statusVisibility = PrivacyLevel.contacts,
    this.showReadReceipts = true,
    this.showTypingIndicator = true,
    this.allowGroupInvites = true,
    this.allowFriendRequests = true,
    this.allowLocationSharing = false,
    this.allowDataCollection = true,
    this.blockedUsers = const [],
    this.mutedUsers = const [],
    this.customSettings,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      profileVisibility: PrivacyLevel.values.firstWhere(
        (e) => e.toString() == 'PrivacyLevel.${json['profileVisibility']}',
        orElse: () => PrivacyLevel.contacts,
      ),
      lastSeenVisibility: PrivacyLevel.values.firstWhere(
        (e) => e.toString() == 'PrivacyLevel.${json['lastSeenVisibility']}',
        orElse: () => PrivacyLevel.contacts,
      ),
      statusVisibility: PrivacyLevel.values.firstWhere(
        (e) => e.toString() == 'PrivacyLevel.${json['statusVisibility']}',
        orElse: () => PrivacyLevel.contacts,
      ),
      showReadReceipts: json['showReadReceipts'] ?? true,
      showTypingIndicator: json['showTypingIndicator'] ?? true,
      allowGroupInvites: json['allowGroupInvites'] ?? true,
      allowFriendRequests: json['allowFriendRequests'] ?? true,
      allowLocationSharing: json['allowLocationSharing'] ?? false,
      allowDataCollection: json['allowDataCollection'] ?? true,
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      mutedUsers: List<String>.from(json['mutedUsers'] ?? []),
      customSettings: json['customSettings'] != null ? Map<String, dynamic>.from(json['customSettings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileVisibility': profileVisibility.toString().split('.').last,
      'lastSeenVisibility': lastSeenVisibility.toString().split('.').last,
      'statusVisibility': statusVisibility.toString().split('.').last,
      'showReadReceipts': showReadReceipts,
      'showTypingIndicator': showTypingIndicator,
      'allowGroupInvites': allowGroupInvites,
      'allowFriendRequests': allowFriendRequests,
      'allowLocationSharing': allowLocationSharing,
      'allowDataCollection': allowDataCollection,
      'blockedUsers': blockedUsers,
      'mutedUsers': mutedUsers,
      'customSettings': customSettings,
    };
  }
}

enum PrivacyLevel {
  everyone,
  contacts,
  contactsOfContacts,
  nobody,
}

class SecuritySettings {
  final bool twoFactorEnabled;
  final bool biometricLockEnabled;
  final bool pinLockEnabled;
  final String? pinHash;
  final bool autoLockEnabled;
  final int autoLockTimeoutMinutes;
  final bool endToEndEncryptionEnabled;
  final bool deviceBindingEnabled;
  final List<SecuritySession> activeSessions;
  final List<SecurityEvent> securityHistory;
  final Map<String, dynamic>? customSettings;

  SecuritySettings({
    this.twoFactorEnabled = false,
    this.biometricLockEnabled = false,
    this.pinLockEnabled = false,
    this.pinHash,
    this.autoLockEnabled = true,
    this.autoLockTimeoutMinutes = 5,
    this.endToEndEncryptionEnabled = true,
    this.deviceBindingEnabled = true,
    this.activeSessions = const [],
    this.securityHistory = const [],
    this.customSettings,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      biometricLockEnabled: json['biometricLockEnabled'] ?? false,
      pinLockEnabled: json['pinLockEnabled'] ?? false,
      pinHash: json['pinHash'],
      autoLockEnabled: json['autoLockEnabled'] ?? true,
      autoLockTimeoutMinutes: json['autoLockTimeoutMinutes'] ?? 5,
      endToEndEncryptionEnabled: json['endToEndEncryptionEnabled'] ?? true,
      deviceBindingEnabled: json['deviceBindingEnabled'] ?? true,
      activeSessions: (json['activeSessions'] as List?)
          ?.map((session) => SecuritySession.fromJson(session))
          .toList() ?? [],
      securityHistory: (json['securityHistory'] as List?)
          ?.map((event) => SecurityEvent.fromJson(event))
          .toList() ?? [],
      customSettings: json['customSettings'] != null ? Map<String, dynamic>.from(json['customSettings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'twoFactorEnabled': twoFactorEnabled,
      'biometricLockEnabled': biometricLockEnabled,
      'pinLockEnabled': pinLockEnabled,
      'pinHash': pinHash,
      'autoLockEnabled': autoLockEnabled,
      'autoLockTimeoutMinutes': autoLockTimeoutMinutes,
      'endToEndEncryptionEnabled': endToEndEncryptionEnabled,
      'deviceBindingEnabled': deviceBindingEnabled,
      'activeSessions': activeSessions.map((session) => session.toJson()).toList(),
      'securityHistory': securityHistory.map((event) => event.toJson()).toList(),
      'customSettings': customSettings,
    };
  }
}

class SecuritySession {
  final String id;
  final String deviceId;
  final String deviceName;
  final String platform;
  final String? location;
  final String? ipAddress;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isCurrent;
  final bool isActive;

  SecuritySession({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    this.location,
    this.ipAddress,
    required this.createdAt,
    this.lastActiveAt,
    this.isCurrent = false,
    this.isActive = true,
  });

  factory SecuritySession.fromJson(Map<String, dynamic> json) {
    return SecuritySession(
      id: json['id'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      platform: json['platform'],
      location: json['location'],
      ipAddress: json['ipAddress'],
      createdAt: DateTime.parse(json['createdAt']),
      lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt']) : null,
      isCurrent: json['isCurrent'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'platform': platform,
      'location': location,
      'ipAddress': ipAddress,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'isCurrent': isCurrent,
      'isActive': isActive,
    };
  }
}

class SecurityEvent {
  final String id;
  final SecurityEventType type;
  final String description;
  final String? deviceId;
  final String? location;
  final String? ipAddress;
  final DateTime occurredAt;
  final bool isResolved;
  final Map<String, dynamic>? metadata;

  SecurityEvent({
    required this.id,
    required this.type,
    required this.description,
    this.deviceId,
    this.location,
    this.ipAddress,
    required this.occurredAt,
    this.isResolved = false,
    this.metadata,
  });

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      id: json['id'],
      type: SecurityEventType.values.firstWhere(
        (e) => e.toString() == 'SecurityEventType.${json['type']}',
        orElse: () => SecurityEventType.login,
      ),
      description: json['description'],
      deviceId: json['deviceId'],
      location: json['location'],
      ipAddress: json['ipAddress'],
      occurredAt: DateTime.parse(json['occurredAt']),
      isResolved: json['isResolved'] ?? false,
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'description': description,
      'deviceId': deviceId,
      'location': location,
      'ipAddress': ipAddress,
      'occurredAt': occurredAt.toIso8601String(),
      'isResolved': isResolved,
      'metadata': metadata,
    };
  }
}

enum SecurityEventType {
  login,
  logout,
  passwordChange,
  twoFactorEnabled,
  twoFactorDisabled,
  deviceAdded,
  deviceRemoved,
  suspiciousActivity,
  dataExport,
  accountDeletion,
}

class AppSettings {
  final String language;
  final String region;
  final bool isRTL;
  final ThemeMode themeMode;
  final bool isDarkMode;
  final bool isSystemTheme;
  final double fontSize;
  final bool isLargeText;
  final bool isScreenReaderEnabled;
  final bool isHighContrast;
  final bool isReduceMotion;
  final NotificationSettings notifications;
  final CacheSettings cache;
  final Map<String, dynamic>? customSettings;

  AppSettings({
    this.language = 'en',
    this.region = 'US',
    this.isRTL = false,
    this.themeMode = ThemeMode.system,
    this.isDarkMode = false,
    this.isSystemTheme = true,
    this.fontSize = 16.0,
    this.isLargeText = false,
    this.isScreenReaderEnabled = false,
    this.isHighContrast = false,
    this.isReduceMotion = false,
    required this.notifications,
    required this.cache,
    this.customSettings,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] ?? 'en',
      region: json['region'] ?? 'US',
      isRTL: json['isRTL'] ?? false,
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.${json['themeMode']}',
        orElse: () => ThemeMode.system,
      ),
      isDarkMode: json['isDarkMode'] ?? false,
      isSystemTheme: json['isSystemTheme'] ?? true,
      fontSize: (json['fontSize'] ?? 16.0).toDouble(),
      isLargeText: json['isLargeText'] ?? false,
      isScreenReaderEnabled: json['isScreenReaderEnabled'] ?? false,
      isHighContrast: json['isHighContrast'] ?? false,
      isReduceMotion: json['isReduceMotion'] ?? false,
      notifications: NotificationSettings.fromJson(json['notifications']),
      cache: CacheSettings.fromJson(json['cache']),
      customSettings: json['customSettings'] != null ? Map<String, dynamic>.from(json['customSettings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'region': region,
      'isRTL': isRTL,
      'themeMode': themeMode.toString().split('.').last,
      'isDarkMode': isDarkMode,
      'isSystemTheme': isSystemTheme,
      'fontSize': fontSize,
      'isLargeText': isLargeText,
      'isScreenReaderEnabled': isScreenReaderEnabled,
      'isHighContrast': isHighContrast,
      'isReduceMotion': isReduceMotion,
      'notifications': notifications.toJson(),
      'cache': cache.toJson(),
      'customSettings': customSettings,
    };
  }
}

class NotificationSettings {
  final bool pushEnabled;
  final bool chatNotifications;
  final bool groupNotifications;
  final bool momentNotifications;
  final bool callNotifications;
  final bool silentMode;
  final List<QuietHours> quietHours;
  final List<String> exceptionContacts;
  final Map<String, dynamic>? customSettings;

  NotificationSettings({
    this.pushEnabled = true,
    this.chatNotifications = true,
    this.groupNotifications = true,
    this.momentNotifications = true,
    this.callNotifications = true,
    this.silentMode = false,
    this.quietHours = const [],
    this.exceptionContacts = const [],
    this.customSettings,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] ?? true,
      chatNotifications: json['chatNotifications'] ?? true,
      groupNotifications: json['groupNotifications'] ?? true,
      momentNotifications: json['momentNotifications'] ?? true,
      callNotifications: json['callNotifications'] ?? true,
      silentMode: json['silentMode'] ?? false,
      quietHours: (json['quietHours'] as List?)
          ?.map((hours) => QuietHours.fromJson(hours))
          .toList() ?? [],
      exceptionContacts: List<String>.from(json['exceptionContacts'] ?? []),
      customSettings: json['customSettings'] != null ? Map<String, dynamic>.from(json['customSettings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'chatNotifications': chatNotifications,
      'groupNotifications': groupNotifications,
      'momentNotifications': momentNotifications,
      'callNotifications': callNotifications,
      'silentMode': silentMode,
      'quietHours': quietHours.map((hours) => hours.toJson()).toList(),
      'exceptionContacts': exceptionContacts,
      'customSettings': customSettings,
    };
  }
}

class QuietHours {
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> daysOfWeek; // 0 = Sunday, 1 = Monday, etc.
  final bool isEnabled;

  QuietHours({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    this.isEnabled = true,
  });

  factory QuietHours.fromJson(Map<String, dynamic> json) {
    return QuietHours(
      name: json['name'],
      startTime: TimeOfDay.fromJson(json['startTime']),
      endTime: TimeOfDay.fromJson(json['endTime']),
      daysOfWeek: List<int>.from(json['daysOfWeek']),
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startTime': startTime.toJson(),
      'endTime': endTime.toJson(),
      'daysOfWeek': daysOfWeek,
      'isEnabled': isEnabled,
    };
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromJson(Map<String, dynamic> json) {
    return TimeOfDay(
      hour: json['hour'],
      minute: json['minute'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }
}

class CacheSettings {
  final int maxCacheSizeMB;
  final int maxCacheAgeDays;
  final bool autoCleanup;
  final bool compressImages;
  final bool compressVideos;
  final String cacheDirectory;
  final Map<String, dynamic>? customSettings;

  CacheSettings({
    this.maxCacheSizeMB = 500,
    this.maxCacheAgeDays = 30,
    this.autoCleanup = true,
    this.compressImages = true,
    this.compressVideos = false,
    this.cacheDirectory = 'cache',
    this.customSettings,
  });

  factory CacheSettings.fromJson(Map<String, dynamic> json) {
    return CacheSettings(
      maxCacheSizeMB: json['maxCacheSizeMB'] ?? 500,
      maxCacheAgeDays: json['maxCacheAgeDays'] ?? 30,
      autoCleanup: json['autoCleanup'] ?? true,
      compressImages: json['compressImages'] ?? true,
      compressVideos: json['compressVideos'] ?? false,
      cacheDirectory: json['cacheDirectory'] ?? 'cache',
      customSettings: json['customSettings'] != null ? Map<String, dynamic>.from(json['customSettings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxCacheSizeMB': maxCacheSizeMB,
      'maxCacheAgeDays': maxCacheAgeDays,
      'autoCleanup': autoCleanup,
      'compressImages': compressImages,
      'compressVideos': compressVideos,
      'cacheDirectory': cacheDirectory,
      'customSettings': customSettings,
    };
  }
}

class ComplianceSettings {
  final bool gdprCompliant;
  final bool dataTransparencyEnabled;
  final bool dataExportEnabled;
  final bool accountDeletionEnabled;
  final bool contentPolicyEnabled;
  final bool ageVerificationEnabled;
  final int? minimumAge;
  final bool parentalControlsEnabled;
  final Map<String, dynamic>? customSettings;

  ComplianceSettings({
    this.gdprCompliant = true,
    this.dataTransparencyEnabled = true,
    this.dataExportEnabled = true,
    this.accountDeletionEnabled = true,
    this.contentPolicyEnabled = true,
    this.ageVerificationEnabled = false,
    this.minimumAge,
    this.parentalControlsEnabled = false,
    this.customSettings,
  });

  factory ComplianceSettings.fromJson(Map<String, dynamic> json) {
    return ComplianceSettings(
      gdprCompliant: json['gdprCompliant'] ?? true,
      dataTransparencyEnabled: json['dataTransparencyEnabled'] ?? true,
      dataExportEnabled: json['dataExportEnabled'] ?? true,
      accountDeletionEnabled: json['accountDeletionEnabled'] ?? true,
      contentPolicyEnabled: json['contentPolicyEnabled'] ?? true,
      ageVerificationEnabled: json['ageVerificationEnabled'] ?? false,
      minimumAge: json['minimumAge'],
      parentalControlsEnabled: json['parentalControlsEnabled'] ?? false,
      customSettings: json['customSettings'] != null ? Map<String, dynamic>.from(json['customSettings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gdprCompliant': gdprCompliant,
      'dataTransparencyEnabled': dataTransparencyEnabled,
      'dataExportEnabled': dataExportEnabled,
      'accountDeletionEnabled': accountDeletionEnabled,
      'contentPolicyEnabled': contentPolicyEnabled,
      'ageVerificationEnabled': ageVerificationEnabled,
      'minimumAge': minimumAge,
      'parentalControlsEnabled': parentalControlsEnabled,
      'customSettings': customSettings,
    };
  }
}