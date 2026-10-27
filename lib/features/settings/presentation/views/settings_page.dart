import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/dialog/app_dialog.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/widgets/settings_page/profile_header.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/widgets/settings_widgets.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/viewmodels/app_settings_viewmodel.dart';
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
        style: AppFonts.heading3.copyWith(
          color: context.mutedColor,
          height: 1.4,
        ),
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
                style: AppFonts.heading2.copyWith(
                  fontWeight: AppFonts.bold,
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
    final settings = context.watch<AppSettingsViewModel>();
    final user = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: context.bgColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SettingsFadeIn(
            index: 0,
            child: ProfileHeader(
              user: user,
              onEditPhoto: _showImageSourceSheet,
              onEditProfile: () => _open(AppPaths.editProfile),
            ),
          ),

          // Stats row
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          //   child: SettingsFadeIn(
          //     index: 1,
          //     child: Row(
          //       children: [
          //         Expanded(
          //           child: _StatCard(
          //             icon: Icons.receipt_long_rounded,
          //             end: orders.length.toDouble(),
          //             label: 'Orders',
          //           ),
          //         ),
          //         // const SizedBox(width: 12),
          //         // Expanded(
          //         //   child: _StatCard(
          //         //     icon: Icons.account_balance_wallet_rounded,
          //         //     end: balanceValue,
          //         //     prefix: '\$',
          //         //     decimals: 2,
          //         //     label: 'Balance',
          //         //   ),
          //         // ),
          //       ],
          //     ),
          //   ),
          // ),

          // Account section
          SettingsFadeIn(
            index: 2,
            child: SettingsSection(
              title: 'Account',
              children: [
                // Editing lives on the pen icon in the header above, so a
                // duplicate row here would be a second door to one room.
                // SettingsTile(
                //   icon: Icons.credit_card_outlined,
                //   title: 'Payment Methods',
                //   subtitle: 'Manage your saved cards',
                //   onTap: () => _open(AppPaths.paymentMethods),
                // ),
                // SettingsTile(
                //   icon: Icons.history_rounded,
                //   title: 'Order History',
                //   subtitle: 'View past orders',
                //   onTap: () => context.go(AppPaths.history),
                // ),
                // Only for accounts created with Google — they have no password
                // yet, so email/password sign-in is unavailable until they set
                // one. Disappears once a password exists.
                // if (!user.canUseEmailPassword)
                //   SettingsTile(
                //     icon: Icons.key_outlined,
                //     title: 'Set a Password',
                //     subtitle: 'Also log in with your email',
                //     onTap: () => _open(AppPaths.setPassword),
                //   )
                // // Changing needs the current password, so only accounts that
                // // have one see it.
                // else
                //   SettingsTile(
                //     icon: Icons.lock_outline_rounded,
                //     title: 'Change Password',
                //     subtitle: 'Update your login password',
                //     onTap: () => _open(AppPaths.changePassword),
                //   ),
                SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your login password',
                  onTap: () => _open(AppPaths.changePassword),
                ),
                // SettingsTile(
                //   icon: Icons.notifications_outlined,
                //   title: 'Notifications',
                //   subtitle: 'Set your preferences',
                //   isLast: true,
                //   onTap: () => _open(AppPaths.notificationSettings),
                // ),
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
              // The shell uses extendBody, so the nav bar overlaps the list
              // bottom; same clearance as the home page.
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                MediaQuery.of(context).padding.bottom + 50,
              ),
              child: _LogoutButton(onTap: _confirmLogout),
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
          SizedBox(
            width: 40,
            height: 40,
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
                  style: AppFonts.heading3.copyWith(
                    fontWeight: AppFonts.semiBold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDark ? 'Currently on' : 'Currently off',
                  style: AppFonts.heading5.copyWith(color: context.mutedColor),
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
          const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
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
                  style: AppFonts.heading3.copyWith(
                    fontWeight: AppFonts.semiBold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  current.nativeLabel,
                  style: AppFonts.heading5.copyWith(color: context.mutedColor),
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
                  style: AppFonts.heading4.copyWith(
                    fontWeight: AppFonts.bold,
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
            // boxShadow: [
            //   BoxShadow(
            //     color: _kRed.withValues(alpha: 0.32),
            //     blurRadius: 14,
            //     offset: const Offset(0, 6),
            //   ),
            // ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.settingsLogOut,
                style: AppFonts.heading2.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: AppFonts.bold,
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
                style: AppFonts.heading2.copyWith(
                  fontSize: 15,
                  fontWeight: AppFonts.semiBold,
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
