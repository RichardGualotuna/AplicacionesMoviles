// widgets/camera_overlay.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/detection_model.dart';

class CameraOverlay extends StatelessWidget {
  final List<DetectionModel> detections;
  final Size previewSize;
  
  const CameraOverlay({
    Key? key,
    required this.detections,
    required this.previewSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (detections.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      size: Size.infinite,
      painter: DetectionPainter(
        detections: detections,
        previewSize: previewSize,
      ),
    );
  }
}

class DetectionPainter extends CustomPainter {
  final List<DetectionModel> detections;
  final Size previewSize;

  DetectionPainter({
    required this.detections,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var detection in detections) {
      // Calcular posición real en pantalla
      final rect = Rect.fromLTWH(
        detection.boundingBox.x * size.width,
        detection.boundingBox.y * size.height,
        detection.boundingBox.width * size.width,
        detection.boundingBox.height * size.height,
      );

      // Color basado en el tipo de objeto
      final color = _getColorForLabel(detection.label);
      
      // Dibujar bounding box
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawRect(rect, paint);

      // Dibujar fondo para texto
      final textBackgroundPaint = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      final textRect = Rect.fromLTWH(
        rect.left,
        rect.top - 25,
        120,
        25,
      );

      canvas.drawRect(textRect, textBackgroundPaint);

      // Dibujar texto
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${detection.label} ${(detection.confidence * 100).toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left + 5, rect.top - 22),
      );
    }
  }

  Color _getColorForLabel(String label) {
    switch (label) {
      case 'person':
        return Colors.green;
      case 'car':
        return Colors.blue;
      case 'knife':
      case 'gun':
        return Colors.red;
      case 'bottle':
        return Colors.orange;
      case 'cell phone':
        return Colors.purple;
      case 'chair':
        return Colors.teal;
      case 'backpack':
        return Colors.indigo;
      default:
        return Colors.yellow;
    }
  }

  @override
  bool shouldRepaint(DetectionPainter oldDelegate) => true;
}