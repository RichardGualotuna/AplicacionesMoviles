// services/ml_service.dart
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/detection_model.dart';

class MLService {
  static MLService? _instance;
  List<String> _labels = [];
  bool _isInitialized = false;
  final Random _random = Random();

  static MLService get instance {
    _instance ??= MLService._();
    return _instance!;
  }

  MLService._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Inicializando ML Service...');
      
      // Cargar labels
      try {
        final labelsData = await rootBundle.loadString('assets/models/labels.txt');
        _labels = labelsData.split('\n').where((label) => label.isNotEmpty).toList();
        print('Labels cargados: ${_labels.length}');
      } catch (e) {
        print('Usando labels por defecto');
        _labels = [
          'person', 'car', 'bicycle', 'dog', 'cat',
          'bottle', 'chair', 'laptop', 'cell phone', 'backpack'
        ];
      }
      
      // Simular carga de modelos
      await Future.delayed(const Duration(milliseconds: 500));
      
      _isInitialized = true;
      print('ML Service inicializado correctamente (modo simulación)');
      
    } catch (e) {
      print('Error en ML Service: $e');
      _isInitialized = true; // Permitir que funcione igual
    }
  }

  Future<List<DetectionModel>> detectObjects(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Simular procesamiento
    await Future.delayed(const Duration(milliseconds: 50));
    
    List<DetectionModel> detections = [];
    
    // 70% de probabilidad de detectar una persona
    if (_random.nextDouble() > 0.3) {
      detections.add(
        DetectionModel(
          label: 'person',
          confidence: 0.75 + _random.nextDouble() * 0.25,
          boundingBox: BoundingBox(
            x: 0.3 + _random.nextDouble() * 0.4,
            y: 0.2 + _random.nextDouble() * 0.3,
            width: 0.15 + _random.nextDouble() * 0.15,
            height: 0.3 + _random.nextDouble() * 0.2,
          ),
          frameNumber: 0,
          timestamp: DateTime.now(),
        ),
      );
    }
    
    // Ocasionalmente detectar otros objetos
    if (_random.nextDouble() > 0.7) {
      String randomLabel = _labels[_random.nextInt(_labels.length)];
      detections.add(
        DetectionModel(
          label: randomLabel,
          confidence: 0.6 + _random.nextDouble() * 0.4,
          boundingBox: BoundingBox(
            x: _random.nextDouble() * 0.7,
            y: _random.nextDouble() * 0.7,
            width: 0.1 + _random.nextDouble() * 0.1,
            height: 0.1 + _random.nextDouble() * 0.1,
          ),
          frameNumber: 0,
          timestamp: DateTime.now(),
        ),
      );
    }
    
    return detections;
  }

  Future<Map<String, double>> analyzePose(List<List<double>> keypoints) async {
    if (!_isInitialized) {
      await initialize();
    }

    await Future.delayed(const Duration(milliseconds: 30));
    
    // Generar comportamientos aleatorios para demostración
    double normal = 0.6 + _random.nextDouble() * 0.3;
    double remaining = 1.0 - normal;
    
    return {
      'normal': normal,
      'intoxication': remaining * 0.3,
      'violence': remaining * 0.1,
      'theft': remaining * 0.1,
      'suspicious': remaining * 0.3,
      'fall': remaining * 0.1,
      'aggression': remaining * 0.1,
    };
  }

  void dispose() {
    _isInitialized = false;
  }
}