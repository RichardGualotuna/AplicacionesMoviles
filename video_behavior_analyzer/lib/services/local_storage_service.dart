// services/local_storage_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_model.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  SharedPreferences? _prefs;  // Cambiado de late a nullable
  Directory? _documentsDir;
  Directory? _videosDir;
  Directory? _analysisDir;
  bool _isInitialized = false;

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  LocalStorageService._();

  Future<void> _initialize() async {
    try {
      // Inicializar SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // Obtener directorio de documentos
      _documentsDir = await getApplicationDocumentsDirectory();

      // Crear directorios necesarios
      _videosDir = Directory('${_documentsDir!.path}/videos');
      _analysisDir = Directory('${_documentsDir!.path}/analysis');

      if (!await _videosDir!.exists()) {
        await _videosDir!.create(recursive: true);
      }

      if (!await _analysisDir!.exists()) {
        await _analysisDir!.create(recursive: true);
      }
      
      _isInitialized = true;
      print('LocalStorageService inicializado correctamente');
    } catch (e) {
      print('Error inicializando LocalStorageService: $e');
      throw Exception('Failed to initialize LocalStorageService: $e');
    }
  }

  // Verificar inicialización antes de usar
  void _checkInitialization() {
    if (!_isInitialized || _prefs == null) {
      throw Exception('LocalStorageService not initialized. Call getInstance() first.');
    }
  }

  // Guardar video
  Future<String> saveVideo(File videoFile) async {
    _checkInitialization();
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = videoFile.path.split('.').last;
    final newPath = '${_videosDir!.path}/video_$timestamp.$extension';

    final savedFile = await videoFile.copy(newPath);
    return savedFile.path;
  }

  // Guardar análisis de video
  Future<void> saveVideoAnalysis(VideoModel video) async {
    _checkInitialization();
    
    final file = File('${_analysisDir!.path}/${video.id}.json');
    await file.writeAsString(jsonEncode(video.toJson()));

    // Actualizar índice
    await _updateVideoIndex(video.id);
  }

  // Cargar análisis de video
  Future<VideoModel?> loadVideoAnalysis(String videoId) async {
    _checkInitialization();
    
    try {
      final file = File('${_analysisDir!.path}/$videoId.json');

      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString);

      return VideoModel.fromJson(json);
    } catch (e) {
      print('Error loading video analysis: $e');
      return null;
    }
  }

  // Obtener todos los análisis
  Future<List<VideoModel>> getAllAnalyses() async {
    _checkInitialization();
    
    try {
      final videoIds = _prefs!.getStringList('video_ids') ?? [];
      final List<VideoModel> videos = [];

      for (String id in videoIds) {
        final video = await loadVideoAnalysis(id);
        if (video != null) {
          videos.add(video);
        }
      }

      // Ordenar por fecha (más reciente primero)
      videos.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return videos;
    } catch (e) {
      print('Error getting all analyses: $e');
      return [];
    }
  }

  // Eliminar video y análisis
  Future<void> deleteVideo(String videoId) async {
    _checkInitialization();
    
    try {
      // Cargar análisis para obtener path del video
      final analysis = await loadVideoAnalysis(videoId);

      if (analysis != null) {
        // Eliminar archivo de video
        final videoFile = File(analysis.path);
        if (await videoFile.exists()) {
          await videoFile.delete();
        }
      }

      // Eliminar archivo de análisis
      final analysisFile = File('${_analysisDir!.path}/$videoId.json');
      if (await analysisFile.exists()) {
        await analysisFile.delete();
      }

      // Actualizar índice
      final videoIds = _prefs!.getStringList('video_ids') ?? [];
      videoIds.remove(videoId);
      await _prefs!.setStringList('video_ids', videoIds);
    } catch (e) {
      print('Error deleting video: $e');
    }
  }

  // Guardar configuración
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    _checkInitialization();
    
    for (var entry in settings.entries) {
      if (entry.value is bool) {
        await _prefs!.setBool(entry.key, entry.value);
      } else if (entry.value is int) {
        await _prefs!.setInt(entry.key, entry.value);
      } else if (entry.value is double) {
        await _prefs!.setDouble(entry.key, entry.value);
      } else if (entry.value is String) {
        await _prefs!.setString(entry.key, entry.value);
      } else if (entry.value is List<String>) {
        await _prefs!.setStringList(entry.key, entry.value);
      }
    }
  }

  // Cargar configuración
  Map<String, dynamic> loadSettings() {
    // Si no está inicializado, retornar valores por defecto
    if (!_isInitialized || _prefs == null) {
      print('Warning: LocalStorageService not initialized, returning default settings');
      return _getDefaultSettings();
    }
    
    return {
      'enable_notifications': _prefs!.getBool('enable_notifications') ?? true,
      'auto_save_analysis': _prefs!.getBool('auto_save_analysis') ?? true,
      'frame_skip': _prefs!.getInt('frame_skip') ?? 5,
      'confidence_threshold': _prefs!.getDouble('confidence_threshold') ?? 0.5,
      'alert_severity': _prefs!.getString('alert_severity') ?? 'medium',
      'detection_types': _prefs!.getStringList('detection_types') ??
          ['intoxication', 'violence', 'theft', 'fall'],
      'auto_delete_old': _prefs!.getBool('auto_delete_old') ?? false,
      'max_storage_days': _prefs!.getInt('max_storage_days') ?? 30,
      'max_storage_size_mb': _prefs!.getInt('max_storage_size_mb') ?? 1000,
    };
  }

  // Configuración por defecto
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'enable_notifications': true,
      'auto_save_analysis': true,
      'frame_skip': 5,
      'confidence_threshold': 0.5,
      'alert_severity': 'medium',
      'detection_types': ['intoxication', 'violence', 'theft', 'fall'],
      'auto_delete_old': false,
      'max_storage_days': 30,
      'max_storage_size_mb': 1000,
    };
  }

  // Estadísticas
  Future<Map<String, dynamic>> getStatistics() async {
    if (!_isInitialized) {
      return {
        'total_videos': 0,
        'total_detections': 0,
        'behavior_counts': {},
        'last_analysis': null,
        'storage_used': 0,
      };
    }
    
    _checkInitialization();
    
    final analyses = await getAllAnalyses();

    Map<String, int> behaviorCounts = {};
    int totalDetections = 0;
    int totalVideos = analyses.length;

    for (var video in analyses) {
      totalDetections += video.detections.length;

      for (var behavior in video.behaviors) {
        final type = behavior.type.toString();
        behaviorCounts[type] = (behaviorCounts[type] ?? 0) + 1;
      }
    }

    return {
      'total_videos': totalVideos,
      'total_detections': totalDetections,
      'behavior_counts': behaviorCounts,
      'last_analysis': analyses.isNotEmpty ? analyses.first.timestamp : null,
      'storage_used': await _calculateStorageUsed(),
    };
  }

  // Exportar datos
  Future<File> exportData() async {
    _checkInitialization();
    
    final analyses = await getAllAnalyses();
    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'version': '1.0',
      'analyses': analyses.map((v) => v.toJson()).toList(),
      'settings': loadSettings(),
    };

    final exportFile = File(
        '${_documentsDir!.path}/export_${DateTime.now().millisecondsSinceEpoch}.json');
    await exportFile.writeAsString(jsonEncode(exportData));

    return exportFile;
  }

  // Importar datos
  Future<void> importData(File importFile) async {
    _checkInitialization();
    
    try {
      final jsonString = await importFile.readAsString();
      final data = jsonDecode(jsonString);

      // Importar análisis
      final analyses = data['analyses'] as List;
      for (var analysisJson in analyses) {
        final video = VideoModel.fromJson(analysisJson);
        await saveVideoAnalysis(video);
      }

      // Importar configuración
      if (data['settings'] != null) {
        await saveSettings(data['settings']);
      }
    } catch (e) {
      print('Error importing data: $e');
      throw Exception('Failed to import data');
    }
  }

  // Métodos privados
  Future<void> _updateVideoIndex(String videoId) async {
    _checkInitialization();
    
    final videoIds = _prefs!.getStringList('video_ids') ?? [];

    if (!videoIds.contains(videoId)) {
      videoIds.add(videoId);
      await _prefs!.setStringList('video_ids', videoIds);
    }
  }

  Future<int> _calculateStorageUsed() async {
    if (!_isInitialized || _videosDir == null || _analysisDir == null) {
      return 0;
    }
    
    int totalSize = 0;

    try {
      // Calcular tamaño de videos
      if (await _videosDir!.exists()) {
        await for (var entity in _videosDir!.list()) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      // Calcular tamaño de análisis
      if (await _analysisDir!.exists()) {
        await for (var entity in _analysisDir!.list()) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      print('Error calculating storage: $e');
    }

    return totalSize; // en bytes
  }

  // Limpiar caché y archivos temporales
  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();

      await for (var entity in tempDir.list()) {
        if (entity is File) {
          await entity.delete();
        } else if (entity is Directory) {
          await entity.delete(recursive: true);
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Obtener espacio disponible
  Future<int> getAvailableSpace() async {
    // Esta implementación es básica
    // En producción, usar package disk_space o similar
    return 1024 * 1024 * 1024; // 1GB por defecto
  }
  
  // Método para verificar si el servicio está listo
  bool get isInitialized => _isInitialized;
}