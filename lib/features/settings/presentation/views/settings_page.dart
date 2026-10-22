import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/app_dialog.dart';
import 'package:smart_canteen_user_frontend/core/widgets/settings_widgets.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_history_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/viewmodels/app_settings_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/wallet/presentation/viewmodels/balance_viewmodel.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

const Color _kRed = Color(0xFFE53935);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null && mounted) {
      context.read<AuthViewModel>().setPhoto(File(picked.path));
    }
  }

  void _open(String path) {
    HapticFeedback.selectionClick();
    context.push(path);
  }

  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppDialog.show(
      context,
      title: l10n.settingsLogOut,
      body: Text(
        l10n.settingsLogOutConfirm,
        style: TextStyle(color: context.mutedColor, fontSize: 14, height: 1.4),
      ),
      confirmLabel: l10n.settingsLogOut,
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      unawaited(HapticFeedback.mediumImpact());
      // Clears stored tokens + Google sign-out; the router's redirect then
      // returns to the splash screen.
      await context.read<AuthViewModel>().logout();
    }
  }

  void _showImageSourceSheet() {
    final user = context.read<AuthViewModel>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(ctx)!.settingsChangePhoto,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ctx.textColor,
                ),
              ),
              const SizedBox(height: 16),
              _PickerOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _PickerOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (user.photo != null) ...[
                const SizedBox(height: 10),
                _PickerOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove Photo',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    user.setPhoto(null);
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balanceValue = context.watch<BalanceViewModel>().balanceUsd;
    // History holds food orders only — top-ups are no longer recorded there.
    final orders = context.watch<OrderHistoryViewModel>().orders;
    final settings = context.watch<AppSettingsViewModel>();
    final user = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: context.bgColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SettingsFadeIn(
            index: 0,
            child: _Header(
              user: user,
              onEditPhoto: _showImageSourceSheet,
              onEditProfile: () => _open(AppPaths.editProfile),
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: SettingsFadeIn(
              index: 1,
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.receipt_long_rounded,
                      end: orders.length.toDouble(),
                      label: 'Orders',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.account_balance_wallet_rounded,
                      end: balanceValue,
                      prefix: '\$',
                      decimals: 2,
                      label: 'Balance',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile section
          SettingsFadeIn(
            index: 2,
            child: SettingsSection(
              title: 'Profile',
              children: [
                // Editing lives on the pen icon in the header above, so a
                // duplicate row here would be a second door to one room.
                SettingsTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment Methods',
                  subtitle: 'Manage your saved cards',
                  onTap: () => _open(AppPaths.paymentMethods),
                ),
                SettingsTile(
                  icon: Icons.history_rounded,
                  title: 'Order History',
                  subtitle: 'View past orders',
                  onTap: () => context.go(AppPaths.history),
                ),
                // Only for accounts created with Google — they have no password
                // yet, so email/password sign-in is unavailable until they set
                // one. Disappears once a password exists.
                if (!context.watch<AuthViewModel>().canUseEmailPassword)
                  SettingsTile(
                    icon: Icons.key_outlined,
                    title: 'Set a Password',
                    subtitle: 'Also log in with your email',
                    onTap: () => _open(AppPaths.setPassword),
                  ),
                SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Set your preferences',
                  isLast: true,
                  onTap: () => _open(AppPaths.notificationSettings),
                ),
              ],
            ),
          ),

          // Preferences section
          SettingsFadeIn(
            index: 3,
            child: SettingsSection(
              title: 'Preferences',
              children: [
                _DarkModeTile(
                  isDark: settings.isDarkMode,
                  onToggle: settings.toggleDarkMode,
                ),
                _LanguageTile(
                  current: settings.language,
                  onSelected: settings.setLanguage,
                ),
              ],
            ),
          ),

          // App Info section
          SettingsFadeIn(
            index: 4,
            child: SettingsSection(
              title: 'App Info',
              children: [
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  subtitle: 'App info, version & credits',
                  isLast: true,
                  onTap: () => _open(AppPaths.about),
                ),
              ],
            ),
          ),

          // Logout button
          SettingsFadeIn(
            index: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: _LogoutButton(onTap: _confirmLogout),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated gradient header with avatar

class _Header extends StatelessWidget {
  const _Header({
    required this.user,
    required this.onEditPhoto,
    required this.onEditProfile,
  });

  final AuthViewModel user;
  final VoidCallback onEditPhoto;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        32,
      ),
      decoration: const BoxDecoration(
        // Soft mint → emerald gradient.
        gradient: LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.settingsTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              _IconButtonGlass(icon: Icons.edit_outlined, onTap: onEditProfile),
            ],
          ),
          const SizedBox(height: 24),
          _Avatar(
            photo: user.photo,
            initials: user.initials,
            onTap: onEditPhoto,
          ),
          const SizedBox(height: 14),
          Text(
            user.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user.email,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              user.badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButtonGlass extends StatelessWidget {
  const _IconButtonGlass({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.2),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: Colors.white, size: 18),
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
      builder: (context, scale, child) => Transform.scale(
        scale: scale.clamp(0.0, 1.0),
        child: Opacity(opacity: scale.clamp(0.0, 1.0), child: child),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 116,
          height: 116,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Blurred translucent halo for depth.
              ClipOval(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              ),
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: photo != null
                      ? Image.file(
                          photo!,
                          fit: BoxFit.cover,
                          width: 86,
                          height: 86,
                        )
                      : Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
              ),
              // Edit icon overlay.
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Stat card with count-up number

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.end,
    required this.label,
    this.prefix = '',
    this.decimals = 0,
  });

  final IconData icon;

  /// Target value; null shows a loading placeholder.
  final double? end;
  final String label;
  final String prefix;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          const SizedBox(height: 10),
          if (end == null)
            Text(
              '···',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: context.mutedColor,
              ),
            )
          else
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: end),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              builder: (context, value, _) => Text(
                '$prefix${value.toStringAsFixed(decimals)}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: context.mutedColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// Dark mode tile with animated icon + pill toggle

class _DarkModeTile extends StatelessWidget {
  const _DarkModeTile({required this.isDark, required this.onToggle});

  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                key: ValueKey(isDark),
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.settingsDarkMode,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDark ? 'Currently on' : 'Currently off',
                  style: TextStyle(color: context.mutedColor, fontSize: 11),
                ),
              ],
            ),
          ),
          AppPillToggle(value: isDark, onChanged: (_) => onToggle()),
        ],
      ),
    );
  }
}

// Language tile with inline EN / ខ្មែរ segmented control

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.current, required this.onSelected});

  final AppLanguage current;
  final ValueChanged<AppLanguage> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.translate_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLanguage,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  current.nativeLabel,
                  style: TextStyle(color: context.mutedColor, fontSize: 11),
                ),
              ],
            ),
          ),
          _LanguageSegment(current: current, onSelected: onSelected),
        ],
      ),
    );
  }
}

class _LanguageSegment extends StatelessWidget {
  const _LanguageSegment({required this.current, required this.onSelected});

  final AppLanguage current;
  final ValueChanged<AppLanguage> onSelected;

  /// Short labels, each written in its own script so the inactive option stays
  /// recognisable to someone who can't read the active language.
  static String _shortLabel(AppLanguage lang) => switch (lang) {
    AppLanguage.english => 'EN',
    AppLanguage.khmer => 'ខ្មែរ',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final lang in AppLanguage.values)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(lang);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: lang == current
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _shortLabel(lang),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: lang == current ? Colors.white : context.mutedColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Logout button

class _LogoutButton extends StatefulWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: _kRed.withValues(alpha: 0.32),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.settingsLogOut,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Image source picker option

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? _kRed : AppColors.primary;
    final bgColor = isDestructive
        ? const Color(0xFFFFEBEE)
        : context.surfaceColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
