// views/analysis_results_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_behavior_analyzer/models/video_model.dart';
import '../controllers/video_controller.dart';
import '../controllers/detection_controller.dart';
import '../models/detection_model.dart';
import '../config/constants.dart';
import '../widgets/behavior_alert_widget.dart';
import '../widgets/detection_overlay_widget.dart';
import '../widgets/video_preview_widget.dart';
import '../config/themes.dart';
import '../models/behavior_model.dart';


class AnalysisResultsView extends StatefulWidget {
  const AnalysisResultsView({super.key});

  @override
  State<AnalysisResultsView> createState() => _AnalysisResultsViewState();
}

class _AnalysisResultsViewState extends State<AnalysisResultsView>
    with SingleTickerProviderStateMixin {
  final VideoController videoController = Get.find();
  final DetectionController detectionController = Get.find();
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Actualizar estadísticas
    detectionController.updateStatistics(
      videoController.currentDetections,
      videoController.detectedBehaviors,
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados del Análisis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Detecciones'),
            Tab(text: 'Comportamientos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResults,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildDetectionsTab(),
          _buildBehaviorsTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    final videoModel = videoController.currentVideoModel.value;
    
    if (videoModel == null) {
      return const Center(
        child: Text('No hay datos de análisis disponibles'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.video_file, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Video ${videoModel.id.substring(0, 8)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              _formatDateTime(videoModel.timestamp),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Duración', _formatDuration(videoModel.duration)),
                  _buildInfoRow('Fuente', videoModel.source == VideoSource.camera ? 'Cámara' : 'Galería'),
                  _buildInfoRow('Detecciones totales', videoModel.detections.length.toString()),
                  _buildInfoRow('Comportamientos', videoModel.behaviors.length.toString()),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Statistics Overview
          Obx(() {
            final detectionSummary = detectionController.getDetectionSummary(
              videoController.currentDetections,
            );
            final behaviorSummary = detectionController.getBehaviorSummary(
              videoController.detectedBehaviors,
            );
            
            return Column(
              children: [
                // Detection Statistics
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estadísticas de Detección',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: [
                           _buildStatItem(
                             'Total',
                             detectionSummary['total'].toString(),
                             Icons.remove_red_eye,
                             Colors.blue,
                           ),
                           _buildStatItem(
                             'Confianza Prom.',
                             '${(detectionSummary['averageConfidence'] * 100).toStringAsFixed(1)}%',
                             Icons.analytics,
                             Colors.green,
                           ),
                           _buildStatItem(
                             'Alertas',
                             detectionSummary['alerts'].toString(),
                             Icons.warning,
                             Colors.orange,
                           ),
                         ],
                       ),
                       const SizedBox(height: 16),
                       // Detection counts by label
                       if (detectionController.detectionCounts.isNotEmpty) ...[
                         const Divider(),
                         const SizedBox(height: 8),
                         Text(
                           'Por Tipo de Objeto',
                           style: Theme.of(context).textTheme.titleMedium,
                         ),
                         const SizedBox(height: 8),
                         Wrap(
                           spacing: 8,
                           runSpacing: 8,
                           children: detectionController.detectionCounts.entries
                               .map((entry) => Chip(
                                     label: Text('${entry.key}: ${entry.value}'),
                                     backgroundColor: Color(
                                       detectionController.getColorForLabel(entry.key),
                                     ).withOpacity(0.2),
                                   ))
                               .toList(),
                         ),
                       ],
                     ],
                   ),
                 ),
               ),
               
               const SizedBox(height: 16),
               
               // Behavior Statistics
               Card(
                 child: Padding(
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         'Estadísticas de Comportamiento',
                         style: Theme.of(context).textTheme.titleLarge,
                       ),
                       const SizedBox(height: 16),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: [
                           _buildStatItem(
                             'Total',
                             behaviorSummary['total'].toString(),
                             Icons.psychology,
                             Colors.purple,
                           ),
                           _buildStatItem(
                             'Críticos',
                             behaviorSummary['criticalCount'].toString(),
                             Icons.error,
                             Colors.red,
                           ),
                           _buildStatItem(
                             'Alertas',
                             behaviorSummary['alerts'].toString(),
                             Icons.notification_important,
                             Colors.orange,
                           ),
                         ],
                       ),
                       const SizedBox(height: 16),
                       // Severity distribution
                       if ((behaviorSummary['bySeverity'] as Map).isNotEmpty) ...[
                         const Divider(),
                         const SizedBox(height: 8),
                         Text(
                           'Por Severidad',
                           style: Theme.of(context).textTheme.titleMedium,
                         ),
                         const SizedBox(height: 8),
                         _buildSeverityChart(behaviorSummary['bySeverity']),
                       ],
                     ],
                   ),
                 ),
               ),
             ],
           );
         }),
         
         const SizedBox(height: 16),
         
         // Alert Summary
         if (videoController.detectedBehaviors
             .where((b) => b.severity == SeverityLevel.critical || 
                          b.severity == SeverityLevel.high)
             .isNotEmpty)
           Card(
             color: Theme.of(context).colorScheme.errorContainer,
             child: Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Icon(
                         Icons.warning_amber,
                         color: Theme.of(context).colorScheme.error,
                       ),
                       const SizedBox(width: 8),
                       Text(
                         'Alertas Importantes',
                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
                           color: Theme.of(context).colorScheme.error,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 12),
                   ...videoController.detectedBehaviors
                       .where((b) => b.severity == SeverityLevel.critical || 
                                    b.severity == SeverityLevel.high)
                       .map((b) => Padding(
                             padding: const EdgeInsets.symmetric(vertical: 4),
                             child: Row(
                               children: [
                                 Text(
                                   AppConstants.behaviorIcons[b.type.toString().split('.').last] ?? '⚠️',
                                   style: const TextStyle(fontSize: 20),
                                 ),
                                 const SizedBox(width: 8),
                                 Expanded(
                                   child: Text(
                                     '${_getBehaviorName(b.type)} - ${_formatTime(b.startTime)}',
                                     style: TextStyle(
                                       color: Theme.of(context).colorScheme.error,
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ))
                       ,
                 ],
               ),
             ),
           ),
       ],
     ),
   );
 }

 Widget _buildDetectionsTab() {
   return Obx(() {
     final filteredDetections = detectionController.filterDetections(
       videoController.currentDetections,
     );

     if (filteredDetections.isEmpty) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const Icon(Icons.search_off, size: 64),
             const SizedBox(height: 16),
             const Text('No se encontraron detecciones'),
             const SizedBox(height: 8),
             TextButton(
               onPressed: () => detectionController.resetFilters(),
               child: const Text('Limpiar filtros'),
             ),
           ],
         ),
       );
     }

     return ListView.builder(
       padding: const EdgeInsets.all(8),
       itemCount: filteredDetections.length,
       itemBuilder: (context, index) {
         final detection = filteredDetections[index];
         return Card(
           margin: const EdgeInsets.symmetric(vertical: 4),
           child: ListTile(
             leading: Container(
               width: 40,
               height: 40,
               decoration: BoxDecoration(
                 color: Color(detectionController.getColorForLabel(detection.label))
                     .withOpacity(0.2),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Center(
                 child: Icon(
                   _getIconForLabel(detection.label),
                   color: Color(detectionController.getColorForLabel(detection.label)),
                 ),
               ),
             ),
             title: Text(
               detection.label.toUpperCase(),
               style: const TextStyle(fontWeight: FontWeight.bold),
             ),
             subtitle: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text('Confianza: ${(detection.confidence * 100).toStringAsFixed(1)}%'),
                 Text('Frame: ${detection.frameNumber}'),
                 Text('Tiempo: ${_formatTime(detection.timestamp)}'),
               ],
             ),
             trailing: detectionController.requiresAlert(detection)
                 ? const Icon(Icons.warning, color: Colors.orange)
                 : null,
             onTap: () => _showDetectionDetails(detection),
           ),
         );
       },
     );
   });
 }

 Widget _buildBehaviorsTab() {
   return Obx(() {
     final filteredBehaviors = detectionController.filterBehaviors(
       videoController.detectedBehaviors,
     );

     if (filteredBehaviors.isEmpty) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const Icon(Icons.psychology_outlined, size: 64),
             const SizedBox(height: 16),
             const Text('No se detectaron comportamientos'),
             const SizedBox(height: 8),
             if (detectionController.selectedBehaviors.isNotEmpty ||
                 detectionController.minSeverity.value != null)
               TextButton(
                 onPressed: () => detectionController.resetFilters(),
                 child: const Text('Limpiar filtros'),
               ),
           ],
         ),
       );
     }

     // Agrupar comportamientos por tipo
     final groupedBehaviors = <BehaviorType, List<BehaviorModel>>{};
     for (var behavior in filteredBehaviors) {
       groupedBehaviors.putIfAbsent(behavior.type, () => []).add(behavior);
     }

     return ListView.builder(
       padding: const EdgeInsets.all(8),
       itemCount: groupedBehaviors.length,
       itemBuilder: (context, index) {
         final type = groupedBehaviors.keys.elementAt(index);
         final behaviors = groupedBehaviors[type]!;
         
         return Card(
           margin: const EdgeInsets.symmetric(vertical: 8),
           child: ExpansionTile(
             leading: Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: _getColorForSeverity(
                   behaviors.map((b) => b.severity).reduce(
                     (a, b) => _getHigherSeverity(a, b),
                   ),
                 ).withOpacity(0.2),
                 shape: BoxShape.circle,
               ),
               child: Text(
                 AppConstants.behaviorIcons[type.toString().split('.').last] ?? '❓',
                 style: const TextStyle(fontSize: 20),
               ),
             ),
             title: Text(
               _getBehaviorName(type),
               style: const TextStyle(fontWeight: FontWeight.bold),
             ),
             subtitle: Text('${behaviors.length} detección(es)'),
             children: behaviors.map((behavior) => ListTile(
               leading: const SizedBox(width: 40),
               title: Row(
                 children: [
                   Container(
                     width: 12,
                     height: 12,
                     decoration: BoxDecoration(
                       color: _getColorForSeverity(behavior.severity),
                       shape: BoxShape.circle,
                     ),
                   ),
                   const SizedBox(width: 8),
                   Text(
                     _getSeverityName(behavior.severity),
                     style: TextStyle(
                       color: _getColorForSeverity(behavior.severity),
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ],
               ),
               subtitle: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Confianza: ${(behavior.confidence * 100).toStringAsFixed(1)}%'),
                   Text('Inicio: ${_formatTime(behavior.startTime)}'),
                   if (behavior.endTime != null)
                     Text('Fin: ${_formatTime(behavior.endTime!)}'),
                   if (behavior.involvedPersonIds.isNotEmpty)
                     Text('Personas involucradas: ${behavior.involvedPersonIds.length}'),
                 ],
               ),
               trailing: detectionController.behaviorRequiresAlert(behavior)
                   ? const Icon(Icons.notification_important, color: Colors.red)
                   : null,
               onTap: () => _showBehaviorDetails(behavior),
             )).toList(),
           ),
         );
       },
     );
   });
 }

 Widget _buildInfoRow(String label, String value) {
   return Padding(
     padding: const EdgeInsets.symmetric(vertical: 4),
     child: Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         Text(
           label,
           style: Theme.of(context).textTheme.bodyMedium,
         ),
         Text(
           value,
           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
             fontWeight: FontWeight.bold,
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildStatItem(String label, String value, IconData icon, Color color) {
   return Column(
     children: [
       Icon(icon, color: color, size: 32),
       const SizedBox(height: 8),
       Text(
         value,
         style: const TextStyle(
           fontSize: 20,
           fontWeight: FontWeight.bold,
         ),
       ),
       Text(
         label,
         style: Theme.of(context).textTheme.bodySmall,
       ),
     ],
   );
 }

 Widget _buildSeverityChart(Map<SeverityLevel, int> severityData) {
   final total = severityData.values.fold(0, (a, b) => a + b);
   
   return Column(
     children: severityData.entries.map((entry) {
       final percentage = (entry.value / total * 100).toStringAsFixed(1);
       
       return Padding(
         padding: const EdgeInsets.symmetric(vertical: 4),
         child: Row(
           children: [
             Container(
               width: 12,
               height: 12,
               decoration: BoxDecoration(
                 color: _getColorForSeverity(entry.key),
                 shape: BoxShape.circle,
               ),
             ),
             const SizedBox(width: 8),
             SizedBox(
               width: 80,
               child: Text(_getSeverityName(entry.key)),
             ),
             Expanded(
               child: LinearProgressIndicator(
                 value: entry.value / total,
                 backgroundColor: Colors.grey.shade300,
                 valueColor: AlwaysStoppedAnimation<Color>(
                   _getColorForSeverity(entry.key),
                 ),
               ),
             ),
             const SizedBox(width: 8),
             Text('$percentage%'),
           ],
         ),
       );
     }).toList(),
   );
 }

 void _showFilterDialog() {
   Get.dialog(
     AlertDialog(
       title: const Text('Filtros'),
       content: SingleChildScrollView(
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             // Filtro de confianza mínima
             Obx(() => Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text('Confianza mínima: ${(detectionController.minConfidence.value * 100).toInt()}%'),
                 Slider(
                   value: detectionController.minConfidence.value,
                   min: 0,
                   max: 1,
                   divisions: 20,
                   onChanged: (value) {
                     detectionController.minConfidence.value = value;
                   },
                 ),
               ],
             )),
             
             const Divider(),
             
             // Filtro de severidad
             Obx(() => DropdownButtonFormField<SeverityLevel?>(
               value: detectionController.minSeverity.value,
               decoration: const InputDecoration(
                 labelText: 'Severidad mínima',
               ),
               items: [
                 const DropdownMenuItem(
                   value: null,
                   child: Text('Todas'),
                 ),
                 ...SeverityLevel.values.map((severity) => DropdownMenuItem(
                   value: severity,
                   child: Text(_getSeverityName(severity)),
                 )),
               ],
               onChanged: (value) {
                 detectionController.minSeverity.value = value;
               },
             )),
           ],
         ),
       ),
       actions: [
         TextButton(
           onPressed: () {
             detectionController.resetFilters();
             Get.back();
           },
           child: const Text('Resetear'),
         ),
         TextButton(
           onPressed: () => Get.back(),
           child: const Text('Aplicar'),
         ),
       ],
     ),
   );
 }

 void _showDetectionDetails(DetectionModel detection) {
   Get.dialog(
     AlertDialog(
       title: Text(detection.label.toUpperCase()),
       content: Column(
         mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           _buildDetailRow('Confianza', '${(detection.confidence * 100).toStringAsFixed(2)}%'),
           _buildDetailRow('Frame', detection.frameNumber.toString()),
           _buildDetailRow('Timestamp', _formatTime(detection.timestamp)),
           const SizedBox(height: 8),
           const Text('Bounding Box:', style: TextStyle(fontWeight: FontWeight.bold)),
           _buildDetailRow('X', detection.boundingBox.x.toStringAsFixed(2)),
           _buildDetailRow('Y', detection.boundingBox.y.toStringAsFixed(2)),
           _buildDetailRow('Ancho', detection.boundingBox.width.toStringAsFixed(2)),
           _buildDetailRow('Alto', detection.boundingBox.height.toStringAsFixed(2)),
         ],
       ),
       actions: [
         TextButton(
           onPressed: () => Get.back(),
           child: const Text('Cerrar'),
         ),
       ],
     ),
   );
 }

 void _showBehaviorDetails(BehaviorModel behavior) {
   Get.dialog(
     AlertDialog(
       title: Text(_getBehaviorName(behavior.type)),
       content: SingleChildScrollView(
         child: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             _buildDetailRow('ID', behavior.id),
             _buildDetailRow('Confianza', '${(behavior.confidence * 100).toStringAsFixed(2)}%'),
             _buildDetailRow('Severidad', _getSeverityName(behavior.severity)),
             _buildDetailRow('Inicio', _formatTime(behavior.startTime)),
             if (behavior.endTime != null)
               _buildDetailRow('Fin', _formatTime(behavior.endTime!)),
             if (behavior.involvedPersonIds.isNotEmpty) ...[
               const SizedBox(height: 8),
               const Text('Personas involucradas:', style: TextStyle(fontWeight: FontWeight.bold)),
               ...behavior.involvedPersonIds.map((id) => Text('• $id')),
             ],
             if (behavior.metadata.isNotEmpty) ...[
               const SizedBox(height: 8),
               const Text('Metadata:', style: TextStyle(fontWeight: FontWeight.bold)),
               ...behavior.metadata.entries.map((entry) => 
                 _buildDetailRow(entry.key, entry.value.toString()),
               ),
             ],
           ],
         ),
       ),
       actions: [
         TextButton(
           onPressed: () => Get.back(),
           child: const Text('Cerrar'),
         ),
       ],
     ),
   );
 }

 Widget _buildDetailRow(String label, String value) {
   return Padding(
     padding: const EdgeInsets.symmetric(vertical: 2),
     child: Row(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         SizedBox(
           width: 100,
           child: Text(
             '$label:',
             style: const TextStyle(fontWeight: FontWeight.w500),
           ),
         ),
         Expanded(
           child: Text(value),
         ),
       ],
     ),
   );
 }

 void _shareResults() {
   // Implementar compartir resultados
   // Usar package share_plus
   Get.snackbar(
     'Compartir',
     'Funcionalidad de compartir en desarrollo',
     snackPosition: SnackPosition.BOTTOM,
   );
 }

 // Utilidades
 String _formatDateTime(DateTime dateTime) {
   return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
 }

 String _formatTime(DateTime time) {
   return '${time.hour}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
 }

 String _formatDuration(Duration duration) {
   String twoDigits(int n) => n.toString().padLeft(2, '0');
   String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
   String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
   return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
 }

 IconData _getIconForLabel(String label) {
   final icons = {
     'person': Icons.person,
     'car': Icons.directions_car,
     'bicycle': Icons.directions_bike,
     'dog': Icons.pets,
     'cat': Icons.pets,
     'knife': Icons.restaurant,
     'gun': Icons.warning,
     'backpack': Icons.backpack,
     'bottle': Icons.local_drink,
     'chair': Icons.chair,
     'laptop': Icons.laptop,
     'cell phone': Icons.phone_android,
   };
   return icons[label] ?? Icons.help_outline;
 }

 String _getBehaviorName(BehaviorType type) {
   final names = {
     BehaviorType.intoxication: 'Intoxicación',
     BehaviorType.violence: 'Violencia',
     BehaviorType.theft: 'Robo',
     BehaviorType.fall: 'Caída',
     BehaviorType.suspicious: 'Comportamiento Sospechoso',
     BehaviorType.aggression: 'Agresión',
     BehaviorType.normal: 'Normal',
   };
   return names[type] ?? type.toString();
 }

 String _getSeverityName(SeverityLevel severity) {
   final names = {
     SeverityLevel.low: 'Baja',
     SeverityLevel.medium: 'Media',
     SeverityLevel.high: 'Alta',
     SeverityLevel.critical: 'Crítica',
   };
   return names[severity] ?? severity.toString();
 }

 Color _getColorForSeverity(SeverityLevel severity) {
   final colors = {
     SeverityLevel.low: Colors.green,
     SeverityLevel.medium: Colors.orange,
     SeverityLevel.high: Colors.deepOrange,
     SeverityLevel.critical: Colors.red,
   };
   return colors[severity] ?? Colors.grey;
 }

 SeverityLevel _getHigherSeverity(SeverityLevel a, SeverityLevel b) {
   final order = {
     SeverityLevel.low: 0,
     SeverityLevel.medium: 1,
     SeverityLevel.high: 2,
     SeverityLevel.critical: 3,
   };
   return order[a]! > order[b]! ? a : b;
 }
}