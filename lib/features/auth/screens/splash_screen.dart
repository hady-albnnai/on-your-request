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
        duration: const Duration(milliseconds: 1400));
    _fade  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.7, end: 1)
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
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF3E3A33), Color(0xFF2D2A25)],
                  ),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: AppColors.wheat400, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: AppColors.wheat400.withValues(alpha: 0.3),
                        blurRadius: 28, spreadRadius: 2),
                    BoxShadow(color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: CustomPaint(painter: WheatCrownPainter()),
              ),
              const SizedBox(height: 28),
              const Text(AppStrings.appName,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900,
                    color: AppColors.wheat300, fontFamily: 'Cairo', letterSpacing: 2)),
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

/// سنبلتا قمح مقوستان تلتقيان من الأسفل كالتاج
class WheatCrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2 + 6;

    // نقطة الالتقاء في الأسفل المنتصف
    final meetX = cx;
    final meetY = cy + 26.0;

    // ── ألوان الحبات ──────────────────────────────────────────────────
    const colorLight  = Color(0xFFEEC84A);
    const colorMid    = Color(0xFFD9A030);
    const colorDark   = Color(0xFFC28B22);
    const colorAwn    = Color(0xFFF5D87A);
    const colorStem   = Color(0xFFD4982A);

    // ── دالة رسم حبة ناعمة ───────────────────────────────────────────
    void drawGrain(double x, double y, double angle, double w, double h) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      // حبة ناعمة جداً - بيضاوية مستطيلة ممدودة
      final grainPath = Path()
        ..moveTo(0, -h * 0.5)
        ..cubicTo( w * 0.42, -h * 0.35,  w * 0.42,  h * 0.35,  0,  h * 0.5)
        ..cubicTo(-w * 0.42,  h * 0.35, -w * 0.42, -h * 0.35,  0, -h * 0.5);

      // تعبئة متدرجة
      canvas.drawPath(grainPath,
          Paint()..color = colorLight..style = PaintingStyle.fill);
      // ظل داخلي
      canvas.drawPath(grainPath,
          Paint()..color = colorDark..style = PaintingStyle.stroke..strokeWidth = 0.6);
      // خط وسط ناعم
      canvas.drawLine(Offset(0, -h * 0.28), Offset(0, h * 0.28),
          Paint()..color = colorMid..strokeWidth = 0.5
              ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
      canvas.restore();
    }

    // ── دالة رسم شارب (awn) ──────────────────────────────────────────
    void drawAwn(double x, double y, double angle, double len) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawLine(
        Offset(0, 0), Offset(0, -len),
        Paint()..color = colorAwn..strokeWidth = 0.9
            ..strokeCap = StrokeCap.round..style = PaintingStyle.stroke,
      );
      canvas.restore();
    }

    // ── دالة رسم سنبلة مقوسة ─────────────────────────────────────────
    void drawCurvedStalk({
      required bool isLeft,
    }) {
      // نقطة البداية (الالتقاء)
      final x0 = meetX;
      final y0 = meetY;

      // نقطة النهاية (القمة)
      final topX = isLeft ? cx - 30.0 : cx + 30.0;
      final topY = cy - 38.0;

      // نقطة تحكم القوس - تعطي الانحناء الطبيعي للسنبلة
      final ctrlX = isLeft ? cx - 28.0 : cx + 28.0;
      final ctrlY = cy + 2.0;

      // رسم الساق المقوسة
      final stemPath = Path()
        ..moveTo(x0, y0)
        ..quadraticBezierTo(ctrlX, ctrlY, topX, topY);

      canvas.drawPath(stemPath,
          Paint()..color = colorStem..strokeWidth = 2.0
              ..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);

      // ── وضع الحبات على طول المنحنى ───────────────────────────────
      // نحسب نقاطاً على المنحنى ونرسم الحبات عليها
      const numGrains = 5;
      for (int i = 0; i < numGrains; i++) {
        final t  = (i + 1) / (numGrains + 1.0);
        final mt = 1 - t;

        // نقطة على المنحنى Bezier
        final gx = mt * mt * x0 + 2 * mt * t * ctrlX + t * t * topX;
        final gy = mt * mt * y0 + 2 * mt * t * ctrlY + t * t * topY;

        // المماس (اتجاه الساق) لتوجيه الحبات
        final tx2 = 2 * mt * (ctrlX - x0) + 2 * t * (topX - ctrlX);
        final ty2 = 2 * mt * (ctrlY - y0) + 2 * t * (topY - ctrlY);
        final stemAngle = math.atan2(tx2, -ty2);

        // زاوية عمودية على الساق لوضع الحبات
        final perpAngle = stemAngle + math.pi / 2;

        final gw = 5.5 - i * 0.3;
        final gh = 10.0 - i * 0.6;

        // حبة يمين السنبلة
        final rx = gx + math.cos(perpAngle) * (gw + 2.5);
        final ry = gy + math.sin(perpAngle) * (gw + 2.5);
        drawGrain(rx, ry, stemAngle + (isLeft ? 0.4 : -0.4), gw, gh);
        drawAwn(rx, ry, stemAngle + (isLeft ? 0.3 : -0.3) - math.pi, 8 - i * 0.5);

        // حبة يسار السنبلة
        final lx = gx - math.cos(perpAngle) * (gw + 2.5);
        final ly = gy - math.sin(perpAngle) * (gw + 2.5);
        drawGrain(lx, ly, stemAngle + (isLeft ? -0.4 : 0.4), gw, gh);
        drawAwn(lx, ly, stemAngle + (isLeft ? -0.3 : 0.3) - math.pi, 8 - i * 0.5);
      }

      // ── الحبة القمة ──────────────────────────────────────────────
      final tx3 = 2 * 0 * (ctrlX - x0) + 2 * 1 * (topX - ctrlX);
      final ty3 = 2 * 0 * (ctrlY - y0) + 2 * 1 * (topY - ctrlY);
      final topStemAngle = math.atan2(tx3, -ty3);

      drawGrain(topX, topY - 5, topStemAngle, 5.5, 10);
      drawAwn(topX, topY - 10, topStemAngle - math.pi, 10);
      // شارب إضافي للقمة
      drawAwn(topX - 3, topY - 8,
          topStemAngle - math.pi + (isLeft ? 0.4 : -0.4), 8);
      drawAwn(topX + 3, topY - 8,
          topStemAngle - math.pi + (isLeft ? -0.4 : 0.4), 8);
    }

    // ── رسم السنبلتين ─────────────────────────────────────────────────
    drawCurvedStalk(isLeft: true);
    drawCurvedStalk(isLeft: false);

    // ── نقطة الالتقاء + خط زخرفي ─────────────────────────────────────
    // دائرة صغيرة في نقطة الالتقاء
    canvas.drawCircle(
      Offset(meetX, meetY),
      3.5,
      Paint()..color = colorMid..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(meetX, meetY),
      3.5,
      Paint()..color = colorDark..style = PaintingStyle.stroke..strokeWidth = 0.8,
    );

    // خط منحنٍ أسفل نقطة الالتقاء
    final basePath = Path()
      ..moveTo(cx - 22, meetY + 5)
      ..quadraticBezierTo(cx, meetY + 10, cx + 22, meetY + 5);
    canvas.drawPath(basePath,
        Paint()..color = colorDark..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_) => false;
}
