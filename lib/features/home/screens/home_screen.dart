import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_provider.dart';
import '../../posts/screens/posts_screen.dart';
import '../../my_account/screens/my_account_screen.dart';
import '../../add_post/screens/add_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    PostsScreen(),
    MyAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth       = context.watch<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        // ── اللوغو في AppBar ──────────────────────────────────────────
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32, height: 32,
              child: CustomPaint(painter: _MiniLogoPainter()),
            ),
            const SizedBox(width: 8),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontFamily:  'Cairo',
                fontWeight:  FontWeight.w900,
                color:       AppColors.wheat300,
                fontSize:    20,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 1 && !isLoggedIn) {
            _showLoginRequired();
            return;
          }
          setState(() => _currentIndex = i);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.home),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.myAccount),
        ],
      ),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddPostScreen())),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }

  void _showLoginRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.loginRequired,
          style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppColors.basalt700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ── لوغو مصغّر للـ AppBar ─────────────────────────────────────────────
class _MiniLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.42;

    // السداسية
    final hexPaint = Paint()
      ..color       = AppColors.wheat400
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, hexPaint);

    // ساق السنبلة
    final stemPaint = Paint()
      ..color       = AppColors.wheat300
      ..strokeWidth = 1.5
      ..strokeCap   = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy + r * 0.55),
      Offset(cx, cy - r * 0.5),
      stemPaint,
    );

    // حبوب مصغّرة
    final grainPaint = Paint()
      ..color = AppColors.wheat300
      ..style = PaintingStyle.fill;
    final grains = [
      [cx - 5.0, cy - 3.0,  -0.4],
      [cx + 5.0, cy - 3.0,   0.4],
      [cx - 5.0, cy + 3.0,  -0.4],
      [cx + 5.0, cy + 3.0,   0.4],
      [cx - 4.5, cy - 9.0, -0.35],
      [cx + 4.5, cy - 9.0,  0.35],
    ];
    for (final g in grains) {
      canvas.save();
      canvas.translate(g[0], g[1]);
      canvas.rotate(g[2]);
      canvas.drawOval(const Rect.fromLTWH(-3, -2, 6, 4), grainPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
