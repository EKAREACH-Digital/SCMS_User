import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_colors.dart';

/// [Deprecated_File]
///  Left over from before refactor

/// The bordered camera viewfinder overlay for the QR scanner screen.
///
/// Renders a semi-transparent dark scrim over the camera preview with a
/// transparent cutout rectangle in the centre. Corner marks are drawn with
/// [AppColors.primary] to indicate the scan area.
class QrViewfinder extends StatelessWidget {
  const QrViewfinder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        // Dark scrim with transparent cutout
        _ScrimOverlay(),
        // Corner marks on top of the scrim
        Center(child: _CornerMarks()),
      ],
    );
  }
}

/// Semi-transparent black scrim with a transparent rectangle cutout.
class _ScrimOverlay extends StatelessWidget {
  const _ScrimOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScrimPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ScrimPainter extends CustomPainter {
  static const double _boxSize = 260.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scrimPaint = Paint()
      ..color = const Color(0xBB000000)
      ..blendMode = BlendMode.srcOver;

    final full = Rect.fromLTWH(0, 0, size.width, size.height);
    final cutout = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: _boxSize,
      height: _boxSize,
    );

    final path = Path()
      ..addRect(full)
      ..addRRect(RRect.fromRectAndRadius(cutout, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, scrimPaint);
  }

  @override
  bool shouldRepaint(covariant _ScrimPainter old) => false;
}

/// Four L-shaped corner marks drawn at the corners of the scan area.
class _CornerMarks extends StatelessWidget {
  const _CornerMarks();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: CustomPaint(painter: _CornerMarksPainter()),
    );
  }
}

class _CornerMarksPainter extends CustomPainter {
  static const double _armLength = 28.0;
  static const double _strokeWidth = 4.0;
  static const double _radius = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Top-left
    _drawCorner(canvas, paint, Offset.zero, 1, 1);
    // Top-right
    _drawCorner(canvas, paint, Offset(w, 0), -1, 1);
    // Bottom-left
    _drawCorner(canvas, paint, Offset(0, h), 1, -1);
    // Bottom-right
    _drawCorner(canvas, paint, Offset(w, h), -1, -1);
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint,
    Offset corner,
    double dx,
    double dy,
  ) {
    final path = Path()
      ..moveTo(corner.dx + dx * _armLength, corner.dy)
      ..lineTo(corner.dx + dx * _radius, corner.dy)
      ..arcToPoint(
        Offset(corner.dx, corner.dy + dy * _radius),
        radius: const Radius.circular(_radius),
        clockwise:
            !(dx == 1 && dy == 1) && !(dx == -1 && dy == -1) && (dx != dy),
      )
      ..lineTo(corner.dx, corner.dy + dy * _armLength);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerMarksPainter old) => false;
}
