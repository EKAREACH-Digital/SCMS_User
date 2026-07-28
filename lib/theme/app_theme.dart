import 'package:flutter/material.dart';

class AppTheme {
  // Brand greens (same in both themes)
  static const Color green = Color(0xFF4CAF50);
  static const Color greenDark = Color(0xFF2E7D32);

  // Light surface tint
  static const Color accentBlue = Color(0xFFA6CDFF);

  // ── Light palette ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF7F8FA);
  static const Color card = Colors.white;
  static const Color greenSurface = Color(0xFFE8F5E9);
  static const Color text = Color(0xFF1A1F1A);
  static const Color mutedText = Color(0xFF8A8A8A);
  static const Color border = Color(0xFFE4EDE4);

  // ── Dark palette ───────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1612);
  static const Color darkCard = Color(0xFF1A2318);
  static const Color darkGreenSurface = Color(0xFF1B2E1E);
  static const Color darkText = Color(0xFFE8F0E8);
  static const Color darkMutedText = Color(0xFF7A8A7A);
  static const Color darkBorder = Color(0xFF2A3A2A);

  // ── Gradients (same in both themes) ────────────────────────────────────────
  static final LinearGradient balanceCardGradient = const LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient headerGradient = const LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: green,
      brightness: Brightness.light,
      primary: green,
      secondary: accentBlue,
      surface: background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Poppins',
      // Khmer has no glyphs in the Latin default, so km text would render as
      // tofu boxes on iOS. Resolution is per glyph: Latin keeps the primary
      // family, Khmer characters fall through to Noto Sans Khmer.
      fontFamilyFallback: const ['NotoSansKhmer'],
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: green, width: 1.3),
        ),
      ),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: green,
      brightness: Brightness.dark,
      primary: green,
      secondary: accentBlue,
      surface: darkBackground,
      onSurface: darkText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: 'Poppins',
      // Khmer has no glyphs in the Latin default, so km text would render as
      // tofu boxes on iOS. Resolution is per glyph: Latin keeps the primary
      // family, Khmer characters fall through to Noto Sans Khmer.
      fontFamilyFallback: const ['NotoSansKhmer'],
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: green, width: 1.3),
        ),
        hintStyle: const TextStyle(color: darkMutedText),
      ),
    );
  }
}

// ── Context extension — use these instead of hardcoded AppTheme.* constants ──
extension AppThemeX on BuildContext {
  bool get _dark => Theme.of(this).brightness == Brightness.dark;

  Color get bgColor => _dark ? AppTheme.darkBackground : AppTheme.background;
  Color get cardColor => _dark ? AppTheme.darkCard : Colors.white;
  Color get textColor => _dark ? AppTheme.darkText : AppTheme.text;
  Color get mutedColor => _dark ? AppTheme.darkMutedText : AppTheme.mutedText;
  Color get borderColor => _dark ? AppTheme.darkBorder : AppTheme.border;
  Color get surfaceColor =>
      _dark ? AppTheme.darkGreenSurface : AppTheme.greenSurface;
}
