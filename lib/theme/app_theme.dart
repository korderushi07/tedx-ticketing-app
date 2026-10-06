import 'package:flutter/material.dart';

class TEDxColors {
  // Brand
  static const Color tedRed = Color(0xFFE62B1E);
  static const Color tedRedDark = Color(0xFFB31B10);
  static const Color tedRedSubtle = Color(0x26E62B1E);

  // Backgrounds & Neutral Surfaces
  static const Color bgDark = Color(0xFF0A0A0A);
  static const Color cardDark = Color(0xFF141414);
  static const Color cardBorder = Color(0xFF262626);
  static const Color surfaceElevated = Color(0xFF1F1F1F);
  static const Color inputBg = Color(0xFF1A1A1A);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA3A3A3);
  static const Color textMuted = Color(0xFF737373);

  // Operational Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successBg = Color(0xFF022C22);
  static const Color successBorder = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFF451A03);
  static const Color warningBorder = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFF450A0A);
  static const Color errorBorder = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0xFF1E3A8A);
}

class TEDxTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TEDxColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: TEDxColors.tedRed,
        secondary: TEDxColors.tedRed,
        surface: TEDxColors.cardDark,
        error: TEDxColors.error,
        onPrimary: Colors.white,
        onSurface: TEDxColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TEDxColors.bgDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: TEDxColors.textPrimary),
        titleTextStyle: TextStyle(
          color: TEDxColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: TEDxColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TEDxColors.cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TEDxColors.tedRed,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TEDxColors.textPrimary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: TEDxColors.cardBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TEDxColors.inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TEDxColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TEDxColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TEDxColors.tedRed, width: 1.5),
        ),
        labelStyle: const TextStyle(color: TEDxColors.textSecondary),
        hintStyle: const TextStyle(color: TEDxColors.textMuted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: TEDxColors.bgDark,
        selectedItemColor: TEDxColors.tedRed,
        unselectedItemColor: TEDxColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );
  }
}
