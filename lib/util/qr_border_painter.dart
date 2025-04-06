import 'package:flutter/material.dart';

class QRBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  final double gapSize;

  QRBorderPainter({
    required this.borderColor,
    this.borderWidth = 2.0,
    this.cornerRadius = 20.0,
    this.gapSize = 30.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;

    // 计算每条边的长度（减去两个圆角和中间的间隙）
    final sideLength = (width - 2 * cornerRadius - gapSize) / 2;

    // 绘制左上角
    final path1 =
        Path()
          ..moveTo(cornerRadius, 0)
          ..lineTo(cornerRadius + sideLength, 0);
    path1.addArc(
      Rect.fromLTWH(0, 0, cornerRadius * 2, cornerRadius * 2),
      3 * 3.14159 / 2,
      3.14159 / 2,
    );
    path1.lineTo(0, cornerRadius + sideLength);

    // 绘制右上角
    final path2 =
        Path()
          ..moveTo(width - cornerRadius - sideLength, 0)
          ..lineTo(width - cornerRadius, 0);
    path2.addArc(
      Rect.fromLTWH(
        width - cornerRadius * 2,
        0,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      3 * 3.14159 / 2,
      -3.14159 / 2,
    );
    path2.lineTo(width, cornerRadius + sideLength);

    // 绘制左下角
    final path3 =
        Path()
          ..moveTo(0, height - cornerRadius - sideLength)
          ..lineTo(0, height - cornerRadius);
    path3.addArc(
      Rect.fromLTWH(
        0,
        height - cornerRadius * 2,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      3.14159,
      3.14159 / 2,
    );
    path3.lineTo(cornerRadius + sideLength, height);

    // 绘制右下角
    final path4 =
        Path()
          ..moveTo(width, height - cornerRadius - sideLength)
          ..lineTo(width, height - cornerRadius);
    path4.addArc(
      Rect.fromLTWH(
        width - cornerRadius * 2,
        height - cornerRadius * 2,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      0,
      3.14159 / 2,
    );
    path4.lineTo(width - cornerRadius - sideLength, height);

    // 绘制所有路径
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is QRBorderPainter &&
        (oldDelegate.borderColor != borderColor ||
            oldDelegate.borderWidth != borderWidth ||
            oldDelegate.cornerRadius != cornerRadius ||
            oldDelegate.gapSize != gapSize);
  }
}
