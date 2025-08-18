// views/camera_view.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../controllers/camera_controller.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/behavior_alert_widget.dart';
import '../controllers/video_controller.dart';

class CameraView extends StatefulWidget {
 const CameraView({super.key});

 @override
 State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
 final CameraControllerX cameraController = Get.find();
 double _currentZoom = 1.0;
 double _minZoom = 1.0;
 double _maxZoom = 1.0;

 @override
 void initState() {
   super.initState();
   WidgetsBinding.instance.addObserver(this);
   _initializeCamera();
 }

 @override
 void dispose() {
   WidgetsBinding.instance.removeObserver(this);
   super.dispose();
 }

 @override
 void didChangeAppLifecycleState(AppLifecycleState state) {
   if (state == AppLifecycleState.inactive) {
     cameraController.cameraController?.dispose();
   } else if (state == AppLifecycleState.resumed) {
     _initializeCamera();
   }
 }

 Future<void> _initializeCamera() async {
   await cameraController.initializeCameras();
   final zoomLevels = await cameraController.getZoomLevels();
   setState(() {
     _minZoom = zoomLevels['min']!;
     _maxZoom = zoomLevels['max']!;
     _currentZoom = _minZoom;
   });
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.black,
     body: SafeArea(
       child: Obx(() {
         if (!cameraController.isInitialized.value) {
           return const Center(
             child: CircularProgressIndicator(color: Colors.white),
           );
         }

         return Stack(
  children: [
    // Camera Preview
    Center(
      child: AspectRatio(
        aspectRatio: cameraController.cameraController!.value.aspectRatio,
        child: CameraPreview(cameraController.cameraController!),
      ),
    ),

    // Detection Overlay - MEJORADO
    if (cameraController.isRealTimeAnalysis.value &&
        cameraController.showBoundingBoxes.value)
      Positioned.fill(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Obx(() => CameraOverlay(
              detections: cameraController.liveDetections,
              previewSize: Size(constraints.maxWidth, constraints.maxHeight),
            ));
          },
        ),
      ),

    // Resto del código...

             // Top Controls
             Positioned(
               top: 0,
               left: 0,
               right: 0,
               child: Container(
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     begin: Alignment.topCenter,
                     end: Alignment.bottomCenter,
                     colors: [
                       Colors.black.withOpacity(0.7),
                       Colors.transparent,
                     ],
                   ),
                 ),
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     // Back Button
                     IconButton(
                       icon: const Icon(Icons.arrow_back, color: Colors.white),
                       onPressed: () => Get.back(),
                     ),

                     // Status Indicators
                     Row(
                       children: [
                         if (cameraController.isRecording.value)
                           Container(
                             padding: const EdgeInsets.symmetric(
                               horizontal: 12,
                               vertical: 6,
                             ),
                             decoration: BoxDecoration(
                               color: Colors.red,
                               borderRadius: BorderRadius.circular(20),
                             ),
                             child: Row(
                               children: [
                                 const Icon(
                                   Icons.fiber_manual_record,
                                   color: Colors.white,
                                   size: 12,
                                 ),
                                 const SizedBox(width: 4),
                                 Text(
                                   'REC',
                                   style: const TextStyle(
                                     color: Colors.white,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         const SizedBox(width: 8),
                         if (cameraController.isRealTimeAnalysis.value)
                           Container(
                             padding: const EdgeInsets.symmetric(
                               horizontal: 12,
                               vertical: 6,
                             ),
                             decoration: BoxDecoration(
                               color: Colors.green,
                               borderRadius: BorderRadius.circular(20),
                             ),
                             child: Row(
                               children: [
                                 const Icon(
                                   Icons.analytics,
                                   color: Colors.white,
                                   size: 16,
                                 ),
                                 const SizedBox(width: 4),
                                 Text(
                                   'AI',
                                   style: const TextStyle(
                                     color: Colors.white,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                       ],
                     ),

                     // Settings
                     IconButton(
                       icon: const Icon(Icons.settings, color: Colors.white),
                       onPressed: _showCameraSettings,
                     ),
                   ],
                 ),
               ),
             ),

             // Behavior Alerts
             if (cameraController.liveBehaviors.isNotEmpty)
               Positioned(
                 top: 80,
                 left: 16,
                 right: 16,
                 child: BehaviorAlertWidget(
                   behavior: cameraController.liveBehaviors.last,
                 ),
               ),

             // Zoom Slider
             Positioned(
               right: 16,
               top: 150,
               bottom: 150,
               child: RotatedBox(
                 quarterTurns: 3,
                 child: SizedBox(
                   width: 300,
                   child: Slider(
                     value: _currentZoom,
                     min: _minZoom,
                     max: _maxZoom,
                     onChanged: (value) {
                       setState(() {
                         _currentZoom = value;
                       });
                       cameraController.setZoomLevel(value);
                     },
                   ),
                 ),
               ),
             ),

             // Zoom Indicator
             Positioned(
               right: 16,
               bottom: 140,
               child: Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: Colors.black54,
                   borderRadius: BorderRadius.circular(20),
                 ),
                 child: Text(
                   '${_currentZoom.toStringAsFixed(1)}x',
                   style: const TextStyle(
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             ),

             // Bottom Controls
             Positioned(
               bottom: 0,
               left: 0,
               right: 0,
               child: Container(
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     begin: Alignment.bottomCenter,
                     end: Alignment.topCenter,
                     colors: [
                       Colors.black.withOpacity(0.7),
                       Colors.transparent,
                     ],
                   ),
                 ),
                 padding: const EdgeInsets.all(20),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                     // Flash Toggle
                     _buildControlButton(
                       icon: _getFlashIcon(),
                       onPressed: () => cameraController.toggleFlash(),
                     ),

                     // AI Analysis Toggle
                     _buildControlButton(
                       icon: cameraController.isRealTimeAnalysis.value
                           ? Icons.visibility
                           : Icons.visibility_off,
                       onPressed: () {
                         if (cameraController.isRealTimeAnalysis.value) {
                           cameraController.stopRealTimeAnalysis();
                         } else {
                           cameraController.startRealTimeAnalysis();
                         }
                       },
                       isActive: cameraController.isRealTimeAnalysis.value,
                     ),

                     // Main Action Button (Record/Stop/Capture)
                     GestureDetector(
                       onTap: _handleMainAction,
                       child: Container(
                         width: 70,
                         height: 70,
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           border: Border.all(
                             color: Colors.white,
                             width: 4,
                           ),
                           color: cameraController.isRecording.value
                               ? Colors.red
                               : Colors.transparent,
                         ),
                         child: cameraController.isRecording.value
                             ? const Icon(
                                 Icons.stop,
                                 color: Colors.white,
                                 size: 30,
                               )
                             : Container(
                                 margin: const EdgeInsets.all(8),
                                 decoration: const BoxDecoration(
                                   shape: BoxShape.circle,
                                   color: Colors.white,
                                 ),
                               ),
                       ),
                     ),

                     // Photo Capture
                     _buildControlButton(
                       icon: Icons.photo_camera,
                       onPressed: cameraController.isRecording.value
                           ? null
                           : () async {
                               final photo = await cameraController.takePicture();
                               if (photo != null) {
                                 Get.snackbar(
                                   'Foto guardada',
                                   photo.path,
                                   snackPosition: SnackPosition.TOP,
                                   backgroundColor: Colors.green,
                                   colorText: Colors.white,
                                 );
                               }
                             },
                     ),

                     // Switch Camera
                     _buildControlButton(
                       icon: Icons.flip_camera_ios,
                       onPressed: () => cameraController.switchCamera(),
                     ),
                   ],
                 ),
               ),
             ),

             // Detection Count Badge
             if (cameraController.liveDetections.isNotEmpty)
               Positioned(
                 left: 16,
                 bottom: 140,
                 child: Container(
                   padding: const EdgeInsets.symmetric(
                     horizontal: 12,
                     vertical: 6,
                   ),
                   decoration: BoxDecoration(
                     color: Colors.black54,
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Row(
                     children: [
                       const Icon(
                         Icons.remove_red_eye,
                         color: Colors.white,
                         size: 16,
                       ),
                       const SizedBox(width: 4),
                       Text(
                         '${cameraController.liveDetections.length}',
                         style: const TextStyle(
                           color: Colors.white,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                     ],
                   ),
                 ),
               ),

             // Processing Indicator
             if (cameraController.isProcessing.value)
               Positioned(
                 top: 80,
                 right: 16,
                 child: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: Colors.orange,
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Row(
                     children: [
                       SizedBox(
                         width: 12,
                         height: 12,
                         child: CircularProgressIndicator(
                           strokeWidth: 2,
                           valueColor: AlwaysStoppedAnimation<Color>(
                             Colors.white,
                           ),
                         ),
                       ),
                       const SizedBox(width: 8),
                       const Text(
                         'Procesando',
                         style: TextStyle(
                           color: Colors.white,
                           fontSize: 12,
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
           ],
         );
       }),
     ),
   );
 }

 Widget _buildControlButton({
   required IconData icon,
   VoidCallback? onPressed,
   bool isActive = false,
 }) {
   return Container(
     decoration: BoxDecoration(
       shape: BoxShape.circle,
       color: isActive ? Colors.white24 : Colors.transparent,
     ),
     child: IconButton(
       icon: Icon(icon),
       color: Colors.white,
       iconSize: 28,
       onPressed: onPressed,
     ),
   );
 }

 IconData _getFlashIcon() {
   switch (cameraController.flashMode.value) {
     case FlashMode.off:
       return Icons.flash_off;
     case FlashMode.auto:
       return Icons.flash_auto;
     case FlashMode.always:
       return Icons.flash_on;
     case FlashMode.torch:
       return Icons.flashlight_on;
   }
 }

 void _handleMainAction() async {
   if (cameraController.isRecording.value) {
     final video = await cameraController.stopRecording();
     if (video != null) {
       Get.dialog(
         AlertDialog(
           title: const Text('Video Grabado'),
           content: const Text('¿Qué deseas hacer con el video?'),
           actions: [
             TextButton(
               onPressed: () => Get.back(),
               child: const Text('Cancelar'),
             ),
             TextButton(
               onPressed: () {
                 Get.back();
                 Get.back();
                 Get.find<VideoController>().selectedVideo.value = video;
               },
               child: const Text('Analizar'),
             ),
           ],
         ),
       );
     }
   } else {
     await cameraController.startRecording();
   }
 }

 void _showCameraSettings() {
   Get.bottomSheet(
     Container(
       padding: const EdgeInsets.all(16),
       decoration: const BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
       ),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           const Text(
             'Configuración de Cámara',
             style: TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
             ),
           ),
           const SizedBox(height: 16),
           
           // FPS de detección
           Obx(() => ListTile(
             title: const Text('FPS de Detección'),
             subtitle: Slider(
               value: cameraController.detectionFPS.value,
               min: 1,
               max: 10,
               divisions: 9,
               label: cameraController.detectionFPS.value.toString(),
               onChanged: (value) {
                 cameraController.detectionFPS.value = value;
               },
             ),
             trailing: Text('${cameraController.detectionFPS.value.toInt()} fps'),
           )),
           
           // Mostrar cajas delimitadoras
           Obx(() => SwitchListTile(
             title: const Text('Mostrar Detecciones'),
             subtitle: const Text('Muestra cajas alrededor de objetos detectados'),
             value: cameraController.showBoundingBoxes.value,
             onChanged: (value) {
               cameraController.showBoundingBoxes.value = value;
             },
           )),
           
           // Alertas de audio
           Obx(() => SwitchListTile(
             title: const Text('Alertas de Audio'),
             subtitle: const Text('Reproduce sonidos para comportamientos críticos'),
             value: cameraController.enableAudioAlerts.value,
             onChanged: (value) {
               cameraController.enableAudioAlerts.value = value;
             },
           )),
         ],
       ),
     ),
   );
 }
}
