import 'package:flutter/material.dart';

/// Advanced video editing models for professional "Bearbeiter weit" functionality
/// This provides comprehensive video editing capabilities similar to professional tools

// Main Advanced Video Edit Session
class AdvancedVideoEditSession {
  final String id;
  final String projectName;
  final List<VideoTrack> videoTracks;
  final List<AudioTrack> audioTracks;
  final List<EffectLayer> effectLayers;
  final List<TextLayer> textLayers;
  final List<GraphicsLayer> graphicsLayers;
  final Timeline timeline;
  final ColorGrading colorGrading;
  final AudioMaster audioMaster;
  final ExportPresets exportPresets;
  final ProjectSettings projectSettings;
  final DateTime createdAt;
  final DateTime? lastModified;
  final bool autoSaveEnabled;

  AdvancedVideoEditSession({
    required this.id,
    required this.projectName,
    this.videoTracks = const [],
    this.audioTracks = const [],
    this.effectLayers = const [],
    this.textLayers = const [],
    this.graphicsLayers = const [],
    required this.timeline,
    required this.colorGrading,
    required this.audioMaster,
    required this.exportPresets,
    required this.projectSettings,
    required this.createdAt,
    this.lastModified,
    this.autoSaveEnabled = true,
  });
}

// Multi-track video support
class VideoTrack {
  final String id;
  final String name;
  final int trackIndex;
  final List<VideoClip> clips;
  final bool isEnabled;
  final bool isLocked;
  final double opacity;
  final BlendMode blendMode;
  final VideoTrackType type;

  VideoTrack({
    required this.id,
    required this.name,
    required this.trackIndex,
    this.clips = const [],
    this.isEnabled = true,
    this.isLocked = false,
    this.opacity = 1.0,
    this.blendMode = BlendMode.normal,
    this.type = VideoTrackType.standard,
  });
}

enum VideoTrackType {
  standard,
  overlay,
  mask,
  adjustment,
  reference,
}

enum BlendMode {
  normal,
  multiply,
  screen,
  overlay,
  softLight,
  hardLight,
  colorDodge,
  colorBurn,
  darken,
  lighten,
  difference,
  exclusion,
}

// Enhanced video clip with keyframes
class VideoClip {
  final String id;
  final String sourcePath;
  final Duration inPoint;
  final Duration outPoint;
  final Duration timelinePosition;
  final double scale;
  final Offset position;
  final double rotation;
  final List<Keyframe> keyframes;
  final SpeedRamp? speedRamp;
  final StabilizationSettings? stabilization;
  final CropSettings? cropSettings;

  VideoClip({
    required this.id,
    required this.sourcePath,
    required this.inPoint,
    required this.outPoint,
    required this.timelinePosition,
    this.scale = 1.0,
    this.position = Offset.zero,
    this.rotation = 0.0,
    this.keyframes = const [],
    this.speedRamp,
    this.stabilization,
    this.cropSettings,
  });
}

// Keyframe animation support
class Keyframe {
  final Duration time;
  final String property;
  final dynamic value;
  final InterpolationType interpolation;
  final BezierCurve? bezierCurve;

  Keyframe({
    required this.time,
    required this.property,
    required this.value,
    this.interpolation = InterpolationType.linear,
    this.bezierCurve,
  });
}

enum InterpolationType {
  linear,
  bezier,
  hold,
  easeIn,
  easeOut,
  easeInOut,
}

class BezierCurve {
  final Offset controlPoint1;
  final Offset controlPoint2;

  BezierCurve({
    required this.controlPoint1,
    required this.controlPoint2,
  });
}

// Speed ramping for dynamic speed changes
class SpeedRamp {
  final List<SpeedPoint> points;
  final bool smoothTransitions;

  SpeedRamp({
    required this.points,
    this.smoothTransitions = true,
  });
}

class SpeedPoint {
  final Duration time;
  final double speed;

  SpeedPoint({
    required this.time,
    required this.speed,
  });
}

// Video stabilization
class StabilizationSettings {
  final double strength;
  final bool rotationCorrection;
  final bool scaleCorrection;
  final bool rollingShutterCorrection;

  StabilizationSettings({
    this.strength = 0.5,
    this.rotationCorrection = true,
    this.scaleCorrection = true,
    this.rollingShutterCorrection = false,
  });
}

// Advanced crop settings
class CropSettings {
  final Rect cropRect;
  final double aspectRatio;
  final bool maintainAspectRatio;
  final bool animatedCrop;
  final List<Keyframe>? cropKeyframes;

  CropSettings({
    required this.cropRect,
    required this.aspectRatio,
    this.maintainAspectRatio = true,
    this.animatedCrop = false,
    this.cropKeyframes,
  });
}

// Multi-track audio support
class AudioTrack {
  final String id;
  final String name;
  final int trackIndex;
  final List<AudioClip> clips;
  final double volume;
  final double pan;
  final bool isMuted;
  final bool isSolo;
  final List<AudioEffect> effects;
  final AudioTrackType type;

  AudioTrack({
    required this.id,
    required this.name,
    required this.trackIndex,
    this.clips = const [],
    this.volume = 1.0,
    this.pan = 0.0,
    this.isMuted = false,
    this.isSolo = false,
    this.effects = const [],
    this.type = AudioTrackType.standard,
  });
}

enum AudioTrackType {
  standard,
  music,
  voiceover,
  soundEffect,
  ambience,
}

class AudioClip {
  final String id;
  final String sourcePath;
  final Duration inPoint;
  final Duration outPoint;
  final Duration timelinePosition;
  final double volume;
  final List<Keyframe> volumeKeyframes;
  final FadeSettings? fadeIn;
  final FadeSettings? fadeOut;
  final AudioEnvelope? envelope;
  final double pitch;
  final bool reverseAudio;

  AudioClip({
    required this.id,
    required this.sourcePath,
    required this.inPoint,
    required this.outPoint,
    required this.timelinePosition,
    this.volume = 1.0,
    this.volumeKeyframes = const [],
    this.fadeIn,
    this.fadeOut,
    this.envelope,
    this.pitch = 0.0,
    this.reverseAudio = false,
  });
}

class FadeSettings {
  final Duration duration;
  final FadeCurve curve;

  FadeSettings({
    required this.duration,
    this.curve = FadeCurve.linear,
  });
}

enum FadeCurve {
  linear,
  exponential,
  logarithmic,
  sCurve,
}

class AudioEnvelope {
  final List<EnvelopePoint> points;

  AudioEnvelope({
    required this.points,
  });
}

class EnvelopePoint {
  final Duration time;
  final double level;

  EnvelopePoint({
    required this.time,
    required this.level,
  });
}

// Audio effects
class AudioEffect {
  final String id;
  final AudioEffectType type;
  final Map<String, dynamic> parameters;
  final bool isEnabled;

  AudioEffect({
    required this.id,
    required this.type,
    required this.parameters,
    this.isEnabled = true,
  });
}

enum AudioEffectType {
  equalizer,
  compressor,
  limiter,
  reverb,
  delay,
  chorus,
  flanger,
  phaser,
  distortion,
  noiseSuppression,
  gate,
}

// Effect layers
class EffectLayer {
  final String id;
  final String name;
  final EffectType type;
  final Duration startTime;
  final Duration endTime;
  final Map<String, dynamic> parameters;
  final List<Keyframe> keyframes;
  final bool isEnabled;
  final double opacity;

  EffectLayer({
    required this.id,
    required this.name,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.parameters,
    this.keyframes = const [],
    this.isEnabled = true,
    this.opacity = 1.0,
  });
}

enum EffectType {
  // Color effects
  colorCorrection,
  lumaKey,
  chromaKey,
  
  // Blur effects
  gaussianBlur,
  motionBlur,
  radialBlur,
  
  // Distortion effects
  warp,
  ripple,
  twirl,
  bulge,
  
  // Stylize effects
  cartoon,
  oilPaint,
  pencilSketch,
  halftone,
  
  // Light effects
  lensFlare,
  lightLeak,
  glowHighlights,
  
  // Particle effects
  snow,
  rain,
  confetti,
  sparkles,
  
  // Transitions
  dissolve,
  wipe,
  slide,
  zoom,
  spin,
  
  // 3D effects
  threeDRotation,
  threeDExtrude,
  perspective,
}

// Text layers with advanced typography
class TextLayer {
  final String id;
  final String text;
  final TextStyle style;
  final Offset position;
  final double rotation;
  final Duration startTime;
  final Duration endTime;
  final TextAnimation? animation;
  final TextEffects? effects;
  final List<Keyframe> keyframes;

  TextLayer({
    required this.id,
    required this.text,
    required this.style,
    required this.position,
    this.rotation = 0.0,
    required this.startTime,
    required this.endTime,
    this.animation,
    this.effects,
    this.keyframes = const [],
  });
}

class TextAnimation {
  final TextAnimationType type;
  final Duration duration;
  final Map<String, dynamic> parameters;

  TextAnimation({
    required this.type,
    required this.duration,
    required this.parameters,
  });
}

enum TextAnimationType {
  fadeIn,
  fadeOut,
  typewriter,
  slideIn,
  slideOut,
  bounce,
  scale,
  rotate,
  blur,
  glitch,
  neon,
  fire,
}

class TextEffects {
  final bool hasShadow;
  final Shadow? shadow;
  final bool hasStroke;
  final Paint? strokePaint;
  final bool hasGradient;
  final Gradient? gradient;
  final bool has3D;
  final ThreeDTextSettings? threeDSettings;

  TextEffects({
    this.hasShadow = false,
    this.shadow,
    this.hasStroke = false,
    this.strokePaint,
    this.hasGradient = false,
    this.gradient,
    this.has3D = false,
    this.threeDSettings,
  });
}

class ThreeDTextSettings {
  final double depth;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final Color extrudeColor;

  ThreeDTextSettings({
    required this.depth,
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.rotationZ = 0.0,
    required this.extrudeColor,
  });
}

// Graphics layers for overlays
class GraphicsLayer {
  final String id;
  final GraphicsType type;
  final dynamic content;
  final Offset position;
  final Size size;
  final double rotation;
  final Duration startTime;
  final Duration endTime;
  final double opacity;
  final BlendMode blendMode;
  final List<Keyframe> keyframes;

  GraphicsLayer({
    required this.id,
    required this.type,
    required this.content,
    required this.position,
    required this.size,
    this.rotation = 0.0,
    required this.startTime,
    required this.endTime,
    this.opacity = 1.0,
    this.blendMode = BlendMode.normal,
    this.keyframes = const [],
  });
}

enum GraphicsType {
  image,
  shape,
  svg,
  animatedGif,
  lottie,
  particle,
  mask,
}

// Timeline management
class Timeline {
  final Duration totalDuration;
  final double frameRate;
  final int width;
  final int height;
  final List<Marker> markers;
  final List<Region> regions;
  final TimelineSettings settings;

  Timeline({
    required this.totalDuration,
    this.frameRate = 30.0,
    this.width = 1920,
    this.height = 1080,
    this.markers = const [],
    this.regions = const [],
    required this.settings,
  });
}

class Marker {
  final String id;
  final String name;
  final Duration time;
  final Color color;
  final String? note;

  Marker({
    required this.id,
    required this.name,
    required this.time,
    required this.color,
    this.note,
  });
}

class Region {
  final String id;
  final String name;
  final Duration startTime;
  final Duration endTime;
  final Color color;
  final RegionType type;

  Region({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.type,
  });
}

enum RegionType {
  render,
  preview,
  loop,
  selection,
}

class TimelineSettings {
  final bool snapToGrid;
  final Duration gridSize;
  final bool showWaveforms;
  final bool showThumbnails;
  final bool magneticTimeline;
  final double zoomLevel;

  TimelineSettings({
    this.snapToGrid = true,
    this.gridSize = const Duration(milliseconds: 100),
    this.showWaveforms = true,
    this.showThumbnails = true,
    this.magneticTimeline = true,
    this.zoomLevel = 1.0,
  });
}

// Professional color grading
class ColorGrading {
  final ColorWheels colorWheels;
  final ColorCurves colorCurves;
  final HSLAdjustments hslAdjustments;
  final LUTSettings lutSettings;
  final ScopeSettings scopeSettings;

  ColorGrading({
    required this.colorWheels,
    required this.colorCurves,
    required this.hslAdjustments,
    required this.lutSettings,
    required this.scopeSettings,
  });
}

class ColorWheels {
  final ColorWheel shadows;
  final ColorWheel midtones;
  final ColorWheel highlights;
  final double exposure;
  final double temperature;
  final double tint;

  ColorWheels({
    required this.shadows,
    required this.midtones,
    required this.highlights,
    this.exposure = 0.0,
    this.temperature = 0.0,
    this.tint = 0.0,
  });
}

class ColorWheel {
  final double hue;
  final double saturation;
  final double luminance;

  ColorWheel({
    this.hue = 0.0,
    this.saturation = 0.0,
    this.luminance = 0.0,
  });
}

class ColorCurves {
  final List<CurvePoint> masterCurve;
  final List<CurvePoint> redCurve;
  final List<CurvePoint> greenCurve;
  final List<CurvePoint> blueCurve;

  ColorCurves({
    required this.masterCurve,
    required this.redCurve,
    required this.greenCurve,
    required this.blueCurve,
  });
}

class CurvePoint {
  final double x;
  final double y;

  CurvePoint({
    required this.x,
    required this.y,
  });
}

class HSLAdjustments {
  final double hueShift;
  final double saturation;
  final double lightness;
  final List<HSLRange> selectiveAdjustments;

  HSLAdjustments({
    this.hueShift = 0.0,
    this.saturation = 1.0,
    this.lightness = 0.0,
    this.selectiveAdjustments = const [],
  });
}

class HSLRange {
  final double hueMin;
  final double hueMax;
  final double saturationAdjust;
  final double lightnessAdjust;

  HSLRange({
    required this.hueMin,
    required this.hueMax,
    required this.saturationAdjust,
    required this.lightnessAdjust,
  });
}

class LUTSettings {
  final String? lutFile;
  final double intensity;
  final bool enabled;

  LUTSettings({
    this.lutFile,
    this.intensity = 1.0,
    this.enabled = false,
  });
}

class ScopeSettings {
  final bool showVectorscope;
  final bool showWaveform;
  final bool showHistogram;
  final bool showParade;

  ScopeSettings({
    this.showVectorscope = false,
    this.showWaveform = false,
    this.showHistogram = false,
    this.showParade = false,
  });
}

// Audio mastering
class AudioMaster {
  final MasterEQ masterEQ;
  final MasterCompressor masterCompressor;
  final MasterLimiter masterLimiter;
  final double masterVolume;
  final double masterPan;
  final bool loudnessNormalization;
  final double targetLUFS;

  AudioMaster({
    required this.masterEQ,
    required this.masterCompressor,
    required this.masterLimiter,
    this.masterVolume = 1.0,
    this.masterPan = 0.0,
    this.loudnessNormalization = false,
    this.targetLUFS = -14.0,
  });
}

class MasterEQ {
  final List<EQBand> bands;
  final bool enabled;

  MasterEQ({
    required this.bands,
    this.enabled = true,
  });
}

class EQBand {
  final double frequency;
  final double gain;
  final double q;
  final EQType type;

  EQBand({
    required this.frequency,
    required this.gain,
    required this.q,
    required this.type,
  });
}

enum EQType {
  lowShelf,
  highShelf,
  bell,
  notch,
  lowPass,
  highPass,
}

class MasterCompressor {
  final double threshold;
  final double ratio;
  final double attack;
  final double release;
  final double knee;
  final double makeupGain;
  final bool enabled;

  MasterCompressor({
    this.threshold = -20.0,
    this.ratio = 4.0,
    this.attack = 10.0,
    this.release = 100.0,
    this.knee = 2.0,
    this.makeupGain = 0.0,
    this.enabled = true,
  });
}

class MasterLimiter {
  final double ceiling;
  final double release;
  final bool enabled;

  MasterLimiter({
    this.ceiling = -0.1,
    this.release = 50.0,
    this.enabled = true,
  });
}

// Export presets
class ExportPresets {
  final List<ExportPreset> presets;
  final ExportPreset? customPreset;

  ExportPresets({
    required this.presets,
    this.customPreset,
  });
}

class ExportPreset {
  final String name;
  final VideoCodec videoCodec;
  final AudioCodec audioCodec;
  final int width;
  final int height;
  final double frameRate;
  final int videoBitrate;
  final int audioBitrate;
  final int audioSampleRate;
  final ContainerFormat format;
  final bool twoPass;
  final Map<String, dynamic> advancedSettings;

  ExportPreset({
    required this.name,
    required this.videoCodec,
    required this.audioCodec,
    required this.width,
    required this.height,
    required this.frameRate,
    required this.videoBitrate,
    required this.audioBitrate,
    required this.audioSampleRate,
    required this.format,
    this.twoPass = false,
    this.advancedSettings = const {},
  });
}

enum VideoCodec {
  h264,
  h265,
  vp9,
  av1,
  prores,
  dnxhd,
}

enum AudioCodec {
  aac,
  mp3,
  opus,
  flac,
  pcm,
}

enum ContainerFormat {
  mp4,
  mov,
  avi,
  mkv,
  webm,
  mxf,
}

// Project settings
class ProjectSettings {
  final String projectPath;
  final VideoStandard videoStandard;
  final AspectRatio aspectRatio;
  final ColorSpace colorSpace;
  final bool proxyEnabled;
  final ProxySettings? proxySettings;
  final bool hardwareAcceleration;
  final RenderEngine renderEngine;

  ProjectSettings({
    required this.projectPath,
    required this.videoStandard,
    required this.aspectRatio,
    required this.colorSpace,
    this.proxyEnabled = false,
    this.proxySettings,
    this.hardwareAcceleration = true,
    this.renderEngine = RenderEngine.metal,
  });
}

enum VideoStandard {
  ntsc,
  pal,
  cinema,
  web,
  custom,
}

enum AspectRatio {
  sixteenNine,
  fourThree,
  twentyOneNine,
  oneOne,
  nineSixteen,
  custom,
}

enum ColorSpace {
  srgb,
  rec709,
  rec2020,
  p3,
  aces,
}

enum RenderEngine {
  software,
  opengl,
  metal,
  vulkan,
  cuda,
}

class ProxySettings {
  final ProxyResolution resolution;
  final ProxyCodec codec;
  final String proxyPath;

  ProxySettings({
    required this.resolution,
    required this.codec,
    required this.proxyPath,
  });
}

enum ProxyResolution {
  quarter,
  half,
  full,
}

enum ProxyCodec {
  h264,
  prores,
  dnxhd,
}