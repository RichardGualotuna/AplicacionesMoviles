// views/video_player_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/video_controller.dart';
import '../models/detection_model.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  final VideoController videoController = Get.find();
  VideoPlayerController? _videoPlayerController;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  List<DetectionModel> _currentFrameDetections = [];

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    if (videoController.selectedVideo.value == null) return;

    _videoPlayerController = VideoPlayerController.file(
      videoController.selectedVideo.value!,
    );

    await _videoPlayerController!.initialize();
    
    _videoPlayerController!.addListener(_videoListener);
    
    setState(() {
      _duration = _videoPlayerController!.value.duration;
    });
  }

  void _videoListener() {
    if (_videoPlayerController != null) {
      setState(() {
        _position = _videoPlayerController!.value.position;
        _isPlaying = _videoPlayerController!.value.isPlaying;
        
        // Actualizar detecciones para el frame actual
        if (videoController.currentVideoModel.value != null) {
          _updateCurrentFrameDetections();
        }
      });
    }
  }

  void _updateCurrentFrameDetections() {
    if (videoController.currentDetections.isEmpty) return;
    
    // Calcular frame actual basado en posición
    final fps = 30; // Asumimos 30 fps
    final currentFrame = (_position.inMilliseconds * fps / 1000).round();
    
    // Filtrar detecciones para el frame actual
    _currentFrameDetections = videoController.currentDetections
        .where((d) => (d.frameNumber - currentFrame).abs() < 2)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Reproductor de Video'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: videoController.currentVideoModel.value == null
                ? () => videoController.analyzeVideo()
                : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Video Player
            Expanded(
              child: Center(
                child: _videoPlayerController != null &&
                        _videoPlayerController!.value.isInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _videoPlayerController!.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController!),
                          ),
                          
                          // Overlay de detecciones
                          if (_currentFrameDetections.isNotEmpty)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: DetectionPainter(
                                    detections: _currentFrameDetections,
                                    videoSize: _videoPlayerController!.value.size,
                                  ),
                                ),
                              ),
                            ),
                          
                          // Play/Pause Overlay
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: AnimatedOpacity(
                                  opacity: _isPlaying ? 0 : 1,
                                  duration: const Duration(milliseconds: 200),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
            
            // Video Controls
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress Bar
                  Row(
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: _position.inSeconds.toDouble(),
                          max: _duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            _videoPlayerController?.seekTo(
                              Duration(seconds: value.toInt()),
                            );
                          },
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  
                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        color: Colors.white,
                        onPressed: () {
                          final newPosition = _position - const Duration(seconds: 10);
                          _videoPlayerController?.seekTo(
                            newPosition < Duration.zero ? Duration.zero : newPosition,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 40,
                        ),
                        color: Colors.white,
                        onPressed: _togglePlayPause,
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        color: Colors.white,
                        onPressed: () {
                          final newPosition = _position + const Duration(seconds: 10);
                          _videoPlayerController?.seekTo(
                            newPosition > _duration ? _duration : newPosition,
                          );
                        },
                      ),
                    ],
                  ),
                  
                  // Analysis Status
                  Obx(() {
                    if (videoController.isAnalyzing.value) {
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: videoController.analysisProgress.value,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            videoController.currentStatus.value,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePlayPause() {
    if (_videoPlayerController == null) return;
    
    setState(() {
      if (_isPlaying) {
        _videoPlayerController!.pause();
      } else {
        _videoPlayerController!.play();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

// Custom Painter para dibujar detecciones
class DetectionPainter extends CustomPainter {
  final List<DetectionModel> detections;
  final Size videoSize;

  DetectionPainter({
    required this.detections,
    required this.videoSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / videoSize.width;
    final scaleY = size.height / videoSize.height;

    for (var detection in detections) {
      final paint = Paint()
        ..color = _getColorForLabel(detection.label)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final rect = Rect.fromLTWH(
        detection.boundingBox.x * scaleX,
        detection.boundingBox.y * scaleY,
        detection.boundingBox.width * scaleX,
        detection.boundingBox.height * scaleY,
      );

      canvas.drawRect(rect, paint);

      // Dibujar etiqueta
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${detection.label} ${(detection.confidence * 100).toInt()}%',
          style: TextStyle(
            color: _getColorForLabel(detection.label),
            fontSize: 12,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left, rect.top - textPainter.height),
      );
    }
  }

  Color _getColorForLabel(String label) {
    final colors = {
      'person': Colors.green,
      'car': Colors.blue,
      'knife': Colors.red,
      'gun': Colors.red,
    };
    return colors[label] ?? Colors.yellow;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}