import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
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
            // ── Header: العنوان + الشارة ──────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(post.title,
                    style: const TextStyle(fontFamily: 'Cairo',
                        fontSize: AppDimens.fontLg, fontWeight: FontWeight.w700,
                        color: AppColors.basalt900)),
                ),
                const SizedBox(width: AppDimens.sm),
                _TypeBadge(isOffer: post.isOffer),
              ],
            ),

            // ── التفاصيل ──────────────────────────────────────────────
            if (post.details != null && post.details!.isNotEmpty) ...[
              const SizedBox(height: AppDimens.xs),
              Text(
                post.details!.length > 80
                    ? '${post.details!.substring(0, 80)}...'
                    : post.details!,
                style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: AppDimens.fontSm, color: AppColors.basalt500),
              ),
            ],

            const SizedBox(height: AppDimens.sm),

            // ── المنطقة + الوقت ───────────────────────────────────────
            Row(children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.basalt400),
              const SizedBox(width: 3),
              Text(post.region,
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

            // ── السعر (للعروض فقط) ────────────────────────────────────
            if (post.isOffer && post.price != null) ...[
              const SizedBox(height: AppDimens.xs),
              Text(
                '${ArabicUtils.formatPrice(post.price!)} '
                '${post.currency == "USD" ? AppStrings.symbolUSD : AppStrings.symbolSYP}',
                style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: AppDimens.fontMd, fontWeight: FontWeight.w700,
                    color: AppColors.wheat600),
              ),
            ],

            const Divider(height: AppDimens.lg),

            // ── Footer: عداد الاتصالات + الأزرار ─────────────────────
            Row(children: [
              const Icon(Icons.phone_outlined,
                  size: 14, color: AppColors.basalt400),
              const SizedBox(width: 3),
              Text('${post.contactCount} تواصل',
                style: const TextStyle(fontFamily: 'Cairo',
                    fontSize: AppDimens.fontXs, color: AppColors.basalt400)),
              const Spacer(),

              // زر المشاركة
              IconButton(
                icon: const Icon(Icons.share_outlined,
                    size: 20, color: AppColors.basalt400),
                onPressed: () => _sharePost(context),
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),

              // زر الاتصال (للمسجلين وليس لصاحب المنشور)
              if (isLoggedIn && !isOwn) ...[
                const SizedBox(width: AppDimens.md),
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.md),
                      minimumSize: Size.zero,
                      textStyle: const TextStyle(
                          fontFamily: 'Cairo', fontSize: AppDimens.fontSm,
                          fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => _showContactDialog(context),
                    child: const Text(AppStrings.callPhone == '📞 اتصال هاتفي'
                        ? 'تواصل' : 'تواصل'),
                  ),
                ),
              ],

              // دعوة للتسجيل (للزوار)
              if (!isLoggedIn) ...[
                const SizedBox(width: AppDimens.sm),
                TextButton(
                  onPressed: () => _showLoginSnack(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: const Text('سجّل للتواصل',
                    style: TextStyle(fontFamily: 'Cairo',
                        fontSize: AppDimens.fontXs, color: AppColors.wheat500)),
                ),
              ],
            ]),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تواصل بشأن: ${post.title}',
          style: const TextStyle(fontFamily: 'Cairo', fontSize: AppDimens.fontMd)),
        content: null,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.phone, color: AppColors.wheat600),
            label: const Text(AppStrings.callPhone,
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.basalt800)),
            onPressed: () {
              Navigator.pop(context);
              _launchPhone(context);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.chat, color: Colors.green),
            label: const Text(AppStrings.whatsapp,
              style: TextStyle(fontFamily: 'Cairo', color: AppColors.basalt800)),
            onPressed: () {
              Navigator.pop(context);
              _launchWhatsApp(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context) async {
    // في MVP نعرض رقم وهمي – سيُستبدل بجلب من Firestore
    final uri = Uri.parse('tel:+963000000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final uri = Uri.parse('https://api.whatsapp.com/send?phone=963000000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.noWhatsapp,
              style: TextStyle(fontFamily: 'Cairo'))));
      }
    }
  }

  void _sharePost(BuildContext context) {
    final priceText = post.isOffer && post.price != null
        ? '\n💰 السعر: ${ArabicUtils.formatPrice(post.price!)} '
          '${post.currency == "USD" ? "\$" : "ل.س"}'
        : '';
    final text = '${post.isOffer ? "🛍️ عرض" : "🔍 طلب"}: ${post.title}'
        '${post.details != null ? "\n${post.details!.take(100)}" : ""}'
        '$priceText\n📍 ${post.region}\n\n${AppStrings.shareFooter}';
    Share.shareWithResult(text, subject: post.title);
  }

  void _showLoginSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.loginRequired,
          style: TextStyle(fontFamily: 'Cairo'))));
  }
}

extension on String {
  String take(int n) => length > n ? substring(0, n) : this;
}

// ── شارة النوع ─────────────────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  final bool isOffer;
  const _TypeBadge({required this.isOffer});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.sm, vertical: 3),
      decoration: BoxDecoration(
        color:        isOffer ? AppColors.badgeOfferBg   : AppColors.badgeRequestBg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        isOffer ? AppStrings.typeOffer : AppStrings.typeRequest,
        style: TextStyle(
          fontFamily:  'Cairo',
          fontSize:    AppDimens.fontXs,
          fontWeight:  FontWeight.w700,
          color: isOffer ? AppColors.badgeOfferText : AppColors.badgeRequestText,
        ),
      ),
    );
  }
}
