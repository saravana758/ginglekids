import 'package:flutter/material.dart';


class DashedBorderPainter extends CustomPainter {
  final Paint _paint;
  final double _dashWidth;
  final double _dashSpace;

  DashedBorderPainter({Color color = Colors.black, double strokeWidth = 2, double dotSize = 3})
      : _paint = Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke,
        _dashWidth = dotSize,
        _dashSpace = dotSize;

  @override
  void paint(Canvas canvas, Size size) {
    bool isPaintingLine = true;

    // Draw top border
    for (double i = 0; i < size.width; i += _dashWidth + _dashSpace) {
      if (isPaintingLine) {
        canvas.drawLine(Offset(i, 0), Offset(i + _dashWidth, 0), _paint);
      }
      isPaintingLine = !isPaintingLine;
    }

    // Draw right border
    for (double i = 0; i < size.height; i += _dashWidth + _dashSpace) {
      if (isPaintingLine) {
        canvas.drawLine(
            Offset(size.width, i), Offset(size.width, i + _dashWidth), _paint);
      }
      isPaintingLine = !isPaintingLine;
    }

    // Draw bottom border
    for (double i = size.width; i > 0; i -= _dashWidth + _dashSpace) {
      if (isPaintingLine) {
        canvas.drawLine(
            Offset(i, size.height), Offset(i - _dashWidth, size.height), _paint);
      }
      isPaintingLine = !isPaintingLine;
    }

    // Draw left border
    for (double i = size.height; i > 0; i -= _dashWidth + _dashSpace) {
      if (isPaintingLine) {
        canvas.drawLine(Offset(0, i), Offset(0, i - _dashWidth), _paint);
      }
      isPaintingLine = !isPaintingLine;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
