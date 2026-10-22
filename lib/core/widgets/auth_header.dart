import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

/// Logo badge + title + tagline used at the top of every auth screen.
///
/// [title] — the large heading (e.g. "Welcome Back", "Register")
/// [subtitle] — the lighter tagline below the title
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: AppColors.onPrimary,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppFonts.heading1.copyWith(
            color: AppColors.primaryDark,
            fontSize: 30,
            fontWeight: AppFonts.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppFonts.heading3.copyWith(
            color: AppColors.text.withValues(alpha: 0.5),
            height: 1.4,
            fontWeight: AppFonts.regular,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
