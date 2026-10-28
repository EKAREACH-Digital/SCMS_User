import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// Renders [data] as a black QR code using the `qr` package matrix.
/// The white background is provided by the caller's container.
class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key, required this.data, required this.size});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    // QrCode.fromData auto-selects the smallest type number that fits the data.
    final code = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    return CustomPaint(
      size: Size(size, size),
      painter: _QrPainter(qrImage: QrImage(code)),
    );
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter({required this.qrImage});

  final QrImage qrImage;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final moduleCount = qrImage.moduleCount;
    final moduleSize = size.width / moduleCount;

    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (qrImage.isDark(row, col)) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * moduleSize,
              row * moduleSize,
              moduleSize,
              moduleSize,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => qrImage != oldDelegate.qrImage;
}
