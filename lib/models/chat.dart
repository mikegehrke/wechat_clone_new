import 'message.dart';
import 'user.dart';

enum ChatType {
  direct,
  group,
}

class Chat {
  final String id;
  final String name;
  final ChatType type;
  final List<String> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;
  final String? avatar;
  final bool isOnline;
  final DateTime? lastSeen;
  final Map<String, dynamic>? metadata;
  
  // WhatsApp-like features
  final bool isPinned;
  final bool isMuted;
  final bool isArchived;
  final String? category;
  final String? draftMessage;
  final bool hasDisappearingMessages;
  final bool isVerified;
  final bool isTyping;
  final DateTime? pinnedAt;
  final DateTime? mutedUntil;

  Chat({
    required this.id,
    required this.name,
    required this.type,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.lastActivity,
    this.avatar,
    this.isOnline = false,
    this.lastSeen,
    this.metadata,
    this.isPinned = false,
    this.isMuted = false,
    this.isArchived = false,
    this.category,
    this.draftMessage,
    this.hasDisappearingMessages = false,
    this.isVerified = false,
    this.isTyping = false,
    this.pinnedAt,
    this.mutedUntil,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      name: json['name'],
      type: ChatType.values.firstWhere(
        (e) => e.toString() == 'ChatType.${json['type']}',
        orElse: () => ChatType.direct,
      ),
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage']) 
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      lastActivity: DateTime.parse(json['lastActivity']),
      avatar: json['avatar'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      metadata: json['metadata'],
      isPinned: json['isPinned'] ?? false,
      isMuted: json['isMuted'] ?? false,
      isArchived: json['isArchived'] ?? false,
      category: json['category'],
      draftMessage: json['draftMessage'],
      hasDisappearingMessages: json['hasDisappearingMessages'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isTyping: json['isTyping'] ?? false,
      pinnedAt: json['pinnedAt'] != null ? DateTime.parse(json['pinnedAt']) : null,
      mutedUntil: json['mutedUntil'] != null ? DateTime.parse(json['mutedUntil']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'participants': participants,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'lastActivity': lastActivity.toIso8601String(),
      'avatar': avatar,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'metadata': metadata,
      'isPinned': isPinned,
      'isMuted': isMuted,
      'isArchived': isArchived,
      'category': category,
      'draftMessage': draftMessage,
      'hasDisappearingMessages': hasDisappearingMessages,
      'isVerified': isVerified,
      'isTyping': isTyping,
      'pinnedAt': pinnedAt?.toIso8601String(),
      'mutedUntil': mutedUntil?.toIso8601String(),
    };
  }

  Chat copyWith({
    String? id,
    String? name,
    ChatType? type,
    List<String>? participants,
    Message? lastMessage,
    int? unreadCount,
    DateTime? lastActivity,
    String? avatar,
    bool? isOnline,
    DateTime? lastSeen,
    Map<String, dynamic>? metadata,
    bool? isPinned,
    bool? isMuted,
    bool? isArchived,
    String? category,
    String? draftMessage,
    bool? hasDisappearingMessages,
    bool? isVerified,
    bool? isTyping,
    DateTime? pinnedAt,
    DateTime? mutedUntil,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastActivity: lastActivity ?? this.lastActivity,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      metadata: metadata ?? this.metadata,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      category: category ?? this.category,
      draftMessage: draftMessage ?? this.draftMessage,
      hasDisappearingMessages: hasDisappearingMessages ?? this.hasDisappearingMessages,
      isVerified: isVerified ?? this.isVerified,
      isTyping: isTyping ?? this.isTyping,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      mutedUntil: mutedUntil ?? this.mutedUntil,
    );
  }

  // Helper method to get display name for direct chats
  String getDisplayName(String currentUserId, Map<String, User> users) {
    if (type == ChatType.group) {
      return name;
    }
    
    // For direct chats, show the other participant's name
    final otherParticipantId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participants.first,
    );
    
    return users[otherParticipantId]?.username ?? 'Unknown User';
  }

  // Helper method to get avatar for direct chats
  String? getDisplayAvatar(String currentUserId, Map<String, User> users) {
    if (type == ChatType.group) {
      return avatar;
    }
    
    // For direct chats, show the other participant's avatar
    final otherParticipantId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participants.first,
    );
    
    return users[otherParticipantId]?.avatar;
  }
}
