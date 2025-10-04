import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/video_call_service.dart';

class VideoCallPage extends StatefulWidget {
  final String callId;
  final String channelName;
  final bool isVideo;

  const VideoCallPage({
    super.key,
    required this.callId,
    required this.channelName,
    required this.isVideo,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = true;
  int? _remoteUid;
  bool _isCallConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      
      await VideoCallService.joinChannel(
        channelName: widget.channelName,
        userId: userId,
        isVideo: widget.isVideo,
      );

      setState(() => _isCallConnected = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join call: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _endCall() async {
    try {
      await VideoCallService.endCall(widget.callId);
      await VideoCallService.leaveChannel();
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await VideoCallService.toggleMicrophone(_isMuted);
  }

  Future<void> _toggleVideo() async {
    setState(() => _isVideoEnabled = !_isVideoEnabled);
    await VideoCallService.toggleVideo(_isVideoEnabled);
  }

  Future<void> _switchCamera() async {
    await VideoCallService.switchCamera();
  }

  Future<void> _toggleSpeaker() async {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    await VideoCallService.toggleSpeaker(_isSpeakerOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video (full screen)
          if (widget.isVideo && _remoteUid != null)
            Center(
              child: _remoteVideo(),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isCallConnected ? 'Connected' : 'Connecting...',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),

          // Local video (small preview)
          if (widget.isVideo && _isVideoEnabled)
            Positioned(
              top: 60,
              right: 16,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _localPreview(),
                ),
              ),
            ),

          // Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mute
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  onTap: _toggleMute,
                  color: _isMuted ? Colors.red : Colors.white,
                ),

                // Video toggle
                if (widget.isVideo)
                  _buildControlButton(
                    icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    onTap: _toggleVideo,
                    color: _isVideoEnabled ? Colors.white : Colors.red,
                  ),

                // End call
                _buildControlButton(
                  icon: Icons.call_end,
                  onTap: _endCall,
                  color: Colors.red,
                  size: 60,
                ),

                // Switch camera
                if (widget.isVideo)
                  _buildControlButton(
                    icon: Icons.flip_camera_ios,
                    onTap: _switchCamera,
                    color: Colors.white,
                  ),

                // Speaker
                _buildControlButton(
                  icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                  onTap: _toggleSpeaker,
                  color: _isSpeakerOn ? Colors.white : Colors.grey,
                ),
              ],
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _endCall,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '00:00',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    double size = 50,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color == Colors.red ? Colors.red : Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color == Colors.red ? Colors.white : color),
      ),
    );
  }

  Widget _localPreview() {
    // Placeholder for Agora local video view
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.person, size: 40, color: Colors.white),
      ),
    );
  }

  Widget _remoteVideo() {
    // Placeholder for Agora remote video view
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.person, size: 100, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    VideoCallService.leaveChannel();
    super.dispose();
  }
}
