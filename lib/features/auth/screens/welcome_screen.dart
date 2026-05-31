import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../home/screens/home_screen.dart';
import 'phone_auth_screen.dart';
import 'splash_screen.dart'; // نعيد استخدام WheatLogoPainter

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.basalt800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
          child: Column(children: [
            const Spacer(flex: 2),
            // اللوغو
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color:        AppColors.basalt700,
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                border: Border.all(color: AppColors.wheat400, width: 2.5),
              ),
              child: CustomPaint(painter: WheatCrownPainter()),
            ),
            const SizedBox(height: AppDimens.xl),
            const Text(AppStrings.appName,
              style: TextStyle(fontSize: AppDimens.fontTitle, fontWeight: FontWeight.w900,
                  color: AppColors.wheat300, fontFamily: 'Cairo')),
            const SizedBox(height: AppDimens.sm),
            const Text(AppStrings.appTagline,
              style: TextStyle(fontSize: AppDimens.fontLg,
                  color: AppColors.basalt300, fontFamily: 'Cairo')),
            const Spacer(flex: 2),
            SizedBox(width: double.infinity, height: AppDimens.btnHeight,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PhoneAuthScreen())),
                child: const Text(AppStrings.login))),
            const SizedBox(height: AppDimens.md),
            SizedBox(width: double.infinity, height: AppDimens.btnHeight,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.wheat300,
                  side: const BorderSide(color: AppColors.basalt500)),
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen())),
                child: const Text(AppStrings.browseAsGuest))),
            const Spacer(),
          ]),
        ),
      ),
    );
  }
}
