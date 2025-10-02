import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class VideoToolsPanel extends StatefulWidget {
  final String selectedTool;
  final Function(String) onToolChanged;
  final double brightness;
  final double contrast;
  final double saturation;
  final Function(double) onBrightnessChanged;
  final Function(double) onContrastChanged;
  final Function(double) onSaturationChanged;
  final Function(String) onFilterSelected;
  final VoidCallback onAddText;
  final VoidCallback onAddAudio;
  final double playbackSpeed;
  final Function(double) onSpeedChanged;

  const VideoToolsPanel({
    super.key,
    required this.selectedTool,
    required this.onToolChanged,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.onBrightnessChanged,
    required this.onContrastChanged,
    required this.onSaturationChanged,
    required this.onFilterSelected,
    required this.onAddText,
    required this.onAddAudio,
    required this.playbackSpeed,
    required this.onSpeedChanged,
  });

  @override
  State<VideoToolsPanel> createState() => _VideoToolsPanelState();
}

class _VideoToolsPanelState extends State<VideoToolsPanel> {
  final List<String> _tools = [
    'trim',
    'filter',
    'adjust',
    'text',
    'audio',
    'speed',
    'transition',
    'sticker',
  ];

  final List<Map<String, dynamic>> _filters = [
    {'name': 'none', 'displayName': 'Original', 'icon': Icons.image},
    {'name': 'vintage', 'displayName': 'Vintage', 'icon': Icons.filter_vintage},
    {'name': 'dramatic', 'displayName': 'Dramatic', 'icon': Icons.theater_comedy},
    {'name': 'warm', 'displayName': 'Warm', 'icon': Icons.wb_sunny},
    {'name': 'cool', 'displayName': 'Cool', 'icon': Icons.ac_unit},
    {'name': 'blackwhite', 'displayName': 'B&W', 'icon': Icons.filter_b_and_w},
    {'name': 'sepia', 'displayName': 'Sepia', 'icon': Icons.filter_frames},
    {'name': 'blur', 'displayName': 'Blur', 'icon': Icons.blur_on},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.grey[900],
      child: Column(
        children: [
          // Tool tabs
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tools.length,
              itemBuilder: (context, index) {
                final tool = _tools[index];
                final isSelected = widget.selectedTool == tool;
                
                return GestureDetector(
                  onTap: () => widget.onToolChanged(tool),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        _getToolDisplayName(tool),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[400],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Tool content
          Expanded(
            child: _buildToolContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolContent() {
    switch (widget.selectedTool) {
      case 'trim':
        return _buildTrimTool();
      case 'filter':
        return _buildFilterTool();
      case 'adjust':
        return _buildAdjustTool();
      case 'text':
        return _buildTextTool();
      case 'audio':
        return _buildAudioTool();
      case 'speed':
        return _buildSpeedTool();
      case 'transition':
        return _buildTransitionTool();
      case 'sticker':
        return _buildStickerTool();
      default:
        return const Center(child: Text('Select a tool'));
    }
  }

  Widget _buildTrimTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Trim Video',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Start Time', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('00:00', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    const Text('End Time', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('00:30', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video trimmed successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply Trim'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter['name'] == 'none'; // In real app, check current filter
                
                return GestureDetector(
                  onTap: () => widget.onFilterSelected(filter['name']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          filter['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          filter['displayName'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adjustments',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Brightness
          _buildAdjustmentSlider(
            'Brightness',
            widget.brightness,
            -1.0,
            1.0,
            widget.onBrightnessChanged,
            Icons.brightness_6,
          ),
          
          const SizedBox(height: 16),
          
          // Contrast
          _buildAdjustmentSlider(
            'Contrast',
            widget.contrast,
            0.0,
            2.0,
            widget.onContrastChanged,
            Icons.contrast,
          ),
          
          const SizedBox(height: 16),
          
          // Saturation
          _buildAdjustmentSlider(
            'Saturation',
            widget.saturation,
            0.0,
            2.0,
            widget.onSaturationChanged,
            Icons.color_lens,
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: Colors.red,
          inactiveColor: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildTextTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Add Text',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onAddText,
                  icon: const Icon(Icons.text_fields),
                  label: const Text('Add Text'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showColorPicker(),
                  icon: const Icon(Icons.color_lens),
                  label: const Text('Color'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showFontPicker(),
                  icon: const Icon(Icons.font_download),
                  label: const Text('Font'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAnimationPicker(),
                  icon: const Icon(Icons.animation),
                  label: const Text('Animation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Audio',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onAddAudio,
                  icon: const Icon(Icons.music_note),
                  label: const Text('Add Music'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAudioLibrary(),
                  icon: const Icon(Icons.library_music),
                  label: const Text('Library'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showVoiceRecording(),
                  icon: const Icon(Icons.mic),
                  label: const Text('Voice Over'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAudioEffects(),
                  icon: const Icon(Icons.equalizer),
                  label: const Text('Effects'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Playback Speed',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildSpeedButton('0.5x', 0.5),
              const SizedBox(width: 8),
              _buildSpeedButton('0.75x', 0.75),
              const SizedBox(width: 8),
              _buildSpeedButton('1x', 1.0),
              const SizedBox(width: 8),
              _buildSpeedButton('1.25x', 1.25),
              const SizedBox(width: 8),
              _buildSpeedButton('1.5x', 1.5),
              const SizedBox(width: 8),
              _buildSpeedButton('2x', 2.0),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Slider(
            value: widget.playbackSpeed,
            min: 0.25,
            max: 3.0,
            divisions: 11,
            onChanged: widget.onSpeedChanged,
            activeColor: Colors.red,
            inactiveColor: Colors.grey[600],
          ),
          
          Text(
            'Current Speed: ${widget.playbackSpeed}x',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(String label, double speed) {
    final isSelected = widget.playbackSpeed == speed;
    
    return GestureDetector(
      onTap: () => widget.onSpeedChanged(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransitionTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Transitions',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _buildTransitionButton('Fade', Icons.fade),
              _buildTransitionButton('Slide', Icons.slideshow),
              _buildTransitionButton('Zoom', Icons.zoom_in),
              _buildTransitionButton('Wipe', Icons.swipe),
              _buildTransitionButton('Flip', Icons.flip),
              _buildTransitionButton('Rotate', Icons.rotate_right),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionButton(String name, IconData icon) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name transition applied')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Stickers & Emojis',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                '😀', '😂', '😍', '🤔', '😎', '🥳',
                '❤️', '👍', '👏', '🎉', '🔥', '💯',
                '⭐', '🌟', '✨', '💫', '🌈', '🎨',
                '🎵', '🎶', '🎤', '🎧', '🎸', '🎹',
                '🏆', '🎯', '🎪', '🎭', '🎨', '🎬',
                '📱', '💻', '🎮', '🕹️', '🎲', '🎰',
              ].map((emoji) => GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$emoji sticker added')),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getToolDisplayName(String tool) {
    switch (tool) {
      case 'trim': return 'Trim';
      case 'filter': return 'Filter';
      case 'adjust': return 'Adjust';
      case 'text': return 'Text';
      case 'audio': return 'Audio';
      case 'speed': return 'Speed';
      case 'transition': return 'Transition';
      case 'sticker': return 'Sticker';
      default: return tool;
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: Colors.red,
            onColorChanged: (color) {
              // Handle color change
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFontPicker() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Font picker coming soon!')),
    );
  }

  void _showAnimationPicker() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Animation picker coming soon!')),
    );
  }

  void _showAudioLibrary() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio library coming soon!')),
    );
  }

  void _showVoiceRecording() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording coming soon!')),
    );
  }

  void _showAudioEffects() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audio effects coming soon!')),
    );
  }
}