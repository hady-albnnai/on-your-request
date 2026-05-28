import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});
  @override State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController(text: '+963');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() { _phoneController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.basalt800,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.wheat300),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أدخل رقم هاتفك',
                  style: TextStyle(fontSize: AppDimens.fontXxl, fontWeight: FontWeight.w700,
                      color: AppColors.wheat300, fontFamily: 'Cairo')),
                const SizedBox(height: AppDimens.sm),
                const Text('سنرسل لك رمز تحقق عبر SMS',
                  style: TextStyle(fontSize: AppDimens.fontMd, color: AppColors.basalt300, fontFamily: 'Cairo')),
                const SizedBox(height: AppDimens.xxl),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(color: AppColors.wheat100, fontFamily: 'Cairo',
                      fontSize: AppDimens.fontLg, letterSpacing: 1),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.basalt700,
                    hintText: AppStrings.phoneHint,
                    hintStyle: const TextStyle(color: AppColors.basalt400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      borderSide: const BorderSide(color: AppColors.basalt500),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      borderSide: const BorderSide(color: AppColors.basalt500),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      borderSide: const BorderSide(color: AppColors.wheat400, width: 2),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'الرقم مطلوب';
                    if (!v.startsWith('+')) return 'ابدأ بـ + (مثال: +963...)';
                    if (v.length < 10) return 'الرقم قصير جداً';
                    return null;
                  },
                ),

                if (auth.errorMsg != null) ...[
                  const SizedBox(height: AppDimens.md),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      border: Border.all(color: AppColors.error.withOpacity(0.4)),
                    ),
                    child: Text(auth.errorMsg!,
                      style: const TextStyle(color: AppColors.error, fontFamily: 'Cairo',
                          fontSize: AppDimens.fontSm)),
                  ),
                ],

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: AppDimens.btnHeight,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _sendCode,
                    child: auth.isLoading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2,
                                color: AppColors.basalt900))
                        : const Text(AppStrings.sendCode),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.sendVerificationCode(_phoneController.text.trim());
    if (mounted && auth.state == AuthState.success) {
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => OtpScreen(phone: _phoneController.text.trim())));
    }
  }
}
