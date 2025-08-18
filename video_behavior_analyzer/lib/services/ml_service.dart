// services/ml_service.dart - VERSIÓN ESTABLE
import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;
import '../models/detection_model.dart';

class MLService {
  static MLService? _instance;
  bool _isInitialized = false;
  final Random _random = Random();
  
  // Para simular tracking consistente
  final Map<String, DetectionModel> _trackedObjects = {};
  
  static MLService get instance {
    _instance ??= MLService._();
    return _instance!;
  }

  MLService._();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    print('Inicializando ML Service (modo demo)...');
    _isInitialized = true;
    print('ML Service inicializado');
  }

  Future<List<DetectionModel>> detectObjects(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Simulación estable de detección
    return _stableSimulatedDetection();
  }

  List<DetectionModel> _stableSimulatedDetection() {
    List<DetectionModel> detections = [];
    
    // Mantener persona principal con movimiento suave
    if (!_trackedObjects.containsKey('person_main')) {
      _trackedObjects['person_main'] = DetectionModel(
        label: 'person',
        confidence: 0.85,
        boundingBox: BoundingBox(
          x: 0.4,
          y: 0.3,
          width: 0.2,
          height: 0.4,
        ),
        frameNumber: 0,
        timestamp: DateTime.now(),
      );
    }
    
    // Actualizar posición con pequeño movimiento
    var mainPerson = _trackedObjects['person_main']!;
    double newX = mainPerson.boundingBox.x + (_random.nextDouble() - 0.5) * 0.02;
    double newY = mainPerson.boundingBox.y + (_random.nextDouble() - 0.5) * 0.02;
    
    // Mantener dentro de límites
    newX = newX.clamp(0.1, 0.7);
    newY = newY.clamp(0.1, 0.5);
    
    // Actualizar detección
    _trackedObjects['person_main'] = DetectionModel(
      label: 'person',
      confidence: 0.80 + _random.nextDouble() * 0.15,
      boundingBox: BoundingBox(
        x: newX,
        y: newY,
        width: 0.2 + _random.nextDouble() * 0.05,
        height: 0.4 + _random.nextDouble() * 0.05,
      ),
      frameNumber: DateTime.now().millisecondsSinceEpoch,
      timestamp: DateTime.now(),
    );
    
    detections.add(_trackedObjects['person_main']!);
    
    // Ocasionalmente agregar otros objetos
    if (_random.nextDouble() > 0.7) {
      detections.add(
        DetectionModel(
          label: ['bottle', 'cell phone', 'chair', 'backpack'][_random.nextInt(4)],
          confidence: 0.6 + _random.nextDouble() * 0.3,
          boundingBox: BoundingBox(
            x: _random.nextDouble() * 0.6,
            y: 0.5 + _random.nextDouble() * 0.3,
            width: 0.1,
            height: 0.1,
          ),
          frameNumber: DateTime.now().millisecondsSinceEpoch,
          timestamp: DateTime.now(),
        ),
      );
    }
    
    return detections;
  }

  void dispose() {
    _trackedObjects.clear();
    _isInitialized = false;
  }
}