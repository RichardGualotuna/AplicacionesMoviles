// widgets/detection_overlay_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/detection_model.dart';
import '../controllers/detection_controller.dart';

class DetectionOverlayWidget extends StatelessWidget {
  final RxList<DetectionModel> detections;
  final double aspectRatio;
  final bool showLabels;
  final bool showConfidence;
  final double opacity;

  DetectionOverlayWidget({
    super.key,
    required this.detections,
    required this.aspectRatio,
    this.showLabels = true,
    this.showConfidence = true,
    this.opacity = 0.7,
  });

  final DetectionController detectionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (detections.isEmpty) {
        return const SizedBox.shrink();
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: DetectionPainter(
              detections: detections,
              aspectRatio: aspectRatio,
              showLabels: showLabels && detectionController.showLabels.value,
              showConfidence: showConfidence && detectionController.showConfidence.value,
              opacity: detectionController.boundingBoxOpacity.value,
              labelColors: detectionController.labelColors,
            ),
          );
        },
      );
    });
  }
}

class DetectionPainter extends CustomPainter {
  final List<DetectionModel> detections;
  final double aspectRatio;
  final bool showLabels;
  final bool showConfidence;
  final double opacity;
  final Map<String, int> labelColors;

  DetectionPainter({
    required this.detections,
    required this.aspectRatio,
    required this.showLabels,
    required this.showConfidence,
    required this.opacity,
    required this.labelColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale factors
    final scaleX = size.width;
    final scaleY = size.height;

    for (var detection in detections) {
      // Get color for this label
      final colorValue = labelColors[detection.label] ?? 0xFFFFFFFF;
      final color = Color(colorValue).withOpacity(opacity);

      // Draw bounding box
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final rect = Rect.fromLTWH(
        detection.boundingBox.x * scaleX,
        detection.boundingBox.y * scaleY,
        detection.boundingBox.width * scaleX,
        detection.boundingBox.height * scaleY,
      );

      canvas.drawRect(rect, paint);

      // Draw corners for emphasis
      _drawCorners(canvas, rect, color);

      // Draw label and confidence
      if (showLabels || showConfidence) {
        _drawLabel(
          canvas,
          rect,
          detection.label,
          detection.confidence,
          color,
        );
      }
    }
  }

  void _drawCorners(Canvas canvas, Rect rect, Color color) {
    final cornerLength = 20.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + cornerLength),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - cornerLength),
      Offset(rect.right, rect.bottom),
      paint,
    );
  }

  void _drawLabel(
    Canvas canvas,
    Rect rect,
    String label,
    double confidence,
    Color color,
  ) {
    String text = '';
    if (showLabels) text += label;
    if (showLabels && showConfidence) text += ' ';
    if (showConfidence) text += '${(confidence * 100).toInt()}%';

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        backgroundColor: color.withOpacity(0.7),
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Position label above the box
    final labelOffset = Offset(
      rect.left,
      rect.top - textPainter.height - 2,
    );

    // Draw background for label
    final backgroundRect = Rect.fromLTWH(
      labelOffset.dx - 2,
      labelOffset.dy - 1,
      textPainter.width + 4,
      textPainter.height + 2,
    );

    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(backgroundRect, const Radius.circular(2)),
      backgroundPaint,
    );

    // Draw text
    textPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(DetectionPainter oldDelegate) {
    return detections != oldDelegate.detections ||
           showLabels != oldDelegate.showLabels ||
           showConfidence != oldDelegate.showConfidence ||
           opacity != oldDelegate.opacity;
  }
}