import 'package:flutter/material.dart';

class CardOverlayPainter extends CustomPainter {
  final double cardWidth;
  final double cardHeight;

  CardOverlayPainter({required this.cardWidth, required this.cardHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final left = (size.width - cardWidth) / 2;
    final top = (size.height - cardHeight) / 2;

    final clearRect = Rect.fromLTWH(left, top, cardWidth, cardHeight);
    canvas.drawRect(clearRect, paint..blendMode = BlendMode.clear);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(clearRect, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
