// models/detection_model.dart
class DetectionModel {
  final String label;
  final double confidence;
  final BoundingBox boundingBox;
  final int frameNumber;
  final DateTime timestamp;

  DetectionModel({
    required this.label,
    required this.confidence,
    required this.boundingBox,
    required this.frameNumber,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'confidence': confidence,
    'boundingBox': boundingBox.toJson(),
    'frameNumber': frameNumber,
    'timestamp': timestamp.toIso8601String(),
  };

  factory DetectionModel.fromJson(Map<String, dynamic> json) => DetectionModel(
    label: json['label'],
    confidence: json['confidence'],
    boundingBox: BoundingBox.fromJson(json['boundingBox']),
    frameNumber: json['frameNumber'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };

  factory BoundingBox.fromJson(Map<String, dynamic> json) => BoundingBox(
    x: json['x'],
    y: json['y'],
    width: json['width'],
    height: json['height'],
  );
}