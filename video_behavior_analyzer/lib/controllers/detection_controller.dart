// controllers/detection_controller.dart
import 'package:get/get.dart';
import '../models/detection_model.dart';
import '../models/behavior_model.dart';

class DetectionController extends GetxController {
  // Filtros observables
  final RxList<String> selectedLabels = <String>[].obs;
  final RxDouble minConfidence = 0.5.obs;
  final RxList<BehaviorType> selectedBehaviors = <BehaviorType>[].obs;
  final Rx<SeverityLevel?> minSeverity = Rx<SeverityLevel?>(null);
  
  // Estadísticas
  final RxMap<String, int> detectionCounts = <String, int>{}.obs;
  final RxMap<BehaviorType, int> behaviorCounts = <BehaviorType, int>{}.obs;
  
  // Configuración de visualización
  final RxBool showLabels = true.obs;
  final RxBool showConfidence = true.obs;
  final RxBool showBoundingBoxes = true.obs;
  final RxDouble boundingBoxOpacity = 0.7.obs;
  final RxMap<String, int> labelColors = <String, int>{}.obs;
  
  // Alertas
  final RxList<String> alertLabels = <String>['person', 'knife', 'gun'].obs;
  final RxList<BehaviorType> alertBehaviors = <BehaviorType>[
    BehaviorType.violence,
    BehaviorType.theft,
    BehaviorType.fall,
  ].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeLabelColors();
  }

  void _initializeLabelColors() {
    // Colores predefinidos para etiquetas comunes
    labelColors.value = {
      'person': 0xFF4CAF50,
      'car': 0xFF2196F3,
      'bicycle': 0xFFFF9800,
      'motorcycle': 0xFFFF5722,
      'dog': 0xFF795548,
      'cat': 0xFF9C27B0,
      'knife': 0xFFFF0000,
      'gun': 0xFFCC0000,
      'backpack': 0xFF607D8B,
      'handbag': 0xFF673AB7,
      'bottle': 0xFF00BCD4,
      'chair': 0xFF8BC34A,
      'couch': 0xFFCDDC39,
      'bed': 0xFFFFC107,
      'dining table': 0xFFFF9800,
      'laptop': 0xFF3F51B5,
      'cell phone': 0xFF009688,
    };
  }

  // Filtrar detecciones
  List<DetectionModel> filterDetections(List<DetectionModel> detections) {
    return detections.where((detection) {
      // Filtrar por confianza
      if (detection.confidence < minConfidence.value) {
        return false;
      }
      
      // Filtrar por etiquetas seleccionadas
      if (selectedLabels.isNotEmpty && 
          !selectedLabels.contains(detection.label)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Filtrar comportamientos
  List<BehaviorModel> filterBehaviors(List<BehaviorModel> behaviors) {
    return behaviors.where((behavior) {
      // Filtrar por tipo de comportamiento
      if (selectedBehaviors.isNotEmpty && 
          !selectedBehaviors.contains(behavior.type)) {
        return false;
      }
      
      // Filtrar por severidad mínima
      if (minSeverity.value != null) {
        final severityOrder = {
          SeverityLevel.low: 0,
          SeverityLevel.medium: 1,
          SeverityLevel.high: 2,
          SeverityLevel.critical: 3,
        };
        
        if (severityOrder[behavior.severity]! < 
            severityOrder[minSeverity.value]!) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

// Actualizar estadísticas
 void updateStatistics(List<DetectionModel> detections, List<BehaviorModel> behaviors) {
   // Contar detecciones por etiqueta
   final newDetectionCounts = <String, int>{};
   for (var detection in detections) {
     newDetectionCounts[detection.label] = 
         (newDetectionCounts[detection.label] ?? 0) + 1;
   }
   detectionCounts.value = newDetectionCounts;
   
   // Contar comportamientos por tipo
   final newBehaviorCounts = <BehaviorType, int>{};
   for (var behavior in behaviors) {
     newBehaviorCounts[behavior.type] = 
         (newBehaviorCounts[behavior.type] ?? 0) + 1;
   }
   behaviorCounts.value = newBehaviorCounts;
 }

 // Verificar si una detección requiere alerta
 bool requiresAlert(DetectionModel detection) {
   return alertLabels.contains(detection.label) && 
          detection.confidence >= minConfidence.value;
 }

 // Verificar si un comportamiento requiere alerta
 bool behaviorRequiresAlert(BehaviorModel behavior) {
   return alertBehaviors.contains(behavior.type);
 }

 // Obtener color para una etiqueta
 int getColorForLabel(String label) {
   return labelColors[label] ?? 0xFF9E9E9E; // Gris por defecto
 }

 // Agregar nueva etiqueta para alertas
 void addAlertLabel(String label) {
   if (!alertLabels.contains(label)) {
     alertLabels.add(label);
   }
 }

 // Remover etiqueta de alertas
 void removeAlertLabel(String label) {
   alertLabels.remove(label);
 }

 // Agregar comportamiento para alertas
 void addAlertBehavior(BehaviorType behavior) {
   if (!alertBehaviors.contains(behavior)) {
     alertBehaviors.add(behavior);
   }
 }

 // Remover comportamiento de alertas
 void removeAlertBehavior(BehaviorType behavior) {
   alertBehaviors.remove(behavior);
 }

 // Resetear filtros
 void resetFilters() {
   selectedLabels.clear();
   minConfidence.value = 0.5;
   selectedBehaviors.clear();
   minSeverity.value = null;
 }

 // Obtener resumen de detecciones
 Map<String, dynamic> getDetectionSummary(List<DetectionModel> detections) {
   final filtered = filterDetections(detections);
   
   return {
     'total': filtered.length,
     'byLabel': detectionCounts,
     'averageConfidence': filtered.isEmpty ? 0.0 : 
         filtered.map((d) => d.confidence).reduce((a, b) => a + b) / filtered.length,
     'alerts': filtered.where((d) => requiresAlert(d)).length,
   };
 }

 // Obtener resumen de comportamientos
 Map<String, dynamic> getBehaviorSummary(List<BehaviorModel> behaviors) {
   final filtered = filterBehaviors(behaviors);
   
   Map<SeverityLevel, int> severityCounts = {};
   for (var behavior in filtered) {
     severityCounts[behavior.severity] = 
         (severityCounts[behavior.severity] ?? 0) + 1;
   }
   
   return {
     'total': filtered.length,
     'byType': behaviorCounts,
     'bySeverity': severityCounts,
     'criticalCount': severityCounts[SeverityLevel.critical] ?? 0,
     'alerts': filtered.where((b) => behaviorRequiresAlert(b)).length,
   };
 }

 // Exportar configuración
 Map<String, dynamic> exportSettings() {
   return {
     'selectedLabels': selectedLabels.toList(),
     'minConfidence': minConfidence.value,
     'selectedBehaviors': selectedBehaviors.map((b) => b.toString()).toList(),
     'minSeverity': minSeverity.value?.toString(),
     'showLabels': showLabels.value,
     'showConfidence': showConfidence.value,
     'showBoundingBoxes': showBoundingBoxes.value,
     'boundingBoxOpacity': boundingBoxOpacity.value,
     'alertLabels': alertLabels.toList(),
     'alertBehaviors': alertBehaviors.map((b) => b.toString()).toList(),
   };
 }

void importSettings(Map<String, dynamic> settings) {
    if (settings['selectedLabels'] != null) {
      selectedLabels.value = List<String>.from(settings['selectedLabels']);
    }
    
    if (settings['minConfidence'] != null) {
      minConfidence.value = settings['minConfidence'];
    }
    
    if (settings['selectedBehaviors'] != null) {
      selectedBehaviors.value = (settings['selectedBehaviors'] as List)
          .map((b) => BehaviorType.values.firstWhere(
              (type) => type.toString() == b,
              orElse: () => BehaviorType.normal))
          .toList();
    }
    
    if (settings['minSeverity'] != null) {
      minSeverity.value = SeverityLevel.values.firstWhereOrNull(
          (s) => s.toString() == settings['minSeverity']);
    }
    
    showLabels.value = settings['showLabels'] ?? true;
    showConfidence.value = settings['showConfidence'] ?? true;
    showBoundingBoxes.value = settings['showBoundingBoxes'] ?? true;
    boundingBoxOpacity.value = settings['boundingBoxOpacity'] ?? 0.7;
    
    if (settings['alertLabels'] != null) {
      alertLabels.value = List<String>.from(settings['alertLabels']);
    }
    
    if (settings['alertBehaviors'] != null) {
      alertBehaviors.value = (settings['alertBehaviors'] as List)
          .map((b) => BehaviorType.values.firstWhere(
              (type) => type.toString() == b,
              orElse: () => BehaviorType.normal))
          .toList();
    }
  }
}

// Extensión para firstWhereOrNull
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}