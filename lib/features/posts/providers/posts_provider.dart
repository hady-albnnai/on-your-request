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

  String _currentType    = 'request';
  String _selectedRegion = AppStrings.allRegions;
  String _searchText     = '';
  Timer? _debounceTimer;

  List<PostModel> get posts          => _posts;
  LoadState       get state          => _state;
  String?         get errorMsg       => _errorMsg;
  bool            get hasMore        => _hasMore;
  String          get currentType    => _currentType;
  String          get selectedRegion => _selectedRegion;

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
      // ── بناء الاستعلام ─────────────────────────────────────────────
      Query query = _db.collection('posts')
          .where('type',      isEqualTo: _currentType)
          .where('status',    isEqualTo: 'active')
          .where('expiresAt', isGreaterThan: Timestamp.now());

      // فلتر المنطقة فقط إذا لم تكن "جميع المناطق"
      if (_selectedRegion != AppStrings.allRegions) {
        query = query.where('region', isEqualTo: _selectedRegion);
      }

      // فلتر البحث
      if (_searchText.trim().isNotEmpty) {
        final kw = ArabicUtils.normalizeQuery(_searchText);
        if (kw.isNotEmpty) {
          query = query.where('searchKeywords', arrayContains: kw);
        }
      }

      query = query
          .orderBy('expiresAt', descending: false)
          .orderBy('createdAt', descending: true)
          .limit(AppDimens.postsPageSize);

      if (_lastDoc != null) query = query.startAfterDocument(_lastDoc!);

      debugPrint('🔍 Query: type=$_currentType region=$_selectedRegion');

      final snap = await query
          .get()
          .timeout(const Duration(seconds: AppDimens.timeoutSeconds));

      if (myId != _requestId) return;

      final newPosts = snap.docs.map(PostModel.fromFirestore).toList();
      debugPrint('✅ Got ${newPosts.length} posts');

      _hasMore = newPosts.length == AppDimens.postsPageSize;
      if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;
      _posts.addAll(newPosts);
      _state = LoadState.success;

    } catch (e) {
      debugPrint('❌ Firestore error: $e');
      if (myId == _requestId) {
        // إذا كانت القائمة فارغة نظهر خطأ، وإلا نكتفي بإيقاف التحميل
        if (_posts.isEmpty) {
          _errorMsg = e.toString().contains('index')
              ? 'الفهارس لم تُفعَّل بعد، انتظر دقيقة'
              : 'لا توجد منشورات حالياً';
          _state = LoadState.success; // نعرض "لا توجد منشورات" بدل خطأ
        }
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
