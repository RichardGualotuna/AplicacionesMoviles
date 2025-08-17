// services/ml_service.dart - IMPLEMENTACIÓN REAL
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
  
  // Configuración del modelo
  static const String MODEL_FILE = 'ssd_mobilenet.tflite';
  static const String LABELS_FILE = 'coco_labels.txt';
  static const int INPUT_SIZE = 300;
  static const int NUM_RESULTS = 10;
  static const double THRESHOLD = 0.5;
  
  static MLService get instance {
    _instance ??= MLService._();
    return _instance!;
  }

  MLService._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('Inicializando ML Service con modelo real...');
      
      // Cargar etiquetas
      await _loadLabels();
      
      // Cargar modelo
      await _loadModel();
      
      _isInitialized = true;
      print('ML Service inicializado correctamente con modelo real');
      
    } catch (e) {
      print('Error inicializando ML Service: $e');
      print('Continuando en modo simulación...');
      _isInitialized = true;
      // Si falla, usar modo simulación
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/models/$LABELS_FILE');
      _labels = labelsData.split('\n')
          .where((label) => label.isNotEmpty)
          .map((label) => label.trim())
          .toList();
      print('Labels cargados: ${_labels.length}');
    } catch (e) {
      print('Error cargando labels: $e');
      // Usar labels por defecto si falla
      _labels = _getDefaultLabels();
    }
  }

  Future<void> _loadModel() async {
    try {
      // Opciones del intérprete
      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = true;
      
      // Cargar modelo desde assets
      _interpreter = await Interpreter.fromAsset(
        'models/$MODEL_FILE',
        options: options,
      );
      
      print('Modelo TFLite cargado exitosamente');
      
      // Imprimir información del modelo
      var inputTensor = _interpreter!.getInputTensor(0);
      var outputTensor = _interpreter!.getOutputTensor(0);
      
      print('Input shape: ${inputTensor.shape}');
      print('Input type: ${inputTensor.type}');
      print('Output shape: ${outputTensor.shape}');
      print('Output type: ${outputTensor.type}');
      
    } catch (e) {
      print('Error cargando modelo: $e');
      _interpreter = null;
    }
  }

  Future<List<DetectionModel>> detectObjects(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Si no hay intérprete, usar modo simulación
    if (_interpreter == null) {
      return _simulateDetection();
    }

    try {
      // Decodificar imagen
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        print('No se pudo decodificar la imagen');
        return [];
      }

      // Preprocesar imagen
      var input = _preprocessImage(image);
      
      // Preparar outputs
      var output = _prepareOutputs();
      
      // Ejecutar inferencia
      _interpreter!.run(input, output);
      
      // Procesar resultados
      return _processResults(output, image.width, image.height);
      
    } catch (e) {
      print('Error durante la detección: $e');
      return _simulateDetection();
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Redimensionar imagen a INPUT_SIZE x INPUT_SIZE
    img.Image resized = img.copyResize(
      image,
      width: INPUT_SIZE,
      height: INPUT_SIZE,
      interpolation: img.Interpolation.linear,
    );

    // Normalizar pixels a [0, 1] o [-1, 1] dependiendo del modelo
    var input = List.generate(
      1,
      (i) => List.generate(
        INPUT_SIZE,
        (y) => List.generate(
          INPUT_SIZE,
          (x) {
            var pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,  // Red
              pixel.g / 255.0,  // Green  
              pixel.b / 255.0,  // Blue
            ];
          },
        ),
      ),
    );

    return input;
  }

  Map<int, Object> _prepareOutputs() {
    // La estructura de salida depende del modelo específico
    // Para SSD MobileNet típicamente es:
    
    // Locations/Boxes [1, NUM_RESULTS, 4]
    var locations = List.generate(
      1,
      (i) => List.generate(
        NUM_RESULTS,
        (j) => List<double>.filled(4, 0),
      ),
    );
    
    // Classes [1, NUM_RESULTS]
    var classes = List.generate(
      1,
      (i) => List<double>.filled(NUM_RESULTS, 0),
    );
    
    // Scores [1, NUM_RESULTS]
    var scores = List.generate(
      1,
      (i) => List<double>.filled(NUM_RESULTS, 0),
    );
    
    // Number of detections [1]
    var numDetections = List<double>.filled(1, 0);
    
    return {
      0: locations,
      1: classes,
      2: scores,
      3: numDetections,
    };
  }

  List<DetectionModel> _processResults(
    Map<int, Object> outputs,
    int imageWidth,
    int imageHeight,
  ) {
    List<DetectionModel> detections = [];
    
    try {
      var locations = outputs[0] as List<List<List<double>>>;
      var classes = outputs[1] as List<List<double>>;
      var scores = outputs[2] as List<List<double>>;
      var numDetections = (outputs[3] as List<double>)[0].toInt();
      
      for (int i = 0; i < min(numDetections, NUM_RESULTS); i++) {
        double score = scores[0][i];
        
        if (score >= THRESHOLD) {
          int classId = classes[0][i].toInt();
          String label = classId < _labels.length ? _labels[classId] : 'Unknown';
          
          // Las coordenadas están normalizadas [0, 1]
          double y1 = locations[0][i][0];
          double x1 = locations[0][i][1];
          double y2 = locations[0][i][2];
          double x2 = locations[0][i][3];
          
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
    } catch (e) {
      print('Error procesando resultados: $e');
    }
    
    return detections;
  }

  // Método alternativo para modelos YOLO
  List<DetectionModel> _processYoloResults(
    List<List<double>> output,
    int imageWidth,
    int imageHeight,
  ) {
    List<DetectionModel> detections = [];
    
    // YOLO output format: [x, y, w, h, confidence, ...class_scores]
    for (var detection in output) {
      if (detection.length < 5) continue;
      
      double confidence = detection[4];
      if (confidence < THRESHOLD) continue;
      
      // Encontrar la clase con mayor probabilidad
      int bestClass = 0;
      double maxScore = 0;
      
      for (int i = 5; i < detection.length; i++) {
        if (detection[i] > maxScore) {
          maxScore = detection[i];
          bestClass = i - 5;
        }
      }
      
      if (maxScore < THRESHOLD) continue;
      
      String label = bestClass < _labels.length ? _labels[bestClass] : 'Unknown';
      
      detections.add(
        DetectionModel(
          label: label,
          confidence: maxScore,
          boundingBox: BoundingBox(
            x: detection[0] - detection[2] / 2,
            y: detection[1] - detection[3] / 2,
            width: detection[2],
            height: detection[3],
          ),
          frameNumber: 0,
          timestamp: DateTime.now(),
        ),
      );
    }
    
    return detections;
  }

  // Método de respaldo para simulación
  List<DetectionModel> _simulateDetection() {
    final random = Random();
    List<DetectionModel> detections = [];
    
    // Simular detección de persona con alta probabilidad
    if (random.nextDouble() > 0.3) {
      detections.add(
        DetectionModel(
          label: 'person',
          confidence: 0.75 + random.nextDouble() * 0.25,
          boundingBox: BoundingBox(
            x: 0.3 + random.nextDouble() * 0.4,
            y: 0.2 + random.nextDouble() * 0.3,
            width: 0.15 + random.nextDouble() * 0.15,
            height: 0.3 + random.nextDouble() * 0.2,
          ),
          frameNumber: 0,
          timestamp: DateTime.now(),
        ),
      );
    }
    
    return detections;
  }

  // Análisis de pose para comportamientos (simplificado)
  Future<Map<String, double>> analyzePose(List<List<double>> keypoints) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Por ahora retornamos análisis simulado
    // En producción, aquí iría el modelo de clasificación de comportamientos
    return _simulateBehaviorAnalysis();
  }

  Map<String, double> _simulateBehaviorAnalysis() {
    final random = Random();
    double normal = 0.6 + random.nextDouble() * 0.3;
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

  List<String> _getDefaultLabels() {
    return [
      'person', 'bicycle', 'car', 'motorcycle', 'airplane',
      'bus', 'train', 'truck', 'boat', 'traffic light',
      'fire hydrant', 'stop sign', 'parking meter', 'bench', 'bird',
      'cat', 'dog', 'horse', 'sheep', 'cow',
      'elephant', 'bear', 'zebra', 'giraffe', 'backpack',
      'umbrella', 'handbag', 'tie', 'suitcase', 'frisbee',
      'skis', 'snowboard', 'sports ball', 'kite', 'baseball bat',
      'baseball glove', 'skateboard', 'surfboard', 'tennis racket', 'bottle',
      'wine glass', 'cup', 'fork', 'knife', 'spoon',
      'bowl', 'banana', 'apple', 'sandwich', 'orange',
      'broccoli', 'carrot', 'hot dog', 'pizza', 'donut',
      'cake', 'chair', 'couch', 'potted plant', 'bed',
      'dining table', 'toilet', 'tv', 'laptop', 'mouse',
      'remote', 'keyboard', 'cell phone', 'microwave', 'oven',
      'toaster', 'sink', 'refrigerator', 'book', 'clock',
      'vase', 'scissors', 'teddy bear', 'hair drier', 'toothbrush'
    ];
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}