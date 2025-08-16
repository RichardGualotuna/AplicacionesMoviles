// widgets/video_preview_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewWidget extends StatefulWidget {
  final File videoFile;
  final double? height;
  final bool showControls;
  final VoidCallback? onTap;

  const VideoPreviewWidget({
    super.key,
    required this.videoFile,
    this.height,
    this.showControls = true,
    this.onTap,
 });

 @override
 State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
 VideoPlayerController? _controller;
 bool _isInitialized = false;
 bool _isPlaying = false;
 bool _hasError = false;

 @override
 void initState() {
   super.initState();
   _initializeVideo();
 }

 @override
 void dispose() {
   _controller?.dispose();
   super.dispose();
 }

 Future<void> _initializeVideo() async {
   try {
     _controller = VideoPlayerController.file(widget.videoFile);
     await _controller!.initialize();
     
     setState(() {
       _isInitialized = true;
     });
   } catch (e) {
     print('Error initializing video preview: $e');
     setState(() {
       _hasError = true;
     });
   }
 }

 @override
 Widget build(BuildContext context) {
   if (_hasError) {
     return Container(
       height: widget.height ?? 200,
       decoration: BoxDecoration(
         color: Colors.grey.shade200,
         borderRadius: BorderRadius.circular(8),
       ),
       child: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(
               Icons.error_outline,
               size: 48,
               color: Colors.grey.shade600,
             ),
             const SizedBox(height: 8),
             Text(
               'Error al cargar el video',
               style: TextStyle(color: Colors.grey.shade600),
             ),
           ],
         ),
       ),
     );
   }

   if (!_isInitialized) {
     return Container(
       height: widget.height ?? 200,
       decoration: BoxDecoration(
         color: Colors.grey.shade200,
         borderRadius: BorderRadius.circular(8),
       ),
       child: const Center(
         child: CircularProgressIndicator(),
       ),
     );
   }

   return GestureDetector(
     onTap: widget.onTap ?? () {
       if (widget.showControls) {
         setState(() {
           if (_isPlaying) {
             _controller?.pause();
           } else {
             _controller?.play();
           }
           _isPlaying = !_isPlaying;
         });
       }
     },
     child: Container(
       height: widget.height ?? 200,
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(8),
         color: Colors.black,
       ),
       child: ClipRRect(
         borderRadius: BorderRadius.circular(8),
         child: Stack(
           alignment: Alignment.center,
           children: [
             AspectRatio(
               aspectRatio: _controller!.value.aspectRatio,
               child: VideoPlayer(_controller!),
             ),
             
             if (widget.showControls && !_isPlaying)
               Container(
                 decoration: BoxDecoration(
                   color: Colors.black26,
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: const Icon(
                   Icons.play_circle_outline,
                   size: 64,
                   color: Colors.white,
                 ),
               ),
             
             // Duration overlay
             Positioned(
               bottom: 8,
               right: 8,
               child: Container(
                 padding: const EdgeInsets.symmetric(
                   horizontal: 8,
                   vertical: 4,
                 ),
                 decoration: BoxDecoration(
                   color: Colors.black54,
                   borderRadius: BorderRadius.circular(4),
                 ),
                 child: Text(
                   _formatDuration(_controller!.value.duration),
                   style: const TextStyle(
                     color: Colors.white,
                     fontSize: 12,
                   ),
                 ),
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }

 String _formatDuration(Duration duration) {
   String twoDigits(int n) => n.toString().padLeft(2, '0');
   final minutes = twoDigits(duration.inMinutes.remainder(60));
   final seconds = twoDigits(duration.inSeconds.remainder(60));
   if (duration.inHours > 0) {
     return '${twoDigits(duration.inHours)}:$minutes:$seconds';
   }
   return '$minutes:$seconds';
 }
}