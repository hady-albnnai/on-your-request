import 'package:flutter/material.dart';

/// ألوان تطبيق "بخدمتك" – ثيم البازلت والقمح
/// السويداء – سوريا
abstract class AppColors {
  // ── البازلت (الألوان الداكنة الرئيسية) ──────────────────────────────
  static const basalt900 = Color(0xFF1C1A17);
  static const basalt800 = Color(0xFF2D2A25);
  static const basalt700 = Color(0xFF3E3A33);
  static const basalt600 = Color(0xFF4F4A42);
  static const basalt500 = Color(0xFF6B6560);
  static const basalt300 = Color(0xFF9E9890);
  static const basalt400 = Color(0xFFB5AFA8);
  static const basalt100 = Color(0xFFD6D0C8);
  static const basalt50  = Color(0xFFEDE9E2);

  // ── القمح (ألوان التمييز والنداء للفعل) ─────────────────────────────
  static const wheat600  = Color(0xFFA0731A);
  static const wheat500  = Color(0xFFC28B22);
  static const wheat400  = Color(0xFFD9A030); // ★ اللون الرئيسي
  static const wheat300  = Color(0xFFE8B84B);
  static const wheat200  = Color(0xFFF0CC7A);
  static const wheat100  = Color(0xFFF7E4B0);
  static const wheat50   = Color(0xFFFDF5DC);

  // ── الخلفيات ─────────────────────────────────────────────────────────
  static const background = Color(0xFFF5F2EC);
  static const surface    = Color(0xFFFFFFFF);

  // ── حالات الواجهة ────────────────────────────────────────────────────
  static const error   = Color(0xFFC0392B);
  static const success = Color(0xFF27AE60);
  static const info    = Color(0xFF2471A3);

  // ── شارات النوع ──────────────────────────────────────────────────────
  static const badgeRequestBg   = Color(0xFFF7E4B0);
  static const badgeRequestText = Color(0xFFA0731A);
  static const badgeOfferBg     = Color(0xFFE8F4FD);
  static const badgeOfferText   = Color(0xFF2471A3);

  // ── اختصارات Material ─────────────────────────────────────────────
  static const primary        = wheat400;
  static const primaryDark    = basalt800;
  static const onPrimary      = basalt900;
  static const secondary      = basalt800;
  static const onSecondary    = wheat300;
}
