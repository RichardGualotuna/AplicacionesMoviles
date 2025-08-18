// controllers/camera_controller.dart
import 'dart:io' show File;
import 'dart:async';
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
  final RxDouble detectionFPS = 5.0.obs; // Frames por segundo para análisis
  final RxBool showBoundingBoxes = true.obs;
  final RxBool enableAudioAlerts = true.obs;

  List<CameraDescription> cameras = [];
  String? recordingPath;
  DateTime? lastFrameTime;

  @override
  void onInit() async {
    super.onInit();
    // Dar tiempo para que el binding se complete
    await Future.delayed(const Duration(milliseconds: 100));
    await initializeCameras();
  }

  Future<void> initializeCameras() async {
    try {
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
        'No se pudieron inicializar las cámaras: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> initializeCamera(int cameraIndex) async {
    if (cameraIndex >= cameras.length) return;

    try {
      // Dispose del controller anterior si existe
      if (cameraController != null) {
        await cameraController!.dispose();
      }

      selectedCameraIndex.value = cameraIndex;

      cameraController = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();

      // Configurar flash
      await cameraController!.setFlashMode(flashMode.value);

      isInitialized.value = true;

      // Iniciar análisis en tiempo real si está habilitado
      if (isRealTimeAnalysis.value) {
        startRealTimeAnalysis();
      }
    } catch (e) {
      print('Error initializing camera: $e');
      isInitialized.value = false;
      Get.snackbar(
        'Error',
        'No se pudo inicializar la cámara: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Cambiar entre cámaras
  Future<void> switchCamera() async {
    if (cameras.length <= 1) return;

    final newIndex = (selectedCameraIndex.value + 1) % cameras.length;
    await initializeCamera(newIndex);
  }

  // Cambiar modo de flash
  Future<void> toggleFlash() async {
    if (cameraController == null) return;

    final modes = [
      FlashMode.off,
      FlashMode.auto,
      FlashMode.always,
      FlashMode.torch
    ];
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
        'No se pudo iniciar la grabación: $e',
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
        'No se pudo detener la grabación: $e',
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
        'No se pudo tomar la foto: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Análisis en tiempo real
  void startRealTimeAnalysis() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    isRealTimeAnalysis.value = true;
    _processFrames();
  }

  void stopRealTimeAnalysis() {
    isRealTimeAnalysis.value = false;
    liveDetections.clear();
    liveBehaviors.clear();
  }

  void _processFrames() async {
    if (!isRealTimeAnalysis.value || cameraController == null) {
      return;
    }

    final now = DateTime.now();
    if (lastFrameTime != null) {
      final elapsed = now.difference(lastFrameTime!).inMilliseconds;
      final targetInterval = 1000 / detectionFPS.value;

      if (elapsed < targetInterval) {
        await Future.delayed(
          Duration(milliseconds: (targetInterval - elapsed).toInt()),
        );
      }
    }

    if (!isRealTimeAnalysis.value) return;

    try {
      isProcessing.value = true;
      lastFrameTime = DateTime.now();

      // Usar el stream de imágenes de la cámara en lugar de tomar fotos
      if (cameraController!.value.isStreamingImages) {
        // Ya estamos procesando
        return;
      }

      // Tomar una foto para análisis
      final image = await cameraController!.takePicture();

      // Leer bytes de la imagen
      final imageBytes = await image.readAsBytes();

      // Detectar objetos
      final detections = await _mlService.detectObjects(imageBytes);

      // Actualizar detecciones solo si hay resultados válidos
      if (detections.isNotEmpty) {
        liveDetections.value = detections;
      }

      // Analizar comportamientos
      final personDetections =
          detections.where((d) => d.label == 'person').toList();

      if (personDetections.isNotEmpty) {
        final behavior = await _behaviorService.analyzeFrame(
          imageBytes,
          personDetections,
          {},
          0,
        );

        if (behavior != null && behavior.type != BehaviorType.normal) {
          liveBehaviors.add(behavior);

          if (liveBehaviors.length > 10) {
            liveBehaviors.removeAt(0);
          }

          if (enableAudioAlerts.value &&
              (behavior.severity == SeverityLevel.high ||
                  behavior.severity == SeverityLevel.critical)) {
            _playAlert(behavior.type);
          }
        }
      }

      // Limpiar imagen temporal
      try {
        final file = File(image.path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignorar errores de limpieza
      }
    } catch (e) {
      print('Error processing frame: $e');
    } finally {
      isProcessing.value = false;

      // Continuar procesando si está activo
      if (isRealTimeAnalysis.value) {
        // Pequeño delay para no saturar
        await Future.delayed(const Duration(milliseconds: 100));
        _processFrames();
      }
    }
  }

  void _playAlert(BehaviorType type) {
    // Implementar reproducción de audio según el tipo de comportamiento
    // Por ahora solo mostramos notificación
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
