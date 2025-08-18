// controllers/camera_controller.dart - VERSIÓN CORREGIDA
import 'dart:io' show File;
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../services/ml_service.dart';
import '../models/detection_model.dart';
import '../models/behavior_model.dart';
import '../services/behavior_detection_service.dart';

class CameraControllerX extends GetxController {
  CameraController? cameraController;
  final MLService _mlService = MLService.instance;
  final BehaviorDetectionService _behaviorService = BehaviorDetectionService();
  
  // Estados observables
  final RxBool isInitialized = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isRealTimeAnalysis = false.obs;
  final Rx<FlashMode> flashMode = FlashMode.off.obs;
  final RxInt selectedCameraIndex = 0.obs;
  
  // Detecciones en tiempo real
  final RxList<DetectionModel> liveDetections = <DetectionModel>[].obs;
  final RxList<BehaviorModel> liveBehaviors = <BehaviorModel>[].obs;
  
  // Configuración
  final RxDouble detectionFPS = 2.0.obs; // Reducido para mejor rendimiento
  final RxBool showBoundingBoxes = true.obs;
  final RxBool enableAudioAlerts = true.obs;
  
  List<CameraDescription> cameras = [];
  String? recordingPath;
  DateTime? lastFrameTime;
  Timer? _analysisTimer;
  bool _isProcessingFrame = false;
  
  @override
  void onInit() async {
    super.onInit();
    await Future.delayed(const Duration(milliseconds: 100));
    await initializeCameras();
  }

  Future<void> initializeCameras() async {
    try {
      // Inicializar ML Service primero
      await _mlService.initialize();
      
      cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        Get.snackbar(
          'Error',
          'No se encontraron cámaras disponibles',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      await initializeCamera(selectedCameraIndex.value);
    } catch (e) {
      print('Error initializing cameras: $e');
      Get.snackbar(
        'Error',
        'No se pudieron inicializar las cámaras',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> initializeCamera(int cameraIndex) async {
    if (cameraIndex >= cameras.length) return;
    
    try {
      // Detener análisis si está activo
      stopRealTimeAnalysis();
      
      // Dispose del controller anterior si existe
      if (cameraController != null) {
        await cameraController!.dispose();
      }
      
      selectedCameraIndex.value = cameraIndex;
      
      cameraController = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.medium, // Reducido para mejor rendimiento
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await cameraController!.initialize();
      
      // Configurar flash
      await cameraController!.setFlashMode(flashMode.value);
      
      isInitialized.value = true;
      
      print('Cámara inicializada correctamente');
      
    } catch (e) {
      print('Error initializing camera: $e');
      isInitialized.value = false;
      Get.snackbar(
        'Error',
        'No se pudo inicializar la cámara',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Cambiar entre cámaras
  Future<void> switchCamera() async {
    if (cameras.length <= 1) return;
    
    final newIndex = (selectedCameraIndex.value + 1) % cameras.length;
    await initializeCamera(newIndex);
    
    // Reiniciar análisis si estaba activo
    if (isRealTimeAnalysis.value) {
      startRealTimeAnalysis();
    }
  }

  // Cambiar modo de flash
  Future<void> toggleFlash() async {
    if (cameraController == null) return;
    
    final modes = [FlashMode.off, FlashMode.auto, FlashMode.always];
    final currentIndex = modes.indexOf(flashMode.value);
    final newMode = modes[(currentIndex + 1) % modes.length];
    
    try {
      await cameraController!.setFlashMode(newMode);
      flashMode.value = newMode;
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  // Iniciar grabación
  Future<void> startRecording() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    
    if (isRecording.value) return;
    
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      recordingPath = '${directory.path}/video_$timestamp.mp4';
      
      await cameraController!.startVideoRecording();
      isRecording.value = true;
      
      Get.snackbar(
        'Grabación',
        'Grabación iniciada',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      
    } catch (e) {
      print('Error starting recording: $e');
      Get.snackbar(
        'Error',
        'No se pudo iniciar la grabación',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Detener grabación
  Future<File?> stopRecording() async {
    if (cameraController == null || !isRecording.value) {
      return null;
    }
    
    try {
      final video = await cameraController!.stopVideoRecording();
      isRecording.value = false;
      
      final videoFile = File(video.path);
      
      Get.snackbar(
        'Grabación',
        'Video guardado exitosamente',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      
      return videoFile;
      
    } catch (e) {
      print('Error stopping recording: $e');
      Get.snackbar(
        'Error',
        'No se pudo detener la grabación',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Tomar foto
  Future<File?> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return null;
    }
    
    if (isRecording.value) {
      Get.snackbar(
        'Atención',
        'No se pueden tomar fotos durante la grabación',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
    
    try {
      final image = await cameraController!.takePicture();
      return File(image.path);
    } catch (e) {
      print('Error taking picture: $e');
      Get.snackbar(
        'Error',
        'No se pudo tomar la foto',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // ANÁLISIS EN TIEMPO REAL - IMPLEMENTACIÓN MEJORADA
  void startRealTimeAnalysis() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      print('Cannot start analysis - camera not initialized');
      return;
    }
    
    print('Starting real-time analysis...');
    isRealTimeAnalysis.value = true;
    
    // Usar Timer en lugar de recursión para mejor control
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(
      Duration(milliseconds: (1000 / detectionFPS.value).round()),
      (_) => _captureAndAnalyzeFrame(),
    );
  }

  void stopRealTimeAnalysis() {
    print('Stopping real-time analysis...');
    isRealTimeAnalysis.value = false;
    _analysisTimer?.cancel();
    _analysisTimer = null;
    liveDetections.clear();
    liveBehaviors.clear();
    _isProcessingFrame = false;
  }

  Future<void> _captureAndAnalyzeFrame() async {
    // Evitar procesamiento múltiple simultáneo
    if (_isProcessingFrame || !isRealTimeAnalysis.value) {
      return;
    }
    
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }
    
    try {
      _isProcessingFrame = true;
      isProcessing.value = true;
      
      // Capturar frame actual
      final image = await cameraController!.takePicture();
      
      // Leer bytes de la imagen
      final imageBytes = await File(image.path).readAsBytes();
      
      // Detectar objetos
      final detections = await _mlService.detectObjects(imageBytes);
      
      // Actualizar detecciones en UI
      if (detections.isNotEmpty) {
        liveDetections.value = detections;
        print('Detected ${detections.length} objects');
        
        // Analizar comportamientos si hay personas
        final personDetections = detections.where((d) => d.label == 'person').toList();
        
        if (personDetections.isNotEmpty) {
          final behavior = await _behaviorService.analyzeFrame(
            imageBytes,
            personDetections,
            {},
            DateTime.now().millisecondsSinceEpoch,
          );
          
          if (behavior != null && behavior.type != BehaviorType.normal) {
            liveBehaviors.add(behavior);
            
            // Mantener solo los últimos 5 comportamientos
            if (liveBehaviors.length > 5) {
              liveBehaviors.removeAt(0);
            }
            
            // Alertas para comportamientos críticos
            if (enableAudioAlerts.value && 
                (behavior.severity == SeverityLevel.high || 
                 behavior.severity == SeverityLevel.critical)) {
              _playAlert(behavior.type);
            }
          }
        }
      } else {
        // Si no hay detecciones, limpiar gradualmente
        if (liveDetections.length > 0) {
          liveDetections.removeLast();
        }
      }
      
      // Limpiar archivo temporal
      try {
        await File(image.path).delete();
      } catch (e) {
        // Ignorar errores de limpieza
      }
      
    } catch (e) {
      print('Error analyzing frame: $e');
    } finally {
      _isProcessingFrame = false;
      isProcessing.value = false;
    }
  }

  void _playAlert(BehaviorType type) {
    String message = '';
    
    switch (type) {
      case BehaviorType.violence:
        message = '⚠️ Violencia detectada';
        break;
      case BehaviorType.intoxication:
        message = '🍺 Persona intoxicada detectada';
        break;
      case BehaviorType.theft:
        message = '🚨 Posible robo detectado';
        break;
      case BehaviorType.fall:
        message = '🏥 Caída detectada';
        break;
      default:
        return;
    }
    
    Get.snackbar(
      'Alerta',
      message,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  // Zoom
  Future<void> setZoomLevel(double zoom) async {
    if (cameraController == null) return;
    
    try {
      await cameraController!.setZoomLevel(zoom);
    } catch (e) {
      print('Error setting zoom: $e');
    }
  }

  // Obtener zoom mínimo y máximo
  Future<Map<String, double>> getZoomLevels() async {
    if (cameraController == null) {
      return {'min': 1.0, 'max': 1.0};
    }
    
    try {
      final min = await cameraController!.getMinZoomLevel();
      final max = await cameraController!.getMaxZoomLevel();
      return {'min': min, 'max': max};
    } catch (e) {
      print('Error getting zoom levels: $e');
      return {'min': 1.0, 'max': 1.0};
    }
  }

  @override
  void onClose() {
    stopRealTimeAnalysis();
    cameraController?.dispose();
    super.onClose();
  }
}