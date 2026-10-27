import 'package:flutter/material.dart';

/// Typography system for the app.
///
/// Primary font : Roboto        (local asset, pubspec.yaml) — English
/// Khmer fallback: KantumruyPro (local asset, pubspec.yaml) — Khmer
///
/// fontFamilyFallback is the bilingual key — Roboto has no Khmer glyphs, so
/// Flutter picks KantumruyPro for any Khmer codepoint (U+1780–U+17FF) in the
/// same Text(). Without it, Khmer characters render as tofu boxes on iOS.
///
/// Rules:
///   YES : AppFonts.heading2.copyWith(color: AppColors.text)
///   NO  :  TextStyle(fontSize: 16, fontWeight: FontWeight.w600)  — breaks Khmer
class AppFonts {
  AppFonts._();

  // Font families, declared in pubspec.yaml
  static const String family = 'Roboto';
  static const List<String> fallback = ['KantumruyPro'];

  // Font weight constants
  // Always use these — never FontWeight.wXXX directly.
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Font size constants
  static const double fontSize10 = 10.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;
  static const double fontSize32 = 32.0;

  // Private factory
  static TextStyle _style({
    required double size,
    required FontWeight weight,
    double letterSpacing = 0,
  }) =>
      // The fallback is set here as well as on ThemeData so Khmer still
      // renders where no theme style is merged in (TextPainter, inherit: false).
      TextStyle(
        fontFamily: family,
        fontFamilyFallback: fallback,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      );

  // Type scale
  // Size + weight only. Color is always added at the call site:
  //   AppFonts.heading1.copyWith(color: AppColors.text)
  static TextStyle get heading1 =>
      _style(size: fontSize20, weight: semiBold); // AppBar titles
  static TextStyle get heading2 => _style(
    size: fontSize16,
    weight: semiBold,
  ); // Section headers, button labels
  static TextStyle get heading3 =>
      _style(size: fontSize14, weight: medium); // Input labels, card body
  static TextStyle get heading4 =>
      _style(size: fontSize12, weight: medium); // Body text, list items
  static TextStyle get heading5 =>
      _style(size: fontSize10, weight: medium); // Captions, stepper labels

  // Bilingual utility
  // Only needed when you must check for Khmer at the data level (e.g. dynamic
  // API content). Normal widget code gets Khmer support automatically.
  static bool containsKhmer(String text) =>
      text.runes.any((r) => r >= 0x1780 && r <= 0x17FF);
}
