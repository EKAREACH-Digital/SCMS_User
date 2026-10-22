import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';

/// Top bar: user avatar (left) + greeting + notification bell (right).
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.authViewModel,
    required this.onNotificationTap,
    required this.onAvatarTap,
  });

  final AuthViewModel authViewModel;
  final VoidCallback onNotificationTap;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final firstName = authViewModel.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          _AvatarButton(initials: authViewModel.initials, onTap: onAvatarTap),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $firstName',
                  style: AppFonts.heading2.copyWith(color: context.textColor),
                ),
                Text(
                  'What would you like to eat?',
                  style: AppFonts.heading4.copyWith(color: context.mutedColor),
                ),
              ],
            ),
          ),
          _NotificationButton(onTap: onNotificationTap),
        ],
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.initials, required this.onTap});

  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primaryTint,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            initials,
            style: AppFonts.heading3.copyWith(
              color: AppColors.primary,
              fontWeight: AppFonts.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.notifications_outlined,
          color: AppColors.primary,
          size: 22,
        ),
      ),
    );
  }
}
