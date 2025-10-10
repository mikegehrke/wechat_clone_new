import 'dart:io';
import 'package:flutter/material.dart';
import '../models/video_edit_session.dart';
import '../pages/video_editor_page.dart';

/// App-wide video editor service
/// Provides centralized access to video editing functionality across the entire app
class VideoEditorService {
  static final VideoEditorService _instance = VideoEditorService._internal();
  
  factory VideoEditorService() => _instance;
  
  VideoEditorService._internal();

  // Current editing session
  VideoEditSession? _currentSession;
  
  // Recent edits history
  final List<VideoEditSession> _editHistory = [];
  
  // Quick edit presets
  final Map<String, VideoEditPreset> _presets = {
    'story': VideoEditPreset(
      name: 'Story',
      maxDuration: const Duration(seconds: 15),
      aspectRatio: 9 / 16,
      filters: ['vintage', 'dramatic', 'warm'],
      defaultFilter: 'warm',
    ),
    'post': VideoEditPreset(
      name: 'Post',
      maxDuration: const Duration(minutes: 1),
      aspectRatio: 1.0,
      filters: ['none', 'vintage', 'dramatic', 'warm', 'cool'],
      defaultFilter: 'none',
    ),
    'tiktok': VideoEditPreset(
      name: 'TikTok',
      maxDuration: const Duration(minutes: 3),
      aspectRatio: 9 / 16,
      filters: ['none', 'vintage', 'dramatic', 'warm', 'cool', 'blackwhite', 'sepia'],
      defaultFilter: 'none',
    ),
    'professional': VideoEditPreset(
      name: 'Professional',
      maxDuration: const Duration(minutes: 10),
      aspectRatio: 16 / 9,
      filters: ['none'],
      defaultFilter: 'none',
    ),
  };

  /// Get current editing session
  VideoEditSession? get currentSession => _currentSession;
  
  /// Get edit history
  List<VideoEditSession> get editHistory => List.unmodifiable(_editHistory);
  
  /// Get available presets
  Map<String, VideoEditPreset> get presets => Map.unmodifiable(_presets);

  /// Open video editor with optional video path and preset
  Future<String?> openEditor(
    BuildContext context, {
    String? videoPath,
    String? presetName,
  }) async {
    // Create new session if needed
    if (videoPath != null) {
      _currentSession = VideoEditSession(
        videoPath: videoPath,
        duration: Duration.zero, // Will be set when video loads
        presetName: presetName,
      );
    }

    // Navigate to editor
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => VideoEditorPage(videoPath: videoPath),
      ),
    );

    // Save to history if editing completed
    if (result != null && _currentSession != null) {
      _editHistory.insert(0, _currentSession!);
      if (_editHistory.length > 20) {
        _editHistory.removeLast();
      }
    }

    return result;
  }

  /// Quick edit: Apply preset to video
  Future<String?> quickEdit(
    BuildContext context, {
    required String videoPath,
    required String presetName,
  }) async {
    final preset = _presets[presetName];
    if (preset == null) {
      throw ArgumentError('Preset not found: $presetName');
    }

    return await openEditor(
      context,
      videoPath: videoPath,
      presetName: presetName,
    );
  }

  /// Quick edit: Apply filter only
  Future<File?> applyFilter(
    String videoPath,
    String filterName, {
    Function(double)? onProgress,
  }) async {
    // In a real app, this would process the video with the filter
    // For now, return null (not implemented)
    onProgress?.call(1.0);
    return null;
  }

  /// Quick edit: Trim video
  Future<File?> trimVideo(
    String videoPath, {
    required Duration startTime,
    required Duration endTime,
    Function(double)? onProgress,
  }) async {
    // In a real app, this would trim the video
    // For now, return null (not implemented)
    onProgress?.call(1.0);
    return null;
  }

  /// Quick edit: Add text overlay
  Future<File?> addTextOverlay(
    String videoPath, {
    required String text,
    required Offset position,
    required Duration startTime,
    required Duration endTime,
    Color color = Colors.white,
    double fontSize = 24,
    Function(double)? onProgress,
  }) async {
    // In a real app, this would add text overlay to the video
    // For now, return null (not implemented)
    onProgress?.call(1.0);
    return null;
  }

  /// Quick edit: Adjust playback speed
  Future<File?> adjustSpeed(
    String videoPath, {
    required double speed,
    Function(double)? onProgress,
  }) async {
    // In a real app, this would adjust video speed
    // For now, return null (not implemented)
    onProgress?.call(1.0);
    return null;
  }

  /// Get video thumbnail
  Future<File?> getThumbnail(String videoPath, {Duration? position}) async {
    // In a real app, this would extract a thumbnail from the video
    // For now, return null (not implemented)
    return null;
  }

  /// Get video metadata
  Future<VideoMetadata> getMetadata(String videoPath) async {
    // In a real app, this would read video metadata
    // For now, return dummy data
    return VideoMetadata(
      duration: const Duration(seconds: 30),
      width: 1920,
      height: 1080,
      fps: 30,
      size: 5 * 1024 * 1024, // 5MB
    );
  }

  /// Clear edit history
  void clearHistory() {
    _editHistory.clear();
  }

  /// Remove from history
  void removeFromHistory(VideoEditSession session) {
    _editHistory.remove(session);
  }

  /// Show quick edit menu
  Future<String?> showQuickEditMenu(
    BuildContext context, {
    required String videoPath,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Edit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickAction(
                  context,
                  icon: Icons.cut,
                  label: 'Trim',
                  onTap: () async {
                    Navigator.pop(context);
                    await openEditor(context, videoPath: videoPath);
                  },
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.filter,
                  label: 'Filter',
                  onTap: () async {
                    Navigator.pop(context);
                    await openEditor(context, videoPath: videoPath);
                  },
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.text_fields,
                  label: 'Text',
                  onTap: () async {
                    Navigator.pop(context);
                    await openEditor(context, videoPath: videoPath);
                  },
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.music_note,
                  label: 'Music',
                  onTap: () async {
                    Navigator.pop(context);
                    await openEditor(context, videoPath: videoPath);
                  },
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.speed,
                  label: 'Speed',
                  onTap: () async {
                    Navigator.pop(context);
                    await openEditor(context, videoPath: videoPath);
                  },
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.tune,
                  label: 'Full Edit',
                  onTap: () async {
                    Navigator.pop(context);
                    await openEditor(context, videoPath: videoPath);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              'Presets',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ..._presets.entries.map((entry) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await quickEdit(
                            context,
                            videoPath: videoPath,
                            presetName: entry.key,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          entry.value.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Video edit preset configuration
class VideoEditPreset {
  final String name;
  final Duration maxDuration;
  final double aspectRatio;
  final List<String> filters;
  final String defaultFilter;

  VideoEditPreset({
    required this.name,
    required this.maxDuration,
    required this.aspectRatio,
    required this.filters,
    required this.defaultFilter,
  });
}

/// Video metadata
class VideoMetadata {
  final Duration duration;
  final int width;
  final int height;
  final int fps;
  final int size; // in bytes

  VideoMetadata({
    required this.duration,
    required this.width,
    required this.height,
    required this.fps,
    required this.size,
  });

  String get resolution => '${width}x$height';
  
  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  double get aspectRatio => width / height;
}
