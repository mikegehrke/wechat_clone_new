import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../pages/video_editor_page.dart';

class VideoPreview extends StatefulWidget {
  final VideoPlayerController controller;
  final double brightness;
  final double contrast;
  final double saturation;
  final String selectedFilter;
  final List<TextOverlay> textOverlays;
  final Duration currentPosition;

  const VideoPreview({
    super.key,
    required this.controller,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.selectedFilter,
    required this.textOverlays,
    required this.currentPosition,
  });

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),
          
          // Filter overlay
          if (widget.selectedFilter != 'none')
            _buildFilterOverlay(),
          
          // Adjustments overlay
          if (widget.brightness != 0.0 || widget.contrast != 1.0 || widget.saturation != 1.0)
            _buildAdjustmentsOverlay(),
          
          // Text overlays
          ..._buildTextOverlays(),
          
          // Play button overlay (when paused)
          if (!widget.controller.value.isPlaying)
            _buildPlayOverlay(),
          
          // Video info overlay
          _buildVideoInfoOverlay(),
        ],
      ),
    );
  }

  Widget _buildFilterOverlay() {
    Color filterColor;
    double opacity = 0.3;
    
    switch (widget.selectedFilter) {
      case 'vintage':
        filterColor = const Color(0xFF8B4513);
        break;
      case 'dramatic':
        filterColor = Colors.black;
        opacity = 0.4;
        break;
      case 'warm':
        filterColor = Colors.orange;
        break;
      case 'cool':
        filterColor = Colors.blue;
        break;
      case 'blackwhite':
        filterColor = Colors.grey;
        opacity = 0.8;
        break;
      case 'sepia':
        filterColor = const Color(0xFF704214);
        break;
      case 'blur':
        // Blur effect would be implemented differently
        filterColor = Colors.transparent;
        break;
      default:
        filterColor = Colors.transparent;
    }
    
    return Container(
      color: filterColor.withOpacity(opacity),
    );
  }

  Widget _buildAdjustmentsOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(
          (widget.brightness + 1.0) * 0.1, // Adjust brightness
        ),
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix([
          widget.contrast, 0, 0, 0, 0, // Red
          0, widget.contrast, 0, 0, 0, // Green
          0, 0, widget.contrast, 0, 0, // Blue
          0, 0, 0, 1, 0, // Alpha
        ]),
        child: Container(
          color: Colors.white.withOpacity(
            (widget.saturation - 1.0) * 0.1, // Adjust saturation
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTextOverlays() {
    return widget.textOverlays.map((overlay) {
      // Check if overlay should be visible at current position
      final isVisible = widget.currentPosition >= overlay.startTime &&
          widget.currentPosition <= overlay.endTime;
      
      if (!isVisible) return const SizedBox.shrink();
      
      return Positioned(
        left: overlay.position.dx * MediaQuery.of(context).size.width,
        top: overlay.position.dy * MediaQuery.of(context).size.height,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            overlay.text,
            style: TextStyle(
              color: overlay.color,
              fontSize: overlay.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPlayOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: Icon(
          Icons.play_arrow,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildVideoInfoOverlay() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFilterIcon(),
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              _getFilterDisplayName(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilterIcon() {
    switch (widget.selectedFilter) {
      case 'vintage':
        return Icons.filter_vintage;
      case 'dramatic':
        return Icons.theater_comedy;
      case 'warm':
        return Icons.wb_sunny;
      case 'cool':
        return Icons.ac_unit;
      case 'blackwhite':
        return Icons.filter_b_and_w;
      case 'sepia':
        return Icons.filter_frames;
      case 'blur':
        return Icons.blur_on;
      default:
        return Icons.image;
    }
  }

  String _getFilterDisplayName() {
    switch (widget.selectedFilter) {
      case 'vintage':
        return 'Vintage';
      case 'dramatic':
        return 'Dramatic';
      case 'warm':
        return 'Warm';
      case 'cool':
        return 'Cool';
      case 'blackwhite':
        return 'B&W';
      case 'sepia':
        return 'Sepia';
      case 'blur':
        return 'Blur';
      default:
        return 'Original';
    }
  }
}