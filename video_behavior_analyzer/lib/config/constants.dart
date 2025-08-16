// config/constants.dart

class AppConstants {
  // App Info
  static const String appName = 'Vision Guard';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistema de análisis de video con IA para detección de comportamientos';
  static const String developerName = 'Tu Empresa';
  static const String supportEmail = 'support@visionguard.com';
  
  // API & Backend (para futuras implementaciones)
  static const String baseUrl = 'https://api.visionguard.com';
  static const int connectionTimeout = 30000; // milliseconds
  static const int receiveTimeout = 30000;
  
  // ML Model Configuration
  static const double defaultConfidenceThreshold = 0.5;
  static const double minConfidenceThreshold = 0.1;
  static const double maxConfidenceThreshold = 0.95;
  static const int defaultFrameSkip = 5;
  static const double defaultDetectionFPS = 5.0;
  static const int maxDetectionsPerFrame = 100;
  
  // Model Paths
  static const String yoloModelPath = 'assets/models/yolov8n.tflite';
  static const String behaviorModelPath = 'assets/models/behavior_model.tflite';
  static const String labelsPath = 'assets/models/labels.txt';
  
  // Video Configuration
  static const int maxVideoDurationMinutes = 10;
  static const int maxVideoSizeMB = 500;
  static const int maxStorageGB = 5;
  static const int videoQuality = 720; // pixels
  static const int videoBitrate = 3000000; // 3 Mbps
  static const int audioSampleRate = 44100;
  
  // Camera Settings
  static const double minZoom = 1.0;
  static const double maxZoom = 5.0;
  static const int cameraResolutionWidth = 1280;
  static const int cameraResolutionHeight = 720;
  
  // Storage Limits
  static const int maxCacheSizeMB = 500;
  static const int maxTempFileAgeDays = 7;
  static const int defaultStorageWarningThreshold = 90; // percentage
  static const int criticalStorageThreshold = 95; // percentage
  
  // Analysis Settings
  static const int batchSize = 1;
  static const int numThreads = 4;
  static const bool useGPU = false;
  static const int maxPersonTracking = 10;
  static const int trackingHistoryFrames = 30;
  
  // UI Configuration
  static const double defaultBoundingBoxOpacity = 0.7;
  static const double defaultAlertDuration = 5.0; // seconds
  static const int animationDuration = 300; // milliseconds
  static const double cornerRadius = 12.0;
  static const double defaultPadding = 16.0;
  
  // Behavior Thresholds
  static const double intoxicationThreshold = 0.7;
  static const double violenceThreshold = 0.8;
  static const double theftThreshold = 0.6;
  static const double fallThreshold = 0.85;
  static const double suspiciousThreshold = 0.65;
  static const double aggressionThreshold = 0.75;
  
  // Alert Configuration
  static const List<String> criticalLabels = ['knife', 'gun', 'weapon'];
  static const List<String> warningLabels = ['person', 'backpack', 'bag'];
  static const int maxAlertsInQueue = 5;
  static const int alertCooldownSeconds = 10;
  
  // Colors (as integer values for easy storage)
  static const Map<String, int> severityColors = {
    'low': 0xFF4CAF50,      // Green
    'medium': 0xFFFFC107,    // Amber
    'high': 0xFFFF9800,      // Orange
    'critical': 0xFFF44336,  // Red
  };
  
  // Label Colors for Detection
  static const Map<String, int> defaultLabelColors = {
    'person': 0xFF4CAF50,    // Green
    'bicycle': 0xFF2196F3,   // Blue
    'car': 0xFF3F51B5,       // Indigo
    'motorcycle': 0xFF9C27B0, // Purple
    'airplane': 0xFF00BCD4,  // Cyan
    'bus': 0xFFFF9800,       // Orange
    'train': 0xFF795548,     // Brown
    'truck': 0xFF607D8B,     // Blue Grey
    'boat': 0xFF009688,      // Teal
    'traffic light': 0xFFFFEB3B, // Yellow
    'fire hydrant': 0xFFFF5722,  // Deep Orange
    'stop sign': 0xFFFF0000,     // Red
    'parking meter': 0xFF9E9E9E,  // Grey
    'bench': 0xFF8BC34A,          // Light Green
    'bird': 0xFFE91E63,           // Pink
    'cat': 0xFF673AB7,            // Deep Purple
    'dog': 0xFF795548,            // Brown
    'horse': 0xFF3E2723,          // Dark Brown
    'sheep': 0xFFF5F5F5,          // White
    'cow': 0xFF5D4037,            // Brown
    'elephant': 0xFF616161,       // Dark Grey
    'bear': 0xFF6D4C41,           // Brown
    'zebra': 0xFF000000,          // Black
    'giraffe': 0xFFFFB300,        // Amber
    'backpack': 0xFF546E7A,       // Blue Grey
    'umbrella': 0xFF7B1FA2,       // Purple
    'handbag': 0xFFAD1457,        // Pink
    'tie': 0xFF1A237E,            // Indigo
    'suitcase': 0xFF4E342E,       // Brown
    'knife': 0xFFFF0000,          // Red
    'gun': 0xFFCC0000,            // Dark Red
    'bottle': 0xFF0288D1,         // Light Blue
    'wine glass': 0xFF880E4F,     // Wine
    'cup': 0xFFA1887F,            // Brown
    'fork': 0xFFBDBDBD,           // Silver
    'spoon': 0xFFCFD8DC,          // Silver
    'bowl': 0xFF8D6E63,           // Brown
    'banana': 0xFFFFEB3B,         // Yellow
    'apple': 0xFFEF5350,          // Red
    'sandwich': 0xFFFFA726,       // Orange
    'orange': 0xFFFF9800,         // Orange
    'chair': 0xFF5D4037,          // Brown
    'couch': 0xFF37474F,          // Dark Grey
    'bed': 0xFF78909C,            // Blue Grey
    'dining table': 0xFF4E342E,   // Brown
    'laptop': 0xFF455A64,         // Dark Blue Grey
    'cell phone': 0xFF263238,     // Dark
  };
  
  // Behavior Icons
  static const Map<String, String> behaviorIcons = {
    'intoxication': '🍺',
    'violence': '⚔️',
    'theft': '🚨',
    'fall': '🏥',
    'suspicious': '👁️',
    'aggression': '💢',
    'normal': '✅',
  };
  
  // Behavior Descriptions
  static const Map<String, String> behaviorDescriptions = {
    'intoxication': 'Persona en posible estado de ebriedad',
    'violence': 'Acto violento detectado',
    'theft': 'Posible intento de robo',
    'fall': 'Caída detectada - posible emergencia médica',
    'suspicious': 'Comportamiento sospechoso identificado',
    'aggression': 'Comportamiento agresivo detectado',
    'normal': 'Comportamiento normal',
  };
  
  // File Extensions
  static const List<String> supportedVideoFormats = [
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
    '.webm',
    '.m4v',
    '.3gp',
  ];
  
  static const List<String> supportedImageFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
  ];
  
  // Error Messages
  static const Map<String, String> errorMessages = {
    'camera_init_failed': 'No se pudo inicializar la cámara',
    'model_load_failed': 'Error al cargar el modelo de IA',
    'video_load_failed': 'No se pudo cargar el video',
    'storage_full': 'Almacenamiento insuficiente',
    'permission_denied': 'Permiso denegado',
    'network_error': 'Error de conexión',
    'analysis_failed': 'Error durante el análisis',
    'export_failed': 'No se pudo exportar los datos',
    'import_failed': 'No se pudo importar los datos',
    'invalid_format': 'Formato de archivo no válido',
  };
  
  // Success Messages
  static const Map<String, String> successMessages = {
    'video_saved': 'Video guardado exitosamente',
    'analysis_complete': 'Análisis completado',
    'export_success': 'Datos exportados correctamente',
    'import_success': 'Datos importados correctamente',
    'settings_saved': 'Configuración guardada',
    'cache_cleared': 'Caché limpiado exitosamente',
  };
  
  // Regular Expressions
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp phoneRegex = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Notification Channels (Android)
  static const String notificationChannelId = 'vision_guard_alerts';
  static const String notificationChannelName = 'Alertas de Seguridad';
  static const String notificationChannelDescription = 
      'Notificaciones de comportamientos detectados';
}