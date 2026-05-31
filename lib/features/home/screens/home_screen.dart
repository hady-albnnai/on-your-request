import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/welcome_screen.dart';
import '../../auth/screens/splash_screen.dart';
import '../../posts/screens/posts_screen.dart';
import '../../my_account/screens/my_account_screen.dart';
import '../../add_post/screens/add_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth       = context.watch<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          // أيقونة سنبلة القمح في AppBar
          SizedBox(
            width: 34, height: 34,
            child: CustomPaint(painter: WheatCrownPainter()),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: const [
            Text(AppStrings.appName,
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900,
                  color: AppColors.wheat300, fontSize: 18, height: 1.1)),
            Text(AppStrings.appTagline,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 10,
                  color: AppColors.basalt300, height: 1.1)),
          ]),
        ]),
        centerTitle: true,
        actions: [
          if (!isLoggedIn)
            TextButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen())),
              child: const Text('دخول', style: TextStyle(fontFamily: 'Cairo',
                  color: AppColors.wheat300, fontWeight: FontWeight.w700, fontSize: 14))),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [PostsScreen(), MyAccountScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 1 && !isLoggedIn) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()));
            return;
          }
          setState(() => _currentIndex = i);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home),
            label: AppStrings.home),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person),
            label: AppStrings.myAccount),
        ],
      ),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddPostScreen())),
              child: const Icon(Icons.add, size: 28))
          : FloatingActionButton.extended(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen())),
              backgroundColor: AppColors.wheat400,
              foregroundColor: AppColors.basalt900,
              icon: const Icon(Icons.login),
              label: const Text('سجّل دخولك',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700))),
    );
  }
}
