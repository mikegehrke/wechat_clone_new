import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/api_config.dart';
import 'api_service.dart';

class SocketService {
  static io.Socket? _socket;
  static bool _isConnected = false;
  static String? _userId;
  
  // Singleton
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();
  
  // Get socket instance
  io.Socket? get socket => _socket;
  bool get isConnected => _isConnected;
  
  // Initialize and connect
  Future<void> connect(String userId) async {
    if (_isConnected && _userId == userId) return;
    
    _userId = userId;
    
    // Get access token
    final token = await ApiService.getAccessToken();
    
    // Configure socket
    _socket = io.io(
      ApiConfig.wsUrl,
      io.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setAuth({'token': token})
        .build(),
    );
    
    // Connection handlers
    _socket!.onConnect((_) {
      print('✅ Socket connected');
      _isConnected = true;
      
      // Join user rooms
      _socket!.emit('chat:join', userId);
      _socket!.emit('notifications:subscribe', userId);
    });
    
    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
      _isConnected = false;
    });
    
    _socket!.onConnectError((error) {
      print('❌ Socket connection error: $error');
      _isConnected = false;
    });
    
    _socket!.onError((error) {
      print('❌ Socket error: $error');
    });
    
    // Connect
    _socket!.connect();
  }
  
  // Disconnect
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _userId = null;
    }
  }
  
  // Chat methods
  void sendMessage({
    required String chatId,
    required String content,
    String type = 'text',
    List<Map<String, dynamic>>? attachments,
    String? replyTo,
  }) {
    _socket?.emit('message:send', {
      'chatId': chatId,
      'content': content,
      'type': type,
      'attachments': attachments,
      'replyTo': replyTo,
    });
  }
  
  void markMessageAsRead(String chatId, String messageId) {
    _socket?.emit('message:read', {
      'chatId': chatId,
      'messageId': messageId,
    });
  }
  
  void startTyping(String chatId) {
    _socket?.emit('typing:start', {'chatId': chatId});
  }
  
  void stopTyping(String chatId) {
    _socket?.emit('typing:stop', {'chatId': chatId});
  }
  
  void deleteMessage(String chatId, String messageId, {bool forEveryone = false}) {
    _socket?.emit('message:delete', {
      'chatId': chatId,
      'messageId': messageId,
      'forEveryone': forEveryone,
    });
  }
  
  void editMessage(String chatId, String messageId, String newContent) {
    _socket?.emit('message:edit', {
      'chatId': chatId,
      'messageId': messageId,
      'newContent': newContent,
    });
  }
  
  void reactToMessage(String chatId, String messageId, String emoji) {
    _socket?.emit('message:react', {
      'chatId': chatId,
      'messageId': messageId,
      'emoji': emoji,
    });
  }
  
  // Call methods
  void startCall(String chatId, String type) {
    _socket?.emit('call:start', {
      'chatId': chatId,
      'type': type,
    });
  }
  
  void joinCall(String chatId, String callId) {
    _socket?.emit('call:join', {
      'chatId': chatId,
      'callId': callId,
    });
  }
  
  void leaveCall(String chatId, String callId) {
    _socket?.emit('call:leave', {
      'chatId': chatId,
      'callId': callId,
    });
  }
  
  // WebRTC signaling
  void sendOffer(String chatId, String targetUserId, Map<String, dynamic> offer) {
    _socket?.emit('webrtc:offer', {
      'chatId': chatId,
      'targetUserId': targetUserId,
      'offer': offer,
    });
  }
  
  void sendAnswer(String chatId, String targetUserId, Map<String, dynamic> answer) {
    _socket?.emit('webrtc:answer', {
      'chatId': chatId,
      'targetUserId': targetUserId,
      'answer': answer,
    });
  }
  
  void sendIceCandidate(String chatId, String targetUserId, Map<String, dynamic> candidate) {
    _socket?.emit('webrtc:ice-candidate', {
      'chatId': chatId,
      'targetUserId': targetUserId,
      'candidate': candidate,
    });
  }
  
  // Stream methods
  void joinStream(String streamId, String userId) {
    _socket?.emit('stream:join', {
      'streamId': streamId,
      'userId': userId,
    });
  }
  
  void leaveStream(String streamId, String userId) {
    _socket?.emit('stream:leave', {
      'streamId': streamId,
      'userId': userId,
    });
  }
  
  void sendStreamChat(String streamId, String userId, String message) {
    _socket?.emit('stream:chat', {
      'streamId': streamId,
      'userId': userId,
      'message': message,
    });
  }
  
  void sendGift(String streamId, String userId, Map<String, dynamic> gift) {
    _socket?.emit('stream:gift', {
      'streamId': streamId,
      'userId': userId,
      'gift': gift,
    });
  }
  
  void startBroadcast(String streamId, String userId, String title, String description) {
    _socket?.emit('stream:start-broadcast', {
      'streamId': streamId,
      'userId': userId,
      'title': title,
      'description': description,
    });
  }
  
  void stopBroadcast(String streamId) {
    _socket?.emit('stream:stop-broadcast', {
      'streamId': streamId,
    });
  }
  
  // Listen to events
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }
  
  void off(String event) {
    _socket?.off(event);
  }
  
  // Remove all listeners
  void removeAllListeners() {
    _socket?.clearListeners();
  }
}