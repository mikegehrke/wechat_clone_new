import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  PushNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    this.type = NotificationType.general,
    this.priority = NotificationPriority.normal,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
    this.metadata,
  });

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      imageUrl: json['imageUrl'],
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.general,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == 'NotificationPriority.${json['priority']}',
        orElse: () => NotificationPriority.normal,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      actionUrl: json['actionUrl'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionUrl': actionUrl,
      'metadata': metadata,
    };
  }
}

enum NotificationType {
  general,
  chat,
  group,
  moment,
  call,
  payment,
  security,
  system,
  marketing,
}

enum NotificationPriority {
  low,
  normal,
  high,
  critical,
}

class PushNotificationsService {
  static const String _notificationsKey = 'push_notifications';
  static const String _tokenKey = 'push_token';
  static const String _settingsKey = 'push_settings';
  
  // Singleton
  static final PushNotificationsService _instance = PushNotificationsService._internal();
  factory PushNotificationsService() => _instance;
  PushNotificationsService._internal();

  String? _pushToken;
  List<PushNotification> _notifications = [];
  Map<String, dynamic> _settings = {};

  // Getters
  String? get pushToken => _pushToken;
  List<PushNotification> get notifications => _notifications;
  Map<String, dynamic> get settings => _settings;

  // Initialize service
  Future<void> initialize() async {
    await _loadNotificationsFromStorage();
    await _loadTokenFromStorage();
    await _loadSettingsFromStorage();
    await requestPermission();
  }

  // Permission Management
  Future<bool> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      _settings['permissionGranted'] = settings.authorizationStatus == AuthorizationStatus.authorized;
      await _saveSettingsToStorage();
      return _settings['permissionGranted'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      return false;
    }
  }

  // Token Management
  Future<String?> getPushToken() async {
    try {
      _pushToken = await FirebaseMessaging.instance.getToken();
      await _saveTokenToStorage();
      return _pushToken;
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshToken() async {
    try {
      _pushToken = await FirebaseMessaging.instance.getToken(vapidKey: null);
      await _saveTokenToStorage();
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  // Notification Management
  Future<void> sendNotification({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, dynamic>? data,
    NotificationType type = NotificationType.general,
    NotificationPriority priority = NotificationPriority.normal,
    String? actionUrl,
  }) async {
    try {
      final notification = PushNotification(
        id: 'notification_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        imageUrl: imageUrl,
        data: data,
        type: type,
        priority: priority,
        createdAt: DateTime.now(),
        actionUrl: actionUrl,
      );

      _notifications.insert(0, notification);
      await _saveNotificationsToStorage();

      // In real app, send actual push notification
      await _showLocalNotification(notification);
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        final updatedNotification = PushNotification(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl,
          data: notification.data,
          type: notification.type,
          priority: notification.priority,
          createdAt: notification.createdAt,
          isRead: true,
          actionUrl: notification.actionUrl,
          metadata: notification.metadata,
        );
        
        _notifications[index] = updatedNotification;
        await _saveNotificationsToStorage();
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      _notifications = _notifications.map((notification) {
        return PushNotification(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          imageUrl: notification.imageUrl,
          data: notification.data,
          type: notification.type,
          priority: notification.priority,
          createdAt: notification.createdAt,
          isRead: true,
          actionUrl: notification.actionUrl,
          metadata: notification.metadata,
        );
      }).toList();
      
      await _saveNotificationsToStorage();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      _notifications.removeWhere((n) => n.id == notificationId);
      await _saveNotificationsToStorage();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      _notifications.clear();
      await _saveNotificationsToStorage();
    } catch (e) {
      throw Exception('Failed to clear notifications: $e');
    }
  }

  // Settings Management
  Future<void> updateSettings({
    bool? chatNotifications,
    bool? groupNotifications,
    bool? momentNotifications,
    bool? callNotifications,
    bool? paymentNotifications,
    bool? securityNotifications,
    bool? systemNotifications,
    bool? marketingNotifications,
    bool? silentMode,
  }) async {
    try {
      if (chatNotifications != null) _settings['chatNotifications'] = chatNotifications;
      if (groupNotifications != null) _settings['groupNotifications'] = groupNotifications;
      if (momentNotifications != null) _settings['momentNotifications'] = momentNotifications;
      if (callNotifications != null) _settings['callNotifications'] = callNotifications;
      if (paymentNotifications != null) _settings['paymentNotifications'] = paymentNotifications;
      if (securityNotifications != null) _settings['securityNotifications'] = securityNotifications;
      if (systemNotifications != null) _settings['systemNotifications'] = systemNotifications;
      if (marketingNotifications != null) _settings['marketingNotifications'] = marketingNotifications;
      if (silentMode != null) _settings['silentMode'] = silentMode;
      
      await _saveSettingsToStorage();
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  // Quiet Hours
  Future<void> setQuietHours({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> daysOfWeek,
  }) async {
    try {
      _settings['quietHoursEnabled'] = true;
      _settings['quietHoursStart'] = '${startTime.hour}:${startTime.minute}';
      _settings['quietHoursEnd'] = '${endTime.hour}:${endTime.minute}';
      _settings['quietHoursDays'] = daysOfWeek.join(',');
      
      await _saveSettingsToStorage();
    } catch (e) {
      throw Exception('Failed to set quiet hours: $e');
    }
  }

  Future<void> disableQuietHours() async {
    try {
      _settings['quietHoursEnabled'] = false;
      await _saveSettingsToStorage();
    } catch (e) {
      throw Exception('Failed to disable quiet hours: $e');
    }
  }

  // Deep Links
  Future<void> handleDeepLink(String link) async {
    try {
      // In real app, handle actual deep link routing
      await Future.delayed(const Duration(milliseconds: 100));
      
      print('Handling deep link: $link');
    } catch (e) {
      throw Exception('Failed to handle deep link: $e');
    }
  }

  // Chat Notifications
  Future<void> sendChatNotification({
    required String chatId,
    required String senderName,
    required String message,
    String? senderAvatar,
    bool isGroup = false,
  }) async {
    try {
      if (!(_settings['chatNotifications'] ?? true)) return;
      
      final title = isGroup ? '$senderName in Group' : senderName;
      final body = message.length > 50 ? '${message.substring(0, 50)}...' : message;
      
      await sendNotification(
        title: title,
        body: body,
        imageUrl: senderAvatar,
        type: NotificationType.chat,
        priority: NotificationPriority.high,
        data: {
          'chatId': chatId,
          'senderName': senderName,
          'isGroup': isGroup,
        },
        actionUrl: '/chat/$chatId',
      );
    } catch (e) {
      throw Exception('Failed to send chat notification: $e');
    }
  }

  // Call Notifications
  Future<void> sendCallNotification({
    required String callerName,
    required String callerId,
    String? callerAvatar,
    bool isVideoCall = false,
  }) async {
    try {
      if (!(_settings['callNotifications'] ?? true)) return;
      
      final title = 'Incoming ${isVideoCall ? 'Video' : 'Voice'} Call';
      final body = '$callerName is calling you';
      
      await sendNotification(
        title: title,
        body: body,
        imageUrl: callerAvatar,
        type: NotificationType.call,
        priority: NotificationPriority.critical,
        data: {
          'callerId': callerId,
          'callerName': callerName,
          'isVideoCall': isVideoCall,
        },
        actionUrl: '/call/$callerId',
      );
    } catch (e) {
      throw Exception('Failed to send call notification: $e');
    }
  }

  // Payment Notifications
  Future<void> sendPaymentNotification({
    required String title,
    required String body,
    required String transactionId,
    double? amount,
    String? currency,
  }) async {
    try {
      if (!(_settings['paymentNotifications'] ?? true)) return;
      
      await sendNotification(
        title: title,
        body: body,
        type: NotificationType.payment,
        priority: NotificationPriority.high,
        data: {
          'transactionId': transactionId,
          'amount': amount,
          'currency': currency,
        },
        actionUrl: '/payment/$transactionId',
      );
    } catch (e) {
      throw Exception('Failed to send payment notification: $e');
    }
  }

  // Security Notifications
  Future<void> sendSecurityNotification({
    required String title,
    required String body,
    required String eventType,
    String? deviceInfo,
  }) async {
    try {
      if (!(_settings['securityNotifications'] ?? true)) return;
      
      await sendNotification(
        title: title,
        body: body,
        type: NotificationType.security,
        priority: NotificationPriority.critical,
        data: {
          'eventType': eventType,
          'deviceInfo': deviceInfo,
        },
        actionUrl: '/security',
      );
    } catch (e) {
      throw Exception('Failed to send security notification: $e');
    }
  }

  // Private Methods
  Future<void> _showLocalNotification(PushNotification notification) async {
    try {
      // In real app, show actual local notification
      await Future.delayed(const Duration(milliseconds: 100));
      
      print('Showing notification: ${notification.title} - ${notification.body}');
    } catch (e) {
      print('Failed to show local notification: $e');
    }
  }

  Future<void> _loadNotificationsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson != null) {
        final notificationsList = jsonDecode(notificationsJson) as List;
        _notifications = notificationsList
            .map((json) => PushNotification.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Failed to load notifications from storage: $e');
      _notifications = [];
    }
  }

  Future<void> _saveNotificationsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = jsonEncode(_notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_notificationsKey, notificationsJson);
    } catch (e) {
      print('Failed to save notifications to storage: $e');
    }
  }

  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _pushToken = prefs.getString(_tokenKey);
    } catch (e) {
      print('Failed to load token from storage: $e');
    }
  }

  Future<void> _saveTokenToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_pushToken != null) {
        await prefs.setString(_tokenKey, _pushToken!);
      }
    } catch (e) {
      print('Failed to save token to storage: $e');
    }
  }

  Future<void> _loadSettingsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson);
        _settings = Map<String, bool>.from(settingsMap);
      } else {
        _settings = {
          'permissionGranted': false,
          'chatNotifications': true,
          'groupNotifications': true,
          'momentNotifications': true,
          'callNotifications': true,
          'paymentNotifications': true,
          'securityNotifications': true,
          'systemNotifications': true,
          'marketingNotifications': false,
          'silentMode': false,
          'quietHoursEnabled': false,
        };
      }
    } catch (e) {
      print('Failed to load settings from storage: $e');
      _settings = {
        'permissionGranted': false,
        'chatNotifications': true,
        'groupNotifications': true,
        'momentNotifications': true,
        'callNotifications': true,
        'paymentNotifications': true,
        'securityNotifications': true,
        'systemNotifications': true,
        'marketingNotifications': false,
        'silentMode': false,
        'quietHoursEnabled': false,
      };
    }
  }

  Future<void> _saveSettingsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings);
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('Failed to save settings to storage: $e');
    }
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});
}