import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../shell/app_shell.dart';
import '../../utils/async_value.dart';
import '../../widgets/smart_canteen_widgets.dart';
import 'view_model/notification_view_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  static const routeName = '/notifications';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.alertsTitle,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: vm.markAllRead,
            child: Text(l10n.alertsMarkAllRead,
                style: const TextStyle(color: AppTheme.green, fontSize: 13)),
          ),
        ],
      ),
      body: switch (vm.state) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(error: final err) => Center(child: Text('Error: $err')),
        AsyncData(data: final items) when items.isEmpty => Center(
            child: Text(l10n.alertsEmpty,
                style: const TextStyle(color: AppTheme.mutedText)),
          ),
        AsyncData(data: final items) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => AlertTile(item: items[i]),
          ),
      },
      bottomNavigationBar: SmartCanteenNavigationBarButton(
        currentIndex: -1,
        onTap: (i) => AppShell.goToTab(context, i),
      ),
    );
  }
}

class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935)),
      ),
      onDismissed: (_) =>
          context.read<NotificationViewModel>().dismiss(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : AppTheme.greenSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconBg(item.type),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon(item.type), size: 20, color: AppTheme.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.text)),
                  const SizedBox(height: 2),
                  Text(item.body, style: const TextStyle(fontSize: 12, color: AppTheme.mutedText), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (!item.isRead)
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.green, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }

  Color _iconBg(String type) {
    return switch (type) {
      'promo' => const Color(0xFFFFF8E1),
      _ => const Color(0xFFE8F5E9),
    };
  }

  IconData _icon(String type) {
    return switch (type) {
      'wallet' || 'balance' => Icons.account_balance_wallet_outlined,
      'order' => Icons.receipt_long_rounded,
      'promo' => Icons.local_offer_outlined,
      'coupon' => Icons.qr_code_2,
      'announcement' => Icons.campaign_rounded,
      _ => Icons.notifications_outlined,
    };
  }
}
