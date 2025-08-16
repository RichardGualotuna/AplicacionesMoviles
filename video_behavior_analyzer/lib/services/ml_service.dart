// services/ml_service.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/detection_model.dart';

class MLService {
  static MLService? _instance;
  Interpreter? _yoloInterpreter;
  Interpreter? _behaviorInterpreter;
  
  List<String> _labels = [];
  bool _isInitialized = false;

  // Singleton
  static MLService get instance {
    _instance ??= MLService._();
    return _instance!;
  }

  MLService._();

  // Inicializar modelos
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Cargar modelo YOLOv8
      await _loadYoloModel();
      
      // Cargar modelo de comportamiento
      await _loadBehaviorModel();
      
      // Cargar etiquetas
      await _loadLabels();
      
      _isInitialized = true;
      print('ML Service initialized successfully');
    } catch (e) {
      print('Error initializing ML Service: $e');
      throw Exception('Failed to initialize ML models');
    }
  }

  Future<void> _loadYoloModel() async {
    try {
      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = true;
      
      _yoloInterpreter = await Interpreter.fromAsset(
        'assets/models/yolov8n.tflite',
        options: options,
      );
      
      print('YOLOv8 model loaded successfully');
    } catch (e) {
      print('Error loading YOLO model: $e');
      rethrow;
    }
  }

  Future<void> _loadBehaviorModel() async {
    try {
      final options = InterpreterOptions()
        ..threads = 2;
      
      _behaviorInterpreter = await Interpreter.fromAsset(
        'assets/models/behavior_model.tflite',
        options: options,
      );
      
      print('Behavior model loaded successfully');
    } catch (e) {
      print('Error loading behavior model: $e');
      rethrow;
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelsData = await File('assets/models/labels.txt').readAsString();
      _labels = labelsData.split('\n').where((label) => label.isNotEmpty).toList();
    } catch (e) {
      // Labels por defecto si no se puede cargar el archivo
      _labels = [
        'person', 'bicycle', 'car', 'motorcycle', 'airplane',
        'bus', 'train', 'truck', 'boat', 'traffic light',
        'fire hydrant', 'stop sign', 'parking meter', 'bench',
        'bird', 'cat', 'dog', 'horse', 'sheep', 'cow',
        'elephant', 'bear', 'zebra', 'giraffe', 'backpack',
        'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee',
        'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat',
        'baseball glove', 'skateboard', 'surfboard', 'tennis racket',
        'bottle', 'wine glass', 'cup', 'fork', 'knife',
        'spoon', 'bowl', 'banana', 'apple', 'sandwich',
        'orange', 'broccoli', 'carrot', 'hot dog', 'pizza',
        'donut', 'cake', 'chair', 'couch', 'potted plant',
        'bed', 'dining table', 'toilet', 'tv', 'laptop',
        'mouse', 'remote', 'keyboard', 'cell phone', 'microwave',
        'oven', 'toaster', 'sink', 'refrigerator', 'book',
        'clock', 'vase', 'scissors', 'teddy bear', 'hair drier',
        'toothbrush'
      ];
    }
  }

  // Procesar frame para detección de objetos
  Future<List<DetectionModel>> detectObjects(Uint8List imageBytes) async {
    if (!_isInitialized || _yoloInterpreter == null) {
      throw Exception('ML Service not initialized');
    }

    try {
      // Decodificar imagen
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Failed to decode image');

      // Redimensionar a 640x640 (tamaño estándar YOLOv8)
      img.Image resized = img.copyResize(image, width: 640, height: 640);

      // Preprocesar imagen
      var input = _preprocessImage(resized);

      // Preparar output
      var output = List.generate(
        1,
        (index) => List.generate(
          25200, // Número de predicciones
          (index) => List.filled(85, 0.0), // 80 clases + 4 bbox + 1 conf
        ),
      );

      // Ejecutar inferencia
      _yoloInterpreter!.run(input, output);

      // Procesar resultados
      return _processYoloOutput(output[0], image.width, image.height);
    } catch (e) {
      print('Error in object detection: $e');
      return [];
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    var input = List.generate(
      1,
      (b) => List.generate(
        640,
        (y) => List.generate(
          640,
          (x) => List.generate(3, (c) {
            var pixel = image.getPixel(x, y);
            switch (c) {
              case 0:
                return pixel.r / 255.0;
              case 1:
                return pixel.g / 255.0;
              case 2:
                return pixel.b / 255.0;
              default:
                return 0.0;
            }
          }),
        ),
      ),
    );
    return input;
  }

  List<DetectionModel> _processYoloOutput(
    List<List<double>> output,
    int originalWidth,
    int originalHeight,
  ) {
    List<DetectionModel> detections = [];
    final threshold = 0.5; // Umbral de confianza
    final nmsThreshold = 0.4; // Non-Maximum Suppression

    for (var detection in output) {
      double confidence = detection[4];
      
      if (confidence > threshold) {
        // Obtener clase con mayor probabilidad
        int classId = 0;
        double maxClassProb = 0;
        
        for (int i = 5; i < 85; i++) {
          if (detection[i] > maxClassProb) {
            maxClassProb = detection[i];
            classId = i - 5;
          }
        }

        if (maxClassProb > threshold) {
          // Convertir coordenadas
          double centerX = detection[0] * originalWidth / 640;
          double centerY = detection[1] * originalHeight / 640;
          double width = detection[2] * originalWidth / 640;
          double height = detection[3] * originalHeight / 640;

          detections.add(
            DetectionModel(
              label: classId < _labels.length ? _labels[classId] : 'unknown',
              confidence: confidence * maxClassProb,
              boundingBox: BoundingBox(
                x: centerX - width / 2,
                y: centerY - height / 2,
                width: width,
                height: height,
              ),
              frameNumber: 0,
              timestamp: DateTime.now(),
            ),
          );
        }
      }
    }

    // Aplicar NMS
    return _applyNMS(detections, nmsThreshold);
  }

  List<DetectionModel> _applyNMS(List<DetectionModel> detections, double threshold) {
    if (detections.isEmpty) return [];

    // Ordenar por confianza
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    List<DetectionModel> result = [];
    List<bool> suppressed = List.filled(detections.length, false);

    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;

      result.add(detections[i]);

      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;

        double iou = _calculateIoU(
          detections[i].boundingBox,
          detections[j].boundingBox,
        );

        if (iou > threshold && detections[i].label == detections[j].label) {
          suppressed[j] = true;
        }
      }
    }

    return result;
  }

  double _calculateIoU(BoundingBox box1, BoundingBox box2) {
    double x1 = box1.x.clamp(box2.x, box2.x + box2.width);
    double y1 = box1.y.clamp(box2.y, box2.y + box2.height);
    double x2 = (box1.x + box1.width).clamp(box2.x, box2.x + box2.width);
    double y2 = (box1.y + box1.height).clamp(box2.y, box2.y + box2.height);

    double intersectionArea = (x2 - x1).clamp(0, double.infinity) * 
                             (y2 - y1).clamp(0, double.infinity);

    double box1Area = box1.width * box1.height;
    double box2Area = box2.width * box2.height;

    double unionArea = box1Area + box2Area - intersectionArea;

    return unionArea > 0 ? intersectionArea / unionArea : 0;
  }

  // Analizar poses para detección de comportamiento
  Future<Map<String, double>> analyzePose(List<List<double>> keypoints) async {
    if (!_isInitialized || _behaviorInterpreter == null) {
      throw Exception('Behavior model not initialized');
    }

    try {
      // Normalizar keypoints
      var input = _normalizeKeypoints(keypoints);

      // Preparar output [1, 7] para 7 tipos de comportamiento
      var output = List.filled(1, List.filled(7, 0.0));

      // Ejecutar inferencia
      _behaviorInterpreter!.run([input], output);

      // Mapear resultados a comportamientos
      return {
        'normal': output[0][0],
        'intoxication': output[0][1],
        'violence': output[0][2],
        'theft': output[0][3],
        'suspicious': output[0][4],
        'fall': output[0][5],
        'aggression': output[0][6],
      };
    } catch (e) {
      print('Error analyzing pose: $e');
      return {'normal': 1.0};
    }
  }

  List<double> _normalizeKeypoints(List<List<double>> keypoints) {
    List<double> normalized = [];
    
    for (var point in keypoints) {
      // Normalizar coordenadas entre 0 y 1
      normalized.add(point[0] / 640); // x
      normalized.add(point[1] / 640); // y
      normalized.add(point[2]); // confidence
    }
    
    // Padding si es necesario (17 keypoints * 3 valores = 51)
    while (normalized.length < 51) {
      normalized.add(0.0);
    }
    
    return normalized;
  }

  void dispose() {
    _yoloInterpreter?.close();
    _behaviorInterpreter?.close();
    _isInitialized = false;
  }
}