import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/home/screens/home_screen.dart';

class BkhedmtakApp extends StatelessWidget {
  const BkhedmtakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:        AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme:        AppTheme.lightTheme,
      locale:       const Locale('ar', 'SY'),
      // RTL بالكامل
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      // تحديد الشاشة الأولى بناءً على حالة تسجيل الدخول
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoggedIn) return const HomeScreen();
          return const WelcomeScreen();
        },
      ),
    );
  }
}
