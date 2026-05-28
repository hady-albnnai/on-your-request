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
    // تحميل أول دفعة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().resetAndReload();
    });
    // تحميل المزيد عند التمرير
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
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.requests),
            Tab(text: AppStrings.offers),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── شريط البحث والفلتر ────────────────────────────────────────
          const SearchBarWidget(),

          // ── قائمة المنشورات ───────────────────────────────────────────
          Expanded(
            child: Consumer<PostsProvider>(
              builder: (context, provider, _) {
                if (provider.state == LoadState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.wheat400));
                }
                if (provider.state == LoadState.error) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(provider.errorMsg ?? AppStrings.errGeneric,
                        style: const TextStyle(color: AppColors.basalt500,
                            fontFamily: 'Cairo')),
                      const SizedBox(height: AppDimens.md),
                      TextButton(
                        onPressed: provider.resetAndReload,
                        child: const Text(AppStrings.retry,
                          style: TextStyle(color: AppColors.wheat500,
                              fontFamily: 'Cairo'))),
                    ]),
                  );
                }
                if (provider.posts.isEmpty) {
                  return const Center(
                    child: Text(AppStrings.noPostsYet,
                      style: TextStyle(color: AppColors.basalt400,
                          fontFamily: 'Cairo', fontSize: AppDimens.fontLg)));
                }
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
                          child: Center(child: CircularProgressIndicator(
                              color: AppColors.wheat400, strokeWidth: 2)));
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
