class User {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final String? phoneNumber;
  final String? status;
  final bool isOnline;
  final DateTime lastSeen;
  final List<String> friends;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.phoneNumber,
    this.status,
    this.isOnline = false,
    required this.lastSeen,
    this.friends = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'],
      phoneNumber: json['phoneNumber'],
      status: json['status'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: DateTime.parse(json['lastSeen']),
      friends: List<String>.from(json['friends'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'phoneNumber': phoneNumber,
      'status': status,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'friends': friends,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    String? phoneNumber,
    String? status,
    bool? isOnline,
    DateTime? lastSeen,
    List<String>? friends,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      friends: friends ?? this.friends,
    );
  }
}