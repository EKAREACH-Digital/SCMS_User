import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/widgets/settings_widgets.dart';
import 'package:smart_canteen_user_frontend/features/notification/presentation/viewmodels/notification_prefs_viewmodel.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  /// Awaits a toggle's save and shows an error if it was rolled back.
  Future<void> _persist(BuildContext context, Future<bool> save) async {
    final ok = await save;
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't save your preference. Please try again."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFE53935),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<NotificationPrefsViewModel>();

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Column(
        children: [
          const SettingsHeader(
            title: 'Notifications',
            subtitle: 'Choose what you hear about',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                SettingsFadeIn(
                  index: 0,
                  child: SettingsSection(
                    title: 'Push Notifications',
                    children: [
                      _ToggleTile(
                        icon: Icons.receipt_long_rounded,
                        title: 'Order Updates',
                        subtitle: 'Status of your orders & top-ups',
                        value: prefs.orderUpdates,
                        onChanged: (v) =>
                            _persist(context, prefs.setOrderUpdates(v)),
                      ),
                      _ToggleTile(
                        icon: Icons.local_offer_rounded,
                        title: 'Promotions',
                        subtitle: 'Deals, discounts & coupons',
                        value: prefs.promotions,
                        onChanged: (v) =>
                            _persist(context, prefs.setPromotions(v)),
                      ),
                      _ToggleTile(
                        icon: Icons.campaign_rounded,
                        title: 'System Alerts',
                        subtitle: 'Important account & app notices',
                        value: prefs.systemAlerts,
                        onChanged: (v) =>
                            _persist(context, prefs.setSystemAlerts(v)),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                SettingsFadeIn(
                  index: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: context.mutedColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You can change these anytime. System alerts keep '
                            'your account secure.',
                            style: AppFonts.heading5.copyWith(
                              fontSize: 11.5,
                              height: 1.4,
                              color: context.mutedColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      isLast: isLast,
      trailing: AppPillToggle(value: value, onChanged: onChanged),
    );
  }
}
