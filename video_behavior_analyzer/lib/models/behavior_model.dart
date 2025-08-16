// models/behavior_model.dart
class BehaviorModel {
  final String id;
  final BehaviorType type;
  final double confidence;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> involvedPersonIds;
  final Map<String, dynamic> metadata;
  final SeverityLevel severity;

  BehaviorModel({
    required this.id,
    required this.type,
    required this.confidence,
    required this.startTime,
    this.endTime,
    required this.involvedPersonIds,
    required this.metadata,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'confidence': confidence,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'involvedPersonIds': involvedPersonIds,
        'metadata': metadata,
        'severity': severity.toString(),
      };

  factory BehaviorModel.fromJson(Map<String, dynamic> json) => BehaviorModel(
        id: json['id'],
        type: BehaviorType.values.firstWhere(
          (t) => t.toString() == json['type'],
        ),
        confidence: json['confidence'],
        startTime: DateTime.parse(json['startTime']),
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        involvedPersonIds: List<String>.from(json['involvedPersonIds']),
        metadata: json['metadata'],
        severity: SeverityLevel.values.firstWhere(
          (s) => s.toString() == json['severity'],
        ),
      );
}

enum BehaviorType {
  intoxication,
  violence,
  theft,
  suspicious,
  fall,
  aggression,
  normal
}

enum SeverityLevel { low, medium, high, critical }
