import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/post_model.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/arabic_utils.dart';

enum LoadState { initial, loading, success, error, loadingMore }

class PostsProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<PostModel>   _posts        = [];
  LoadState         _state        = LoadState.initial;
  String?           _errorMsg;
  DocumentSnapshot? _lastDoc;
  bool              _hasMore      = true;
  bool              _isLoading    = false;
  int               _requestId    = 0;

  // فلاتر
  String _currentType   = 'request';
  String _selectedRegion = AppDimens.postsPageSize.toString(); // placeholder
  String _searchText    = '';
  Timer? _debounceTimer;

  // ── Getters ──────────────────────────────────────────────────────────
  List<PostModel> get posts        => _posts;
  LoadState       get state        => _state;
  String?         get errorMsg     => _errorMsg;
  bool            get hasMore      => _hasMore;
  String          get currentType  => _currentType;
  String          get selectedRegion => _selectedRegion;

  PostsProvider() { _selectedRegion = 'جميع المناطق'; }

  // ── تغيير التبويب ────────────────────────────────────────────────────
  void setType(String type) {
    if (_currentType == type) return;
    _currentType = type;
    resetAndReload();
  }

  // ── تغيير المنطقة ────────────────────────────────────────────────────
  void setRegion(String region) {
    if (_selectedRegion == region) return;
    _selectedRegion = region;
    resetAndReload();
  }

  // ── البحث مع Debounce ─────────────────────────────────────────────────
  void onSearchChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: AppDimens.debounceSearchMs),
      () {
        _searchText = text;
        resetAndReload();
      },
    );
  }

  // ── إعادة التحميل من البداية ──────────────────────────────────────────
  void resetAndReload() {
    _posts    = [];
    _lastDoc  = null;
    _hasMore  = true;
    _requestId++;
    notifyListeners();
    loadMore();
  }

  // ── تحميل المزيد (Pagination) ─────────────────────────────────────────
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    final myRequestId = _requestId;
    _isLoading = true;
    _state     = _posts.isEmpty ? LoadState.loading : LoadState.loadingMore;
    notifyListeners();

    try {
      Query query = _db.collection('posts')
          .where('type',   isEqualTo: _currentType)
          .where('status', isEqualTo: 'active')
          .where('expiresAt', isGreaterThan: Timestamp.now());

      if (_selectedRegion != 'جميع المناطق') {
        query = query.where('region', isEqualTo: _selectedRegion);
      }
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

      final snap = await query
          .get()
          .timeout(const Duration(seconds: AppDimens.timeoutSeconds));

      // تجاهل نتائج طلبات قديمة
      if (myRequestId != _requestId) return;

      final newPosts = snap.docs.map(PostModel.fromFirestore).toList();
      _hasMore = newPosts.length == AppDimens.postsPageSize;
      if (snap.docs.isNotEmpty) _lastDoc = snap.docs.last;
      _posts.addAll(newPosts);
      _state = LoadState.success;

    } on TimeoutException {
      if (myRequestId == _requestId) {
        _errorMsg = 'فشل التحميل، اسحب للأسفل للمحاولة';
        _state    = LoadState.error;
      }
    } catch (e) {
      if (myRequestId == _requestId) {
        _errorMsg = 'خطأ في تحميل البيانات';
        _state    = LoadState.error;
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
