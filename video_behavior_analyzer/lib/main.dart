// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'config/themes.dart';
import 'controllers/video_controller.dart';
import 'controllers/camera_controller.dart';
import 'controllers/detection_controller.dart';
import 'controllers/storage_controller.dart';
import 'views/home_view.dart';
import 'views/camera_view.dart';
import 'views/video_player_view.dart';
import 'views/analysis_results_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeView()),
        GetPage(name: '/camera', page: () => const CameraView()),
        GetPage(name: '/video-player', page: () => const VideoPlayerView()),
        GetPage(name: '/analysis-results', page: () => const AnalysisResultsView()),
      ],
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoController>(() => VideoController());
    Get.lazyPut<CameraControllerX>(() => CameraControllerX());
    Get.lazyPut<DetectionController>(() => DetectionController());
    Get.lazyPut<StorageController>(() => StorageController());
  }
}

// config/constants.dart
class AppConstants {
  static const String appName = 'Vision Guard';
  static const String appVersion = '1.0.0';
  
  // Configuración de ML
  static const double defaultConfidenceThreshold = 0.5;
  static const int defaultFrameSkip = 5;
  static const double defaultDetectionFPS = 5.0;
  
  // Límites
  static const int maxVideoDurationMinutes = 10;
  static const int maxVideoSizeMB = 500;
  static const int maxStorageGB = 5;
  
  // Colores de severidad
  static const Map<String, int> severityColors = {
    'low': 0xFF4CAF50,
    'medium': 0xFFFFC107,
    'high': 0xFFFF9800,
    'critical': 0xFFF44336,
  };
  
  // Iconos de comportamiento
  static const Map<String, String> behaviorIcons = {
    'intoxication': '🍺',
    'violence': '⚔️',
    'theft': '🚨',
    'fall': '🏥',
    'suspicious': '👁️',
    'aggression': '💢',
    'normal': '✅',
  };
  
}