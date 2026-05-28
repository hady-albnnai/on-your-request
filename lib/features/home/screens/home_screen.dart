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
