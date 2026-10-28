import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_colors.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_fonts.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Liquid Glass bottom navigation bar.
///
/// Wraps [GlassTabBar.bottom] from `liquid_glass_widgets` to provide the
/// same 5-tab navigation (Home / Menu / QR / History / Settings) that the
/// app shell (`ScaffoldWithNavBar` in `app_router.dart`) switches between.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Edge-to-edge draws the app under the system nav bar, and GlassTabBar
    // adds no bottom inset itself, so lift it above the system bar here.
    return SafeArea(
      top: false,
      child: GlassTabBar.bottom(
        selectedIndex: currentIndex,
        onTabSelected: onTap,
        selectedIconColor: AppColors.primary,
        unselectedIconColor: AppColors.mutedText,
        selectedLabelColor: AppColors.primary,
        unselectedLabelColor: AppColors.mutedText,
        selectedLabelStyle: AppFonts.heading5.copyWith(
          fontWeight: AppFonts.semiBold,
        ),
        unselectedLabelStyle: AppFonts.heading5.copyWith(
          fontWeight: AppFonts.regular,
        ),
        verticalPadding: 16,
        barHeight: 56,
        tabs: [
          GlassTab(icon: const Icon(Icons.home_rounded), label: l10n.navHome),
          GlassTab(
            icon: const Icon(Icons.restaurant_menu_rounded),
            label: l10n.navMenu,
          ),
          GlassTab(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: l10n.navQrPay,
          ),
          GlassTab(
            icon: const Icon(Icons.receipt_long_rounded),
            label: l10n.navHistory,
          ),
          GlassTab(
            icon: const Icon(Icons.settings_rounded),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
