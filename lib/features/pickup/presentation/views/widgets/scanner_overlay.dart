import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_colors.dart';

/// Full-rectangle viewfinder drawn on top of the camera preview.
///
/// The rectangle is purely decorative — it guides the user to center the
/// counter QR within the camera frame. The actual detection area is the full
/// [MobileScanner] widget underneath.
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment(0, -0.5),
      child: SizedBox(
        width: 220,
        height: 220,
        child: CustomPaint(painter: _RectPainter()),
      ),
    );
  }
}

class _RectPainter extends CustomPainter {
  const _RectPainter();

  static const double _stroke = 2.5;
  static const double _radius = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = _stroke
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(_radius),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
