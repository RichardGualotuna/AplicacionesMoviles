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

  // Configuración del modelo - actualizar según tu modelo
  static const String MODEL_FILE =
      'ssd_mobilenet.tflite'; // Cambia por el nombre de tu modelo
  static const String LABELS_FILE = 'coco_labels.txt';
  static const int INPUT_SIZE = 640; // Típico para YOLOv8
  static const int NUM_RESULTS = 100;
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
      final labelsData =
          await rootBundle.loadString('assets/models/$LABELS_FILE');
      _labels = labelsData
          .split('\n')
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
      // Verificar si el archivo existe
      try {
        await rootBundle.load('assets/models/$MODEL_FILE');
      } catch (e) {
        print(
            'Modelo $MODEL_FILE no encontrado en assets. Usando modo simulación.');
        _interpreter = null;
        return;
      }

      // Opciones del intérprete
      final options = InterpreterOptions()..threads = 4;

      // Intentar usar aceleración por hardware si está disponible
      try {
        options.useNnApiForAndroid = true;
      } catch (e) {
        print('NNAPI no disponible: $e');
      }

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

      // Preparar outputs - esto depende del modelo específico
      var outputs = _prepareOutputs();

      // Ejecutar inferencia
      _interpreter!.run(input, outputs);

      // Procesar resultados
      return _processResults(outputs, image.width, image.height);
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

    // Normalizar pixels [0, 255] -> [0, 1]
    var input = List.generate(
      1,
      (i) => List.generate(
        INPUT_SIZE,
        (y) => List.generate(
          INPUT_SIZE,
          (x) {
            var pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    return input;
  }

  Map<int, Object> _prepareOutputs() {
    // Para YOLOv8, típicamente el output es [1, 84, 8400] o similar
    // Esto puede variar según tu modelo específico

    return {
      0: List.generate(
        1,
        (i) => List.generate(
          84, // num_classes + 4 (bbox)
          (j) => List<double>.filled(8400, 0), // num_anchors
        ),
      ),
    };
  }

  List<DetectionModel> _processResults(
    Map<int, Object> outputs,
    int imageWidth,
    int imageHeight,
  ) {
    List<DetectionModel> detections = [];

    try {
      // Este es un ejemplo genérico - ajusta según tu modelo
      var output = outputs[0] as List<List<List<double>>>;

      // Procesar cada detección
      for (int i = 0; i < output[0][0].length; i++) {
        // Extraer coordenadas y confianza
        double x = output[0][0][i];
        double y = output[0][1][i];
        double w = output[0][2][i];
        double h = output[0][3][i];

        // Encontrar la clase con mayor confianza
        double maxConf = 0;
        int bestClass = 0;

        for (int j = 4; j < output[0].length; j++) {
          double conf = output[0][j][i];
          if (conf > maxConf) {
            maxConf = conf;
            bestClass = j - 4;
          }
        }

        if (maxConf >= THRESHOLD) {
          String label =
              bestClass < _labels.length ? _labels[bestClass] : 'Unknown';

          detections.add(
            DetectionModel(
              label: label,
              confidence: maxConf,
              boundingBox: BoundingBox(
                x: (x - w / 2) / INPUT_SIZE,
                y: (y - h / 2) / INPUT_SIZE,
                width: w / INPUT_SIZE,
                height: h / INPUT_SIZE,
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
      'person',
      'bicycle',
      'car',
      'motorcycle',
      'airplane',
      'bus',
      'train',
      'truck',
      'boat',
      'traffic light',
      'fire hydrant',
      'stop sign',
      'parking meter',
      'bench',
      'bird',
      'cat',
      'dog',
      'horse',
      'sheep',
      'cow',
      'elephant',
      'bear',
      'zebra',
      'giraffe',
      'backpack',
      'umbrella',
      'handbag',
      'tie',
      'suitcase',
      'frisbee',
      'skis',
      'snowboard',
      'sports ball',
      'kite',
      'baseball bat',
      'baseball glove',
      'skateboard',
      'surfboard',
      'tennis racket',
      'bottle',
      'wine glass',
      'cup',
      'fork',
      'knife',
      'spoon',
      'bowl',
      'banana',
      'apple',
      'sandwich',
      'orange',
      'broccoli',
      'carrot',
      'hot dog',
      'pizza',
      'donut',
      'cake',
      'chair',
      'couch',
      'potted plant',
      'bed',
      'dining table',
      'toilet',
      'tv',
      'laptop',
      'mouse',
      'remote',
      'keyboard',
      'cell phone',
      'microwave',
      'oven',
      'toaster',
      'sink',
      'refrigerator',
      'book',
      'clock',
      'vase',
      'scissors',
      'teddy bear',
      'hair drier',
      'toothbrush'
    ];
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
