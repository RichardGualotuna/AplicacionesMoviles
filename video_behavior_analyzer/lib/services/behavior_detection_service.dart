// services/behavior_detection_service.dart
import 'dart:typed_data';
import 'dart:math';
import '../models/detection_model.dart';
import '../models/behavior_model.dart';
import 'ml_service.dart';
import '../services/ml_service.dart';

class BehaviorDetectionService {
  final MLService _mlService = MLService.instance;

  // Historial para análisis temporal
  final Map<String, List<DetectionModel>> _personHistory = {};
  final Map<String, List<Point<double>>> _movementHistory = {};
  final Map<String, List<double>> _velocityHistory = {};

  // Umbrales configurables
  static const double INTOXICATION_THRESHOLD = 0.7;
  static const double VIOLENCE_THRESHOLD = 0.8;
  static const double THEFT_THRESHOLD = 0.6;
  static const double FALL_THRESHOLD = 0.85;

  Future<BehaviorModel?> analyzeFrame(
    Uint8List frameData,
    List<DetectionModel> personDetections,
    Map<int, List<DetectionModel>> trackingHistory,
    int currentFrame,
  ) async {
    try {
      // Analizar cada persona detectada
      for (var person in personDetections) {
        final personId = _getPersonId(person, trackingHistory, currentFrame);

        // Actualizar historial
        _updatePersonHistory(personId, person);

        // Calcular métricas de movimiento
        final movement = _calculateMovementMetrics(personId);

        // Detectar comportamientos específicos
        final behavior = await _detectBehavior(
          personId,
          movement,
          frameData,
          person,
        );

        if (behavior != null) {
          return behavior;
        }
      }

      // Analizar interacciones entre personas
      if (personDetections.length > 1) {
        final interaction = _analyzeInteractions(personDetections);
        if (interaction != null) {
          return interaction;
        }
      }

      return null;
    } catch (e) {
      print('Error in behavior analysis: $e');
      return null;
    }
  }

  String _getPersonId(
    DetectionModel person,
    Map<int, List<DetectionModel>> history,
    int currentFrame,
  ) {
    // Implementar tracking simple basado en IoU
    String bestMatch = 'person_${DateTime.now().millisecondsSinceEpoch}';
    double maxIoU = 0.3; // Umbral mínimo

    // Buscar en frames anteriores
    for (int i = 1; i <= 5; i++) {
      final prevFrame = history[currentFrame - i];
      if (prevFrame == null) continue;

      for (var prevPerson in prevFrame) {
        if (prevPerson.label != 'person') continue;

        double iou = _calculateIoU(person.boundingBox, prevPerson.boundingBox);
        if (iou > maxIoU) {
          maxIoU = iou;
          bestMatch = 'person_${prevPerson.hashCode}';
        }
      }
    }

    return bestMatch;
  }

  void _updatePersonHistory(String personId, DetectionModel detection) {
    // Actualizar historial de detecciones
    _personHistory.putIfAbsent(personId, () => []);
    _personHistory[personId]!.add(detection);

    // Limitar tamaño del historial
    if (_personHistory[personId]!.length > 30) {
      _personHistory[personId]!.removeAt(0);
    }

    // Actualizar historial de movimiento
    final center = Point(
      detection.boundingBox.x + detection.boundingBox.width / 2,
      detection.boundingBox.y + detection.boundingBox.height / 2,
    );

    _movementHistory.putIfAbsent(personId, () => []);
    _movementHistory[personId]!.add(center);

    if (_movementHistory[personId]!.length > 30) {
      _movementHistory[personId]!.removeAt(0);
    }

    // Calcular velocidad
    if (_movementHistory[personId]!.length >= 2) {
      final lastTwo = _movementHistory[personId]!
          .skip(_movementHistory[personId]!.length - 2)
          .toList();

      final velocity = _calculateVelocity(lastTwo[0], lastTwo[1]);

      _velocityHistory.putIfAbsent(personId, () => []);
      _velocityHistory[personId]!.add(velocity);

      if (_velocityHistory[personId]!.length > 30) {
        _velocityHistory[personId]!.removeAt(0);
      }
    }
  }

  Map<String, double> _calculateMovementMetrics(String personId) {
    final movements = _movementHistory[personId] ?? [];
    final velocities = _velocityHistory[personId] ?? [];

    if (movements.length < 5 || velocities.isEmpty) {
      return {
        'stability': 1.0,
        'avgVelocity': 0.0,
        'maxVelocity': 0.0,
        'jerkiness': 0.0,
        'pathDeviation': 0.0,
      };
    }

    // Calcular estabilidad (desviación estándar de posiciones)
    final stability = _calculateStability(movements);

    // Velocidad promedio y máxima
    final avgVelocity = velocities.reduce((a, b) => a + b) / velocities.length;
    final maxVelocity = velocities.reduce(max);

    // Jerkiness (cambios bruscos de dirección)
    final jerkiness = _calculateJerkiness(movements);

    // Desviación del camino (cuán errático es el movimiento)
    final pathDeviation = _calculatePathDeviation(movements);

    return {
      'stability': stability,
      'avgVelocity': avgVelocity,
      'maxVelocity': maxVelocity,
      'jerkiness': jerkiness,
      'pathDeviation': pathDeviation,
    };
  }

  Future<BehaviorModel?> _detectBehavior(
    String personId,
    Map<String, double> movement,
    Uint8List frameData,
    DetectionModel person,
  ) async {
    // Detectar caída
    if (_detectFall(personId, person)) {
      return BehaviorModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: BehaviorType.fall,
        confidence: 0.9,
        startTime: DateTime.now(),
        involvedPersonIds: [personId],
        metadata: movement,
        severity: SeverityLevel.high,
      );
    }

    // Detectar intoxicación
    final intoxicationScore = _detectIntoxication(movement);
    if (intoxicationScore > INTOXICATION_THRESHOLD) {
      return BehaviorModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: BehaviorType.intoxication,
        confidence: intoxicationScore,
        startTime: DateTime.now(),
        involvedPersonIds: [personId],
        metadata: movement,
        severity: _getSeverityLevel(intoxicationScore),
      );
    }

    // Detectar comportamiento sospechoso
    final suspiciousScore = _detectSuspicious(movement, personId);
    if (suspiciousScore > THEFT_THRESHOLD) {
      return BehaviorModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: BehaviorType.suspicious,
        confidence: suspiciousScore,
        startTime: DateTime.now(),
        involvedPersonIds: [personId],
        metadata: movement,
        severity: _getSeverityLevel(suspiciousScore),
      );
    }

    return null;
  }

  bool _detectFall(String personId, DetectionModel person) {
    final history = _personHistory[personId] ?? [];
    if (history.length < 5) return false;

    // Detectar cambio rápido en altura del bounding box
    final recentBoxes = history.skip(history.length - 5).toList();
    final heights = recentBoxes.map((d) => d.boundingBox.height).toList();

    // Si la altura se reduce más del 40% rápidamente, posible caída
    final initialHeight = heights.first;
    final finalHeight = heights.last;

    if (initialHeight > 0 && finalHeight / initialHeight < 0.6) {
      // Verificar que el centro se movió hacia abajo
      final initialY = recentBoxes.first.boundingBox.y;
      final finalY = recentBoxes.last.boundingBox.y;

      return finalY > initialY + (initialHeight * 0.3);
    }

    return false;
  }

  double _detectIntoxication(Map<String, double> movement) {
    // Análisis basado en métricas de movimiento
    double score = 0.0;

    // Alta inestabilidad
    if (movement['stability']! < 0.3) {
      score += 0.3;
    }

    // Movimiento errático
    if (movement['jerkiness']! > 0.7) {
      score += 0.3;
    }

    // Desviación alta del camino
    if (movement['pathDeviation']! > 0.6) {
      score += 0.2;
    }

    // Velocidad variable
    if (movement['avgVelocity']! > 0 &&
        movement['maxVelocity']! / movement['avgVelocity']! > 2.5) {
      score += 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  double _detectSuspicious(Map<String, double> movement, String personId) {
    double score = 0.0;

    // Movimientos furtivos (velocidad baja pero cambios de dirección)
    if (movement['avgVelocity']! < 0.3 && movement['jerkiness']! > 0.5) {
      score += 0.4;
    }

    // Patrón de merodeo (mucho movimiento sin dirección clara)
    if (movement['pathDeviation']! > 0.7) {
      score += 0.3;
    }

    // Cambios repentinos de velocidad
    final velocities = _velocityHistory[personId] ?? [];
    if (velocities.length > 10) {
      final recentVelocities = velocities.skip(velocities.length - 10).toList();
      final velocityVariance = _calculateVariance(recentVelocities);

      if (velocityVariance > 0.5) {
        score += 0.3;
      }
    }

    return score.clamp(0.0, 1.0);
  }

  BehaviorModel? _analyzeInteractions(List<DetectionModel> persons) {
    if (persons.length < 2) return null;

    // Calcular distancias entre personas
    for (int i = 0; i < persons.length - 1; i++) {
      for (int j = i + 1; j < persons.length; j++) {
        final distance = _calculateDistance(
          persons[i].boundingBox,
          persons[j].boundingBox,
        );

        // Si están muy cerca, posible interacción
        if (distance < 100) {
          // pixels
          // Analizar tipo de interacción basado en velocidades y movimientos
          // Por ahora, retornamos null
          // En implementación completa, analizar patrones de violencia
        }
      }
    }

    return null;
  }

  // Métodos auxiliares de cálculo
  double _calculateIoU(BoundingBox box1, BoundingBox box2) {
    double x1 = max(box1.x, box2.x);
    double y1 = max(box1.y, box2.y);
    double x2 = min(box1.x + box1.width, box2.x + box2.width);
    double y2 = min(box1.y + box1.height, box2.y + box2.height);

    if (x2 < x1 || y2 < y1) return 0.0;

    double intersection = (x2 - x1) * (y2 - y1);
    double union =
        box1.width * box1.height + box2.width * box2.height - intersection;

    return intersection / union;
  }

  double _calculateVelocity(Point<double> p1, Point<double> p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
  }

  double _calculateStability(List<Point<double>> points) {
    if (points.isEmpty) return 1.0;

    // Calcular centro promedio
    double avgX =
        points.map((p) => p.x).reduce((a, b) => a + b) / points.length;
    double avgY =
        points.map((p) => p.y).reduce((a, b) => a + b) / points.length;

    // Calcular desviación estándar
    double variance = 0;
    for (var point in points) {
      variance += pow(point.x - avgX, 2) + pow(point.y - avgY, 2);
    }

    double stdDev = sqrt(variance / points.length);

    // Normalizar (invertir para que mayor estabilidad = valor más alto)
    return 1.0 / (1.0 + stdDev / 100);
  }

  double _calculateJerkiness(List<Point<double>> points) {
    if (points.length < 3) return 0.0;

    double totalAngleChange = 0;

    for (int i = 1; i < points.length - 1; i++) {
      final angle1 = atan2(
        points[i].y - points[i - 1].y,
        points[i].x - points[i - 1].x,
      );
      final angle2 = atan2(
        points[i + 1].y - points[i].y,
        points[i + 1].x - points[i].x,
      );

      double angleDiff = (angle2 - angle1).abs();
      if (angleDiff > pi) angleDiff = 2 * pi - angleDiff;
      totalAngleChange += angleDiff;
    }

    // Normalizar por número de cambios
    return (totalAngleChange / (points.length - 2)) / pi;
  }

  double _calculatePathDeviation(List<Point<double>> points) {
    if (points.length < 2) return 0.0;

    // Calcular línea directa desde inicio a fin
    final start = points.first;
    final end = points.last;
    final directDistance = _calculatePointDistance(start, end);

    if (directDistance == 0) return 0.0;

    // Calcular distancia total recorrida
    double totalDistance = 0;
    for (int i = 1; i < points.length; i++) {
      totalDistance += _calculatePointDistance(points[i - 1], points[i]);
    }

    // Ratio de desviación
    return (totalDistance / directDistance - 1.0).clamp(0.0, 1.0);
  }

  double _calculatePointDistance(Point<double> p1, Point<double> p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
  }

  double _calculateDistance(BoundingBox box1, BoundingBox box2) {
    final center1 = Point(
      box1.x + box1.width / 2,
      box1.y + box1.height / 2,
    );
    final center2 = Point(
      box2.x + box2.width / 2,
      box2.y + box2.height / 2,
    );

    return _calculatePointDistance(center1, center2);
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;

    double mean = values.reduce((a, b) => a + b) / values.length;
    double variance = 0;

    for (var value in values) {
      variance += pow(value - mean, 2);
    }

    return variance / values.length;
  }

  SeverityLevel _getSeverityLevel(double confidence) {
    if (confidence > 0.9) return SeverityLevel.critical;
    if (confidence > 0.75) return SeverityLevel.high;
    if (confidence > 0.5) return SeverityLevel.medium;
    return SeverityLevel.low;
  }

  void clearHistory() {
    _personHistory.clear();
    _movementHistory.clear();
    _velocityHistory.clear();
  }
}
