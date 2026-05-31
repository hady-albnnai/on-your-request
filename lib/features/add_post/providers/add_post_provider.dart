import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/arabic_utils.dart';

enum AddPostState { initial, uploading, publishing, success, error }

class AddPostProvider extends ChangeNotifier {
  final _db      = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  AddPostState _state       = AddPostState.initial;
  String?      _errorMsg;
  bool         _isPublishing = false;

  AddPostState get state    => _state;
  String?      get errorMsg => _errorMsg;
  bool get isLoading =>
      _state == AddPostState.uploading || _state == AddPostState.publishing;

  // إعادة الضبط عند فتح الشاشة
  void reset() {
    _state       = AddPostState.initial;
    _errorMsg    = null;
    _isPublishing = false;
    notifyListeners();
  }

  Future<bool> publishPost({
    required String userId,   // يُمرَّر من AuthProvider مباشرة
    required String type,
    required String title,
    required String details,
    required String category,
    required String subCategory,
    required String region,
    required String location,
    double?  price,
    String?  currency,
    File?    imageFile,
  }) async {
    if (_isPublishing) return false;
    if (userId.isEmpty) { _setError(AppStrings.loginRequired); return false; }

    // التحقق من البيانات
    if (title.trim().isEmpty)  { _setError(AppStrings.errTitleRequired);    return false; }
    if (title.trim().length > AppDimens.maxTitleLength) { _setError(AppStrings.errTitleLong); return false; }
    if (region == AppStrings.allRegions)  { _setError(AppStrings.errRegionRequired);   return false; }
    if (location.trim().isEmpty)          { _setError(AppStrings.errLocationRequired); return false; }
    if (type == 'offer' && (price == null || price <= 0)) { _setError(AppStrings.errPriceRequired); return false; }
    if (details.length > AppDimens.maxDetailsLength)      { _setError(AppStrings.errDetails500);    return false; }

    _isPublishing = true;
    final postId  = const Uuid().v4();
    String? imageUrl;
    String? storagePath;

    // رفع الصورة
    if (imageFile != null) {
      _setState(AddPostState.uploading);
      storagePath = 'posts/$postId/image.jpg';
      final ref = _storage.ref(storagePath);
      try {
        await ref.putFile(imageFile)
            .timeout(const Duration(seconds: AppDimens.timeoutSeconds));
        imageUrl = await ref.getDownloadURL()
            .timeout(const Duration(seconds: AppDimens.shortTimeoutSecs));
      } catch (e) {
        await ref.delete().catchError((_) {});
        _setError(AppStrings.errUploadImage);
        _isPublishing = false;
        return false;
      }
    }

    // بناء الكلمات المفتاحية
    final keywords = ArabicUtils.buildKeywords(
        '$title $category $subCategory', details, '$region $location');

    final now    = Timestamp.now();
    final expiry = Timestamp.fromDate(
        DateTime.now().add(const Duration(days: AppDimens.postExpiryDays)));

    final postData = {
      'id':             postId,
      'userId':         userId,
      'type':           type,
      'title':          title.trim(),
      'details':        details.trim(),
      'category':       category,
      'subCategory':    subCategory,
      'region':         region,
      'location':       location.trim(),
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

    _setState(AddPostState.publishing);

    try {
      // التحقق من التكرار
      final cutoff = Timestamp.fromDate(DateTime.now()
          .subtract(const Duration(hours: AppDimens.duplicateWindowHrs)));

      final existing = await _db.collection('posts')
          .where('userId', isEqualTo: userId)
          .where('type',   isEqualTo: type)
          .where('title',  isEqualTo: title.trim())
          .where('region', isEqualTo: region)
          .where('createdAt', isGreaterThan: cutoff)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: AppDimens.timeoutSeconds));

      if (existing.docs.isNotEmpty) {
        if (storagePath != null) await _storage.ref(storagePath).delete().catchError((_) {});
        _setError(AppStrings.duplicatePost);
        _isPublishing = false;
        return false;
      }

      await _db.collection('posts').doc(postId).set(postData)
          .timeout(const Duration(seconds: AppDimens.timeoutSeconds));

      _setState(AddPostState.success);
      _isPublishing = false;
      return true;

    } catch (e) {
      debugPrint('Publish error: $e');
      if (storagePath != null) await _storage.ref(storagePath).delete().catchError((_) {});
      _setError(AppStrings.errGeneric);
      _isPublishing = false;
      return false;
    }
  }

  void _setState(AddPostState s) { _state = s; notifyListeners(); }
  void _setError(String msg) { _errorMsg = msg; _state = AddPostState.error; notifyListeners(); }
}
