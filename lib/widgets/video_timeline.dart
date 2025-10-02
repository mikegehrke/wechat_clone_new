import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../pages/video_editor_page.dart';

class VideoTimeline extends StatefulWidget {
  final VideoPlayerController controller;
  final Duration currentPosition;
  final Duration totalDuration;
  final Function(Duration) onSeek;
  final List<TextOverlay> textOverlays;
  final List<AudioTrack> audioTracks;

  const VideoTimeline({
    super.key,
    required this.controller,
    required this.currentPosition,
    required this.totalDuration,
    required this.onSeek,
    required this.textOverlays,
    required this.audioTracks,
  });

  @override
  State<VideoTimeline> createState() => _VideoTimelineState();
}

class _VideoTimelineState extends State<VideoTimeline> {
  double _timelineWidth = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: Colors.grey[900],
      child: Column(
        children: [
          // Timeline header with time indicators
          Container(
            height: 20,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(widget.currentPosition),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(widget.totalDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Main timeline
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _timelineWidth = constraints.maxWidth;
                return Stack(
                  children: [
                    // Background grid
                    _buildTimelineGrid(),
                    
                    // Video track
                    _buildVideoTrack(),
                    
                    // Audio tracks
                    ..._buildAudioTracks(),
                    
                    // Text overlays
                    ..._buildTextOverlays(),
                    
                    // Playhead
                    _buildPlayhead(),
                    
                    // Trim handles
                    _buildTrimHandles(),
                  ],
                );
              },
            ),
          ),
          
          // Timeline controls
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _zoomOut(),
                  icon: const Icon(Icons.zoom_out, color: Colors.white),
                ),
                Expanded(
                  child: Slider(
                    value: _getTimelinePosition(),
                    onChanged: (value) {
                      final position = Duration(
                        milliseconds: (value * widget.totalDuration.inMilliseconds).round(),
                      );
                      widget.onSeek(position);
                    },
                    activeColor: Colors.red,
                    inactiveColor: Colors.grey[600],
                  ),
                ),
                IconButton(
                  onPressed: () => _zoomIn(),
                  icon: const Icon(Icons.zoom_in, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineGrid() {
    return CustomPaint(
      painter: TimelineGridPainter(
        duration: widget.totalDuration,
        width: _timelineWidth,
      ),
      size: Size(_timelineWidth, 60),
    );
  }

  Widget _buildVideoTrack() {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            // Video thumbnail strip
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.3),
                    Colors.orange.withOpacity(0.3),
                    Colors.yellow.withOpacity(0.3),
                    Colors.green.withOpacity(0.3),
                    Colors.blue.withOpacity(0.3),
                    Colors.purple.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            // Video duration indicator
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  'VIDEO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAudioTracks() {
    return widget.audioTracks.asMap().entries.map((entry) {
      final index = entry.key;
      final track = entry.value;
      final startPosition = _getPositionFromTime(track.startTime);
      
      return Positioned(
        top: 60 + (index * 25),
        left: startPosition,
        child: Container(
          height: 20,
          width: 100, // Fixed width for now
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Center(
            child: Text(
              'AUDIO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildTextOverlays() {
    return widget.textOverlays.asMap().entries.map((entry) {
      final index = entry.key;
      final overlay = entry.value;
      final startPosition = _getPositionFromTime(overlay.startTime);
      final endPosition = _getPositionFromTime(overlay.endTime);
      
      return Positioned(
        top: 60 + (widget.audioTracks.length * 25) + (index * 25),
        left: startPosition,
        child: Container(
          height: 20,
          width: endPosition - startPosition,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Center(
            child: Text(
              'TEXT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPlayhead() {
    final position = _getPositionFromTime(widget.currentPosition);
    
    return Positioned(
      left: position - 1,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        decoration: const BoxDecoration(
          color: Colors.red,
          boxShadow: [
            BoxShadow(
              color: Colors.red,
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrimHandles() {
    return Stack(
      children: [
        // Left trim handle
        Positioned(
          left: 16,
          top: 10,
          child: GestureDetector(
            onPanUpdate: (details) {
              // Handle trim start
            },
            child: Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        // Right trim handle
        Positioned(
          right: 16,
          top: 10,
          child: GestureDetector(
            onPanUpdate: (details) {
              // Handle trim end
            },
            child: Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getPositionFromTime(Duration time) {
    if (widget.totalDuration.inMilliseconds == 0) return 0;
    return (time.inMilliseconds / widget.totalDuration.inMilliseconds) * _timelineWidth;
  }

  double _getTimelinePosition() {
    if (widget.totalDuration.inMilliseconds == 0) return 0;
    return widget.currentPosition.inMilliseconds / widget.totalDuration.inMilliseconds;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _zoomIn() {
    // Implement zoom in functionality
  }

  void _zoomOut() {
    // Implement zoom out functionality
  }
}

class TimelineGridPainter extends CustomPainter {
  final Duration duration;
  final double width;

  TimelineGridPainter({
    required this.duration,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 0.5;

    // Draw vertical grid lines
    final interval = duration.inSeconds / 10; // 10 grid lines
    for (int i = 0; i <= 10; i++) {
      final x = (i / 10) * width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}