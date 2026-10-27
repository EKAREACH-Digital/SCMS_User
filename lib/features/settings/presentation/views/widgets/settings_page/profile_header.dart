import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:smart_canteen_user_frontend/core/constants/images_constant.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

const BorderRadius _kRadius = BorderRadius.vertical(
  bottom: Radius.circular(32),
);

/// Settings page header: brand gradient with the wave line pattern, rounded
/// bottom corners, and the signed-in user's avatar, name, email and school.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEditPhoto,
    required this.onEditProfile,
  });

  final AuthViewModel user;
  final VoidCallback onEditPhoto;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _kRadius,
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _kRadius,
        child: Stack(
          children: [
            const Positioned.fill(child: _WavePattern()),
            _HeaderContent(
              user: user,
              onEditPhoto: onEditPhoto,
              onEditProfile: onEditProfile,
            ),
          ],
        ),
      ),
    );
  }
}

// Decorative line art, tinted white and kept faint so the text stays readable
class _WavePattern extends StatelessWidget {
  const _WavePattern();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SvgPicture.asset(
        ImageConst.waveVectorPattern,
        fit: BoxFit.cover,
        alignment: Alignment.centerRight,
        colorFilter: ColorFilter.mode(
          AppColors.onPrimary.withValues(alpha: 0.14),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent({
    required this.user,
    required this.onEditPhoto,
    required this.onEditProfile,
  });

  final AuthViewModel user;
  final VoidCallback onEditPhoto;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        32,
      ),
      child: Column(
        children: [
          _TitleRow(onEditProfile: onEditProfile),
          const SizedBox(height: 24),
          _Avatar(
            photo: user.photo,
            initials: user.initials,
            onTap: onEditPhoto,
          ),
          const SizedBox(height: 14),
          Text(
            user.displayName,
            style: AppFonts.heading1.copyWith(
              color: AppColors.onPrimary,
              fontWeight: AppFonts.bold,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user.email,
            style: AppFonts.heading3.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.75),
              fontWeight: AppFonts.regular,
            ),
          ),
          const SizedBox(height: 12),
          _SchoolBadge(label: user.badge),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.onEditProfile});

  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: AppFonts.heading1.copyWith(
            color: AppColors.onPrimary,
            fontWeight: AppFonts.bold,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        _GlassIconButton(icon: Icons.edit_outlined, onTap: onEditProfile),
      ],
    );
  }
}

class _SchoolBadge extends StatelessWidget {
  const _SchoolBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.onPrimary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppFonts.heading4.copyWith(
          color: AppColors.onPrimary,
          fontWeight: AppFonts.semiBold,
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onPrimary.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.onPrimary.withValues(alpha: 0.2),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: AppColors.onPrimary, size: 18),
        ),
      ),
    );
  }
}

/// Avatar with a blurred halo behind it and a gentle scale-in on load.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.photo,
    required this.initials,
    required this.onTap,
  });

  final File? photo;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.7, end: 1.0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale.clamp(0.0, 1.0), child: child),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 116,
          height: 116,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              const _AvatarHalo(),
              _AvatarCircle(photo: photo, initials: initials),
              const Positioned(right: 12, bottom: 12, child: _CameraBadge()),
            ],
          ),
        ),
      ),
    );
  }
}

// Blurred translucent ring behind the avatar for depth
class _AvatarHalo extends StatelessWidget {
  const _AvatarHalo();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.onPrimary.withValues(alpha: 0.18),
          ),
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.photo, required this.initials});

  final File? photo;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.onPrimary,
        border: Border.all(color: AppColors.onPrimary, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: photo != null
            ? Image.file(photo!, fit: BoxFit.cover, width: 86, height: 86)
            : Center(
                child: Text(
                  initials,
                  style: AppFonts.heading1.copyWith(
                    fontSize: 28,
                    fontWeight: AppFonts.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
      ),
    );
  }
}

class _CameraBadge extends StatelessWidget {
  const _CameraBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6)],
      ),
      child: const Icon(
        Icons.camera_alt_rounded,
        size: 14,
        color: AppColors.primary,
      ),
    );
  }
}
