import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/post_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/welcome_screen.dart';
import '../providers/my_account_provider.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});
  @override State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) {
        context.read<MyAccountProvider>().loadMyPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // ── شاشة الزائر ────────────────────────────────────────────────
    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.myAccount)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.basalt50,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.basalt100, width: 2),
                  ),
                  child: const Icon(Icons.person_outline,
                      size: 44, color: AppColors.basalt400),
                ),
                const SizedBox(height: AppDimens.lg),
                const Text(
                  'سجّل دخولك للوصول إلى حسابك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: AppDimens.fontLg,
                    fontWeight: FontWeight.w700,
                    color: AppColors.basalt700,
                  ),
                ),
                const SizedBox(height: AppDimens.sm),
                const Text(
                  'يمكنك نشر الطلبات والعروض وإدارة منشوراتك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: AppDimens.fontMd,
                    color: AppColors.basalt400,
                  ),
                ),
                const SizedBox(height: AppDimens.xl),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.btnHeight,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen())),
                    icon: const Icon(Icons.login),
                    label: const Text(
                      AppStrings.login,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: AppDimens.fontLg),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── شاشة المستخدم المسجل ─────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myAccount),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.wheat300),
            onPressed: () => _confirmLogout(context, auth),
          ),
        ],
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          color: AppColors.basalt800,
          padding: const EdgeInsets.fromLTRB(
              AppDimens.lg, 0, AppDimens.lg, AppDimens.lg),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.wheat400,
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              ),
              child: const Icon(Icons.person,
                  color: AppColors.basalt900, size: 28),
            ),
            const SizedBox(width: AppDimens.md),
            Text(auth.phoneNumber ?? '',
              style: const TextStyle(fontFamily: 'Cairo',
                  fontSize: AppDimens.fontMd,
                  color: AppColors.wheat100, letterSpacing: 1)),
          ]),
        ),
        Expanded(
          child: Consumer<MyAccountProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator(
                    color: AppColors.wheat400));
              }
              if (provider.myPosts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.inbox_outlined,
                          size: 56, color: AppColors.basalt200),
                      const SizedBox(height: AppDimens.md),
                      const Text(AppStrings.noMyPosts,
                          style: TextStyle(fontFamily: 'Cairo',
                              color: AppColors.basalt400,
                              fontSize: AppDimens.fontLg)),
                      const SizedBox(height: AppDimens.lg),
                      ElevatedButton.icon(
                        onPressed: provider.loadMyPosts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('تحديث',
                            style: TextStyle(fontFamily: 'Cairo')),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.wheat400,
                onRefresh: provider.loadMyPosts,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.sm),
                  itemCount: provider.myPosts.length,
                  itemBuilder: (_, i) => _MyPostCard(
                    post: provider.myPosts[i],
                    provider: provider),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.logout,
            style: TextStyle(fontFamily: 'Cairo')),
        content: const Text(AppStrings.confirmLogout,
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel,
                style: TextStyle(fontFamily: 'Cairo',
                    color: AppColors.basalt500))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              auth.logout();
            },
            child: const Text(AppStrings.logout,
                style: TextStyle(fontFamily: 'Cairo',
                    color: AppColors.error))),
        ],
      ),
    );
  }
}

class _MyPostCard extends StatelessWidget {
  final PostModel post;
  final MyAccountProvider provider;
  const _MyPostCard({required this.post, required this.provider});

  @override
  Widget build(BuildContext context) {
    final days = post.daysRemaining;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(post.title,
                  style: const TextStyle(fontFamily: 'Cairo',
                      fontSize: AppDimens.fontMd,
                      fontWeight: FontWeight.w700,
                      color: AppColors.basalt900))),
              _StatusBadge(post: post),
            ]),
            const SizedBox(height: AppDimens.xs),
            Text('📍 ${post.fullLocation}',
              style: const TextStyle(fontFamily: 'Cairo',
                  fontSize: AppDimens.fontXs,
                  color: AppColors.basalt400)),
            if (post.isActive) ...[
              const SizedBox(height: AppDimens.xs),
              Text(
                days == 0
                    ? AppStrings.expiresToday
                    : '$days ${days == 1 ? "يوم متبقي" : "أيام متبقية"}',
                style: TextStyle(fontFamily: 'Cairo',
                    fontSize: AppDimens.fontXs,
                    color: days <= 2 ? AppColors.error : AppColors.basalt400),
              ),
            ],
            const SizedBox(height: AppDimens.sm),
            if (post.isActive) ...[
              Row(children: [
                if (post.canRenew) ...[
                  _ActionBtn(
                    label: AppStrings.renew,
                    color: AppColors.wheat500,
                    onTap: () async {
                      final ok = await provider.renewPost(post);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            ok ? AppStrings.renewOk : AppStrings.errGeneric,
                            style: const TextStyle(fontFamily: 'Cairo'))));
                      }
                    },
                  ),
                  const SizedBox(width: AppDimens.sm),
                ],
                _ActionBtn(
                  label: AppStrings.completePost,
                  color: AppColors.info,
                  onTap: () async {
                    final ok = await provider.completePost(post.id);
                    if (context.mounted && ok) _showRatingDialog(context);
                  },
                ),
                const SizedBox(width: AppDimens.sm),
                _ActionBtn(
                  label: AppStrings.delete,
                  color: AppColors.error,
                  onTap: () => _confirmDelete(context),
                ),
              ]),
            ] else ...[
              _ActionBtn(
                label: AppStrings.delete,
                color: AppColors.error,
                onTap: () => _confirmDelete(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.delete,
            style: TextStyle(fontFamily: 'Cairo')),
        content: Text('حذف "${post.title}"؟',
            style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel,
                style: TextStyle(fontFamily: 'Cairo',
                    color: AppColors.basalt500))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deletePost(post);
            },
            child: const Text(AppStrings.delete,
                style: TextStyle(fontFamily: 'Cairo',
                    color: AppColors.error))),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.ratingTitle,
            style: TextStyle(fontFamily: 'Cairo',
                fontSize: AppDimens.fontMd)),
        content: const Text(AppStrings.ratingMsg,
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.rateLater,
                style: TextStyle(fontFamily: 'Cairo',
                    color: AppColors.basalt500))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.rateNow,
                style: TextStyle(fontFamily: 'Cairo'))),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
        style: TextStyle(fontFamily: 'Cairo',
            fontSize: AppDimens.fontXs,
            fontWeight: FontWeight.w700,
            color: color)),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final PostModel post;
  const _StatusBadge({required this.post});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sm, vertical: 3),
    decoration: BoxDecoration(
      color: post.isActive ? AppColors.badgeRequestBg : AppColors.basalt50,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
    ),
    child: Text(post.statusLabel,
      style: TextStyle(fontFamily: 'Cairo',
          fontSize: AppDimens.fontXs,
          fontWeight: FontWeight.w700,
          color: post.isActive
              ? AppColors.badgeRequestText
              : AppColors.basalt400)),
  );
}
