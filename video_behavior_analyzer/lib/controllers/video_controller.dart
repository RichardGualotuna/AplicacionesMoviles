// controllers/video_controller.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/video_model.dart';
import '../models/behavior_model.dart';
import '../models/detection_model.dart';
import '../services/video_analysis_service.dart';
import '../services/local_storage_service.dart';
import '../services/ml_service.dart';
import 'package:flutter/material.dart';

class VideoController extends GetxController {
  final VideoAnalysisService _analysisService = VideoAnalysisService();
  late final LocalStorageService _storageService;
  
  // Estados observables
  final RxBool isLoading = false.obs;
  final RxBool isAnalyzing = false.obs;
  final RxDouble analysisProgress = 0.0.obs;
  final RxString currentStatus = ''.obs;
  
  // Video actual
  final Rx<File?> selectedVideo = Rx<File?>(null);
  final Rx<VideoModel?> currentVideoModel = Rx<VideoModel?>(null);
  
  // Resultados de análisis
  final RxList<DetectionModel> currentDetections = <DetectionModel>[].obs;
  final RxList<BehaviorModel> detectedBehaviors = <BehaviorModel>[].obs;
  
  // Historial
  final RxList<VideoModel> videoHistory = <VideoModel>[].obs;
  
  // Configuración
  final RxInt frameSkip = 5.obs;
  final RxDouble confidenceThreshold = 0.5.obs;
  final RxBool autoSave = true.obs;
  
  @override
  void onInit() async {
    super.onInit();
    await _initializeServices();
    await loadVideoHistory();
  }

  Future<void> _initializeServices() async {
    try {
      isLoading.value = true;
      currentStatus.value = 'Inicializando servicios...';
      
      // Inicializar ML Service
      await MLService.instance.initialize();
      
      // Inicializar Storage Service
      _storageService = await LocalStorageService.getInstance();
      
      // Cargar configuración
      _loadSettings();
      
      currentStatus.value = 'Servicios inicializados';
    } catch (e) {
      currentStatus.value = 'Error: $e';
      Get.snackbar(
        'Error',
        'No se pudieron inicializar los servicios: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _loadSettings() {
    final settings = _storageService.loadSettings();
    frameSkip.value = settings['frame_skip'] ?? 5;
    confidenceThreshold.value = settings['confidence_threshold'] ?? 0.5;
    autoSave.value = settings['auto_save_analysis'] ?? true;
  }

  // Seleccionar video de galería
  Future<void> pickVideoFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );
      
      if (video != null) {
        selectedVideo.value = File(video.path);
        currentStatus.value = 'Video seleccionado: ${video.name}';
        
        // Resetear análisis previo
        _resetAnalysis();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo seleccionar el video: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Grabar video con cámara
  Future<void> recordVideoFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (video != null) {
        selectedVideo.value = File(video.path);
        currentStatus.value = 'Video grabado exitosamente';
        
        // Resetear análisis previo
        _resetAnalysis();
        
        // Guardar video en almacenamiento local
        if (autoSave.value) {
          final savedPath = await _storageService.saveVideo(File(video.path));
          selectedVideo.value = File(savedPath);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo grabar el video: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Analizar video seleccionado
  Future<void> analyzeVideo() async {
    if (selectedVideo.value == null) {
      Get.snackbar(
        'Atención',
        'Por favor selecciona un video primero',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isAnalyzing.value = true;
      analysisProgress.value = 0.0;
      currentStatus.value = 'Iniciando análisis...';
      
      // Configurar callbacks
      _analysisService.onProgress = (progress) {
        analysisProgress.value = progress;
        currentStatus.value = 'Analizando... ${(progress * 100).toStringAsFixed(1)}%';
      };
      
      _analysisService.onDetection = (detections) {
        // Filtrar por umbral de confianza
        final filtered = detections
            .where((d) => d.confidence >= confidenceThreshold.value)
            .toList();
        currentDetections.addAll(filtered);
      };
      
      _analysisService.onBehaviorDetected = (behavior) {
        detectedBehaviors.add(behavior);
        _handleBehaviorAlert(behavior);
      };
      
      // Ejecutar análisis
      final videoModel = await _analysisService.analyzeVideo(
        selectedVideo.value!.path,
        frameSkip: frameSkip.value,
      );
      
      currentVideoModel.value = videoModel;
      
      // Guardar análisis si está habilitado
      if (autoSave.value) {
        await _storageService.saveVideoAnalysis(videoModel);
        await loadVideoHistory(); // Actualizar historial
      }
      
      currentStatus.value = 'Análisis completado';
      _showAnalysisResults();
      
    } catch (e) {
      currentStatus.value = 'Error en análisis: $e';
      Get.snackbar(
        'Error',
        'No se pudo completar el análisis: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAnalyzing.value = false;
    }
  }

  // Manejar alertas de comportamiento
  void _handleBehaviorAlert(BehaviorModel behavior) {
    String message = '';
    String title = '';
    
    switch (behavior.type) {
      case BehaviorType.violence:
        title = '⚠️ Violencia Detectada';
        message = 'Se ha detectado un posible acto de violencia';
        break;
      case BehaviorType.intoxication:
        title = '🍺 Intoxicación Detectada';
        message = 'Se ha detectado una posible persona en estado de ebriedad';
        break;
      case BehaviorType.theft:
        title = '🚨 Robo Detectado';
        message = 'Se ha detectado un posible intento de robo';
        break;
      case BehaviorType.fall:
        title = '🏥 Caída Detectada';
        message = 'Se ha detectado una caída';
        break;
      case BehaviorType.suspicious:
        title = '👁️ Comportamiento Sospechoso';
        message = 'Se ha detectado comportamiento sospechoso';
        break;
      default:
        return;
    }
    
    // Mostrar notificación según severidad
    if (behavior.severity == SeverityLevel.critical || 
        behavior.severity == SeverityLevel.high) {
      Get.snackbar(
        title,
        message,
        backgroundColor: behavior.severity == SeverityLevel.critical 
            ? Get.theme.colorScheme.error 
            : Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Mostrar resultados del análisis
// controllers/video_controller.dart - Método actualizado
// Reemplazar el método _showAnalysisResults() completo:

void _showAnalysisResults() {
  if (currentVideoModel.value == null) return;
  
  final model = currentVideoModel.value!;
  
  Get.defaultDialog(
    title: 'Análisis Completado',
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Duración: ${_formatDuration(model.duration)}'),
          const SizedBox(height: 10),
          Text('Objetos detectados: ${model.detections.length}'),
          Text('Comportamientos detectados: ${model.behaviors.length}'),
          const SizedBox(height: 10),
          if (model.behaviors.isNotEmpty) ...[
            const Text('Comportamientos:'),
            ...model.behaviors.take(3).map((b) => Text(
              '• ${_getBehaviorName(b.type)} (${(b.confidence * 100).toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 12),
            )),
          ],
        ],
      ),
    ),
    confirm: TextButton(
      onPressed: () {
        Get.back(); // Cerrar el diálogo
        // Asegurarse de que los datos están listos antes de navegar
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.toNamed('/analysis-results');
        });
      },
      child: const Text('Ver Detalles'),
    ),
    cancel: TextButton(
      onPressed: () => Get.back(),
      child: const Text('Cerrar'),
    ),
  );
}

  // Cargar historial de videos
  Future<void> loadVideoHistory() async {
    try {
      isLoading.value = true;
      final videos = await _storageService.getAllAnalyses();
      videoHistory.value = videos;
    } catch (e) {
      print('Error loading video history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Cargar análisis previo
  Future<void> loadPreviousAnalysis(String videoId) async {
    try {
      isLoading.value = true;
      currentStatus.value = 'Cargando análisis...';
      
      final videoModel = await _storageService.loadVideoAnalysis(videoId);
      
      if (videoModel != null) {
        currentVideoModel.value = videoModel;
        selectedVideo.value = File(videoModel.path);
        currentDetections.value = videoModel.detections;
        detectedBehaviors.value = videoModel.behaviors;
        
        currentStatus.value = 'Análisis cargado';
      } else {
        Get.snackbar(
          'Error',
          'No se pudo cargar el análisis',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      currentStatus.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Eliminar video
  Future<void> deleteVideo(String videoId) async {
    try {
      await _storageService.deleteVideo(videoId);
      await loadVideoHistory();
      
      Get.snackbar(
        'Éxito',
        'Video eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el video: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Exportar datos
  Future<void> exportData() async {
    try {
      isLoading.value = true;
      currentStatus.value = 'Exportando datos...';
      
      final file = await _storageService.exportData();
      
      Get.snackbar(
        'Éxito',
        'Datos exportados a: ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron exportar los datos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Obtener estadísticas
  Future<Map<String, dynamic>> getStatistics() async {
    return await _storageService.getStatistics();
  }

  // Detener análisis
  void stopAnalysis() {
    _analysisService.stopAnalysis();
    isAnalyzing.value = false;
    currentStatus.value = 'Análisis detenido';
  }

  // Resetear análisis
  void _resetAnalysis() {
    currentDetections.clear();
    detectedBehaviors.clear();
    analysisProgress.value = 0.0;
    currentVideoModel.value = null;
  }

  // Utilidades
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  String _getBehaviorName(BehaviorType type) {
    switch (type) {
      case BehaviorType.intoxication:
        return 'Intoxicación';
      case BehaviorType.violence:
        return 'Violencia';
      case BehaviorType.theft:
        return 'Robo';
      case BehaviorType.fall:
        return 'Caída';
      case BehaviorType.suspicious:
        return 'Sospechoso';
      case BehaviorType.aggression:
        return 'Agresión';
      case BehaviorType.normal:
        return 'Normal';
    }
  }

  @override
  void onClose() {
    _analysisService.dispose();
    super.onClose();
  }
}