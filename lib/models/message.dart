import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
enum MessageType {
  text,
  image,
  video,
  voice,
  file,
  location,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String? content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final Map<String, dynamic>? metadata;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.metadata,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final dynamic tsRaw = json['timestamp'];
    DateTime parsedTs;
    if (tsRaw == null) {
      parsedTs = DateTime.now();
    } else if (tsRaw is String) {
      parsedTs = DateTime.tryParse(tsRaw) ?? DateTime.now();
    } else if (tsRaw is Timestamp) {
      parsedTs = tsRaw.toDate();
    } else if (tsRaw is int) {
      parsedTs = DateTime.fromMillisecondsSinceEpoch(tsRaw);
    } else {
      parsedTs = DateTime.now();
    }

    return Message(
      id: json['id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      timestamp: parsedTs,
      filePath: json['filePath'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'filePath': filePath,
      'fileName': fileName,
      'fileSize': fileSize,
      'metadata': metadata,
    };
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? filePath,
    String? fileName,
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      metadata: metadata ?? this.metadata,
    );
  }
}