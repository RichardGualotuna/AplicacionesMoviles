// utils/permissions_helper.dart
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PermissionsHelper {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      Get.dialog(
        AlertDialog(
          title: const Text('Permiso de Cámara'),
          content: const Text(
            'El permiso de cámara ha sido denegado permanentemente. '
            'Por favor, habilítalo en la configuración de la aplicación.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                openAppSettings();
              },
              child: const Text('Abrir Configuración'),
            ),
          ],
        ),
      );
      return false;
    }
    
    return status.isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    // Para Android 13+, usar Permission.photos y Permission.videos
    if (GetPlatform.isAndroid) {
      final photosStatus = await Permission.photos.status;
      final videosStatus = await Permission.videos.status;
      
      if (photosStatus.isDenied || videosStatus.isDenied) {
        final results = await [
          Permission.photos,
          Permission.videos,
        ].request();
        
        return results[Permission.photos]!.isGranted &&
               results[Permission.videos]!.isGranted;
      }
      
      return photosStatus.isGranted && videosStatus.isGranted;
    } else {
      // iOS
      final status = await Permission.storage.status;
      
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      
      return status.isGranted;
    }
  }

  static Future<bool> requestAllPermissions() async {
    try {
      if (GetPlatform.isAndroid) {
        // Para Android 13+ usar permisos separados
        final Map<Permission, PermissionStatus> results = await [
          Permission.camera,
          Permission.microphone,
          Permission.photos,
          Permission.videos,
        ].request();

        // Verificar si todos los permisos críticos están concedidos
        final cameraGranted = results[Permission.camera]?.isGranted ?? false;
        final micGranted = results[Permission.microphone]?.isGranted ?? false;
        
        // Para almacenamiento, al menos uno debe estar concedido
        final photosGranted = results[Permission.photos]?.isGranted ?? false;
        final videosGranted = results[Permission.videos]?.isGranted ?? false;
        
        return cameraGranted && micGranted && (photosGranted || videosGranted);
      } else {
        // iOS y otros
        final results = await [
          Permission.camera,
          Permission.microphone,
          Permission.storage,
        ].request();

        return results.values.every((status) => status.isGranted);
      }
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  static void showPermissionDeniedDialog(String permissionName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Permiso Requerido'),
        content: Text(
          'Se necesita el permiso de $permissionName para usar esta función.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}