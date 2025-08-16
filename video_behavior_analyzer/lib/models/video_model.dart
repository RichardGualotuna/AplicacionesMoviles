// lib/models/video_model.dart
import 'detection_model.dart';
import 'behavior_model.dart';

// models/video_model.dart
class VideoModel {
  final String id;
  final String path;
  final DateTime timestamp;
  final Duration duration;
  final VideoSource source;
  final List<DetectionModel> detections;
  final List<BehaviorModel> behaviors;

  VideoModel({
    required this.id,
    required this.path,
    required this.timestamp,
    required this.duration,
    required this.source,
    this.detections = const [],
    this.behaviors = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration.inSeconds,
    'source': source.toString(),
    'detections': detections.map((d) => d.toJson()).toList(),
    'behaviors': behaviors.map((b) => b.toJson()).toList(),
  };

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
    id: json['id'],
    path: json['path'],
    timestamp: DateTime.parse(json['timestamp']),
    duration: Duration(seconds: json['duration']),
    source: VideoSource.values.firstWhere(
      (s) => s.toString() == json['source'],
    ),
    detections: (json['detections'] as List)
        .map((d) => DetectionModel.fromJson(d))
        .toList(),
    behaviors: (json['behaviors'] as List)
        .map((b) => BehaviorModel.fromJson(b))
        .toList(),
  );
}

enum VideoSource { camera, gallery }