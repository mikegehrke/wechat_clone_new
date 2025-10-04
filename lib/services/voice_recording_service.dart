import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VoiceRecordingService {
  static final AudioRecorder _recorder = AudioRecorder();
  static String? _currentRecordingPath;
  static DateTime? _recordingStartTime;

  /// Start recording voice message
  static Future<void> startRecording() async {
    try {
      // Check permission
      if (!await _recorder.hasPermission()) {
        throw Exception('Microphone permission denied');
      }

      // Get temp directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/voice_$timestamp.m4a';

      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _recordingStartTime = DateTime.now();
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  /// Stop recording and return file path
  static Future<Map<String, dynamic>> stopRecording() async {
    try {
      final path = await _recorder.stop();
      
      if (path == null || _recordingStartTime == null) {
        throw Exception('No recording in progress');
      }

      final duration = DateTime.now().difference(_recordingStartTime!);
      final file = File(path);
      final fileSize = await file.length();

      return {
        'path': path,
        'duration': duration.inSeconds,
        'size': fileSize,
      };
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  /// Cancel recording
  static Future<void> cancelRecording() async {
    try {
      await _recorder.stop();
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _currentRecordingPath = null;
      _recordingStartTime = null;
    } catch (e) {
      // Silent fail
    }
  }

  /// Upload voice message to Firebase Storage
  static Future<String> uploadVoiceMessage(String filePath) async {
    try {
      final file = File(filePath);
      final filename = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final ref = FirebaseStorage.instance.ref().child('voice_messages/$filename');
      
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload voice message: $e');
    }
  }

  /// Check if currently recording
  static Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  /// Dispose recorder
  static Future<void> dispose() async {
    await _recorder.dispose();
  }
}
