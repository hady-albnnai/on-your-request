import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/arabic_utils.dart';

enum AddPostState { initial, uploading, publishing, success, error }

class AddPostProvider extends ChangeNotifier {
  final _db      = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  AddPostState _state     = AddPostState.initial;
  String?      _errorMsg;
  bool         _isPublishing = false;

  AddPostState get state    => _state;
  String?      get errorMsg => _errorMsg;
  bool         get isLoading =>
      _state == AddPostState.uploading || _state == AddPostState.publishing;

  /// نشر منشور جديد
  Future<bool> publishPost({
    required String type,
    required String title,
    required String details,
    required String region,
    double?  price,
    String?  currency,
    File?    imageFile,
  }) async {
    // ── 1. منع الضغط المتكرر ─────────────────────────────────────────
    if (_isPublishing) return false;

    // ── 2. التحقق من البيانات ─────────────────────────────────────────
    if (title.trim().isEmpty) {
      _setError(AppStrings.errTitleRequired); return false;
    }
    if (title.trim().length > AppDimens.maxTitleLength) {
      _setError(AppStrings.errTitleLong); return false;
    }
    if (region == AppStrings.allRegions) {
      _setError(AppStrings.errRegionRequired); return false;
    }
    if (type == 'offer' && (price == null || price <= 0)) {
      _setError(AppStrings.errPriceRequired); return false;
    }
    if (details.length > AppDimens.maxDetailsLength) {
      _setError(AppStrings.errDetails500); return false;
    }

    _isPublishing = true;
    final postId      = const Uuid().v4();
    String? imageUrl;
    String? storagePath;

    // ── 3. رفع الصورة ────────────────────────────────────────────────
    if (imageFile != null) {
      _setState(AddPostState.uploading);
      storagePath = 'posts/$postId/image.jpg';
      final ref = _storage.ref(storagePath);
      try {
        await ref.putFile(imageFile)
            .timeout(const Duration(seconds: AppDimens.timeoutSeconds));
        imageUrl = await ref.getDownloadURL()
            .timeout(const Duration(seconds: AppDimens.shortTimeoutSecs));
      } catch (_) {
        // تنظيف الصورة المرفوعة جزئياً
        await ref.delete().catchError((_) {});
        _setError(AppStrings.errUploadImage);
        _isPublishing = false;
        return false;
      }
    }

    // ── 4. بناء الكلمات المفتاحية ─────────────────────────────────────
    final keywords = ArabicUtils.buildKeywords(title, details, region);

    // ── 5. بيانات المنشور ─────────────────────────────────────────────
    final prefs   = await SharedPreferences.getInstance();
    final userId  = prefs.getString('userId') ?? '';
    final now     = Timestamp.now();
    final expiry  = Timestamp.fromDate(
      DateTime.now().add(const Duration(days: AppDimens.postExpiryDays)),
    );
    final postData = {
      'id':             postId,
      'userId':         userId,
      'type':           type,
      'title':          title.trim(),
      'details':        details.trim(),
      'region':         region,
      'price':          price,
      'currency':       currency,
      'imageUrl':       imageUrl,
      'storagePath':    storagePath,
      'status':         'active',
      'createdAt':      now,
      'expiresAt':      expiry,
      'contactCount':   0,
      'reportCount':    0,
      'searchKeywords': keywords,
    };

    // ── 6. معاملة Firestore (منع التكرار + كتابة) ────────────────────
    _setState(AddPostState.publishing);
    try {
      final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(
          const Duration(hours: AppDimens.duplicateWindowHrs),
        ),
      );

      final success = await _db.runTransaction((tx) async {
        final existing = await _db.collection('posts')
            .where('userId', isEqualTo: userId)
            .where('type',   isEqualTo: type)
            .where('title',  isEqualTo: title.trim())
            .where('region', isEqualTo: region)
            .where('createdAt', isGreaterThan: cutoff)
            .get();

        if (existing.docs.isNotEmpty) return false;

        tx.set(_db.collection('posts').doc(postId), postData);
        return true;
      }).timeout(const Duration(seconds: AppDimens.timeoutSeconds));

      if (success == true) {
        _setState(AddPostState.success);
        _isPublishing = false;
        return true;
      } else {
        // تكرار – حذف الصورة إن رُفعت
        if (storagePath != null) {
          await _storage.ref(storagePath).delete().catchError((_) {});
        }
        _setError(AppStrings.duplicatePost);
        _isPublishing = false;
        return false;
      }
    } catch (_) {
      // فشل المعاملة – تنظيف الصورة
      if (storagePath != null) {
        await _storage.ref(storagePath).delete().catchError((_) {});
      }
      _setError(AppStrings.errTimeout);
      _isPublishing = false;
      return false;
    }
  }

  void reset() { _state = AddPostState.initial; _errorMsg = null; notifyListeners(); }
  void _setState(AddPostState s) { _state = s; notifyListeners(); }
  void _setError(String msg)     { _errorMsg = msg; _state = AddPostState.error; notifyListeners(); }
}
