import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../data/models/post_model.dart';
import '../../../core/constants/app_dimens.dart';

class MyAccountProvider extends ChangeNotifier {
  final _db      = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  List<PostModel> _myPosts = [];
  bool            _loading = false;
  String?         _error;

  List<PostModel> get myPosts   => _myPosts;
  bool            get isLoading => _loading;
  String?         get error     => _error;

  Future<void> loadMyPosts(String userId) async {
    if (userId.isEmpty) return;
    _loading = true; notifyListeners();
    try {
      final snap = await _db.collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: AppDimens.timeoutSeconds));
      _myPosts = snap.docs.map(PostModel.fromFirestore).toList();
      _error   = null;
    } catch (e) {
      debugPrint('loadMyPosts error: $e');
      _error = 'فشل تحميل منشوراتك';
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<bool> renewPost(PostModel post) async {
    if (!post.canRenew) return false;
    final newExpiry = Timestamp.fromDate(
        DateTime.now().add(const Duration(days: AppDimens.postExpiryDays)));
    try {
      await _db.collection('posts').doc(post.id)
          .update({'expiresAt': newExpiry})
          .timeout(const Duration(seconds: AppDimens.timeoutSeconds));
      _myPosts = _myPosts.map((p) =>
          p.id == post.id ? p.copyWith(expiresAt: newExpiry) : p).toList();
      notifyListeners();
      return true;
    } catch (_) { return false; }
  }

  Future<bool> completePost(String postId) async {
    try {
      await _db.collection('posts').doc(postId)
          .update({'status': 'completed'})
          .timeout(const Duration(seconds: AppDimens.timeoutSeconds));
      _myPosts = _myPosts.map((p) =>
          p.id == postId ? p.copyWith(status: PostStatus.completed) : p).toList();
      notifyListeners();
      return true;
    } catch (_) { return false; }
  }

  Future<bool> deletePost(PostModel post) async {
    try {
      if (post.storagePath != null) {
        await _storage.ref(post.storagePath!).delete().catchError((_) {});
      }
      await _db.collection('posts').doc(post.id).delete()
          .timeout(const Duration(seconds: AppDimens.timeoutSeconds));
      _myPosts = _myPosts.where((p) => p.id != post.id).toList();
      notifyListeners();
      return true;
    } catch (_) { return false; }
  }

  void clear() { _myPosts = []; _error = null; notifyListeners(); }
}
