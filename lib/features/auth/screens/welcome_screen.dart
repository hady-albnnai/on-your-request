import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../home/screens/home_screen.dart';
import 'phone_auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.basalt800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildLogo(),
              const SizedBox(height: AppDimens.xl),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize:   AppDimens.fontTitle,
                  fontWeight: FontWeight.w900,
                  color:      AppColors.wheat300,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: AppDimens.sm),
              const Text(
                AppStrings.appTagline,
                style: TextStyle(
                  fontSize:   AppDimens.fontLg,
                  color:      AppColors.basalt300,
                  fontFamily: 'Cairo',
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: AppDimens.btnHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PhoneAuthScreen())),
                  child: const Text(AppStrings.login),
                ),
              ),
              const SizedBox(height: AppDimens.md),
              SizedBox(
                width: double.infinity,
                height: AppDimens.btnHeight,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.wheat300,
                    side: const BorderSide(color: AppColors.basalt500),
                  ),
                  onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen())),
                  child: const Text(AppStrings.browseAsGuest),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 110, height: 110,
      decoration: BoxDecoration(
        color:        AppColors.basalt700,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border:       Border.all(color: AppColors.wheat400, width: 2),
      ),
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
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
      final angle = (i * 60 - 90) * 3.14159 / 180;
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, hexPaint);

    final stemPaint = Paint()
      ..color       = AppColors.wheat300
      ..strokeWidth = 2
      ..strokeCap   = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy + r * 0.6), Offset(cx, cy - r * 0.55), stemPaint);

    final grainPaint = Paint()..color = AppColors.wheat300..style = PaintingStyle.fill;
    final grains = [
      [cx - 8.0, cy - 5.0, -0.4],  [cx + 8.0, cy - 5.0,  0.4],
      [cx - 8.0, cy + 5.0, -0.4],  [cx + 8.0, cy + 5.0,  0.4],
      [cx - 7.0, cy - 15.0, -0.35],[cx + 7.0, cy - 15.0,  0.35],
    ];
    for (final g in grains) {
      canvas.save();
      canvas.translate(g[0], g[1]);
      canvas.rotate(g[2]);
      canvas.drawOval(const Rect.fromLTWH(-5, -3, 10, 6), grainPaint);
      canvas.restore();
    }
  }

  double _cos(double x) {
    double result = 1, term = 1;
    for (int i = 1; i <= 10; i++) { term *= -x * x / (2 * i * (2 * i - 1)); result += term; }
    return result;
  }
  double _sin(double x) {
    double result = x, term = x;
    for (int i = 1; i <= 10; i++) { term *= -x * x / ((2 * i + 1) * (2 * i)); result += term; }
    return result;
  }

  @override
  bool shouldRepaint(_) => false;
}
