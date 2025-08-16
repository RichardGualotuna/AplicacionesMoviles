// views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:video_behavior_analyzer/models/behavior_model.dart';
import '../controllers/video_controller.dart';
import '../controllers/storage_controller.dart';
import '../widgets/video_preview_widget.dart';
import '../models/video_model.dart';
import '../config/themes.dart';
import '../config/constants.dart';
import '../views/analysis_results_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  final VideoController videoController = Get.find();
  final StorageController storageController = Get.find();
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Vision Guard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Inicio'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Estadísticas'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildHistoryTab(),
          _buildStatisticsTab(),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera_alt),
            label: 'Cámara',
            backgroundColor: Colors.blue,
            onTap: () => Get.toNamed('/camera'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.video_library),
            label: 'Galería',
            backgroundColor: Colors.green,
            onTap: () => videoController.pickVideoFromGallery(),
          ),
          SpeedDialChild(
            child: const Icon(Icons.videocam),
            label: 'Grabar',
            backgroundColor: Colors.red,
            onTap: () => videoController.recordVideoFromCamera(),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Obx(() {
      if (videoController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Estado del Sistema',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusIndicator(
                          'ML Service',
                          videoController.currentStatus.value.contains('inicializado'),
                        ),
                        _buildStatusIndicator(
                          'Cámara',
                          true,
                        ),
                        _buildStatusIndicator(
                          'Almacenamiento',
                          storageController.storagePercentage.value < 0.9,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Current Video Section
            if (videoController.selectedVideo.value != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video Seleccionado',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      VideoPreviewWidget(
                        videoFile: videoController.selectedVideo.value!,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: videoController.isAnalyzing.value
                                ? null
                                : () => videoController.analyzeVideo(),
                            icon: const Icon(Icons.analytics),
                            label: const Text('Analizar'),
                          ),
                          if (videoController.isAnalyzing.value)
                            CircularPercentIndicator(
                              radius: 30.0,
                              lineWidth: 4.0,
                              percent: videoController.analysisProgress.value,
                              center: Text(
                                '${(videoController.analysisProgress.value * 100).toInt()}%',
                                style: const TextStyle(fontSize: 12),
                              ),
                              progressColor: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                child: InkWell(
                  onTap: () => videoController.pickVideoFromGallery(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_call,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selecciona o graba un video',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toca aquí o usa el botón +',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Quick Actions
            Text(
              'Acciones Rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.camera,
                    label: 'Cámara en Vivo',
                    onTap: () => Get.toNamed('/camera'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.folder,
                    label: 'Ver Historial',
                    onTap: () => _tabController.animateTo(1),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHistoryTab() {
    return Obx(() {
      if (videoController.videoHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay videos analizados',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => videoController.loadVideoHistory(),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: videoController.videoHistory.length,
          itemBuilder: (context, index) {
            final video = videoController.videoHistory[index];
            return _buildHistoryItem(video);
          },
        ),
      );
    });
  }

  Widget _buildHistoryItem(VideoModel video) {
    final behaviorCount = video.behaviors.length;
    final hasCritical = video.behaviors.any(
      (b) => b.severity == SeverityLevel.critical,
    );
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Stack(
          children: [
            const Icon(Icons.video_file, size: 40),
            if (hasCritical)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          'Video ${video.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDateTime(video.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (behaviorCount > 0)
              Text(
                '$behaviorCount comportamientos detectados',
                style: TextStyle(
                  color: hasCritical ? Colors.red : Colors.orange,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                videoController.loadPreviousAnalysis(video.id);
                Get.toNamed('/analysis-results');
                break;
              case 'delete':
                _confirmDelete(video.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Ver análisis'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          videoController.loadPreviousAnalysis(video.id);
          Get.toNamed('/analysis-results');
        },
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: videoController.getStatistics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        final behaviorCounts = stats['behavior_counts'] as Map<String, int>? ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Videos Totales',
                      value: stats['total_videos'].toString(),
                      icon: Icons.video_library,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Detecciones',
                      value: stats['total_detections'].toString(),
                      icon: Icons.remove_red_eye,
                      color: Colors.green,
                    ),
                  ),
                ],
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
                        'Comportamientos Detectados',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (behaviorCounts.isEmpty)
                        const Center(
                          child: Text('No hay comportamientos registrados'),
                        )
                      else
                        ...behaviorCounts.entries.map((entry) {
                          final type = entry.key.split('.').last;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  _getBehaviorIcon(type),
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _getBehaviorName(type),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Storage Info
              Obx(() => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Almacenamiento',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: storageController.storagePercentage.value,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Usado: ${storageController.getFormattedStorageUsed()}',
                          ),
                          Text(
                            'Disponible: ${storageController.getFormattedAvailableSpace()}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        storageController.getCleanupRecommendation(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Gestión de Almacenamiento'),
              onTap: () {
                Get.back();
                _showStorageManagement();
              },
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Configuración de Detección'),
              onTap: () {
                Get.back();
                _showDetectionSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.import_export),
              title: const Text('Exportar Datos'),
              onTap: () {
                Get.back();
                videoController.exportData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Acerca de'),
              onTap: () {
                Get.back();
                _showAbout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStorageManagement() {
    // Implementar diálogo de gestión de almacenamiento
  }

  void _showDetectionSettings() {
    // Implementar diálogo de configuración de detección
  }

  void _showAbout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Vision Guard'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Versión 1.0.0'),
            SizedBox(height: 8),
            Text('Sistema de análisis de video con IA'),
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

  void _confirmDelete(String videoId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar Video'),
        content: const Text('¿Estás seguro de eliminar este video y su análisis?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              videoController.deleteVideo(videoId);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getBehaviorIcon(String type) {
    final icons = {
      'intoxication': '🍺',
      'violence': '⚔️',
      'theft': '🚨',
      'fall': '🏥',
      'suspicious': '👁️',
      'aggression': '💢',
      'normal': '✅',
    };
    return icons[type] ?? '❓';
  }

  String _getBehaviorName(String type) {
    final names = {
      'intoxication': 'Intoxicación',
      'violence': 'Violencia',
      'theft': 'Robo',
      'fall': 'Caída',
      'suspicious': 'Sospechoso',
      'aggression': 'Agresión',
      'normal': 'Normal',
    };
    return names[type] ?? type;
  }
}