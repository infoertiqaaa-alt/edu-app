import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// ويدجت QR مرسومة يدويًا بـ CustomPainter فوق مكتبة qr (مش qr_flutter)
class QrCodeWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color color;
  final Color backgroundColor;

  const QrCodeWidget({
    super.key,
    required this.data,
    this.size = 200,
    this.color = Colors.black,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _QrCodePainter(
          data: data,
          color: color,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  final String data;
  final Color color;
  final Color backgroundColor;

  _QrCodePainter({
    required this.data,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    if (data.isEmpty) return;

    // QrPayload.fromString بتحدد حجم الكود (version) المناسب للبيانات
    // تلقائيًا، فمش محتاجين نحسب typeNumber بإيدينا زي الـ API القديم
    final qrCode = QrCode(
      payload: QrPayload.fromString(data),
      errorCorrectLevel: QrErrorCorrectLevel.low,
    );
    final qrImage = QrImage(qrCode);
    final moduleCount = qrImage.moduleCount;
    final cellSize = size.width / moduleCount;

    final fgPaint = Paint()..color = color;
    for (var x = 0; x < moduleCount; x++) {
      for (var y = 0; y < moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
            fgPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrCodePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}