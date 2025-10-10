import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/video_edit_advanced.dart';
import '../widgets/video_preview.dart';

/// Advanced Video Editor Page - "Bearbeiter weit" implementation
/// Professional-grade video editing with multi-track support
class VideoEditorAdvancedPage extends StatefulWidget {
  final String? initialVideoPath;
  final String? projectPath;

  const VideoEditorAdvancedPage({
    super.key,
    this.initialVideoPath,
    this.projectPath,
  });

  @override
  State<VideoEditorAdvancedPage> createState() => _VideoEditorAdvancedPageState();
}

class _VideoEditorAdvancedPageState extends State<VideoEditorAdvancedPage>
    with TickerProviderStateMixin {
  // Controllers
  VideoPlayerController? _previewController;
  TabController? _mainTabController;
  TabController? _toolsTabController;
  ScrollController _timelineScrollController = ScrollController();
  
  // Session management
  AdvancedVideoEditSession? _session;
  
  // UI State
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _zoomLevel = 1.0;
  bool _isFullscreen = false;
  String _selectedTool = 'edit';
  
  // Track management
  List<VideoTrack> _videoTracks = [];
  List<AudioTrack> _audioTracks = [];
  int _selectedTrackIndex = 0;
  
  // Panels visibility
  bool _showLeftPanel = true;
  bool _showRightPanel = true;
  bool _showBottomPanel = true;
  
  // Keyboard shortcuts
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeSession();
    if (widget.initialVideoPath != null) {
      _loadVideo(widget.initialVideoPath!);
    }
  }
  
  void _initializeControllers() {
    _mainTabController = TabController(length: 5, vsync: this);
    _toolsTabController = TabController(length: 8, vsync: this);
  }
  
  void _initializeSession() {
    final now = DateTime.now();
    _session = AdvancedVideoEditSession(
      id: 'session_${now.millisecondsSinceEpoch}',
      projectName: 'Untitled Project',
      timeline: Timeline(
        totalDuration: Duration(seconds: 60),
        settings: TimelineSettings(),
      ),
      colorGrading: ColorGrading(
        colorWheels: ColorWheels(
          shadows: ColorWheel(),
          midtones: ColorWheel(),
          highlights: ColorWheel(),
        ),
        colorCurves: ColorCurves(
          masterCurve: [],
          redCurve: [],
          greenCurve: [],
          blueCurve: [],
        ),
        hslAdjustments: HSLAdjustments(),
        lutSettings: LUTSettings(),
        scopeSettings: ScopeSettings(),
      ),
      audioMaster: AudioMaster(
        masterEQ: MasterEQ(bands: []),
        masterCompressor: MasterCompressor(),
        masterLimiter: MasterLimiter(),
      ),
      exportPresets: ExportPresets(
        presets: _getDefaultExportPresets(),
      ),
      projectSettings: ProjectSettings(
        projectPath: widget.projectPath ?? '/projects',
        videoStandard: VideoStandard.web,
        aspectRatio: AspectRatio.sixteenNine,
        colorSpace: ColorSpace.srgb,
      ),
      createdAt: now,
    );
    
    // Initialize default tracks
    _videoTracks = [
      VideoTrack(
        id: 'v1',
        name: 'Video 1',
        trackIndex: 0,
      ),
      VideoTrack(
        id: 'v2',
        name: 'Video 2',
        trackIndex: 1,
      ),
      VideoTrack(
        id: 'v3',
        name: 'Overlay',
        trackIndex: 2,
        type: VideoTrackType.overlay,
      ),
    ];
    
    _audioTracks = [
      AudioTrack(
        id: 'a1',
        name: 'Audio 1',
        trackIndex: 0,
      ),
      AudioTrack(
        id: 'a2',
        name: 'Music',
        trackIndex: 1,
        type: AudioTrackType.music,
      ),
      AudioTrack(
        id: 'a3',
        name: 'Voice',
        trackIndex: 2,
        type: AudioTrackType.voiceover,
      ),
    ];
  }
  
  List<ExportPreset> _getDefaultExportPresets() {
    return [
      ExportPreset(
        name: '4K Ultra HD',
        videoCodec: VideoCodec.h265,
        audioCodec: AudioCodec.aac,
        width: 3840,
        height: 2160,
        frameRate: 30,
        videoBitrate: 50000000,
        audioBitrate: 320000,
        audioSampleRate: 48000,
        format: ContainerFormat.mp4,
      ),
      ExportPreset(
        name: 'Full HD 1080p',
        videoCodec: VideoCodec.h264,
        audioCodec: AudioCodec.aac,
        width: 1920,
        height: 1080,
        frameRate: 30,
        videoBitrate: 10000000,
        audioBitrate: 192000,
        audioSampleRate: 48000,
        format: ContainerFormat.mp4,
      ),
      ExportPreset(
        name: 'ProRes Master',
        videoCodec: VideoCodec.prores,
        audioCodec: AudioCodec.pcm,
        width: 1920,
        height: 1080,
        frameRate: 30,
        videoBitrate: 150000000,
        audioBitrate: 1536000,
        audioSampleRate: 48000,
        format: ContainerFormat.mov,
      ),
    ];
  }
  
  Future<void> _loadVideo(String path) async {
    try {
      _previewController = VideoPlayerController.file(File(path));
      await _previewController!.initialize();
      
      _previewController!.addListener(() {
        if (mounted) {
          setState(() {
            _currentPosition = _previewController!.value.position;
            _totalDuration = _previewController!.value.duration;
            _isPlaying = _previewController!.value.isPlaying;
          });
        }
      });
      
      setState(() {});
    } catch (e) {
      _showError('Failed to load video: $e');
    }
  }
  
  @override
  void dispose() {
    _previewController?.dispose();
    _mainTabController?.dispose();
    _toolsTabController?.dispose();
    _timelineScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Column(
          children: [
            _buildMenuBar(),
            _buildToolbar(),
            Expanded(
              child: Row(
                children: [
                  if (_showLeftPanel) _buildLeftPanel(),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildPreviewArea(),
                        ),
                        if (_showBottomPanel)
                          Expanded(
                            flex: 2,
                            child: _buildTimelineArea(),
                          ),
                      ],
                    ),
                  ),
                  if (_showRightPanel) _buildRightPanel(),
                ],
              ),
            ),
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuBar() {
    return Container(
      height: 30,
      color: const Color(0xFF2a2a2a),
      child: Row(
        children: [
          _buildMenu('File', [
            'New Project',
            'Open Project',
            'Save Project',
            'Save As...',
            'Import Media',
            'Export',
          ]),
          _buildMenu('Edit', [
            'Undo',
            'Redo',
            'Cut',
            'Copy',
            'Paste',
            'Delete',
          ]),
          _buildMenu('View', [
            'Zoom In',
            'Zoom Out',
            'Fit to Window',
            'Show Scopes',
            'Show Waveforms',
          ]),
          _buildMenu('Timeline', [
            'Add Video Track',
            'Add Audio Track',
            'Insert Clip',
            'Ripple Delete',
            'Snap to Grid',
          ]),
          _buildMenu('Effects', [
            'Video Effects',
            'Audio Effects',
            'Transitions',
            'Titles',
            'Generators',
          ]),
          _buildMenu('Color', [
            'Auto Color',
            'Color Wheels',
            'Color Curves',
            'HSL Adjustments',
            'Apply LUT',
          ]),
          _buildMenu('Audio', [
            'Audio Mixer',
            'Master EQ',
            'Compressor',
            'Normalize',
          ]),
          _buildMenu('Window', [
            'Project Panel',
            'Timeline',
            'Inspector',
            'Effects Panel',
            'Scopes',
          ]),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.help_outline, size: 18),
            color: Colors.white70,
            onPressed: _showHelp,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenu(String title, List<String> items) {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ),
      itemBuilder: (context) => items.map((item) {
        if (item == '-') {
          return const PopupMenuItem<String>(
            height: 1,
            enabled: false,
            child: Divider(),
          );
        }
        return PopupMenuItem<String>(
          value: item,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item, style: const TextStyle(fontSize: 13)),
              if (_getShortcut(item) != null)
                Text(
                  _getShortcut(item)!,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
            ],
          ),
        );
      }).toList(),
      onSelected: (value) => _handleMenuAction(title, value),
    );
  }
  
  String? _getShortcut(String action) {
    final shortcuts = {
      'Undo': '⌘Z',
      'Redo': '⌘⇧Z',
      'Cut': '⌘X',
      'Copy': '⌘C',
      'Paste': '⌘V',
      'Delete': '⌫',
      'Save Project': '⌘S',
      'Export': '⌘E',
      'Zoom In': '⌘+',
      'Zoom Out': '⌘-',
    };
    return shortcuts[action];
  }
  
  Widget _buildToolbar() {
    return Container(
      height: 50,
      color: const Color(0xFF2d2d2d),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // File operations
          _buildToolButton(Icons.folder_open, 'Open', _openProject),
          _buildToolButton(Icons.save, 'Save', _saveProject),
          const VerticalDivider(color: Colors.grey),
          
          // Edit operations
          _buildToolButton(Icons.undo, 'Undo', _undo),
          _buildToolButton(Icons.redo, 'Redo', _redo),
          const VerticalDivider(color: Colors.grey),
          
          // Timeline tools
          _buildToolButton(Icons.content_cut, 'Razor', _razorTool),
          _buildToolButton(Icons.pan_tool, 'Hand', _handTool),
          _buildToolButton(Icons.zoom_in, 'Zoom', _zoomTool),
          const VerticalDivider(color: Colors.grey),
          
          // Playback controls
          _buildToolButton(Icons.skip_previous, 'Previous', _previousFrame),
          _buildToolButton(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            _isPlaying ? 'Pause' : 'Play',
            _togglePlayback,
          ),
          _buildToolButton(Icons.skip_next, 'Next', _nextFrame),
          const VerticalDivider(color: Colors.grey),
          
          // Timeline position
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _formatTimecode(_currentPosition),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
          
          const Spacer(),
          
          // View controls
          _buildToolButton(
            _showLeftPanel ? Icons.sidebar_left : Icons.sidebar_left_outlined,
            'Left Panel',
            () => setState(() => _showLeftPanel = !_showLeftPanel),
          ),
          _buildToolButton(
            _showBottomPanel ? Icons.view_timeline : Icons.view_timeline_outlined,
            'Timeline',
            () => setState(() => _showBottomPanel = !_showBottomPanel),
          ),
          _buildToolButton(
            _showRightPanel ? Icons.sidebar_right : Icons.sidebar_right_outlined,
            'Right Panel',
            () => setState(() => _showRightPanel = !_showRightPanel),
          ),
          
          const VerticalDivider(color: Colors.grey),
          
          // Export button
          ElevatedButton.icon(
            onPressed: _showExportDialog,
            icon: const Icon(Icons.file_upload, size: 18),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToolButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: Colors.white70,
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
  
  Widget _buildLeftPanel() {
    return Container(
      width: 300,
      color: const Color(0xFF252525),
      child: Column(
        children: [
          TabBar(
            controller: _mainTabController,
            tabs: const [
              Tab(text: 'Project'),
              Tab(text: 'Media'),
              Tab(text: 'Effects'),
              Tab(text: 'Titles'),
              Tab(text: 'Audio'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.orange,
          ),
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                _buildProjectPanel(),
                _buildMediaPanel(),
                _buildEffectsPanel(),
                _buildTitlesPanel(),
                _buildAudioPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProjectPanel() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildPanelSection('Project Info', [
          _buildInfoRow('Name:', _session?.projectName ?? 'Untitled'),
          _buildInfoRow('Duration:', _formatTimecode(_totalDuration)),
          _buildInfoRow('Resolution:', '1920x1080'),
          _buildInfoRow('Frame Rate:', '30 fps'),
        ]),
        _buildPanelSection('Recent Files', [
          _buildFileItem('intro_video.mp4', Icons.video_file),
          _buildFileItem('background_music.mp3', Icons.audio_file),
          _buildFileItem('logo.png', Icons.image),
        ]),
      ],
    );
  }
  
  Widget _buildMediaPanel() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                index % 3 == 0 ? Icons.video_file
                  : index % 3 == 1 ? Icons.audio_file
                  : Icons.image,
                color: Colors.white60,
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                'Media ${index + 1}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildEffectsPanel() {
    final effectCategories = [
      {'name': 'Color Correction', 'icon': Icons.color_lens},
      {'name': 'Blur & Sharpen', 'icon': Icons.blur_on},
      {'name': 'Distortion', 'icon': Icons.transform},
      {'name': 'Stylize', 'icon': Icons.style},
      {'name': 'Keying', 'icon': Icons.layers},
      {'name': '3D', 'icon': Icons.view_in_ar},
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: effectCategories.length,
      itemBuilder: (context, index) {
        final category = effectCategories[index];
        return ExpansionTile(
          leading: Icon(category['icon'] as IconData, color: Colors.white60),
          title: Text(
            category['name'] as String,
            style: const TextStyle(color: Colors.white),
          ),
          children: List.generate(4, (i) {
            return ListTile(
              contentPadding: const EdgeInsets.only(left: 56, right: 16),
              title: Text(
                'Effect ${i + 1}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              onTap: () => _applyEffect('${category['name']}_$i'),
            );
          }),
        );
      },
    );
  }
  
  Widget _buildTitlesPanel() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        final titles = [
          'Simple Title',
          'Lower Third',
          'Animated Title',
          'Credits Roll',
          'Subtitle',
          'Chapter Title',
          'End Screen',
          'Call to Action',
        ];
        
        return GestureDetector(
          onTap: () => _addTitle(titles[index]),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[850]!, Colors.grey[900]!],
              ),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Center(
              child: Text(
                titles[index],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAudioPanel() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildPanelSection('Audio Tracks', [
          _buildAudioTrackControl('Master', 0.8, true),
          _buildAudioTrackControl('Track 1', 0.6, true),
          _buildAudioTrackControl('Track 2', 0.4, false),
          _buildAudioTrackControl('Track 3', 0.7, true),
        ]),
        _buildPanelSection('Audio Effects', [
          _buildEffectItem('EQ', Icons.equalizer),
          _buildEffectItem('Compressor', Icons.compress),
          _buildEffectItem('Reverb', Icons.water),
          _buildEffectItem('Delay', Icons.timer),
        ]),
      ],
    );
  }
  
  Widget _buildRightPanel() {
    return Container(
      width: 350,
      color: const Color(0xFF252525),
      child: Column(
        children: [
          TabBar(
            controller: _toolsTabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Inspector'),
              Tab(text: 'Color'),
              Tab(text: 'Audio'),
              Tab(text: 'Transform'),
              Tab(text: 'Speed'),
              Tab(text: 'Effects'),
              Tab(text: 'Export'),
              Tab(text: 'Scopes'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.orange,
          ),
          Expanded(
            child: TabBarView(
              controller: _toolsTabController,
              children: [
                _buildInspectorPanel(),
                _buildColorGradingPanel(),
                _buildAudioMixerPanel(),
                _buildTransformPanel(),
                _buildSpeedPanel(),
                _buildEffectsControlPanel(),
                _buildExportPanel(),
                _buildScopesPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInspectorPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Clip Properties',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildPropertyRow('Name:', 'Clip_001'),
        _buildPropertyRow('Duration:', '00:00:10:00'),
        _buildPropertyRow('In Point:', '00:00:00:00'),
        _buildPropertyRow('Out Point:', '00:00:10:00'),
        _buildPropertyRow('Speed:', '100%'),
        const Divider(color: Colors.grey),
        _buildSlider('Opacity', 1.0, 0.0, 1.0),
        _buildSlider('Volume', 0.8, 0.0, 1.0),
        const Divider(color: Colors.grey),
        _buildDropdown('Blend Mode', 'Normal', [
          'Normal', 'Multiply', 'Screen', 'Overlay', 'Soft Light'
        ]),
      ],
    );
  }
  
  Widget _buildColorGradingPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildColorWheel('Shadows'),
        _buildColorWheel('Midtones'),
        _buildColorWheel('Highlights'),
        const Divider(color: Colors.grey),
        _buildSlider('Exposure', 0.0, -2.0, 2.0),
        _buildSlider('Contrast', 1.0, 0.0, 2.0),
        _buildSlider('Highlights', 0.0, -100.0, 100.0),
        _buildSlider('Shadows', 0.0, -100.0, 100.0),
        _buildSlider('Whites', 0.0, -100.0, 100.0),
        _buildSlider('Blacks', 0.0, -100.0, 100.0),
        const Divider(color: Colors.grey),
        _buildSlider('Vibrance', 0.0, -100.0, 100.0),
        _buildSlider('Saturation', 1.0, 0.0, 2.0),
      ],
    );
  }
  
  Widget _buildAudioMixerPanel() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: _buildChannelStrip('CH${index + 1}'),
              );
            }),
          ),
        ),
        Container(
          height: 100,
          padding: const EdgeInsets.all(8),
          color: Colors.grey[900],
          child: Column(
            children: [
              _buildSlider('Master Volume', 0.8, 0.0, 1.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToggleButton('Mute', false),
                  _buildToggleButton('Solo', false),
                  _buildToggleButton('Record', false),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildChannelStrip(String name) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Expanded(
            child: RotatedBox(
              quarterTurns: -1,
              child: Slider(
                value: 0.7,
                onChanged: (v) {},
                activeColor: Colors.green,
                inactiveColor: Colors.grey[700],
              ),
            ),
          ),
          Text(
            '-6.0 dB',
            style: TextStyle(color: Colors.white60, fontSize: 10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.volume_off, size: 16),
                color: Colors.white60,
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              IconButton(
                icon: Icon(Icons.headset, size: 16),
                color: Colors.white60,
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransformPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection('Position', [
          _buildNumberInput('X', 960),
          _buildNumberInput('Y', 540),
          _buildNumberInput('Z', 0),
        ]),
        _buildSection('Rotation', [
          _buildNumberInput('X', 0),
          _buildNumberInput('Y', 0),
          _buildNumberInput('Z', 0),
        ]),
        _buildSection('Scale', [
          _buildNumberInput('Width', 100),
          _buildNumberInput('Height', 100),
          _buildCheckbox('Uniform Scale', true),
        ]),
        _buildSection('Anchor Point', [
          _buildNumberInput('X', 0.5),
          _buildNumberInput('Y', 0.5),
        ]),
      ],
    );
  }
  
  Widget _buildSpeedPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSlider('Speed', 1.0, 0.1, 4.0),
        _buildCheckbox('Reverse', false),
        _buildCheckbox('Frame Blend', true),
        const Divider(color: Colors.grey),
        Text(
          'Speed Ramping',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              'Speed curve editor',
              style: TextStyle(color: Colors.white60),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildSmallButton('Add Point', Icons.add),
            _buildSmallButton('Reset', Icons.refresh),
          ],
        ),
      ],
    );
  }
  
  Widget _buildEffectsControlPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildEffectControl('Gaussian Blur', [
          _buildSlider('Amount', 0.0, 0.0, 100.0),
          _buildSlider('Direction', 0.0, 0.0, 360.0),
        ]),
        _buildEffectControl('Color Correction', [
          _buildSlider('Hue', 0.0, -180.0, 180.0),
          _buildSlider('Saturation', 1.0, 0.0, 2.0),
          _buildSlider('Brightness', 0.0, -1.0, 1.0),
        ]),
        _buildEffectControl('Glow', [
          _buildSlider('Intensity', 0.5, 0.0, 1.0),
          _buildSlider('Radius', 10.0, 0.0, 50.0),
          _buildSlider('Threshold', 0.5, 0.0, 1.0),
        ]),
      ],
    );
  }
  
  Widget _buildExportPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDropdown('Preset', '1080p HD', [
          '4K Ultra HD',
          '1080p HD',
          '720p HD',
          'ProRes Master',
          'Custom',
        ]),
        const Divider(color: Colors.grey),
        _buildPropertyRow('Resolution:', '1920x1080'),
        _buildPropertyRow('Frame Rate:', '30 fps'),
        _buildPropertyRow('Codec:', 'H.264'),
        _buildPropertyRow('Bitrate:', '10 Mbps'),
        _buildPropertyRow('Est. Size:', '~250 MB'),
        const Divider(color: Colors.grey),
        _buildCheckbox('Two-Pass Encoding', false),
        _buildCheckbox('Hardware Acceleration', true),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _startExport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            minimumSize: const Size(double.infinity, 40),
          ),
          child: const Text('Start Export'),
        ),
      ],
    );
  }
  
  Widget _buildScopesPanel() {
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(8),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _buildScope('Vectorscope'),
              _buildScope('Waveform'),
              _buildScope('Histogram'),
              _buildScope('RGB Parade'),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildScope(String name) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            color: Colors.grey[900],
            child: Text(
              name,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ),
          Expanded(
            child: Center(
              child: Icon(
                Icons.show_chart,
                color: Colors.green[700],
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreviewArea() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          if (_previewController != null && _previewController!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: _previewController!.value.aspectRatio,
                child: VideoPlayer(_previewController!),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library, size: 64, color: Colors.white30),
                  const SizedBox(height: 16),
                  Text(
                    'No video loaded',
                    style: TextStyle(color: Colors.white30, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _importMedia,
                    icon: const Icon(Icons.add),
                    label: const Text('Import Media'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          
          // Overlay controls
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.aspect_ratio, color: Colors.white70),
                  onPressed: _toggleAspectRatio,
                ),
                IconButton(
                  icon: Icon(Icons.grid_on, color: Colors.white70),
                  onPressed: _toggleGrid,
                ),
                IconButton(
                  icon: Icon(Icons.fullscreen, color: Colors.white70),
                  onPressed: _toggleFullscreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineArea() {
    return Container(
      color: const Color(0xFF1e1e1e),
      child: Column(
        children: [
          // Timeline controls
          Container(
            height: 30,
            color: const Color(0xFF2a2a2a),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.zoom_out, size: 18),
                  color: Colors.white60,
                  onPressed: _zoomOut,
                ),
                Slider(
                  value: _zoomLevel,
                  min: 0.1,
                  max: 5.0,
                  onChanged: (value) => setState(() => _zoomLevel = value),
                  activeColor: Colors.blue,
                ),
                IconButton(
                  icon: Icon(Icons.zoom_in, size: 18),
                  color: Colors.white60,
                  onPressed: _zoomIn,
                ),
                const VerticalDivider(color: Colors.grey),
                _buildTimelineToggle('Snap', Icons.grid_on),
                _buildTimelineToggle('Link', Icons.link),
                _buildTimelineToggle('Ripple', Icons.waves),
              ],
            ),
          ),
          
          // Timeline ruler
          Container(
            height: 30,
            color: const Color(0xFF252525),
            child: CustomPaint(
              painter: TimelineRulerPainter(_zoomLevel, _totalDuration),
            ),
          ),
          
          // Tracks
          Expanded(
            child: ListView(
              controller: _timelineScrollController,
              children: [
                ..._videoTracks.map((track) => _buildTrack(track, true)),
                const Divider(height: 1, color: Colors.grey),
                ..._audioTracks.map((track) => _buildTrack(track, false)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrack(dynamic track, bool isVideo) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: track.trackIndex == _selectedTrackIndex 
            ? Colors.grey[850] 
            : Colors.grey[900],
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Row(
        children: [
          // Track header
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              border: Border(
                right: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isVideo ? Icons.videocam : Icons.volume_up,
                  size: 16,
                  color: track.isEnabled ? Colors.white60 : Colors.white30,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    track.name,
                    style: TextStyle(
                      color: track.isEnabled ? Colors.white70 : Colors.white30,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    track.isLocked ? Icons.lock : Icons.lock_open,
                    size: 14,
                  ),
                  color: Colors.white30,
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                ),
              ],
            ),
          ),
          
          // Track content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              child: CustomPaint(
                painter: TimelineTrackPainter(track, isVideo, _zoomLevel),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper widgets
  Widget _buildPanelSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
  
  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
  
  Widget _buildFileItem(String name, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white60, size: 20),
      title: Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      dense: true,
    );
  }
  
  Widget _buildEffectItem(String name, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white60, size: 20),
      title: Text(name, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      trailing: Switch(
        value: false,
        onChanged: (v) {},
        activeColor: Colors.orange,
      ),
      dense: true,
    );
  }
  
  Widget _buildAudioTrackControl(String name, double level, bool enabled) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.volume_off, size: 16),
                    color: enabled ? Colors.white60 : Colors.red,
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                  IconButton(
                    icon: Icon(Icons.headset, size: 16),
                    color: Colors.white60,
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                ],
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: level,
              onChanged: (v) {},
              activeColor: level > 0.7 ? Colors.orange : Colors.green,
              inactiveColor: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSlider(String label, double value, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text(value.toStringAsFixed(1), 
                 style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) {},
            activeColor: Colors.blue,
            inactiveColor: Colors.grey[700],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdown(String label, String value, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: Container(),
            dropdownColor: Colors.grey[850],
            style: const TextStyle(color: Colors.white, fontSize: 13),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: (v) {},
          ),
        ),
      ],
    );
  }
  
  Widget _buildColorWheel(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Colors.red,
                  Colors.yellow,
                  Colors.green,
                  Colors.cyan,
                  Colors.blue,
                  Colors.magenta,
                  Colors.red,
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const Divider(color: Colors.grey),
      ],
    );
  }
  
  Widget _buildNumberInput(String label, num value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            child: Container(
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                controller: TextEditingController(text: value.toString()),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCheckbox(String label, bool value) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (v) {},
          activeColor: Colors.orange,
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
  
  Widget _buildToggleButton(String label, bool value) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: value ? Colors.orange : Colors.grey[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
  
  Widget _buildSmallButton(String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(icon, size: 14),
          label: Text(label, style: const TextStyle(fontSize: 11)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEffectControl(String name, List<Widget> controls) {
    return ExpansionTile(
      title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: controls),
        ),
      ],
    );
  }
  
  Widget _buildTimelineToggle(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 11)),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
  
  Widget _buildStatusBar() {
    return Container(
      height: 24,
      color: const Color(0xFF1a1a1a),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            'Ready',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const Spacer(),
          Text(
            'FPS: 30.0',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(width: 16),
          Text(
            'Memory: 2.1 GB',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(width: 16),
          Text(
            'GPU: 45%',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
  
  // Action methods
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _togglePlayback();
      } else if (event.logicalKey == LogicalKeyboardKey.keyS && 
                 HardwareKeyboard.instance.isMetaPressed) {
        _saveProject();
      }
    }
  }
  
  void _handleMenuAction(String menu, String action) {
    // Handle menu actions
    print('Menu action: $menu -> $action');
  }
  
  void _openProject() {}
  void _saveProject() {}
  void _undo() {}
  void _redo() {}
  void _razorTool() {}
  void _handTool() {}
  void _zoomTool() {}
  void _previousFrame() {}
  void _nextFrame() {}
  void _togglePlayback() {
    if (_previewController != null) {
      if (_isPlaying) {
        _previewController!.pause();
      } else {
        _previewController!.play();
      }
    }
  }
  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel * 1.2).clamp(0.1, 5.0);
    });
  }
  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel / 1.2).clamp(0.1, 5.0);
    });
  }
  void _importMedia() {}
  void _toggleAspectRatio() {}
  void _toggleGrid() {}
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }
  void _applyEffect(String effect) {}
  void _addTitle(String title) {}
  void _showExportDialog() {}
  void _startExport() {}
  void _showHelp() {}
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  String _formatTimecode(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final frames = ((duration.inMilliseconds % 1000) ~/ 33).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds:$frames';
  }
}

// Custom painters
class TimelineRulerPainter extends CustomPainter {
  final double zoomLevel;
  final Duration totalDuration;

  TimelineRulerPainter(this.zoomLevel, this.totalDuration);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white60
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final pixelsPerSecond = 50.0 * zoomLevel;
    final secondsVisible = size.width / pixelsPerSecond;
    final majorTickInterval = _getMajorTickInterval(secondsVisible);

    for (double second = 0; second <= totalDuration.inSeconds; second += majorTickInterval) {
      final x = second * pixelsPerSecond;
      if (x > size.width) break;

      canvas.drawLine(
        Offset(x, size.height - 10),
        Offset(x, size.height),
        paint,
      );

      textPainter.text = TextSpan(
        text: _formatTime(second),
        style: const TextStyle(color: Colors.white60, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, 2));
    }
  }

  double _getMajorTickInterval(double secondsVisible) {
    if (secondsVisible < 10) return 1;
    if (secondsVisible < 30) return 5;
    if (secondsVisible < 60) return 10;
    if (secondsVisible < 300) return 30;
    return 60;
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TimelineTrackPainter extends CustomPainter {
  final dynamic track;
  final bool isVideo;
  final double zoomLevel;

  TimelineTrackPainter(this.track, this.isVideo, this.zoomLevel);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw placeholder clips
    final clipPaint = Paint()
      ..color = isVideo ? Colors.blue[700]! : Colors.green[700]!
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isVideo ? Colors.blue[900]! : Colors.green[900]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw some placeholder clips
    final clipWidth = 100.0 * zoomLevel;
    for (int i = 0; i < 3; i++) {
      final x = i * (clipWidth + 10);
      if (x > size.width) break;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 4, clipWidth, size.height - 8),
        const Radius.circular(2),
      );

      canvas.drawRRect(rect, clipPaint);
      canvas.drawRRect(rect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}