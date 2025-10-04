import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoCallService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Agora Configuration
  static const String _agoraAppId = '03923d8fbe6e4fde9017276bdf4ab841';
  static RtcEngine? _engine;

  // ============================================================================
  // CALL INITIATION
  // ============================================================================

  /// Start a call (audio or video)
  static Future<String> startCall({
    required String callerId,
    required String callerName,
    required String receiverId,
    required bool isVideo,
    String? chatId,
  }) async {
    try {
      final callData = {
        'callerId': callerId,
        'callerName': callerName,
        'receiverId': receiverId,
        'type': isVideo ? 'video' : 'audio',
        'status': 'ringing',
        'chatId': chatId,
        'startedAt': FieldValue.serverTimestamp(),
        'channelName': 'call_${DateTime.now().millisecondsSinceEpoch}',
      };

      final docRef = await _firestore.collection('calls').add(callData);
      
      // Send notification to receiver
      await _sendCallNotification(receiverId, callData);
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to start call: $e');
    }
  }

  /// Answer call
  static Future<void> answerCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': 'ongoing',
        'answeredAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to answer call: $e');
    }
  }

  /// Reject call
  static Future<void> rejectCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': 'rejected',
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reject call: $e');
    }
  }

  /// End call
  static Future<void> endCall(String callId) async {
    try {
      final doc = await _firestore.collection('calls').doc(callId).get();
      final data = doc.data();
      
      if (data != null) {
        final startedAt = (data['answeredAt'] as Timestamp?)?.toDate();
        int? duration;
        
        if (startedAt != null) {
          duration = DateTime.now().difference(startedAt).inSeconds;
        }

        await _firestore.collection('calls').doc(callId).update({
          'status': 'ended',
          'endedAt': FieldValue.serverTimestamp(),
          'duration': duration,
        });

        // Save to call history
        await _saveToCallHistory(callId, data, duration);
      }
    } catch (e) {
      throw Exception('Failed to end call: $e');
    }
  }

  /// Missed call
  static Future<void> missedCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': 'missed',
        'endedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark as missed: $e');
    }
  }

  // ============================================================================
  // AGORA INTEGRATION
  // ============================================================================

  /// Initialize Agora engine
  static Future<void> initializeAgora() async {
    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: _agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
    } catch (e) {
      throw Exception('Failed to initialize Agora: $e');
    }
  }

  /// Join call channel
  static Future<void> joinChannel({
    required String channelName,
    required String userId,
    required bool isVideo,
  }) async {
    try {
      if (_engine == null) {
        await initializeAgora();
      }

      // Enable video if video call
      if (isVideo) {
        await _engine!.enableVideo();
      } else {
        await _engine!.enableAudio();
      }

      // Join channel
      await _engine!.joinChannel(
        token: '', // Generate Agora token in production
        channelId: channelName,
        uid: int.parse(userId.hashCode.toString().substring(0, 9)),
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
    } catch (e) {
      throw Exception('Failed to join channel: $e');
    }
  }

  /// Leave channel
  static Future<void> leaveChannel() async {
    try {
      await _engine?.leaveChannel();
    } catch (e) {
      throw Exception('Failed to leave channel: $e');
    }
  }

  /// Toggle camera
  static Future<void> switchCamera() async {
    try {
      await _engine?.switchCamera();
    } catch (e) {
      throw Exception('Failed to switch camera: $e');
    }
  }

  /// Toggle microphone
  static Future<void> toggleMicrophone(bool muted) async {
    try {
      await _engine?.muteLocalAudioStream(muted);
    } catch (e) {
      throw Exception('Failed to toggle microphone: $e');
    }
  }

  /// Toggle video
  static Future<void> toggleVideo(bool enabled) async {
    try {
      await _engine?.muteLocalVideoStream(!enabled);
    } catch (e) {
      throw Exception('Failed to toggle video: $e');
    }
  }

  /// Enable speaker
  static Future<void> toggleSpeaker(bool enabled) async {
    try {
      await _engine?.setEnableSpeakerphone(enabled);
    } catch (e) {
      throw Exception('Failed to toggle speaker: $e');
    }
  }

  // ============================================================================
  // CALL HISTORY
  // ============================================================================

  /// Get call history for user
  static Stream<List<Map<String, dynamic>>> getCallHistoryStream(String userId) {
    return _firestore
        .collection('call_history')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  static Future<void> _sendCallNotification(
    String receiverId,
    Map<String, dynamic> callData,
  ) async {
    // TODO: Send push notification via FCM
    await _firestore.collection('notifications').add({
      'userId': receiverId,
      'type': 'call',
      'data': callData,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  static Future<void> _saveToCallHistory(
    String callId,
    Map<String, dynamic> callData,
    int? duration,
  ) async {
    try {
      await _firestore.collection('call_history').add({
        'callId': callId,
        'callerId': callData['callerId'],
        'callerName': callData['callerName'],
        'receiverId': callData['receiverId'],
        'type': callData['type'],
        'status': callData['status'],
        'duration': duration,
        'participants': [callData['callerId'], callData['receiverId']],
        'timestamp': callData['startedAt'],
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Dispose engine
  static Future<void> dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }
}
