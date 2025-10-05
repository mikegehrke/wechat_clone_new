/// Represents a video editing session with timeline, effects, and export settings
class VideoEditSession {
  final String id;
  final String videoPath;
  final Duration videoDuration;
  final List<VideoClip> clips;
  final List<VideoEffect> effects;
  final List<AudioTrack> audioTracks;
  final ExportSettings exportSettings;
  final DateTime createdAt;
  final DateTime? lastModified;

  VideoEditSession({
    required this.id,
    required this.videoPath,
    required this.videoDuration,
    this.clips = const [],
    this.effects = const [],
    this.audioTracks = const [],
    required this.exportSettings,
    required this.createdAt,
    this.lastModified,
  });
}

/// Represents a video clip on the timeline
class VideoClip {
  final String id;
  final String videoPath;
  final Duration startTime;
  final Duration endTime;
  final Duration timelinePosition;
  final double volume;
  final bool isMuted;

  VideoClip({
    required this.id,
    required this.videoPath,
    required this.startTime,
    required this.endTime,
    required this.timelinePosition,
    this.volume = 1.0,
    this.isMuted = false,
  });
}

/// Represents a video effect (filter, transition, etc.)
class VideoEffect {
  final String id;
  final String name;
  final VideoEffectType type;
  final Duration startTime;
  final Duration endTime;
  final Map<String, dynamic> parameters;

  VideoEffect({
    required this.id,
    required this.name,
    required this.type,
    required this.startTime,
    required this.endTime,
    this.parameters = const {},
  });
}

enum VideoEffectType {
  filter,
  transition,
  text,
  sticker,
  blur,
  colorGrading,
  speed,
  reverse,
  crop,
  rotate,
}

/// Represents an audio track
class AudioTrack {
  final String id;
  final String audioPath;
  final Duration startTime;
  final Duration endTime;
  final double volume;
  final bool isMuted;
  final bool isVoiceover;

  AudioTrack({
    required this.id,
    required this.audioPath,
    required this.startTime,
    required this.endTime,
    this.volume = 1.0,
    this.isMuted = false,
    this.isVoiceover = false,
  });
}

/// Export settings for the final video
class ExportSettings {
  final VideoResolution resolution;
  final int frameRate;
  final int bitrate;
  final VideoFormat format;
  final String outputPath;

  ExportSettings({
    this.resolution = VideoResolution.hd1080,
    this.frameRate = 30,
    this.bitrate = 5000000, // 5 Mbps
    this.format = VideoFormat.mp4,
    required this.outputPath,
  });
}

enum VideoResolution {
  sd480,
  hd720,
  hd1080,
  uhd4k,
}

enum VideoFormat {
  mp4,
  mov,
  avi,
  webm,
}
