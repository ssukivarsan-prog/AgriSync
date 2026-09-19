import 'package:flutter/material.dart';
import '../models/scan_result.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionBoxModel> detections;
  final Size imageOriginalSize;

  BoundingBoxPainter({
    required this.detections,
    required this.imageOriginalSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    final scaleX = size.width / (imageOriginalSize.width > 0 ? imageOriginalSize.width : 416.0);
    final scaleY = size.height / (imageOriginalSize.height > 0 ? imageOriginalSize.height : 416.0);

    final boxPaint = Paint()
      ..color = const Color(0xFFC2410C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final bgPaint = Paint()
      ..color = const Color(0xFFC2410C)
      ..style = PaintingStyle.fill;

    for (final det in detections) {
      if (det.bbox.length < 4) continue;

      final x1 = det.bbox[0] * scaleX;
      final y1 = det.bbox[1] * scaleY;
      final x2 = det.bbox[2] * scaleX;
      final y2 = det.bbox[3] * scaleY;

      final rect = Rect.fromLTRB(x1, y1, x2, y2);
      canvas.drawRect(rect, boxPaint);

      // Label text (clear, bold font for farmers)
      final textSpan = TextSpan(
        text: '${det.className} ${(det.confidence * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelRect = Rect.fromLTWH(
        x1,
        y1 > 22 ? y1 - 22 : y1,
        textPainter.width + 10,
        textPainter.height + 4,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(5)),
        bgPaint,
      );

      textPainter.paint(canvas, Offset(x1 + 5, y1 > 22 ? y1 - 20 : y1 + 2));
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.detections != detections ||
        oldDelegate.imageOriginalSize != imageOriginalSize;
  }
}
