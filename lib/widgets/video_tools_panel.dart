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
    'effects',
    'color',
    'crop',
    'merge',
    'export',
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
      height: 280, // Increased height for wider panel
      color: Colors.grey[900],
      child: Column(
        children: [
          // Tool tabs - now with two rows for better organization
          Container(
            height: 80,
            child: Column(
              children: [
                // First row of tools
                Container(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (_tools.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      if (index >= _tools.length) return const SizedBox.shrink();
                      final tool = _tools[index];
                      final isSelected = widget.selectedTool == tool;
                      
                      return GestureDetector(
                        onTap: () => widget.onToolChanged(tool),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red : Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _getToolDisplayName(tool),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[400],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Second row of tools
                Container(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tools.length - (_tools.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      final toolIndex = index + (_tools.length / 2).ceil();
                      if (toolIndex >= _tools.length) return const SizedBox.shrink();
                      final tool = _tools[toolIndex];
                      final isSelected = widget.selectedTool == tool;
                      
                      return GestureDetector(
                        onTap: () => widget.onToolChanged(tool),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.red : Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _getToolDisplayName(tool),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[400],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
      case 'effects':
        return _buildEffectsTool();
      case 'color':
        return _buildColorTool();
      case 'crop':
        return _buildCropTool();
      case 'merge':
        return _buildMergeTool();
      case 'export':
        return _buildExportTool();
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
              _buildTransitionButton('Fade', Icons.blur_linear),
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

  Widget _buildEffectsTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Advanced Effects',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildEffectButton('Slow Motion', Icons.slow_motion_video, Colors.blue),
                _buildEffectButton('Time Lapse', Icons.fast_forward, Colors.green),
                _buildEffectButton('Reverse', Icons.replay, Colors.orange),
                _buildEffectButton('Glitch', Icons.broken_image, Colors.purple),
                _buildEffectButton('Shake', Icons.vibration, Colors.red),
                _buildEffectButton('Zoom', Icons.zoom_in, Colors.teal),
                _buildEffectButton('Particle', Icons.scatter_plot, Colors.pink),
                _buildEffectButton('Mirror', Icons.flip, Colors.indigo),
                _buildEffectButton('Kaleidoscope', Icons.auto_awesome, Colors.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectButton(String name, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name effect applied')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Color Grading',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildColorSlider('Temperature', Icons.thermostat, Colors.orange, -100, 100, 0),
                  const SizedBox(height: 12),
                  _buildColorSlider('Tint', Icons.palette, Colors.green, -100, 100, 0),
                  const SizedBox(height: 12),
                  _buildColorSlider('Exposure', Icons.exposure, Colors.yellow, -2, 2, 0),
                  const SizedBox(height: 12),
                  _buildColorSlider('Highlights', Icons.highlight, Colors.white, -100, 100, 0),
                  const SizedBox(height: 12),
                  _buildColorSlider('Shadows', Icons.shadow, Colors.grey, -100, 100, 0),
                  const SizedBox(height: 12),
                  _buildColorSlider('Vibrance', Icons.color_lens, Colors.purple, -100, 100, 0),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _resetColorGrading(),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _saveColorPreset(),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Save Preset'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSlider(String label, IconData icon, Color color, double min, double max, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const Spacer(),
            Text(value.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: (newValue) {
            // Handle color adjustment
          },
          activeColor: color,
          inactiveColor: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildCropTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Crop & Resize',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildAspectRatioButton('1:1', 1.0),
                    const SizedBox(height: 8),
                    _buildAspectRatioButton('4:3', 4/3),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    _buildAspectRatioButton('16:9', 16/9),
                    const SizedBox(height: 8),
                    _buildAspectRatioButton('9:16', 9/16),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    _buildAspectRatioButton('Free', 0),
                    const SizedBox(height: 8),
                    _buildAspectRatioButton('Original', -1),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rotateVideo(90),
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('Rotate'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _flipVideo(),
                  icon: const Icon(Icons.flip),
                  label: const Text('Flip'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAspectRatioButton(String ratio, double value) {
    return GestureDetector(
      onTap: () => _setCropRatio(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            ratio,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildMergeTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Merge Videos',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Current Video\n(Main Track)',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                ElevatedButton.icon(
                  onPressed: () => _addVideoToMerge(),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Video to Merge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _mergeSequentially(),
                        icon: const Icon(Icons.queue),
                        label: const Text('Sequential'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _mergeSideBySide(),
                        icon: const Icon(Icons.view_column),
                        label: const Text('Side by Side'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                ElevatedButton.icon(
                  onPressed: () => _mergePictureInPicture(),
                  icon: const Icon(Icons.picture_in_picture),
                  label: const Text('Picture in Picture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportTool() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Export Settings',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildExportOption('4K Ultra HD', '3840x2160', Icons.hd, Colors.red),
                  const SizedBox(height: 8),
                  _buildExportOption('1080p Full HD', '1920x1080', Icons.hd, Colors.orange),
                  const SizedBox(height: 8),
                  _buildExportOption('720p HD', '1280x720', Icons.video_library, Colors.blue),
                  const SizedBox(height: 8),
                  _buildExportOption('480p SD', '854x480', Icons.video_call, Colors.green),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Format', style: TextStyle(color: Colors.white)),
                            const SizedBox(height: 8),
                            DropdownButton<String>(
                              value: 'MP4',
                              dropdownColor: Colors.grey[800],
                              style: const TextStyle(color: Colors.white),
                              items: ['MP4', 'MOV', 'AVI', 'MKV'].map((format) {
                                return DropdownMenuItem(value: format, child: Text(format));
                              }).toList(),
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Quality', style: TextStyle(color: Colors.white)),
                            const SizedBox(height: 8),
                            DropdownButton<String>(
                              value: 'High',
                              dropdownColor: Colors.grey[800],
                              style: const TextStyle(color: Colors.white),
                              items: ['Low', 'Medium', 'High', 'Ultra'].map((quality) {
                                return DropdownMenuItem(value: quality, child: Text(quality));
                              }).toList(),
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ElevatedButton.icon(
                    onPressed: () => _startExport(),
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(50),
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

  Widget _buildExportOption(String title, String resolution, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _selectExportQuality(resolution),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(resolution, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
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
      case 'effects': return 'Effects';
      case 'color': return 'Color';
      case 'crop': return 'Crop';
      case 'merge': return 'Merge';
      case 'export': return 'Export';
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

  // New helper methods for expanded functionality
  void _resetColorGrading() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Color grading reset to default')),
    );
  }

  void _saveColorPreset() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Color preset saved')),
    );
  }

  void _setCropRatio(double ratio) {
    String ratioText = '';
    if (ratio == 1.0) ratioText = '1:1 Square';
    else if (ratio == 4/3) ratioText = '4:3 Standard';
    else if (ratio == 16/9) ratioText = '16:9 Widescreen';
    else if (ratio == 9/16) ratioText = '9:16 Portrait';
    else if (ratio == 0) ratioText = 'Free crop';
    else if (ratio == -1) ratioText = 'Original ratio';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Crop ratio set to $ratioText')),
    );
  }

  void _rotateVideo(int degrees) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Video rotated $degrees degrees')),
    );
  }

  void _flipVideo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video flipped horizontally')),
    );
  }

  void _addVideoToMerge() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video picker for merge not implemented yet')),
    );
  }

  void _mergeSequentially() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Videos will be merged sequentially')),
    );
  }

  void _mergeSideBySide() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Videos will be merged side by side')),
    );
  }

  void _mergePictureInPicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Picture in picture mode enabled')),
    );
  }

  void _selectExportQuality(String resolution) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export quality set to $resolution')),
    );
  }

  void _startExport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Exporting video with advanced settings...'),
          ],
        ),
      ),
    );

    // Simulate export process
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}