// services/video_analysis_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import '../models/detection_model.dart';
import '../models/behavior_model.dart';
import '../models/video_model.dart';
import 'ml_service.dart';
import 'behavior_detection_service.dart';

class VideoAnalysisService {
  final MLService _mlService = MLService.instance;
  final BehaviorDetectionService _behaviorService = BehaviorDetectionService();
  
  VideoPlayerController? _controller;
  bool _isAnalyzing = false;
  
  // Callbacks para actualizar UI
  Function(double)? onProgress;
  Function(List<DetectionModel>)? onDetection;
  Function(BehaviorModel)? onBehaviorDetected;

  Future<VideoModel> analyzeVideo(
    String videoPath, {
    int frameSkip = 5, // Procesar cada 5 frames para optimizar
  }) async {
    if (_isAnalyzing) {
      throw Exception('Analysis already in progress');
    }

    _isAnalyzing = true;
    
    try {
      // Inicializar video controller
      _controller = VideoPlayerController.file(File(videoPath));
      await _controller!.initialize();

      final duration = _controller!.value.duration;
      final fps = 30; // Asumimos 30 fps, ajustar según necesidad
      final totalFrames = (duration.inSeconds * fps).toInt();

      List<DetectionModel> allDetections = [];
      List<BehaviorModel> detectedBehaviors = [];
      Map<int, List<DetectionModel>> personTracking = {};

      // Procesar frames
      for (int frame = 0; frame < totalFrames; frame += frameSkip) {
        if (!_isAnalyzing) break;

        // Actualizar progreso
        onProgress?.call(frame / totalFrames);

        // Obtener frame
        final position = Duration(milliseconds: (frame * 1000 / fps).toInt());
        await _controller!.seekTo(position);
        
        // Capturar frame actual
        final frameData = await _captureFrame();
        if (frameData == null) continue;

        // Detectar objetos y personas
        final detections = await _mlService.detectObjects(frameData);
        
        // Filtrar personas
        final personDetections = detections.where((d) => d.label == 'person').toList();
        
        if (personDetections.isNotEmpty) {
          // Actualizar tracking
          personTracking[frame] = personDetections;
          
          // Analizar comportamiento
          final behavior = await _behaviorService.analyzeFrame(
            frameData,
            personDetections,
            personTracking,
            frame,
          );

          if (behavior != null && behavior.type != BehaviorType.normal) {
            detectedBehaviors.add(behavior);
            onBehaviorDetected?.call(behavior);
          }
        }

        allDetections.addAll(detections);
        onDetection?.call(detections);
      }

      // Crear modelo de video con resultados
      final videoModel = VideoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        path: videoPath,
        timestamp: DateTime.now(),
        duration: duration,
        source: VideoSource.gallery,
        detections: allDetections,
        behaviors: detectedBehaviors,
      );

      onProgress?.call(1.0);
      return videoModel;

    } finally {
      _isAnalyzing = false;
      _controller?.dispose();
      _controller = null;
    }
  }

  Future<Uint8List?> _captureFrame() async {
    try {
      // Este es un método simplificado
      // En producción, usar platform channels o ffmpeg para extraer frames
      
      // Por ahora, retornamos null para indicar que necesita implementación
      // con una librería específica de captura de frames
      return null;
    } catch (e) {
      print('Error capturing frame: $e');
      return null;
    }
  }

  void stopAnalysis() {
    _isAnalyzing = false;
  }

  void dispose() {
    stopAnalysis();
    _controller?.dispose();
  }
}