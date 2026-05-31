import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/post_model.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/arabic_utils.dart';

enum LoadState { initial, loading, success, error, loadingMore }

class PostsProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<PostModel>   _posts     = [];
  LoadState         _state     = LoadState.initial;
  String?           _errorMsg;
  DocumentSnapshot? _lastDoc;
  bool              _hasMore   = true;
  bool              _isLoading = false;
  int               _requestId = 0;

  String _currentType      = 'request';
  String _selectedRegion   = AppStrings.allRegions;
  String _selectedCategory = AppStrings.allCategories;
  String _searchText       = '';
  Timer? _debounceTimer;

  List<PostModel> get posts            => _posts;
  LoadState       get state            => _state;
  String?         get errorMsg         => _errorMsg;
  bool            get hasMore          => _hasMore;
  String          get currentType      => _currentType;
  String          get selectedRegion   => _selectedRegion;
  String          get selectedCategory => _selectedCategory;

  void setType(String type) {
    if (_currentType == type) return;
    _currentType = type;
    resetAndReload();
  }

  void setRegion(String region) {
    if (_selectedRegion == region) return;
    _selectedRegion = region;
    resetAndReload();
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    resetAndReload();
  }

  void onSearchChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: AppDimens.debounceSearchMs),
      () { _searchText = text; resetAndReload(); },
    );
  }

  void resetAndReload() {
    _posts     = [];
    _lastDoc   = null;
    _hasMore   = true;
    _requestId++;
    _state     = LoadState.initial;
    notifyListeners();
    loadMore();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    final myId = _requestId;
    _isLoading = true;
    _state     = _posts.isEmpty ? LoadState.loading : LoadState.loadingMore;
    notifyListeners();

    try {
      // ── استراتيجية الاستعلام الذكية ────────────────────────────────
      // نختار أبسط استعلام ممكن لتجنب الحاجة لفهارس معقدة
      Query query;

      final hasSearch   = _searchText.trim().isNotEmpty;
      final hasRegion   = _selectedRegion   != AppStrings.allRegions;
      final hasCategory = _selectedCategory != AppStrings.allCategories;

      if (hasSearch) {
        // البحث النصي: نستخدم arrayContains مع type + status فقط
        final kw = ArabicUtils.normalizeQuery(_searchText);
        query = _db.collection('posts')
            .where('type',           isEqualTo: _currentType)
            .where('status',         isEqualTo: 'active')
            .where('expiresAt',      isGreaterThan: Timestamp.now())
            .where('searchKeywords', arrayContains: kw)
            .orderBy('expiresAt')
            .orderBy('createdAt', descending: true)
            .limit(AppDimens.postsPageSize);

      } else if (hasCategory) {
        // فلتر الفئة
        query = _db.collection('posts')
            .where('type',     isEqualTo: _currentType)
            .where('status',   isEqualTo: 'active')
            .where('category', isEqualTo: _selectedCategory)
            .where('expiresAt', isGreaterThan: Timestamp.now())
            .orderBy('expiresAt')
            .orderBy('createdAt', descending: true)
            .limit(AppDimens.postsPageSize);

      } else if (hasRegion) {
        // فلتر المنطقة
        query = _db.collection('posts')
            .where('type',     isEqualTo: _currentType)
            .where('status',   isEqualTo: 'active')
            .where('region',   isEqualTo: _selectedRegion)
            .where('expiresAt', isGreaterThan: Timestamp.now())
            .orderBy('expiresAt')
            .orderBy('createdAt', descending: true)
            .limit(AppDimens.postsPageSize);

      } else {
        // الكل: بدون فلاتر إضافية
        query = _db.collection('posts')
            .where('type',     isEqualTo: _currentType)
            .where('status',   isEqualTo: 'active')
            .where('expiresAt', isGreaterThan: Timestamp.now())
            .orderBy('expiresAt')
            .orderBy('createdAt', descending: true)
            .limit(AppDimens.postsPageSize);
      }

      if (_lastDoc != null) query = query.startAfterDocument(_lastDoc!);

      debugPrint('🔍 type=$_currentType region=$_selectedRegion cat=$_selectedCategory search=$_searchText');

      final snap = await query
          .get()
          .timeout(const Duration(seconds: AppDimens.timeoutSeconds));

      if (myId != _requestId) return;

      var newPosts = snap.docs.map(PostModel.fromFirestore).toList();

      // فلترة محلية إضافية إذا كان هناك فلترين معاً
      if (hasCategory && hasRegion) {
        newPosts = newPosts.where((p) =>
          p.category == _selectedCategory && p.region == _selectedRegion
        ).toList();
      } else if (hasSearch && hasRegion) {
        newPosts = newPosts.where((p) => p.region == _selectedRegion).toList();
      } else if (hasSearch && hasCategory) {
        newPosts = newPosts.where((p) => p.category == _selectedCategory).toList();
      }

      debugPrint('✅ Got ${newPosts.length} posts');

      _hasMore = snap.docs.length == AppDimens.postsPageSize;
      if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;
      _posts.addAll(newPosts);
      _state = LoadState.success;

    } catch (e) {
      debugPrint('❌ Error: $e');
      if (myId == _requestId && _posts.isEmpty) {
        _errorMsg = e.toString().contains('index')
            ? 'جارٍ تهيئة الفهارس، حاول مرة أخرى'
            : null;
        _state = LoadState.success;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
