/// أبعاد وتباعد تطبيق "بخدمتك"
abstract class AppDimens {
  // ── Spacing ──────────────────────────────────────────────────────────
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double xxl  = 32.0;
  static const double xxxl = 48.0;

  // ── Border Radius ─────────────────────────────────────────────────────
  static const double radiusSm   = 8.0;
  static const double radiusMd   = 12.0;
  static const double radiusLg   = 16.0;
  static const double radiusXl   = 24.0;
  static const double radiusPill = 100.0;

  // ── Cards ─────────────────────────────────────────────────────────────
  static const double cardElevation = 2.0;
  static const double cardPadding   = 12.0;
  static const double cardMarginH   = 16.0;
  static const double cardMarginV   = 6.0;

  // ── AppBar ────────────────────────────────────────────────────────────
  static const double appBarHeight = 56.0;

  // ── Buttons ───────────────────────────────────────────────────────────
  static const double btnHeight    = 48.0;
  static const double btnRadiusMd  = 10.0;

  // ── Font Sizes ────────────────────────────────────────────────────────
  static const double fontXs   = 10.0;
  static const double fontSm   = 12.0;
  static const double fontMd   = 14.0;
  static const double fontLg   = 16.0;
  static const double fontXl   = 18.0;
  static const double fontXxl  = 22.0;
  static const double fontTitle = 28.0;

  // ── Images ────────────────────────────────────────────────────────────
  static const double postImageHeight = 180.0;

  // ── Bottom Nav ────────────────────────────────────────────────────────
  static const double bottomNavHeight = 60.0;

  // ── FAB ───────────────────────────────────────────────────────────────
  static const double fabMargin = 16.0;

  // ── Network ───────────────────────────────────────────────────────────
  static const int timeoutSeconds     = 30;
  static const int shortTimeoutSecs   = 10;
  static const int debounceSearchMs   = 300;
  static const int debounceContactMs  = 2000;
  static const int postsPageSize      = 20;
  static const int maxImageSizeKB     = 300;
  static const int maxTitleLength     = 100;
  static const int maxDetailsLength   = 500;
  static const int duplicateWindowHrs = 24;
  static const int postExpiryDays     = 15;
  static const int renewThresholdDays = 2;
  static const int reportThreshold    = 5;
}
