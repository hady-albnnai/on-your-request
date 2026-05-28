import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/add_post_provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});
  @override State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _titleCtrl      = TextEditingController();
  final _detailsCtrl    = TextEditingController();
  final _priceCtrl      = TextEditingController();
  String  _type         = 'request';
  String  _region       = AppStrings.regions[1]; // السويداء افتراضياً
  String  _currency     = AppStrings.currencySYP;
  File?   _imageFile;

  @override
  void dispose() {
    _titleCtrl.dispose(); _detailsCtrl.dispose();
    _priceCtrl.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddPostProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addPost)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.lg),
          children: [
            // ── نوع المنشور ───────────────────────────────────────────
            const Text('نوع المنشور', style: TextStyle(fontFamily: 'Cairo',
                fontSize: AppDimens.fontMd, fontWeight: FontWeight.w700,
                color: AppColors.basalt700)),
            const SizedBox(height: AppDimens.sm),
            Row(children: [
              _TypeChip(label: AppStrings.typeRequest, value: 'request',
                  selected: _type == 'request',
                  onTap: () => setState(() => _type = 'request')),
              const SizedBox(width: AppDimens.sm),
              _TypeChip(label: AppStrings.typeOffer, value: 'offer',
                  selected: _type == 'offer',
                  onTap: () => setState(() => _type = 'offer')),
            ]),
            const SizedBox(height: AppDimens.lg),

            // ── العنوان ───────────────────────────────────────────────
            TextFormField(
              controller: _titleCtrl,
              maxLength:  AppDimens.maxTitleLength,
              decoration: const InputDecoration(
                  labelText: AppStrings.postTitle,
                  hintText:  AppStrings.postTitleHint),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.errTitleRequired : null,
            ),
            const SizedBox(height: AppDimens.md),

            // ── التفاصيل ─────────────────────────────────────────────
            TextFormField(
              controller: _detailsCtrl,
              maxLength:  AppDimens.maxDetailsLength,
              maxLines:   3,
              decoration: const InputDecoration(
                  labelText: AppStrings.postDetails,
                  hintText:  'أضف تفاصيل إضافية…'),
            ),
            const SizedBox(height: AppDimens.md),

            // ── المنطقة ───────────────────────────────────────────────
            DropdownButtonFormField<String>(
              initialValue: _region,
              decoration: const InputDecoration(labelText: AppStrings.postRegion),
              items: AppStrings.regions.skip(1).map((r) =>
                DropdownMenuItem(value: r, child: Text(r,
                  style: const TextStyle(fontFamily: 'Cairo',
                      fontSize: AppDimens.fontMd)))).toList(),
              onChanged: (v) { if (v != null) setState(() => _region = v); },
            ),
            const SizedBox(height: AppDimens.md),

            // ── السعر + العملة (للعروض فقط) ──────────────────────────
            if (_type == 'offer') ...[
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: AppStrings.postPrice),
                    validator: (v) {
                      if (_type != 'offer') return null;
                      final n = double.tryParse(v ?? '');
                      return (n == null || n <= 0) ? AppStrings.errPriceRequired : null;
                    },
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                DropdownButton<String>(
                  value: _currency,
                  items: [AppStrings.currencySYP, AppStrings.currencyUSD]
                      .map((c) => DropdownMenuItem(value: c,
                          child: Text(c, style: const TextStyle(
                              fontFamily: 'Cairo')))).toList(),
                  onChanged: (v) { if (v != null) setState(() => _currency = v); },
                ),
              ]),
              const SizedBox(height: AppDimens.md),
            ],

            // ── الصورة ───────────────────────────────────────────────
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120, decoration: BoxDecoration(
                  color:        AppColors.basalt50,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.basalt100),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        child: Image.file(_imageFile!, fit: BoxFit.cover,
                            width: double.infinity))
                    : const Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 36, color: AppColors.basalt400),
                          SizedBox(height: AppDimens.xs),
                          Text(AppStrings.postImage,
                            style: TextStyle(fontFamily: 'Cairo',
                                fontSize: AppDimens.fontSm,
                                color: AppColors.basalt400)),
                        ]),
              ),
            ),

            // ── رسالة الخطأ ───────────────────────────────────────────
            if (provider.errorMsg != null) ...[
              const SizedBox(height: AppDimens.md),
              Container(
                padding: const EdgeInsets.all(AppDimens.md),
                decoration: BoxDecoration(
                  color:        AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Text(provider.errorMsg!,
                  style: const TextStyle(color: AppColors.error,
                      fontFamily: 'Cairo', fontSize: AppDimens.fontSm)),
              ),
            ],

            const SizedBox(height: AppDimens.xxl),

            // ── زر النشر ─────────────────────────────────────────────
            ElevatedButton(
              onPressed: provider.isLoading ? null : _publish,
              child: provider.isLoading
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2,
                              color: AppColors.basalt900)),
                      const SizedBox(width: AppDimens.sm),
                      Text(provider.state == AddPostState.uploading
                          ? 'جارٍ رفع الصورة…' : AppStrings.publishing,
                        style: const TextStyle(fontFamily: 'Cairo')),
                    ])
                  : const Text(AppStrings.publish),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AddPostProvider>();
    final ok = await provider.publishPost(
      type:      _type,
      title:     _titleCtrl.text,
      details:   _detailsCtrl.text,
      region:    _region,
      price:     _type == 'offer' ? double.tryParse(_priceCtrl.text) : null,
      currency:  _currency,
      imageFile: _imageFile,
    );
    if (mounted && ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.publishedOk,
            style: TextStyle(fontFamily: 'Cairo'))));
      Navigator.pop(context);
    }
  }
}

class _TypeChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.value,
      required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.lg, vertical: AppDimens.sm),
      decoration: BoxDecoration(
        color:        selected ? AppColors.wheat400 : AppColors.basalt50,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(
          color: selected ? AppColors.wheat400 : AppColors.basalt100),
      ),
      child: Text(label,
        style: TextStyle(fontFamily: 'Cairo', fontSize: AppDimens.fontMd,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.basalt900 : AppColors.basalt500)),
    ),
  );
}
