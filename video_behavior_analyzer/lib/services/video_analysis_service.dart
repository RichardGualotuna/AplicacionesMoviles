// services/video_analysis_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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

      print('Iniciando análisis de video: ${totalFrames} frames');

      // Procesar frames
      for (int frame = 0; frame < totalFrames; frame += frameSkip) {
        if (!_isAnalyzing) break;

        // Actualizar progreso
        final progress = frame / totalFrames;
        onProgress?.call(progress);

        try {
          // Obtener frame
          final position = Duration(milliseconds: (frame * 1000 / fps).toInt());
          await _controller!.seekTo(position);
          
          // Esperar a que el frame se cargue
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Capturar frame actual
          final frameData = await _captureCurrentFrame();
          if (frameData == null) continue;

          print('Procesando frame $frame...');

          // Detectar objetos
          final detections = await _mlService.detectObjects(frameData);
          
          // Actualizar información del frame
          final timestampedDetections = detections.map((d) => DetectionModel(
            label: d.label,
            confidence: d.confidence,
            boundingBox: d.boundingBox,
            frameNumber: frame,
            timestamp: DateTime.now().add(Duration(milliseconds: (frame * 1000 / fps).toInt())),
          )).toList();
          
          // Filtrar personas
          final personDetections = timestampedDetections.where((d) => d.label == 'person').toList();
          
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
              print('Comportamiento detectado: ${behavior.type}');
            }
          }

          allDetections.addAll(timestampedDetections);
          onDetection?.call(timestampedDetections);

        } catch (e) {
          print('Error procesando frame $frame: $e');
          continue;
        }
      }

      print('Análisis completado: ${allDetections.length} detecciones, ${detectedBehaviors.length} comportamientos');

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

  Future<Uint8List?> _captureCurrentFrame() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        return null;
      }

      // Método alternativo: usar GlobalKey para capturar widget
      // Este es un approach básico, para producción recomendaría usar FFmpeg
      
      // Por ahora, creamos una imagen sintética del frame actual
      // En producción, necesitarías:
      // 1. FFmpeg para extraer frames reales
      // 2. O usar texture_view en Android/iOS
      // 3. O implementar platform channels específicos
      
      return await _createSyntheticFrame();
      
    } catch (e) {
      print('Error capturing frame: $e');
      return null;
    }
  }

  Future<Uint8List> _createSyntheticFrame() async {
    // Esta es una implementación temporal que crea una imagen sintética
    // Para análisis real, necesitas extraer el frame actual del video
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(640, 480);
    
    // Fondo
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1E1E1E),
    );
    
    // Simular algunas formas que representan objetos
    final paint = Paint()..color = const Color(0xFF4CAF50);
    
    // Simular una "persona" (rectángulo)
    canvas.drawRect(
      Rect.fromLTWH(200, 150, 80, 200),
      paint,
    );
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  void stopAnalysis() {
    _isAnalyzing = false;
  }

  void dispose() {
    stopAnalysis();
    _controller?.dispose();
  }
}

// Implementación mejorada para captura real de frames usando FFmpeg
// Necesitarías agregar la dependencia ffmpeg_kit_flutter
class VideoFrameExtractor {
  static Future<List<Uint8List>> extractFrames(
    String videoPath,
    int maxFrames,
    int frameSkip,
  ) async {
    // Implementación con FFmpeg
    // final session = await FFmpegKit.execute(
    //   '-i $videoPath -vf "fps=1/$frameSkip" -frames:v $maxFrames frame_%03d.png'
    // );
    
    // Por ahora retornamos lista vacía
    return [];
  }
  
  static Future<Uint8List?> extractFrameAtTime(
    String videoPath,
    Duration timestamp,
  ) async {
    // Implementación con FFmpeg para extraer frame específico
    // final session = await FFmpegKit.execute(
    //   '-ss ${timestamp.inSeconds} -i $videoPath -vframes 1 -f image2pipe -'
    // );
    
    return null;
  }
}