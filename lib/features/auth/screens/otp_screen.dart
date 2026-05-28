import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../home/screens/home_screen.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});
  @override State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() { _otpController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.basalt800,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.wheat300)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('أدخل رمز التحقق',
                style: TextStyle(fontSize: AppDimens.fontXxl, fontWeight: FontWeight.w700,
                    color: AppColors.wheat300, fontFamily: 'Cairo')),
              const SizedBox(height: AppDimens.sm),
              Text('أُرسل الرمز إلى ${widget.phone}',
                style: const TextStyle(fontSize: AppDimens.fontMd,
                    color: AppColors.basalt300, fontFamily: 'Cairo')),
              const SizedBox(height: AppDimens.xxl),

              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(color: AppColors.wheat100, fontFamily: 'Cairo',
                    fontSize: AppDimens.fontXxl, letterSpacing: 8),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true, fillColor: AppColors.basalt700,
                  hintText: '000000',
                  hintStyle: const TextStyle(color: AppColors.basalt500, letterSpacing: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    borderSide: const BorderSide(color: AppColors.basalt500)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    borderSide: const BorderSide(color: AppColors.basalt500)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                    borderSide: const BorderSide(color: AppColors.wheat400, width: 2)),
                ),
              ),

              if (auth.errorMsg != null) ...[
                const SizedBox(height: AppDimens.md),
                Text(auth.errorMsg!,
                  style: const TextStyle(color: AppColors.error,
                      fontFamily: 'Cairo', fontSize: AppDimens.fontSm)),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity, height: AppDimens.btnHeight,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _verifyOtp,
                  child: auth.isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2,
                              color: AppColors.basalt900))
                      : const Text('تحقق وادخل'),
                ),
              ),
              const SizedBox(height: AppDimens.md),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppStrings.resendCode,
                    style: TextStyle(color: AppColors.wheat400, fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length < 6) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.verifyOtp(_otpController.text.trim());
    if (mounted && ok) {
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
    }
  }
}
