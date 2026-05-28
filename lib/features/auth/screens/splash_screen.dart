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
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim  = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.nextScreen));
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.basalt800,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // اللوغو
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color:        AppColors.basalt700,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.wheat400, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.wheat400.withValues(alpha: 0.3),
                        blurRadius: 20, spreadRadius: 2),
                    ],
                  ),
                  child: CustomPaint(painter: _SplashLogoPainter()),
                ),
                const SizedBox(height: 24),
                const Text(AppStrings.appName,
                  style: TextStyle(
                    fontSize:   36,
                    fontWeight: FontWeight.w900,
                    color:      AppColors.wheat300,
                    fontFamily: 'Cairo',
                    letterSpacing: 2,
                  )),
                const SizedBox(height: 8),
                const Text(AppStrings.appTagline,
                  style: TextStyle(
                    fontSize:   14,
                    color:      AppColors.basalt300,
                    fontFamily: 'Cairo',
                  )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.38;

    final hexPaint = Paint()
      ..color       = AppColors.wheat400
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, hexPaint);

    final stemPaint = Paint()
      ..color = AppColors.wheat300..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy + r * 0.6), Offset(cx, cy - r * 0.55), stemPaint);

    final grainPaint = Paint()..color = AppColors.wheat300..style = PaintingStyle.fill;
    final grains = [
      [cx-8.0,cy-5.0,-0.4],[cx+8.0,cy-5.0,0.4],
      [cx-8.0,cy+5.0,-0.4],[cx+8.0,cy+5.0,0.4],
      [cx-7.0,cy-15.0,-0.35],[cx+7.0,cy-15.0,0.35],
    ];
    for (final g in grains) {
      canvas.save();
      canvas.translate(g[0], g[1]);
      canvas.rotate(g[2]);
      canvas.drawOval(const Rect.fromLTWH(-5, -3, 10, 6), grainPaint);
      canvas.restore();
    }
  }
  @override bool shouldRepaint(_) => false;
}
