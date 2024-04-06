import 'package:Fast_Team/style/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class HeaderCircle extends StatefulWidget {
  final double diameter;

  const HeaderCircle({Key? key, required this.diameter}) : super(key: key);

  @override
  _HeaderCircle createState() => _HeaderCircle();
}

class _HeaderCircle extends State<HeaderCircle> {
  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 2,
      child: CustomPaint(
        painter: CustomCircle(),
        size: Size(ScreenUtil().screenWidth, 280.w),
      ),
    );
  }
}

class CustomCircle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = ColorsTheme.primary!;
    canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.width / 2, 500),
          width: 1200.w,
          height: 800.w,
        ),
        math.pi,
        math.pi,
        false,
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
