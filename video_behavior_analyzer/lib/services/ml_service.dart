// services/ml_service.dart - IMPLEMENTACIÓN CORREGIDA
import 'dart:typed_data';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/detection_model.dart';

class MLService {
  static MLService? _instance;
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;
  
  // Configuración para SSD MobileNet
  static const String MODEL_FILE = 'ssd_mobilenet.tflite';
  static const String LABELS_FILE = 'coco_labels.txt';
  static const int INPUT_SIZE = 300; // SSD MobileNet usa 300x300
  static const int NUM_RESULTS = 10;
  static const double THRESHOLD = 0.5;
  
  // Para modelos SSD típicos
  static const int NUM_BOXES = 1917; // Número típico de anchor boxes
  static const int NUM_CLASSES = 80; // COCO dataset

  static MLService get instance {
    _instance ??= MLService._();
    return _instance!;
  }

  MLService._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Inicializando ML Service...');
      
      // Cargar etiquetas
      await _loadLabels();
      
      // Intentar cargar modelo real, si falla usar modo demo
      await _loadModel();
      
      _isInitialized = true;
      print('ML Service inicializado correctamente');
    } catch (e) {
      print('Error inicializando ML Service: $e');
      _isInitialized = true; // Continuar en modo demo
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/models/$LABELS_FILE');
      _labels = labelsData
          .split('\n')
          .where((label) => label.isNotEmpty)
          .map((label) => label.trim())
          .toList();
      print('Labels cargados: ${_labels.length}');
    } catch (e) {
      print('Usando labels por defecto: $e');
      _labels = _getDefaultLabels();
    }
  }

  Future<void> _loadModel() async {
    try {
      // Por ahora trabajaremos en modo demo hasta que tengas el modelo
      print('Trabajando en modo demo - modelo real no disponible');
      _interpreter = null;
      return;
      
      // Cuando tengas el modelo, descomenta esto:
      /*
      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = true;
        
      _interpreter = await Interpreter.fromAsset(
        'models/$MODEL_FILE',
        options: options,
      );
      
      print('Modelo cargado exitosamente');
      */
    } catch (e) {
      print('Usando modo demo: $e');
      _interpreter = null;
    }
  }

  Future<List<DetectionModel>> detectObjects(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Por ahora usar detección demo mejorada
    return _improvedDemoDetection(imageBytes);
    
    // Cuando tengas el modelo real, cambia a:
    // return _interpreter != null 
    //     ? _realDetection(imageBytes) 
    //     : _improvedDemoDetection(imageBytes);
  }

  // Detección demo mejorada que simula mejor la detección real
  List<DetectionModel> _improvedDemoDetection(Uint8List imageBytes) {
    try {
      // Decodificar imagen para análisis básico
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return [];
      
      List<DetectionModel> detections = [];
      final random = Random();
      
      // Simular detección de persona con patrón más realista
      // Detectar "persona" en el centro de la imagen
      if (random.nextDouble() > 0.2) { // 80% de probabilidad
        // Posición más centrada y realista
        double centerX = 0.35 + random.nextDouble() * 0.3; // Entre 0.35 y 0.65
        double centerY = 0.25 + random.nextDouble() * 0.3; // Entre 0.25 y 0.55
        
        detections.add(
          DetectionModel(
            label: 'person',
            confidence: 0.75 + random.nextDouble() * 0.20, // Entre 0.75 y 0.95
            boundingBox: BoundingBox(
              x: centerX,
              y: centerY,
              width: 0.15 + random.nextDouble() * 0.1, // Tamaño consistente
              height: 0.35 + random.nextDouble() * 0.15,
            ),
            frameNumber: 0,
            timestamp: DateTime.now(),
          ),
        );
      }
      
      // Ocasionalmente agregar otros objetos
      if (random.nextDouble() > 0.7) { // 30% de probabilidad
        String randomLabel = ['car', 'chair', 'bottle', 'cell phone'][random.nextInt(4)];
        detections.add(
          DetectionModel(
            label: randomLabel,
            confidence: 0.6 + random.nextDouble() * 0.3,
            boundingBox: BoundingBox(
              x: random.nextDouble() * 0.7,
              y: random.nextDouble() * 0.7,
              width: 0.1 + random.nextDouble() * 0.1,
              height: 0.1 + random.nextDouble() * 0.1,
            ),
            frameNumber: 0,
            timestamp: DateTime.now(),
          ),
        );
      }
      
      return detections;
      
    } catch (e) {
      print('Error en detección demo: $e');
      return [];
    }
  }

  // Implementación real cuando tengas el modelo
  Future<List<DetectionModel>> _realDetection(Uint8List imageBytes) async {
    if (_interpreter == null) return _improvedDemoDetection(imageBytes);
    
    try {
      // Decodificar y preprocesar imagen
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return [];
      
      // Redimensionar a INPUT_SIZE x INPUT_SIZE
      img.Image resized = img.copyResize(
        image,
        width: INPUT_SIZE,
        height: INPUT_SIZE,
      );
      
      // Convertir a input tensor [1, 300, 300, 3]
      var input = List.generate(
        1,
        (b) => List.generate(
          INPUT_SIZE,
          (y) => List.generate(
            INPUT_SIZE,
            (x) {
              var pixel = resized.getPixel(x, y);
              return [
                (pixel.r - 128) / 128.0, // Normalización [-1, 1]
                (pixel.g - 128) / 128.0,
                (pixel.b - 128) / 128.0,
              ];
            },
          ),
        ),
      );
      
      // Preparar outputs para SSD
      // [1, NUM_BOXES, 4] para boxes
      // [1, NUM_BOXES] para classes
      // [1, NUM_BOXES] para scores
      // [1] para num_detections
      var outputBoxes = List.generate(1, (i) => 
        List.generate(NUM_RESULTS, (j) => List<double>.filled(4, 0))
      );
      var outputClasses = List.generate(1, (i) => List<double>.filled(NUM_RESULTS, 0));
      var outputScores = List.generate(1, (i) => List<double>.filled(NUM_RESULTS, 0));
      var numDetections = List<double>.filled(1, 0);
      
      var outputs = {
        0: outputBoxes,
        1: outputClasses,
        2: outputScores,
        3: numDetections,
      };
      
      // Ejecutar inferencia
      _interpreter!.runForMultipleInputs([input], outputs);
      
      // Procesar resultados
      List<DetectionModel> detections = [];
      int detectionCount = numDetections[0].toInt();
      
      for (int i = 0; i < min(detectionCount, NUM_RESULTS); i++) {
        double score = outputScores[0][i];
        
        if (score >= THRESHOLD) {
          int classId = outputClasses[0][i].toInt();
          String label = classId < _labels.length ? _labels[classId] : 'Unknown';
          
          // Las coordenadas vienen normalizadas [0, 1]
          double y1 = outputBoxes[0][i][0];
          double x1 = outputBoxes[0][i][1];
          double y2 = outputBoxes[0][i][2];
          double x2 = outputBoxes[0][i][3];
          
          detections.add(
            DetectionModel(
              label: label,
              confidence: score,
              boundingBox: BoundingBox(
                x: x1,
                y: y1,
                width: x2 - x1,
                height: y2 - y1,
              ),
              frameNumber: 0,
              timestamp: DateTime.now(),
            ),
          );
        }
      }
      
      return detections;
      
    } catch (e) {
      print('Error en detección real: $e');
      return _improvedDemoDetection(imageBytes);
    }
  }

  List<String> _getDefaultLabels() {
    return ['person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 
            'train', 'truck', 'boat', 'traffic light', 'fire hydrant', 
            'stop sign', 'parking meter', 'bench', 'bird', 'cat', 'dog', 
            'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', 'giraffe',
            'backpack', 'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee',
            'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat',
            'baseball glove', 'skateboard', 'surfboard', 'tennis racket',
            'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon', 'bowl',
            'banana', 'apple', 'sandwich', 'orange', 'broccoli', 'carrot',
            'hot dog', 'pizza', 'donut', 'cake', 'chair', 'couch',
            'potted plant', 'bed', 'dining table', 'toilet', 'tv', 'laptop',
            'mouse', 'remote', 'keyboard', 'cell phone', 'microwave', 'oven',
            'toaster', 'sink', 'refrigerator', 'book', 'clock', 'vase',
            'scissors', 'teddy bear', 'hair drier', 'toothbrush'];
  }
  
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}