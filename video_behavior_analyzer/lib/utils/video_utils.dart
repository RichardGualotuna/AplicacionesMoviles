// utils/video_utils.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoUtils {
  // Obtener duración del video
  static Future<Duration> getVideoDuration(String videoPath) async {
    final controller = VideoPlayerController.file(File(videoPath));
    await controller.initialize();
    final duration = controller.value.duration;
    controller.dispose();
    return duration;
  }

  // Obtener información del video
  static Future<Map<String, dynamic>> getVideoInfo(String videoPath) async {
    final file = File(videoPath);
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    
    final info = {
      'duration': controller.value.duration,
      'size': controller.value.size,
      'aspectRatio': controller.value.aspectRatio,
      'fileSize': await file.length(),
      'path': videoPath,
    };
    
    controller.dispose();
    return info;
  }

  // Validar formato de video
  static bool isValidVideoFormat(String path) {
    final validExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
    final extension = path.toLowerCase().substring(path.lastIndexOf('.'));
    return validExtensions.contains(extension);
  }

  // Generar thumbnail (placeholder - necesita implementación con ffmpeg)
  static Future<Uint8List?> generateThumbnail(String videoPath) async {
    // Esta es una implementación placeholder
    // En producción, usar ffmpeg_kit_flutter para generar thumbnails reales
    try {
      // Por ahora retornamos null
      // Implementar con: ffmpeg -i video.mp4 -ss 00:00:01.000 -vframes 1 thumbnail.png
      return null;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  // Comprimir video (placeholder - necesita implementación con ffmpeg)
  static Future<String?> compressVideo(String inputPath) async {
    // Esta es una implementación placeholder
    // En producción, usar ffmpeg_kit_flutter para comprimir videos
    try {
      // Por ahora retornamos el mismo path
      // Implementar con: ffmpeg -i input.mp4 -vcodec h264 -acodec aac output.mp4
      return inputPath;
    } catch (e) {
      print('Error compressing video: $e');
      return null;
    }
  }

  // Extraer frames del video (placeholder - necesita implementación con ffmpeg)
  static Future<List<Uint8List>> extractFrames(
    String videoPath, {
    int frameCount = 10,
  }) async {
    // Esta es una implementación placeholder
    // En producción, usar ffmpeg_kit_flutter para extraer frames
    try {
      // Por ahora retornamos lista vacía
      // Implementar con: ffmpeg -i video.mp4 -vf fps=1 frame_%d.png
      return [];
    } catch (e) {
      print('Error extracting frames: $e');
      return [];
    }
  }

  // Guardar video temporal
  static Future<String> saveTemporaryVideo(Uint8List videoData) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final videoPath = '${tempDir.path}/temp_video_$timestamp.mp4';
    
    final file = File(videoPath);
    await file.writeAsBytes(videoData);
    
    return videoPath;
  }

  // Limpiar videos temporales
  static Future<void> cleanTemporaryVideos() async {
    final tempDir = await getTemporaryDirectory();
    
    await for (var entity in tempDir.list()) {
      if (entity is File && entity.path.contains('temp_video_')) {
        try {
          await entity.delete();
        } catch (e) {
          print('Error deleting temporary video: $e');
        }
      }
    }
  }

  // Calcular tamaño formateado
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  // Validar tamaño del video
  static Future<bool> isVideoSizeValid(String path, int maxSizeMB) async {
    final file = File(path);
    final sizeInBytes = await file.length();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= maxSizeMB;
  }

  // Obtener orientación del video
  static Future<VideoOrientation> getVideoOrientation(String path) async {
    final controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    
    final size = controller.value.size;
    controller.dispose();
    
    if (size.width > size.height) {
      return VideoOrientation.landscape;
    } else if (size.width < size.height) {
      return VideoOrientation.portrait;
    } else {
      return VideoOrientation.square;
    }
  }
}

enum VideoOrientation {
  portrait,
  landscape,
  square,
}