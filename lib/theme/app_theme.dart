import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Campus Burnt Amber design tokens.
  static const Color primary = Color.fromARGB(255, 211, 124, 3);
  static const Color primaryDark = Color(0xFFB36200);
  static const Color primaryLight = Color(0xFFFFEFD1);
  static const Color onPrimary = Color(0xFF1C130A);
  static const Color secondary = Color(0xFFFFF3E5);
  static const Color tertiary = Color(0xFF10B981);
  static const Color tertiaryDark = Color(0xFF047857);
  static const Color tertiaryLight = Color(0xFF34D399);
  static const Color background = Color(0xFFFAF7F4);
  static const Color card = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1C130A);
  static const Color border = Color(0xFFF0DDB8);

  // Compatibility aliases for existing widgets. New code should use the
  // design-token names above or Theme.of(context).colorScheme.
  @Deprecated('Use AppTheme.primary')
  static const Color green = primary;
  static const Color greenDark = Color(0xFF8C4D00);
  static const Color greenSurface = secondary;

  static const Color accentBlue = tertiary;

  static const Color mutedText = Color(0xFF8C7B70);

  static const Color darkBackground = Color(0xFF140D07);
  static const Color darkCard = Color(0xFF261C14);
  static const Color darkGreenSurface = Color(0xFF3A2A1E);
  static const Color darkText = Color(0xFFFFF3E5);
  static const Color darkMutedText = Color(0xFFD2B99E);
  static const Color darkBorder = Color(0xFF3A2A1E);

  // ── Gradients (same in both themes) ────────────────────────────────────────
  static final LinearGradient balanceCardGradient = const LinearGradient(
    colors: [greenDark, primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient headerGradient = const LinearGradient(
    colors: [greenDark, primaryDark, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: green,
      secondary: secondary,
      tertiary: tertiary,
      surface: card,
      onPrimary: onPrimary,
      onSecondary: text,
      onSurface: text,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: text,
        displayColor: text,
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primary,
        unselectedItemColor: mutedText,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: secondary,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
          borderSide: const BorderSide(color: primaryDark, width: 1.3),
        ),
      ),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: green,
      secondary: secondary,
      tertiary: tertiary,
      surface: darkBackground,
      onSurface: darkText,
      onPrimary: onPrimary,
      onSecondary: text,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: darkText, displayColor: darkText),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: darkCard,
        indicatorColor: darkGreenSurface,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
          borderSide: const BorderSide(color: primaryDark, width: 1.3),
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
