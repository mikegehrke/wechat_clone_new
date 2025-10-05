// Status Models für Story/Status Feature
enum StatusType { image, video, text }

class Status {
  final String id;
  final String userId;
  final String userName;
  final StatusType type;
  final String? content;
  final String? mediaUrl;
  final String? caption;
  final String? backgroundColor;
  final String? textColor;
  final DateTime timestamp;
  final DateTime expiresAt;
  final List<String> views;

  Status({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    this.content,
    this.mediaUrl,
    this.caption,
    this.backgroundColor,
    this.textColor,
    required this.timestamp,
    required this.expiresAt,
    required this.views,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      type: _parseStatusType(json['type']),
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      caption: json['caption'],
      backgroundColor: json['backgroundColor'],
      textColor: json['textColor'],
      timestamp: DateTime.parse(json['timestamp']),
      expiresAt: DateTime.parse(json['expiresAt']),
      views: List<String>.from(json['views'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'type': type.toString().split('.').last,
      'content': content,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'timestamp': timestamp.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'views': views,
    };
  }

  static StatusType _parseStatusType(String? type) {
    switch (type) {
      case 'image':
        return StatusType.image;
      case 'video':
        return StatusType.video;
      case 'text':
        return StatusType.text;
      default:
        return StatusType.text;
    }
  }
}

class StatusGroup {
  final String userId;
  final String userName;
  final List<Status> statuses;
  final bool isViewed;

  StatusGroup({
    required this.userId,
    required this.userName,
    required this.statuses,
    required this.isViewed,
  });

  factory StatusGroup.fromJson(Map<String, dynamic> json) {
    return StatusGroup(
      userId: json['userId'],
      userName: json['userName'],
      statuses: (json['statuses'] as List)
          .map((statusJson) => Status.fromJson(statusJson))
          .toList(),
      isViewed: json['isViewed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'statuses': statuses.map((status) => status.toJson()).toList(),
      'isViewed': isViewed,
    };
  }
}