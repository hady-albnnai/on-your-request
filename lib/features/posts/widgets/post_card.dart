import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../data/models/post_model.dart';
import '../../auth/providers/auth_provider.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final auth       = context.watch<AuthProvider>();
    final isOwn      = auth.userId == post.userId;
    final isLoggedIn = auth.isLoggedIn;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(post.title,
                    style: const TextStyle(fontFamily: 'Cairo',
                        fontSize: AppDimens.fontLg,
                        fontWeight: FontWeight.w700,
                        color: AppColors.basalt900)),
                ),
                const SizedBox(width: AppDimens.sm),
                _TypeBadge(isOffer: post.isOffer),
              ],
            ),

            // ── التفاصيل ─────────────────────────────────────────────
            if (post.details != null && post.details!.isNotEmpty) ...[
              const SizedBox(height: AppDimens.xs),
              Text(
                post.details!.length > 80
                    ? '${post.details!.substring(0, 80)}...'
                    : post.details!,
                style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: AppDimens.fontSm, color: AppColors.basalt500)),
            ],

            const SizedBox(height: AppDimens.sm),

            // ── المنطقة + الوقت ──────────────────────────────────────
            Row(children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.basalt400),
              const SizedBox(width: 3),
              Text(post.fullLocation,
                style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: AppDimens.fontXs, color: AppColors.basalt400)),
              const SizedBox(width: AppDimens.md),
              const Icon(Icons.access_time,
                  size: 14, color: AppColors.basalt400),
              const SizedBox(width: 3),
              Text(ArabicUtils.timeAgo(post.createdAt.toDate()),
                style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: AppDimens.fontXs, color: AppColors.basalt400)),
            ]),

            // ── السعر ────────────────────────────────────────────────
            if (post.isOffer && post.price != null) ...[
              const SizedBox(height: AppDimens.xs),
              Text(
                '${ArabicUtils.formatPrice(post.price!)} '
                '${post.currency == "USD" ? AppStrings.symbolUSD : AppStrings.symbolSYP}',
                style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: AppDimens.fontMd, fontWeight: FontWeight.w700,
                    color: AppColors.wheat600)),
            ],

            const Divider(height: AppDimens.lg),

            // ── Footer ───────────────────────────────────────────────
            Row(children: [
              const Icon(Icons.phone_outlined,
                  size: 14, color: AppColors.basalt400),
              const SizedBox(width: 3),
              Text('${post.contactCount} تواصل',
                style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: AppDimens.fontXs, color: AppColors.basalt400)),
              const Spacer(),

              // زر التبليغ
              if (isLoggedIn && !isOwn)
                IconButton(
                  icon: const Icon(Icons.flag_outlined,
                      size: 18, color: AppColors.basalt400),
                  onPressed: () => _showReportDialog(context, auth.userId!),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: AppStrings.report,
                ),

              const SizedBox(width: AppDimens.sm),

              // زر المشاركة
              IconButton(
                icon: const Icon(Icons.share_outlined,
                    size: 18, color: AppColors.basalt400),
                onPressed: () => _sharePost(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              // زر التواصل
              if (isLoggedIn && !isOwn) ...[
                const SizedBox(width: AppDimens.md),
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.md),
                      minimumSize: Size.zero,
                      textStyle: const TextStyle(fontFamily: 'Cairo',
                          fontSize: AppDimens.fontSm,
                          fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => _showContactDialog(context, auth.userId!),
                    child: const Text('تواصل'),
                  ),
                ),
              ],

              if (!isLoggedIn)
                TextButton(
                  onPressed: () => _showLoginSnack(context),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: const Text('سجّل للتواصل',
                    style: TextStyle(fontFamily: 'Cairo',
                        fontSize: AppDimens.fontXs,
                        color: AppColors.wheat500)),
                ),
            ]),
          ],
        ),
      ),
    );
  }

  // ── حوار التواصل ──────────────────────────────────────────────────
  void _showContactDialog(BuildContext context, String currentUserId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تواصل بشأن: ${post.title}',
          style: const TextStyle(fontFamily: 'Cairo',
              fontSize: AppDimens.fontMd)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.phone, color: AppColors.wheat600),
            label: const Text(AppStrings.callPhone,
              style: TextStyle(fontFamily: 'Cairo',
                  color: AppColors.basalt800)),
            onPressed: () {
              Navigator.pop(context);
              _makeCall(context, currentUserId);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.chat, color: Colors.green),
            label: const Text(AppStrings.whatsapp,
              style: TextStyle(fontFamily: 'Cairo',
                  color: AppColors.basalt800)),
            onPressed: () {
              Navigator.pop(context);
              _openWhatsApp(context, currentUserId);
            },
          ),
        ],
      ),
    );
  }

  // ── جلب رقم الهاتف من Firestore ──────────────────────────────────
  Future<String?> _getPhoneNumber() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(post.userId)
          .get()
          .timeout(const Duration(seconds: AppDimens.shortTimeoutSecs));
      return doc.data()?['phoneNumber'] as String?;
    } catch (_) {
      return null;
    }
  }

  // ── زيادة العداد ─────────────────────────────────────────────────
  Future<void> _incrementContact() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .update({'contactCount': FieldValue.increment(1)});
  }

  // ── اتصال هاتفي ──────────────────────────────────────────────────
  Future<void> _makeCall(BuildContext context, String userId) async {
    final phone = await _getPhoneNumber();
    if (phone == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(AppStrings.errNoPhone,
              style: TextStyle(fontFamily: 'Cairo'))));
      }
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      await _incrementContact();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(AppStrings.noPhone,
              style: TextStyle(fontFamily: 'Cairo'))));
      }
    }
  }

  // ── واتساب ───────────────────────────────────────────────────────
  Future<void> _openWhatsApp(BuildContext context, String userId) async {
    final phone = await _getPhoneNumber();
    if (phone == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(AppStrings.errNoPhone,
              style: TextStyle(fontFamily: 'Cairo'))));
      }
      return;
    }
    final cleaned = phone.replaceAll('+', '').replaceAll(' ', '');
    final uri = Uri.parse('https://api.whatsapp.com/send?phone=$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      await _incrementContact();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(AppStrings.noWhatsapp,
              style: TextStyle(fontFamily: 'Cairo'))));
      }
    }
  }

  // ── التبليغ ──────────────────────────────────────────────────────
  void _showReportDialog(BuildContext context, String reporterId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.report,
            style: TextStyle(fontFamily: 'Cairo')),
        content: const Text(AppStrings.reportConfirm,
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Cairo',
                    color: AppColors.basalt500))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitReport(context, reporterId);
            },
            child: const Text(AppStrings.report,
                style: TextStyle(fontFamily: 'Cairo',
                    color: AppColors.error))),
        ],
      ),
    );
  }

  Future<void> _submitReport(BuildContext context, String reporterId) async {
    final reportId  = '${post.id}_$reporterId';
    final reportRef = FirebaseFirestore.instance
        .collection('reports').doc(reportId);
    try {
      final exists = (await reportRef.get()).exists;
      if (exists) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(AppStrings.alreadyReported,
                style: TextStyle(fontFamily: 'Cairo'))));
        }
        return;
      }
      final batch = FirebaseFirestore.instance.batch();
      batch.update(
        FirebaseFirestore.instance.collection('posts').doc(post.id),
        {'reportCount': FieldValue.increment(1)},
      );
      batch.set(reportRef, {
        'postId':     post.id,
        'reporterId': reporterId,
        'reportedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(AppStrings.reportOk,
              style: TextStyle(fontFamily: 'Cairo'))));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(AppStrings.errGeneric,
              style: TextStyle(fontFamily: 'Cairo'))));
      }
    }
  }

  // ── المشاركة ─────────────────────────────────────────────────────
  void _sharePost() {
    final priceText = post.isOffer && post.price != null
        ? '\n💰 السعر: ${ArabicUtils.formatPrice(post.price!)} '
          '${post.currency == "USD" ? "\$" : "ل.س"}'
        : '';
    final text =
        '${post.isOffer ? "🛍️ عرض" : "🔍 طلب"}: ${post.title}'
        '${post.details != null && post.details!.isNotEmpty ? "\n${post.details!.length > 100 ? post.details!.substring(0, 100) : post.details!}" : ""}'
        '$priceText\n📍 ${post.region}\n\n${AppStrings.shareFooter}';
    Share.share(text, subject: post.title);
  }

  void _showLoginSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(AppStrings.loginRequired,
          style: TextStyle(fontFamily: 'Cairo'))));
  }
}

// ── شارة النوع ────────────────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  final bool isOffer;
  const _TypeBadge({required this.isOffer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.sm, vertical: 3),
      decoration: BoxDecoration(
        color: isOffer
            ? AppColors.badgeOfferBg
            : AppColors.badgeRequestBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        isOffer ? AppStrings.typeOffer : AppStrings.typeRequest,
        style: TextStyle(
          fontFamily:  'Cairo',
          fontSize:    AppDimens.fontXs,
          fontWeight:  FontWeight.w700,
          color: isOffer
              ? AppColors.badgeOfferText
              : AppColors.badgeRequestText,
        ),
      ),
    );
  }
}
