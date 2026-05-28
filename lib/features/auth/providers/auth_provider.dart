import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthState { initial, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final _auth      = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  AuthState _state    = AuthState.initial;
  String?   _errorMsg;
  String?   _userId;
  String?   _phoneNumber;
  String?   _verificationId;

  // ── Getters ────────────────────────────────────────────────────────────
  AuthState get state      => _state;
  String?   get errorMsg   => _errorMsg;
  String?   get userId     => _userId;
  String?   get phoneNumber => _phoneNumber;
  bool      get isLoggedIn  => _userId != null;
  bool      get isLoading   => _state == AuthState.loading;

  // ── تهيئة: قراءة الجلسة المحفوظة ─────────────────────────────────────
  AuthProvider() { _loadSession(); }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _userId      = prefs.getString('userId');
    _phoneNumber = prefs.getString('phoneNumber');
    notifyListeners();
  }

  // ── إرسال رمز SMS ──────────────────────────────────────────────────────
  Future<void> sendVerificationCode(String phone) async {
    if (phone.trim().isEmpty || !phone.startsWith('+')) {
      _setError('أدخل رقم هاتف صحيح بصيغة دولية (+963...)');
      return;
    }
    _setState(AuthState.loading);

    await _auth.verifyPhoneNumber(
      phoneNumber:          phone,
      timeout:              const Duration(seconds: 60),
      verificationCompleted: (cred) async => await _signIn(cred),
      verificationFailed:   (e)    => _setError(_mapAuthError(e.code)),
      codeSent:             (id, _) {
        _verificationId = id;
        _setState(AuthState.success);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  // ── التحقق من رمز OTP ──────────────────────────────────────────────────
  Future<bool> verifyOtp(String otp) async {
    if (_verificationId == null) return false;
    _setState(AuthState.loading);
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode:        otp,
      );
      await _signIn(cred);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e.code));
      return false;
    }
  }

  // ── تسجيل الدخول الفعلي ────────────────────────────────────────────────
  Future<void> _signIn(PhoneAuthCredential cred) async {
    try {
      final result = await _auth.signInWithCredential(cred)
          .timeout(const Duration(seconds: 30));
      final user = result.user!;
      await _saveUser(user.uid, user.phoneNumber ?? '');
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e.code));
    } catch (_) {
      _setError('انتهت المهلة، تأكد من اتصالك');
    }
  }

  // ── حفظ بيانات المستخدم ────────────────────────────────────────────────
  Future<void> _saveUser(String uid, String phone) async {
    await _firestore.collection('users').doc(uid).set({
      'phoneNumber': phone,
      'userType':    'user',
      'createdAt':   FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', uid);
    await prefs.setString('phoneNumber', phone);

    _userId      = uid;
    _phoneNumber = phone;
    _setState(AuthState.success);
  }

  // ── تسجيل الخروج ───────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('phoneNumber');
    _userId      = null;
    _phoneNumber = null;
    _setState(AuthState.initial);
  }

  // ── مساعدات داخلية ─────────────────────────────────────────────────────
  void _setState(AuthState s) { _state = s; notifyListeners(); }
  void _setError(String msg)  { _errorMsg = msg; _state = AuthState.error; notifyListeners(); }

  String _mapAuthError(String code) => switch (code) {
    'invalid-phone-number'   => 'رقم الهاتف غير صحيح',
    'too-many-requests'      => 'طلبات كثيرة، انتظر قليلاً',
    'invalid-verification-code' => 'رمز التحقق غير صحيح',
    'session-expired'        => 'انتهت صلاحية الرمز، أعد الإرسال',
    _                        => 'خطأ في التحقق، حاول مرة أخرى',
  };
}
