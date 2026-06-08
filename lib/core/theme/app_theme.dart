import 'package:flutter/material.dart';

class AppTheme {
  // =====================================================
  // 🎨 BRAND COLORS
  // =====================================================

  static const Color primaryColor = Color(0xFF2F80ED);
  static const Color secondaryColor = Color(0xFF56CCF2);
  static const Color backgroundColor = Color(0xFFF7F8FA);

  // ✅ STATUS COLORS
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF2994A);
  static const Color error = Color(0xFFEB5757);

  // =====================================================
  // 🌞 LIGHT THEME
  // =====================================================

  static final ThemeData light = ThemeData(
    useMaterial3: true,

    // ✅ COLORS
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: backgroundColor,

    // =====================================================
    // ✅ TYPOGRAPHY
    // =====================================================
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
    ),

    // =====================================================
    // ✅ APP BAR
    // =====================================================
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    ),

    // =====================================================
    // ✅ INPUT FIELDS
    // =====================================================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: primaryColor, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: error),
      ),

      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // =====================================================
    // ✅ BUTTONS
    // =====================================================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding:
            const EdgeInsets.symmetric(vertical: 16),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle:
            const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // =====================================================
    // ✅ CARDS (FIXED ✅)
    // =====================================================
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    // =====================================================
    // ✅ SWITCHES
    // =====================================================
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(primaryColor),
      trackColor: WidgetStatePropertyAll(
        primaryColor.withValues(alpha: 0.4), // ✅ FIXED
      ),
    ),

    // =====================================================
    // ✅ SNACKBARS
    // =====================================================
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
  );

  // =====================================================
  // 🌙 DARK THEME
  // =====================================================

  static final ThemeData dark = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),

    scaffoldBackgroundColor: const Color(0xFF121212),
  );
}
