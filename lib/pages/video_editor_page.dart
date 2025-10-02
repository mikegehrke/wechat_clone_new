import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import '../widgets/video_timeline.dart';
import '../widgets/video_tools_panel.dart';
import '../widgets/video_preview.dart';
import '../models/video_edit_session.dart';

class VideoEditorPage extends StatefulWidget {
  final String? videoPath;
  
  const VideoEditorPage({
    super.key,
    this.videoPath,
  });

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  VideoPlayerController? _controller;
  VideoEditSession? _editSession;
  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
  // Editing states
  bool _showTools = false;
  String _selectedTool = 'trim';
  double _playbackSpeed = 1.0;
  
  // Video properties
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  String _selectedFilter = 'none';
  
  // Text overlays
  List<TextOverlay> _textOverlays = [];
  
  // Audio tracks
  List<AudioTrack> _audioTracks = [];

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _loadVideo(widget.videoPath!);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadVideo(String videoPath) async {
    try {
      _controller = VideoPlayerController.file(File(videoPath));
      await _controller!.initialize();
      
      _controller!.addListener(() {
        if (mounted) {
          setState(() {
            _currentPosition = _controller!.value.position;
            _totalDuration = _controller!.value.duration;
            _isPlaying = _controller!.value.isPlaying;
          });
        }
      });

      _editSession = VideoEditSession(
        videoPath: videoPath,
        duration: _controller!.value.duration,
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickVideo() async {
    // FilePicker removed - use image_picker or camera instead
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video picker not implemented yet'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _togglePlayPause() {
    if (_controller != null) {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  void _seekTo(Duration position) {
    if (_controller != null) {
      _controller!.seekTo(position);
    }
  }

  void _setPlaybackSpeed(double speed) {
    if (_controller != null) {
      _controller!.setPlaybackSpeed(speed);
      setState(() {
        _playbackSpeed = speed;
      });
    }
  }

  void _applyFilter(String filterName) {
    setState(() {
      _selectedFilter = filterName;
    });
    // In real app, apply filter to video
  }

  void _adjustBrightness(double value) {
    setState(() {
      _brightness = value;
    });
    // In real app, apply brightness adjustment
  }

  void _adjustContrast(double value) {
    setState(() {
      _contrast = value;
    });
    // In real app, apply contrast adjustment
  }

  void _adjustSaturation(double value) {
    setState(() {
      _saturation = value;
    });
    // In real app, apply saturation adjustment
  }

  void _addTextOverlay() {
    setState(() {
      _textOverlays.add(TextOverlay(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'New Text',
        position: const Offset(0.5, 0.5),
        fontSize: 24,
        color: Colors.white,
        startTime: _currentPosition,
        endTime: _currentPosition + const Duration(seconds: 3),
      ));
    });
  }

  void _addAudioTrack() {
    // Show audio picker
    _showAudioPicker();
  }

  void _showAudioPicker() async {
    // FilePicker removed - audio picker not implemented yet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio picker not implemented yet'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _exportVideo() async {
    // Show export options
    _showExportDialog();
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.hd),
              title: const Text('1080p HD'),
              subtitle: const Text('Best quality'),
              onTap: () => _exportWithQuality('1080p'),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('720p HD'),
              subtitle: const Text('Good quality'),
              onTap: () => _exportWithQuality('720p'),
            ),
            ListTile(
              leading: const Icon(Icons.video_call),
              title: const Text('480p'),
              subtitle: const Text('Smaller file'),
              onTap: () => _exportWithQuality('480p'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportWithQuality(String quality) async {
    Navigator.pop(context);
    
    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Exporting video...'),
          ],
        ),
      ),
    );

    try {
      // Simulate export process
      await Future.delayed(const Duration(seconds: 3));
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video exported successfully in $quality!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Video Editor',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _exportVideo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Preview
          Expanded(
            flex: 3,
            child: _isInitialized
                ? VideoPreview(
                    controller: _controller!,
                    brightness: _brightness,
                    contrast: _contrast,
                    saturation: _saturation,
                    selectedFilter: _selectedFilter,
                    textOverlays: _textOverlays,
                    currentPosition: _currentPosition,
                  )
                : _buildVideoPlaceholder(),
          ),
          
          // Timeline
          Expanded(
            flex: 2,
            child: _isInitialized
                ? VideoTimeline(
                    controller: _controller!,
                    currentPosition: _currentPosition,
                    totalDuration: _totalDuration,
                    onSeek: _seekTo,
                    textOverlays: _textOverlays,
                    audioTracks: _audioTracks,
                  )
                : Container(),
          ),
          
          // Tools Panel
          if (_showTools)
            Expanded(
              flex: 2,
              child: VideoToolsPanel(
                selectedTool: _selectedTool,
                onToolChanged: (tool) => setState(() => _selectedTool = tool),
                brightness: _brightness,
                contrast: _contrast,
                saturation: _saturation,
                onBrightnessChanged: _adjustBrightness,
                onContrastChanged: _adjustContrast,
                onSaturationChanged: _adjustSaturation,
                onFilterSelected: _applyFilter,
                onAddText: _addTextOverlay,
                onAddAudio: _addAudioTrack,
                playbackSpeed: _playbackSpeed,
                onSpeedChanged: _setPlaybackSpeed,
              ),
            ),
          
          // Bottom Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Play/Pause
                IconButton(
                  onPressed: _isInitialized ? _togglePlayPause : null,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                
                // Speed
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Playback Speed'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSpeedOption('0.5x', 0.5),
                            _buildSpeedOption('0.75x', 0.75),
                            _buildSpeedOption('1x', 1.0),
                            _buildSpeedOption('1.25x', 1.25),
                            _buildSpeedOption('1.5x', 1.5),
                            _buildSpeedOption('2x', 2.0),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.speed, color: Colors.white),
                ),
                
                // Tools Toggle
                IconButton(
                  onPressed: () => setState(() => _showTools = !_showTools),
                  icon: Icon(
                    _showTools ? Icons.keyboard_arrow_down : Icons.tune,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                
                // Add Media
                IconButton(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_library,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Video Selected',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + to add a video',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.add),
              label: const Text('Select Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedOption(String label, double speed) {
    return ListTile(
      title: Text(label),
      trailing: _playbackSpeed == speed ? const Icon(Icons.check) : null,
      onTap: () {
        _setPlaybackSpeed(speed);
        Navigator.pop(context);
      },
    );
  }
}

// Data models for video editing
class VideoEditSession {
  final String videoPath;
  final Duration duration;
  final List<VideoClip> clips;
  final List<Transition> transitions;
  final List<Effect> effects;

  VideoEditSession({
    required this.videoPath,
    required this.duration,
    this.clips = const [],
    this.transitions = const [],
    this.effects = const [],
  });
}

class VideoClip {
  final String id;
  final String path;
  final Duration startTime;
  final Duration endTime;
  final double speed;

  VideoClip({
    required this.id,
    required this.path,
    required this.startTime,
    required this.endTime,
    this.speed = 1.0,
  });
}

class Transition {
  final String id;
  final String type;
  final Duration duration;

  Transition({
    required this.id,
    required this.type,
    required this.duration,
  });
}

class Effect {
  final String id;
  final String type;
  final Map<String, dynamic> parameters;

  Effect({
    required this.id,
    required this.type,
    required this.parameters,
  });
}

class TextOverlay {
  final String id;
  final String text;
  final Offset position;
  final double fontSize;
  final Color color;
  final Duration startTime;
  final Duration endTime;

  TextOverlay({
    required this.id,
    required this.text,
    required this.position,
    required this.fontSize,
    required this.color,
    required this.startTime,
    required this.endTime,
  });
}

class AudioTrack {
  final String id;
  final String filePath;
  final Duration startTime;
  final double volume;

  AudioTrack({
    required this.id,
    required this.filePath,
    required this.startTime,
    required this.volume,
  });
}
