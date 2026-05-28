import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../posts/providers/posts_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/search_bar_widget.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final type = _tabController.index == 0 ? 'request' : 'offer';
      context.read<PostsProvider>().setType(type);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().resetAndReload();
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<PostsProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── بدون AppBar هنا لأنه موجود في HomeScreen ──────────────────
      body: Column(
        children: [
          // ── التبويبات ─────────────────────────────────────────────
          Container(
            color: AppColors.basalt800,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: AppStrings.requests),
                Tab(text: AppStrings.offers),
              ],
            ),
          ),

          // ── شريط البحث والفلتر ────────────────────────────────────
          const SearchBarWidget(),

          // ── قائمة المنشورات ───────────────────────────────────────
          Expanded(
            child: Consumer<PostsProvider>(
              builder: (context, provider, _) {

                // حالة التحميل الأولي
                if (provider.state == LoadState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.wheat400));
                }

                // حالة الخطأ
                if (provider.state == LoadState.error &&
                    provider.posts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_outlined,
                              size: 48, color: AppColors.basalt300),
                          const SizedBox(height: AppDimens.md),
                          Text(
                            provider.errorMsg ?? AppStrings.errGeneric,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.basalt500,
                                fontFamily: 'Cairo',
                                fontSize: AppDimens.fontMd)),
                          const SizedBox(height: AppDimens.lg),
                          ElevatedButton.icon(
                            onPressed: provider.resetAndReload,
                            icon: const Icon(Icons.refresh),
                            label: const Text(AppStrings.retry,
                                style: TextStyle(fontFamily: 'Cairo')),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // قائمة فارغة
                if (provider.posts.isEmpty &&
                    provider.state == LoadState.success) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inbox_outlined,
                            size: 56, color: AppColors.basalt200),
                        const SizedBox(height: AppDimens.md),
                        const Text(AppStrings.noPostsYet,
                          style: TextStyle(
                              color: AppColors.basalt400,
                              fontFamily: 'Cairo',
                              fontSize: AppDimens.fontLg)),
                      ],
                    ),
                  );
                }

                // القائمة الرئيسية
                return RefreshIndicator(
                  color: AppColors.wheat400,
                  onRefresh: () async => provider.resetAndReload(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.sm),
                    itemCount: provider.posts.length +
                        (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == provider.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(AppDimens.lg),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.wheat400,
                                strokeWidth: 2)));
                      }
                      return PostCard(post: provider.posts[i]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
