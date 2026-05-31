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
                    begin: Alignment.topLeft,
                    end:   Alignment.bottomRight,
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

/// سنبلتا قمح بشكل تاج ذهبي
class WheatCrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2 + 4;

    // ── أقلام الرسم ──────────────────────────────────────────────────
    final stemPaint = Paint()
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round
      ..strokeWidth = 2.2;

    final grainFill = Paint()
      ..style = PaintingStyle.fill;

    final grainStroke = Paint()
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final awnPaint = Paint()
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round
      ..strokeWidth = 1.1;

    // ── دالة رسم حبة قمح ─────────────────────────────────────────────
    void drawGrain(Canvas c, double x, double y, double angle,
        double w, double h, Color fill, Color stroke) {
      c.save();
      c.translate(x, y);
      c.rotate(angle);
      final p = Path()
        ..moveTo(0, -h / 2)
        ..cubicTo( w * 0.55, -h * 0.25,  w * 0.55,  h * 0.25,  0,  h / 2)
        ..cubicTo(-w * 0.55,  h * 0.25, -w * 0.55, -h * 0.25,  0, -h / 2);
      c.drawPath(p, grainFill..color = fill);
      c.drawPath(p, grainStroke..color = stroke);
      // خط وسط
      c.drawLine(Offset(0, -h * 0.3), Offset(0, h * 0.3),
          Paint()..color = stroke..strokeWidth = 0.5);
      c.restore();
    }

    // ── دالة رسم سنبلة كاملة ─────────────────────────────────────────
    void drawWheatStalk(Canvas c, double baseX, double baseY,
        double stemAngle, double spread, bool mirrorAwns) {
      // الساق
      final stemLen = 52.0;
      final topX = baseX + math.sin(stemAngle) * stemLen;
      final topY = baseY - math.cos(stemAngle) * stemLen;

      stemPaint.color = AppColors.wheat500;
      final stemPath = Path()
        ..moveTo(baseX, baseY)
        ..quadraticBezierTo(
          baseX + math.sin(stemAngle) * stemLen * 0.5 + (mirrorAwns ? -3 : 3),
          baseY - math.cos(stemAngle) * stemLen * 0.5,
          topX, topY,
        );
      c.drawPath(stemPath, stemPaint);

      // الحبات على السنبلة (5 أزواج + قمة)
      const grains = 5;
      for (int i = 0; i < grains; i++) {
        final t  = (i + 1) / (grains + 1);
        final gx = baseX + math.sin(stemAngle) * stemLen * t;
        final gy = baseY - math.cos(stemAngle) * stemLen * t;

        final gAngle = stemAngle + (mirrorAwns ? spread : -spread) * (1 - t * 0.3);
        final gAngleOpp = stemAngle + (mirrorAwns ? -spread : spread) * (1 - t * 0.3);

        final gw = 7.0 - i * 0.4;
        final gh = 11.0 - i * 0.5;

        // حبة يمين
        drawGrain(c,
          gx + math.sin(gAngle) * (gw + 2),
          gy - math.cos(gAngle) * 1,
          gAngle, gw, gh,
          const Color(0xFFE8B84B), const Color(0xFFC28B22));

        // حبة يسار
        drawGrain(c,
          gx + math.sin(gAngleOpp) * (gw + 2),
          gy - math.cos(gAngleOpp) * 1,
          gAngleOpp, gw, gh,
          const Color(0xFFD9A030), const Color(0xFFA0731A));

        // شوارب (awns)
        final awnLen = 9.0 - i * 0.8;
        awnPaint.color = const Color(0xFFF0CC7A);
        c.save();
        c.translate(gx + math.sin(gAngle) * (gw + 2),
                    gy - math.cos(gAngle) * 1);
        c.rotate(gAngle - 0.2);
        c.drawLine(Offset.zero, Offset(0, -awnLen), awnPaint);
        c.restore();

        c.save();
        c.translate(gx + math.sin(gAngleOpp) * (gw + 2),
                    gy - math.cos(gAngleOpp) * 1);
        c.rotate(gAngleOpp + 0.2);
        c.drawLine(Offset.zero, Offset(0, -awnLen), awnPaint);
        c.restore();
      }

      // الحبة القمة
      drawGrain(c, topX, topY - 6, stemAngle, 7, 12,
          const Color(0xFFE8B84B), const Color(0xFFC28B22));
      awnPaint.color = const Color(0xFFF7E4B0);
      c.save();
      c.translate(topX, topY - 12);
      c.rotate(stemAngle);
      c.drawLine(Offset.zero, Offset(0, -11), awnPaint);
      c.restore();
    }

    // ── رسم السنبلتين بشكل تاج ───────────────────────────────────────
    // السنبلة اليسرى - تميل لليسار
    drawWheatStalk(canvas,
      cx - 14, cy + 22,   // قاعدة
      -0.32,              // زاوية الميل (يسار)
      0.55,               // انتشار الحبات
      false,
    );

    // السنبلة اليمنى - تميل لليمين
    drawWheatStalk(canvas,
      cx + 14, cy + 22,   // قاعدة
       0.32,              // زاوية الميل (يمين)
      0.55,
      true,
    );

    // ── خط زخرفي أسفل السنبلتين ──────────────────────────────────────
    final basePaint = Paint()
      ..color       = AppColors.wheat600
      ..strokeWidth = 1.5
      ..strokeCap   = StrokeCap.round
      ..style       = PaintingStyle.stroke;

    final basePath = Path()
      ..moveTo(cx - 28, cy + 26)
      ..quadraticBezierTo(cx, cy + 32, cx + 28, cy + 26);
    canvas.drawPath(basePath, basePaint);

    // نقطة وسط
    canvas.drawCircle(Offset(cx, cy + 29), 2.5,
        Paint()..color = AppColors.wheat400..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_) => false;
}
