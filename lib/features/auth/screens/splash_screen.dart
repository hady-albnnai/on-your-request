import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200));
    _fade  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.75, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.nextScreen));
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.basalt800,
      body: Center(
        child: FadeTransition(opacity: _fade,
          child: ScaleTransition(scale: _scale,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // الأيقونة
              Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  color:        AppColors.basalt700,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.wheat400, width: 2.5),
                  boxShadow: [BoxShadow(
                    color: AppColors.wheat400.withValues(alpha: 0.25),
                    blurRadius: 24, spreadRadius: 2)],
                ),
                child: CustomPaint(painter: WheatLogoPainter()),
              ),
              const SizedBox(height: 28),
              const Text(AppStrings.appName,
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900,
                    color: AppColors.wheat300, fontFamily: 'Cairo',
                    letterSpacing: 2)),
              const SizedBox(height: 8),
              const Text(AppStrings.appTagline,
                style: TextStyle(fontSize: 14, color: AppColors.basalt300,
                    fontFamily: 'Cairo')),
            ]),
          )),
      ),
    );
  }
}

/// رسم سنبلة قمح حقيقية
class WheatLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;

    final stemPaint = Paint()
      ..color       = AppColors.wheat400
      ..strokeWidth = 2.5
      ..strokeCap   = StrokeCap.round
      ..style       = PaintingStyle.stroke;

    final grainFill = Paint()
      ..color = AppColors.wheat300
      ..style = PaintingStyle.fill;

    final grainStroke = Paint()
      ..color       = AppColors.wheat500
      ..strokeWidth = 0.8
      ..style       = PaintingStyle.stroke;

    final awns = Paint()
      ..color       = AppColors.wheat200
      ..strokeWidth = 1.0
      ..strokeCap   = StrokeCap.round
      ..style       = PaintingStyle.stroke;

    // ── الساق الرئيسية ───────────────────────────────────────────────
    final top    = cy - size.height * 0.38;
    final bottom = cy + size.height * 0.42;

    // انحناء خفيف للساق
    final stemPath = Path()
      ..moveTo(cx, bottom)
      ..cubicTo(cx + 3, cy + 10, cx - 2, cy - 10, cx, top);
    canvas.drawPath(stemPath, stemPaint);

    // ── دالة رسم حبة قمح ─────────────────────────────────────────────
    void drawGrain(double x, double y, double angle, double w, double h) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      // شكل بيضاوي مدبب
      final grainPath = Path();
      grainPath.moveTo(0, -h / 2);
      grainPath.cubicTo( w/2, -h/4,  w/2, h/4,  0, h/2);
      grainPath.cubicTo(-w/2,  h/4, -w/2, -h/4,  0, -h/2);
      canvas.drawPath(grainPath, grainFill);
      canvas.drawPath(grainPath, grainStroke);
      // خط وسط الحبة
      canvas.drawLine(Offset(0, -h/4), Offset(0, h/4), awns..strokeWidth = 0.5);
      canvas.restore();
    }

    // دالة رسم شارب (awn)
    void drawAwn(double x, double y, double angle, double len) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawLine(Offset.zero, Offset(0, -len), awns..strokeWidth = 1.0);
      canvas.restore();
    }

    // ── الحبات ────────────────────────────────────────────────────────
    // الحبة القمة
    drawGrain(cx, top + 6, 0, 8, 14);
    drawAwn(cx, top - 1, 0, 10);

    // الصف الأول (زوج)
    final r1 = top + 18.0;
    drawGrain(cx - 9, r1, -0.45, 8, 13);
    drawGrain(cx + 9, r1,  0.45, 8, 13);
    drawAwn(cx - 13, r1 - 6, -0.5, 9);
    drawAwn(cx + 13, r1 - 6,  0.5, 9);

    // الصف الثاني
    final r2 = top + 32.0;
    drawGrain(cx - 11, r2, -0.55, 9, 13);
    drawGrain(cx + 11, r2,  0.55, 9, 13);
    drawAwn(cx - 15, r2 - 5, -0.6, 9);
    drawAwn(cx + 15, r2 - 5,  0.6, 9);

    // الصف الثالث
    final r3 = top + 46.0;
    drawGrain(cx - 10, r3, -0.5, 9, 12);
    drawGrain(cx + 10, r3,  0.5, 9, 12);
    drawAwn(cx - 14, r3 - 4, -0.55, 8);
    drawAwn(cx + 14, r3 - 4,  0.55, 8);

    // الصف الرابع
    final r4 = top + 59.0;
    drawGrain(cx - 8, r4, -0.4, 8, 11);
    drawGrain(cx + 8, r4,  0.4, 8, 11);

    // ── أوراق صغيرة على الساق ────────────────────────────────────────
    final leafPaint = Paint()
      ..color = AppColors.wheat600.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // ورقة يسار
    canvas.save();
    canvas.translate(cx, cy + 5);
    canvas.rotate(-0.3);
    final leafL = Path()
      ..moveTo(0, 0)
      ..cubicTo(-12, -4, -18, -12, -10, -18)
      ..cubicTo(-6, -10, -2, -4, 0, 0);
    canvas.drawPath(leafL, leafPaint);
    canvas.restore();

    // ورقة يمين
    canvas.save();
    canvas.translate(cx, cy + 18);
    canvas.rotate(0.35);
    final leafR = Path()
      ..moveTo(0, 0)
      ..cubicTo(12, -4, 17, -11, 9, -16)
      ..cubicTo(5, -9, 2, -4, 0, 0);
    canvas.drawPath(leafR, leafPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_) => false;
}
