import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/view_state.dart';
import 'package:smart_canteen_user_frontend/features/notification/domain/entities/notification_item.dart';
import 'package:smart_canteen_user_frontend/features/notification/presentation/viewmodels/notification_viewmodel.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.alertsTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: vm.markAllRead,
            child: Text(
              l10n.alertsMarkAllRead,
              style: const TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
        ],
      ),
      body: switch (vm.state) {
        ViewState.error => Center(child: Text(vm.errorMessage ?? '')),
        ViewState.success when vm.items.isEmpty => Center(
          child: Text(
            l10n.alertsEmpty,
            style: const TextStyle(color: AppColors.mutedText),
          ),
        ),
        ViewState.success => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: vm.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) => AlertTile(item: vm.items[i]),
        ),
        // Not fetched yet (idle) or fetching.
        _ => const Center(child: CircularProgressIndicator()),
      },
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
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFE53935),
        ),
      ),
      onDismissed: (_) => context.read<NotificationViewModel>().dismiss(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : AppColors.primaryTint,
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
            _Thumbnail(
              item: item,
              fallbackBg: _iconBg(item.type),
              fallbackIcon: _icon(item.type),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
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

/// The 40×40 leading square: the dish photo or bank logo when the alert has
/// one, otherwise the category icon.
///
/// A remote photo that fails to load falls back to the icon rather than
/// leaving a broken box — alerts arrive on the same patchy connections the
/// rest of the app has to survive.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.item,
    required this.fallbackBg,
    required this.fallbackIcon,
  });

  final NotificationItem item;
  final Color fallbackBg;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final image = _image();
    if (image == null) return _fallback();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(width: 40, height: 40, child: image),
    );
  }

  Widget? _image() {
    final url = item.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _assetOrFallback(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _fallback(),
      );
    }
    final asset = item.imageAsset;
    if (asset != null && asset.isNotEmpty) return _assetImage(asset);
    return null;
  }

  /// Assets here are bank logos as often as they are dishes, so the mark is
  /// fitted whole on the category tint rather than cropped to fill — a
  /// cover-cropped logo loses the part that identifies it.
  Widget _assetImage(String asset) => Container(
    width: 40,
    height: 40,
    color: fallbackBg,
    padding: const EdgeInsets.all(6),
    child: Image.asset(
      asset,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          Icon(fallbackIcon, size: 20, color: AppColors.primary),
    ),
  );

  /// A dish whose remote photo failed still has its bundled image to fall back
  /// on before we give up and show the generic icon.
  Widget _assetOrFallback() {
    final asset = item.imageAsset;
    if (asset != null && asset.isNotEmpty) return _assetImage(asset);
    return _fallback();
  }

  Widget _fallback() => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: fallbackBg,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Icon(fallbackIcon, size: 20, color: AppColors.primary),
  );
}
