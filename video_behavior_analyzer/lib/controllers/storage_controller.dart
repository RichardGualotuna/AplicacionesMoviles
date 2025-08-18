// controllers/storage_controller.dart
import 'dart:io';
import 'package:get/get.dart';
import '../services/local_storage_service.dart';
import 'package:flutter/material.dart';

class StorageController extends GetxController {
  LocalStorageService? _storageService;
  
  // Estados observables
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxInt totalVideos = 0.obs;
  final RxInt totalAnalyses = 0.obs;
  final RxInt storageUsedBytes = 0.obs;
  final RxInt availableSpaceBytes = 0.obs;
  final RxDouble storagePercentage = 0.0.obs;
  
  // Configuración de almacenamiento
  final RxBool autoDeleteOldVideos = false.obs;
  final RxInt maxStorageDays = 30.obs;
  final RxInt maxStorageSizeMB = 1000.obs;
  
  // Cache
  final RxInt cacheSize = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      
      // Inicializar servicio de almacenamiento
      _storageService = await LocalStorageService.getInstance();
      
      // Cargar configuración
      _loadStorageSettings();
      
      // Actualizar información
      await updateStorageInfo();
      
      isInitialized.value = true;
      
    } catch (e) {
      print('Error initializing StorageController: $e');
      Get.snackbar(
        'Error',
        'No se pudo inicializar el almacenamiento',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _loadStorageSettings() {
    if (_storageService == null) return;
    
    try {
      final settings = _storageService!.loadSettings();
      autoDeleteOldVideos.value = settings['auto_delete_old'] ?? false;
      maxStorageDays.value = settings['max_storage_days'] ?? 30;
      maxStorageSizeMB.value = settings['max_storage_size_mb'] ?? 1000;
    } catch (e) {
      print('Error loading storage settings: $e');
    }
  }

  // Actualizar información de almacenamiento
  Future<void> updateStorageInfo() async {
    if (_storageService == null) return;
    
    try {
      isLoading.value = true;
      
      // Obtener estadísticas
      final stats = await _storageService!.getStatistics();
      totalVideos.value = stats['total_videos'] ?? 0;
      totalAnalyses.value = stats['total_videos'] ?? 0; // Same as videos
      storageUsedBytes.value = stats['storage_used'] ?? 0;
      
      // Obtener espacio disponible
      availableSpaceBytes.value = await _storageService!.getAvailableSpace();
      
      // Calcular porcentaje usado
      if (availableSpaceBytes.value > 0) {
        final totalSpace = storageUsedBytes.value + availableSpaceBytes.value;
        storagePercentage.value = storageUsedBytes.value / totalSpace;
      }
      
      // Obtener tamaño de caché
      await _updateCacheSize();
      
    } catch (e) {
      print('Error updating storage info: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Limpiar videos antiguos
  Future<void> cleanOldVideos() async {
    if (_storageService == null) {
      Get.snackbar(
        'Error',
        'Servicio de almacenamiento no disponible',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      final videos = await _storageService!.getAllAnalyses();
      final cutoffDate = DateTime.now().subtract(Duration(days: maxStorageDays.value));
      
      int deletedCount = 0;
      for (var video in videos) {
        if (video.timestamp.isBefore(cutoffDate)) {
          await _storageService!.deleteVideo(video.id);
          deletedCount++;
        }
      }
      
      await updateStorageInfo();
      
      Get.snackbar(
        'Limpieza completada',
        'Se eliminaron $deletedCount videos antiguos',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron eliminar los videos antiguos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Limpiar por tamaño
  Future<void> cleanBySize() async {
    if (_storageService == null) {
      Get.snackbar(
        'Error',
        'Servicio de almacenamiento no disponible',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      final maxSizeBytes = maxStorageSizeMB.value * 1024 * 1024;
      
      if (storageUsedBytes.value <= maxSizeBytes) {
        Get.snackbar(
          'Info',
          'El almacenamiento está dentro del límite',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      final videos = await _storageService!.getAllAnalyses();
      // Ordenar por fecha (más antiguos primero)
      videos.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      int deletedCount = 0;
      int currentSize = storageUsedBytes.value;
      
      for (var video in videos) {
        if (currentSize <= maxSizeBytes) break;
        
        // Estimar tamaño del video (necesitaría implementación real)
        final videoFile = File(video.path);
        if (await videoFile.exists()) {
          final fileSize = await videoFile.length();
          
          await _storageService!.deleteVideo(video.id);
          currentSize -= fileSize;
          deletedCount++;
        }
      }
      
      await updateStorageInfo();
      
      Get.snackbar(
        'Limpieza completada',
        'Se eliminaron $deletedCount videos para liberar espacio',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo liberar espacio: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Limpiar caché
  Future<void> clearCache() async {
    if (_storageService == null) {
      Get.snackbar(
        'Error',
        'Servicio de almacenamiento no disponible',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      await _storageService!.clearCache();
      await _updateCacheSize();
      
      Get.snackbar(
        'Éxito',
        'Caché limpiado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo limpiar el caché: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Actualizar tamaño de caché
  Future<void> _updateCacheSize() async {
    try {
      final tempDir = await Directory.systemTemp.createTemp();
      int size = 0;
      
      await for (var entity in tempDir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
      
      cacheSize.value = size;
    } catch (e) {
      print('Error calculating cache size: $e');
      cacheSize.value = 0;
    }
  }

  // Exportar todos los datos
  Future<void> exportAllData() async {
    if (_storageService == null) {
      Get.snackbar(
        'Error',
        'Servicio de almacenamiento no disponible',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      final exportFile = await _storageService!.exportData();
      
      Get.snackbar(
        'Éxito',
        'Datos exportados a: ${exportFile.path}',
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () {
            // Compartir archivo
            // Implementar con share_plus package
          },
          child: const Text('Compartir'),
        ),
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

  // Importar datos
  Future<void> importData(File file) async {
    if (_storageService == null) {
      Get.snackbar(
        'Error',
        'Servicio de almacenamiento no disponible',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      await _storageService!.importData(file);
      await updateStorageInfo();
      
      Get.snackbar(
        'Éxito',
        'Datos importados correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron importar los datos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Guardar configuración de almacenamiento
  Future<void> saveStorageSettings() async {
    if (_storageService == null) return;
    
    await _storageService!.saveSettings({
      'auto_delete_old': autoDeleteOldVideos.value,
      'max_storage_days': maxStorageDays.value,
      'max_storage_size_mb': maxStorageSizeMB.value,
    });
    
    // Si está habilitada la eliminación automática, ejecutar limpieza
    if (autoDeleteOldVideos.value) {
      await cleanOldVideos();
    }
  }

  // Obtener información formateada
  String getFormattedStorageUsed() {
    return _formatBytes(storageUsedBytes.value);
  }

  String getFormattedAvailableSpace() {
    return _formatBytes(availableSpaceBytes.value);
  }

  String getFormattedCacheSize() {
    return _formatBytes(cacheSize.value);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  // Verificar espacio antes de grabar
  bool hasEnoughSpace(int requiredBytes) {
    return availableSpaceBytes.value > requiredBytes;
  }

  // Obtener recomendación de limpieza
  String getCleanupRecommendation() {
    if (storagePercentage.value > 0.9) {
      return 'Almacenamiento crítico. Se recomienda limpiar videos antiguos.';
    } else if (storagePercentage.value > 0.75) {
      return 'Almacenamiento alto. Considera limpiar videos antiguos.';
    } else if (cacheSize.value > 100 * 1024 * 1024) { // 100 MB
      return 'El caché es grande. Considera limpiarlo.';
    }
    return 'El almacenamiento está en buen estado.';
  }
}