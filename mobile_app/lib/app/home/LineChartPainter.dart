// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // --- DYNAMIQUE : change ici pour tester d'autres courbes ---
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.1),
      Offset(size.width, size.height * 0.3),
    ];
    // ----------------------------------------------------------

    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];

      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      linePath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );
    }

    canvas.drawPath(linePath, linePaint);

    final fillPath = Path.from(linePath);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final pt in points) {
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(pt, 5, borderPaint);
    }

    // Optionnel : labels
    const textStyle = TextStyle(
      color: Colors.black54,
      fontSize: 12,
    );
    for (int i = 0; i < points.length; i++) {
      final textSpan = TextSpan(
        text: '${i + 1}',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(points[i].dx - 10, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}