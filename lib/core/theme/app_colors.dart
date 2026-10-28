import 'package:flutter/material.dart';

/// All color constants for the app.
/// Use these everywhere — never hardcode a Color value inline.
///
/// Rules:
///   FOLLOW:  AppColors.primary
///   PREVENT:  Color(0xFF0B5A7A)  or  Colors.teal
///   FOLLOW:  color.withValues(alpha: 0.5)
///   PREVENT:  color.withOpacity(0.5)
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF0B5A7A);
  static const Color primaryDark = Color(0xFF084460);
  static const Color primaryLight = Color(0xFF3D8FA8);
  static const Color primaryTint = Color(0xFFEAF4F7);

  // Secondary
  static const Color secondary = Color(0xFF0B8F7A);
  static const Color secondaryDark = Color(0xFF08705E);
  static const Color secondaryLight = Color(0xFF3DAFA0);
  static const Color secondaryTint = Color(0xFFE6F7F5);

  // Accents / Status
  static const Color accentRed = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFFFCB3D);
  static const Color orange = Color(0xFFF2994A);
  static const Color success = secondary;

  // Backgrounds
  static const Color background = Color.fromARGB(255, 255, 255, 255);
  static const Color card = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF04161E);
  static const Color darkCard = Color(0xFF0D2530);
  static const Color darkSurface = Color(0xFF0D3040);

  // Text
  static const Color text = Color(0xFF1C130A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF6B8A96);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color mutedText = Color(0xFF6B8A96);
  static const Color darkText = Color(0xFFEAF4F7);
  static const Color darkMutedText = Color(0xFF9BB8C4);

  // Borders
  static const Color border = Color(0xFFD6E8EF);
  static const Color darkBorder = Color(0xFF1A3A4A);

  // Grey Scale
  static const Color grey100 = Color(0xFFF7FAFC);
  static const Color grey200 = Color(0xFFEDF2F7);
  static const Color grey300 = Color(0xFFE2E8F0);
  static const Color grey400 = Color(0xFFCBD5E0);
  static const Color grey500 = Color(0xFFA0AEC0);
  static const Color grey700 = Color(0xFF4A5568);
  static const Color grey800 = Color(0xFF2D3748);

  // Shadows — non-const, use withValues(alpha:) not withOpacity()
  static final Color shadowLight = Colors.black.withValues(alpha: 0.1);
  static final Color shadowMedium = Colors.black.withValues(alpha: 0.2);
  static final Color shadowDark = Colors.black.withValues(alpha: 0.3);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B5A7A), Color(0xFF000A22)],
    stops: [0.0, 0.9],
  );

  static const LinearGradient balanceCardGradient = LinearGradient(
    colors: [primaryDark, secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [primaryDark, secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
