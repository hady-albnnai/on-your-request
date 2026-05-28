import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',

    // ── Color Scheme ────────────────────────────────────────────────────
    colorScheme: const ColorScheme.light(
      primary:        AppColors.wheat400,
      onPrimary:      AppColors.basalt900,
      secondary:      AppColors.basalt800,
      onSecondary:    AppColors.wheat300,
      surface:        AppColors.surface,
      onSurface:      AppColors.basalt900,
      error:          AppColors.error,
      onError:        AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,

    // ── AppBar ──────────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor:    AppColors.basalt800,
      foregroundColor:    AppColors.wheat300,
      elevation:          0,
      centerTitle:        true,
      titleTextStyle: TextStyle(
        fontFamily:  'Cairo',
        fontSize:    AppDimens.fontXl,
        fontWeight:  FontWeight.w700,
        color:       AppColors.wheat300,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor:           AppColors.basalt900,
        statusBarIconBrightness:  Brightness.light,
      ),
      iconTheme: IconThemeData(color: AppColors.wheat300),
    ),

    // ── TabBar ──────────────────────────────────────────────────────────
    tabBarTheme: const TabBarThemeData(
      labelColor:         AppColors.wheat300,
      unselectedLabelColor: AppColors.basalt300,
      indicatorColor:     AppColors.wheat400,
      indicatorSize:      TabBarIndicatorSize.tab,
      labelStyle:    TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: AppDimens.fontMd),
      unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: AppDimens.fontMd),
    ),

    // ── FloatingActionButton ─────────────────────────────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor:  AppColors.wheat400,
      foregroundColor:  AppColors.basalt900,
      elevation:        4,
      shape: CircleBorder(),
    ),

    // ── ElevatedButton ───────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:  AppColors.wheat400,
        foregroundColor:  AppColors.basalt900,
        minimumSize: const Size(double.infinity, AppDimens.btnHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.btnRadiusMd),
        ),
        textStyle: const TextStyle(
          fontFamily:  'Cairo',
          fontWeight:  FontWeight.w700,
          fontSize:    AppDimens.fontMd,
        ),
        elevation: 0,
      ),
    ),

    // ── OutlinedButton ───────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.basalt800,
        side: const BorderSide(color: AppColors.basalt100, width: 1.5),
        minimumSize: const Size(double.infinity, AppDimens.btnHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.btnRadiusMd),
        ),
        textStyle: const TextStyle(
          fontFamily:  'Cairo',
          fontWeight:  FontWeight.w700,
          fontSize:    AppDimens.fontMd,
        ),
      ),
    ),

    // ── TextButton ───────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.wheat600,
        textStyle: const TextStyle(
          fontFamily:  'Cairo',
          fontWeight:  FontWeight.w600,
          fontSize:    AppDimens.fontMd,
        ),
      ),
    ),

    // ── Card ─────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color:        AppColors.surface,
      elevation:    AppDimens.cardElevation,
      margin:  const EdgeInsets.symmetric(
        horizontal: AppDimens.cardMarginH,
        vertical:   AppDimens.cardMarginV,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        side: const BorderSide(color: AppColors.basalt100),
      ),
    ),

    // ── InputDecoration ──────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled:         true,
      fillColor:      AppColors.surface,
      hintStyle:      const TextStyle(color: AppColors.basalt300, fontFamily: 'Cairo'),
      labelStyle:     const TextStyle(color: AppColors.basalt500, fontFamily: 'Cairo'),
      floatingLabelStyle: const TextStyle(color: AppColors.wheat600, fontFamily: 'Cairo'),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: AppDimens.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        borderSide:   const BorderSide(color: AppColors.basalt100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        borderSide:   const BorderSide(color: AppColors.basalt100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        borderSide:   const BorderSide(color: AppColors.wheat400, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        borderSide:   const BorderSide(color: AppColors.error),
      ),
    ),

    // ── BottomNavigationBar ──────────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      AppColors.surface,
      selectedItemColor:    AppColors.wheat500,
      unselectedItemColor:  AppColors.basalt300,
      showSelectedLabels:   true,
      showUnselectedLabels: true,
      type:                 BottomNavigationBarType.fixed,
      elevation:            8,
      selectedLabelStyle:   TextStyle(fontFamily: 'Cairo', fontSize: AppDimens.fontXs, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontSize: AppDimens.fontXs),
    ),

    // ── Divider ──────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color:     AppColors.basalt50,
      thickness: 1,
      space:     0,
    ),

    // ── SnackBar ─────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.basalt800,
      contentTextStyle: const TextStyle(
        fontFamily: 'Cairo',
        color:      AppColors.wheat100,
        fontSize:   AppDimens.fontSm,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSm)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
