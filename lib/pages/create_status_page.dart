import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/status_service.dart';
import '../models/status.dart';

class CreateStatusPage extends StatefulWidget {
  const CreateStatusPage({super.key});

  @override
  State<CreateStatusPage> createState() => _CreateStatusPageState();
}

class _CreateStatusPageState extends State<CreateStatusPage> {
  final _captionController = TextEditingController();
  final _textController = TextEditingController();
  File? _mediaFile;
  String _mediaType = 'image';
  bool _isLoading = false;
  String _statusMode = 'media'; // 'media', 'text'
  Color _backgroundColor = const Color(0xFF4CAF50);
  Color _textColor = Colors.white;
  String _fontStyle = 'normal';

  Future<void> _pickMedia(bool isVideo, {ImageSource source = ImageSource.gallery}) async {
    try {
      final picker = ImagePicker();
      XFile? pickedFile;
      
      if (isVideo) {
        pickedFile = await picker.pickVideo(source: source);
      } else {
        pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 80,
        );
      }

      if (pickedFile != null) {
        setState(() {
          _mediaFile = File(pickedFile!.path);
          _mediaType = isVideo ? 'video' : 'image';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick media: $e')),
      );
    }
  }

  Future<void> _postStatus() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      if (_statusMode == 'text') {
        // Post text status
        if (_textController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter some text')),
          );
          return;
        }

        await StatusService.postTextStatus(
          userId: user.uid,
          userName: user.displayName ?? 'User',
          content: _textController.text.trim(),
          backgroundColor: '#${_backgroundColor.value.toRadixString(16).substring(2)}',
          textColor: '#${_textColor.value.toRadixString(16).substring(2)}',
          fontStyle: _fontStyle,
        );
      } else {
        // Post media status
        if (_mediaFile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an image or video')),
          );
          return;
        }

        // Upload media file first
        String mediaUrl = await StatusService.uploadStatusMedia(
          _mediaFile!, 
          _mediaType,
        );

        // Determine status type
        StatusType statusType = _mediaType == 'video' ? StatusType.video : StatusType.image;

        await StatusService.postStatus(
          userId: user.uid,
          userName: user.displayName ?? 'User',
          type: statusType,
          mediaUrl: mediaUrl,
          caption: _captionController.text.trim().isEmpty ? null : _captionController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status posted!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post status: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Status'),
        actions: [
          if (_statusMode == 'media' && _mediaFile != null || _statusMode == 'text' && _textController.text.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _postStatus,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('POST', style: TextStyle(color: Colors.white)),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _statusMode = 'media'),
                icon: Icon(
                  Icons.photo_camera,
                  color: _statusMode == 'media' ? const Color(0xFF07C160) : Colors.grey,
                ),
                label: Text(
                  'Media',
                  style: TextStyle(
                    color: _statusMode == 'media' ? const Color(0xFF07C160) : Colors.grey,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _statusMode = 'text'),
                icon: Icon(
                  Icons.text_fields,
                  color: _statusMode == 'text' ? const Color(0xFF07C160) : Colors.grey,
                ),
                label: Text(
                  'Text',
                  style: TextStyle(
                    color: _statusMode == 'text' ? const Color(0xFF07C160) : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _statusMode == 'media' ? _buildMediaMode() : _buildTextMode(),
    );
  }

  Widget _buildMediaMode() {
    return Column(
      children: [
        Expanded(
          child: _mediaFile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No media selected', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _pickMedia(false),
                            icon: const Icon(Icons.photo),
                            label: const Text('Image'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => _pickMedia(true),
                            icon: const Icon(Icons.videocam),
                            label: const Text('Video'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _pickMedia(false, source: ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Center(
                      child: _mediaType == 'image'
                          ? Image.file(_mediaFile!, fit: BoxFit.contain)
                          : const Center(
                              child: Icon(Icons.play_circle_outline, size: 100),
                            ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        onPressed: () => setState(() => _mediaFile = null),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        if (_mediaFile != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'Add a caption...',
                border: InputBorder.none,
              ),
              maxLines: 3,
            ),
          ),
      ],
    );
  }

  Widget _buildTextMode() {
    return Column(
      children: [
        // Text customization tools
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Background: '),
                  const SizedBox(width: 8),
                  for (Color color in [
                    const Color(0xFF4CAF50),
                    const Color(0xFF2196F3),
                    const Color(0xFFFF9800),
                    const Color(0xFFE91E63),
                    const Color(0xFF9C27B0),
                    Colors.black,
                  ])
                    GestureDetector(
                      onTap: () => setState(() => _backgroundColor = color),
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _backgroundColor == color ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Text Color: '),
                  const SizedBox(width: 8),
                  for (Color color in [Colors.white, Colors.black, const Color(0xFFFFEB3B)])
                    GestureDetector(
                      onTap: () => setState(() => _textColor = color),
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _textColor == color ? const Color(0xFF07C160) : Colors.grey,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Text status preview
        Expanded(
          child: Container(
            width: double.infinity,
            color: _backgroundColor,
            padding: const EdgeInsets.all(32),
            child: Center(
              child: TextField(
                controller: _textController,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 24,
                  fontWeight: _fontStyle == 'bold' ? FontWeight.bold : FontWeight.normal,
                  fontStyle: _fontStyle == 'italic' ? FontStyle.italic : FontStyle.normal,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your status...',
                  hintStyle: TextStyle(color: _textColor.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
                textAlign: TextAlign.center,
                maxLines: null,
                onChanged: (value) => setState(() {}),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
