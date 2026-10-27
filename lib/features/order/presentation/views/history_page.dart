import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/constants/food_visuals.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/order/presentation/viewmodels/order_history_viewmodel.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

// Shared color cues
const Color _kRed = Color(0xFFE53935); // expenses
const Color _kGray = Color(0xFF9E9E9E); // neutral
// Pending: amber reads as "in progress" and stays legible on both the light
// and dark card backgrounds, unlike a pure yellow.
const Color _kAmber = Color(0xFFF9A825);

/// [OrderRecord.status] carries the English token the state layer produces,
/// which is also what the comparisons in this file branch on.
/// Translate it only at the point of display.
String _statusLabel(AppLocalizations l10n, OrderRecord record) =>
    switch (record.status) {
      'Awaiting Payment' => 'Awaiting Payment',
      'Paid' => 'Paid',
      'Preparing' => 'Preparing',
      'Ready' => 'Ready for Pickup',
      // A finished meal order is "Redeemed" — the same word the staff
      // dashboard uses when it scans the ticket.
      'Completed' => l10n.statusRedeemed,
      'Failed' => l10n.statusFailed,
      _ => l10n.statusPending,
    };

/// Color for a status badge. Green = positive progress, amber = waiting,
/// red = money spent / failed, grey = cancelled (no charge).
Color _statusColor(String status) => switch (status) {
  'Paid' || 'Ready' => const Color(0xFF2E7D32), // green
  'Completed' => _kRed, // spent = red expense
  'Failed' => _kRed,
  _ => _kAmber, // Awaiting Payment, Preparing, Pending
};

/// How the transaction list is ordered.
enum _SortBy { newest, amountHigh, amountLow }

extension on _SortBy {
  String label(AppLocalizations l10n) => switch (this) {
    _SortBy.newest => l10n.historySortNewest,
    _SortBy.amountHigh => l10n.historySortAmountHigh,
    _SortBy.amountLow => l10n.historySortAmountLow,
  };

  IconData get icon => switch (this) {
    _SortBy.newest => Icons.schedule_rounded,
    _SortBy.amountHigh => Icons.arrow_downward_rounded,
    _SortBy.amountLow => Icons.arrow_upward_rounded,
  };
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  _SortBy _sort = _SortBy.newest;

  // Tracks the last TickerMode value so we can detect when this tab
  // becomes active (TickerMode flips false → true on each tab switch).
  bool? _wasTickerEnabled;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = TickerMode.valuesOf(context).enabled;
    // Load on first visit (null → true) and on every subsequent tab switch
    // (false → true). Ignored when the tab goes inactive (true → false).
    if (_wasTickerEnabled != enabled && enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    }
    _wasTickerEnabled = enabled;
  }

  /// Fetches history. Also the retry action on the error state.
  Future<void> _load() {
    return context.read<OrderHistoryViewModel>().loadFromBackend();
  }

  List<OrderRecord> _sorted(List<OrderRecord> orders) {
    final list = [...orders];
    switch (_sort) {
      case _SortBy.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortBy.amountHigh:
        list.sort((a, b) => b.total.compareTo(a.total));
      case _SortBy.amountLow:
        list.sort((a, b) => a.total.compareTo(b.total));
    }
    return list;
  }

  void _showSortMenu() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      // The tab's own navigator sits under the nav bar, so a sheet opened there
      // stops above it; the root navigator lets it cover the full screen.
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        current: _sort,
        onSelected: (s) => setState(() => _sort = s),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderHistoryViewModel>();
    final orders = state.orders;
    final sorted = _sorted(orders);

    return Scaffold(
      body: Column(
        children: [
          _HistoryHeader(
            isSortActive: _sort != _SortBy.newest,
            onSortTap: _showSortMenu,
          ),
          Expanded(
            // Once there is data, keep showing it — a failed background
            // refresh shouldn't blank out a list the user can still read.
            child: orders.isNotEmpty
                ? _OrderList(sorted: sorted)
                : state.isLoading
                ? const _LoadingState()
                : state.error != null
                ? _ErrorState(message: state.error!, onRetry: _load)
                : const _EmptyState(),
          ),
        ],
      ),
    );
  }
}

// Animated gradient header

class _HistoryHeader extends StatefulWidget {
  const _HistoryHeader({required this.isSortActive, required this.onSortTap});

  final bool isSortActive;
  final VoidCallback onSortTap;

  @override
  State<_HistoryHeader> createState() => _HistoryHeaderState();
}

class _HistoryHeaderState extends State<_HistoryHeader> {
  bool _sortPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.12),
            context.bgColor.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
          // Title fades in and slides up once on mount.
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeInOut,
            builder: (context, t, child) => AnimatedOpacity(
              opacity: t,
              duration: Duration.zero,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 14),
                child: child,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.historyTitle,
                        style: AppFonts.heading1.copyWith(
                          fontSize: 24,
                          fontWeight: AppFonts.bold,
                          color: context.textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)!.historySubtitle,
                        style: AppFonts.heading4.copyWith(
                          fontSize: 12.5,
                          color: context.mutedColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTapDown: (_) => setState(() => _sortPressed = true),
                  onTapUp: (_) {
                    setState(() => _sortPressed = false);
                    widget.onSortTap();
                  },
                  onTapCancel: () => setState(() => _sortPressed = false),
                  child: AnimatedScale(
                    scale: _sortPressed ? 0.92 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: widget.isSortActive
                            ? const LinearGradient(
                                colors: [
                                  AppColors.primaryDark,
                                  AppColors.primaryLight,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: widget.isSortActive ? null : context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: widget.isSortActive
                                ? AppColors.primary.withValues(alpha: 0.35)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 21,
                        color: widget.isSortActive
                            ? Colors.white
                            : context.textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Transaction card

class _OrderCard extends StatefulWidget {
  const _OrderCard({required this.order});
  final OrderRecord order;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _pressed = false;

  void _openDetails() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      // The tab's own navigator sits under the nav bar, so a sheet opened there
      // stops above it; the root navigator lets it cover the full screen.
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailsSheet(order: widget.order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isFailed = order.status == 'Failed';
    final isCompleted = order.status == 'Completed';
    final isInProgress = !isFailed && !isCompleted;

    // Color cues: red = spent/failed, amber/green = in-progress, grey = cancelled.
    final statusColor = _statusColor(order.status);

    final amountColor = isFailed
        ? _kGray
        : isInProgress
        ? _kAmber
        : _kRed;
    final amountLabel = '\$${order.total.toStringAsFixed(2)}';
    final itemCount = order.lines.fold<int>(0, (n, l) => n + l.quantity);

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.primary.withValues(alpha: 0.12),
            highlightColor: AppColors.primary.withValues(alpha: 0.05),
            onTap: _openDetails,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: _FoodThumbnail(order: order),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.items,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.heading3.copyWith(
                            fontWeight: AppFonts.bold,
                            color: context.textColor,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: context.mutedColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                order.date,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.heading5.copyWith(
                                  fontSize: 11.5,
                                  color: context.mutedColor,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (itemCount > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.historyItemCount(itemCount),
                            style: AppFonts.heading5.copyWith(
                              fontSize: 11,
                              fontWeight: AppFonts.semiBold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        amountLabel,
                        style: AppFonts.heading2.copyWith(
                          fontWeight: AppFonts.bold,
                          color: amountColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _StatusBadge(
                        label: _statusLabel(
                          AppLocalizations.of(context)!,
                          order,
                        ),
                        color: statusColor,
                        pulse: isCompleted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Status pill. When [pulse] is true (Completed) it gently breathes.
class _StatusBadge extends StatefulWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.pulse,
  });

  final String label;
  final Color color;
  final bool pulse;

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.pulse) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_StatusBadge old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulse && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.pulse) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            widget.label,
            style: AppFonts.heading5.copyWith(
              color: widget.color,
              fontWeight: AppFonts.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (!widget.pulse) return pill;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return AnimatedOpacity(
          opacity: 0.65 + 0.35 * t,
          duration: Duration.zero,
          child: child,
        );
      },
      child: pill,
    );
  }
}

// Loading state

/// Shown only on the first load, while there is nothing to display yet.
/// Without this the empty state flashes before the data arrives.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// Error state

/// Shown when the fetch failed and there is no cached list to fall back on.
/// Distinguishes "we couldn't load this" from "you have no orders".
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _kRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: _kRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.historyErrorTitle,
              textAlign: TextAlign.center,
              style: AppFonts.heading2.copyWith(
                fontWeight: AppFonts.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.heading3.copyWith(
                fontSize: 13,
                color: context.mutedColor,
                fontWeight: AppFonts.regular,
              ),
            ),
            const SizedBox(height: 18),
            _RetryButton(onRetry: onRetry),
          ],
        ),
      ),
    );
  }
}

/// Retry affordance that shows a spinner while the refetch is in flight.
class _RetryButton extends StatefulWidget {
  const _RetryButton({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    unawaited(HapticFeedback.selectionClick());
    setState(() => _busy = true);
    try {
      await widget.onRetry();
    } finally {
      // The screen stays mounted through a failed retry, but guard anyway.
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _run,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: _busy ? 0.15 : 0.35),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: _busy
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(width: 8),
            Text(
              _busy
                  ? AppLocalizations.of(context)!.historyRetrying
                  : AppLocalizations.of(context)!.historyRetry,
              style: AppFonts.heading3.copyWith(
                fontSize: 13.5,
                fontWeight: AppFonts.bold,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Empty state

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.historyEmptyTitle,
            style: AppFonts.heading2.copyWith(
              fontWeight: AppFonts.bold,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.historyEmptyBody,
            style: AppFonts.heading3.copyWith(
              fontSize: 13,
              color: context.mutedColor,
              fontWeight: AppFonts.regular,
            ),
          ),
        ],
      ),
    );
  }
}

// Thumbnails

class _FoodThumbnail extends StatelessWidget {
  const _FoodThumbnail({required this.order});
  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    // Remote photo first — it's the same picture the menu shows. A bundled
    // asset is only present on optimistically-added orders.
    if (order.imageUrl != null) {
      return Image.network(
        order.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(),
        errorBuilder: (_, _, _) => order.imagePath != null
            ? Image.asset(
                order.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      );
    }
    if (order.imagePath != null) {
      return Image.asset(
        order.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final idx = order.colorSeed % kFoodGradients.length;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: kFoodGradients[idx],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          kFoodIcons[idx % kFoodIcons.length],
          color: AppColors.primary,
          size: 22,
        ),
      ),
    );
  }
}

// View Details modal

class _DetailsSheet extends StatelessWidget {
  const _DetailsSheet({required this.order});
  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Pads inside the card (not a SafeArea around it) so the white reaches
      // the screen edge behind the gesture bar.
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      // An order with many lines can outgrow the sheet, so the body scrolls
      // while the grabber and title stay put.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: _FoodThumbnail(order: order),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.historyOrderDetails,
                      style: AppFonts.heading2.copyWith(
                        fontSize: 18,
                        fontWeight: AppFonts.bold,
                        color: context.textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.date,
                      style: AppFonts.heading4.copyWith(
                        color: context.mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Flexible(
            child: SingleChildScrollView(
              child: _FoodOrderDetails(order: order),
            ),
          ),
        ],
      ),
    );
  }
}

// Sort options bottom sheet

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current, required this.onSelected});

  final _SortBy current;
  final ValueChanged<_SortBy> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Pads inside the card (not a SafeArea around it) so the white reaches
      // the screen edge behind the gesture bar.
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            AppLocalizations.of(context)!.commonSortBy,
            style: AppFonts.heading2.copyWith(
              fontSize: 18,
              fontWeight: AppFonts.bold,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 12),
          for (final value in _SortBy.values)
            _SortTile(
              label: value.label(AppLocalizations.of(context)!),
              icon: value.icon,
              selected: current == value,
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(value);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  const _SortTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : context.borderColor,
            width: selected ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : context.mutedColor,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppFonts.heading3.copyWith(
                fontWeight: selected ? AppFonts.bold : AppFonts.medium,
                color: selected ? AppColors.primary : context.textColor,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// Expanded breakdown for food orders

class _FoodOrderDetails extends StatelessWidget {
  const _FoodOrderDetails({required this.order});
  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.historyItems,
          style: AppFonts.heading4.copyWith(
            fontWeight: AppFonts.semiBold,
            color: context.mutedColor,
          ),
        ),
        const SizedBox(height: 8),
        // One row per dish, with its own quantity and what it cost. Falls back
        // to the joined summary string for optimistically-added orders, which
        // have no lines until the next refresh.
        if (order.lines.isEmpty)
          _DetailRow(
            label: l10n.historyItems,
            value: order.items,
            valueStyle: AppFonts.heading3.copyWith(
              fontSize: 13,
              fontWeight: AppFonts.semiBold,
              color: AppColors.primary,
            ),
          )
        else
          for (final line in order.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OrderLineRow(line: line),
            ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Divider(color: context.borderColor, height: 1),
        ),
        const SizedBox(height: 10),
        _DetailRow(
          label: l10n.historyTotalAmount,
          value: '\$${order.total.toStringAsFixed(2)}',
          valueStyle: AppFonts.heading3.copyWith(
            fontWeight: AppFonts.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        _DetailRow(
          label: l10n.historyInKhr,
          value: '៛${(order.total * 4000).toStringAsFixed(0)}',
          valueStyle: AppFonts.heading4.copyWith(
            fontWeight: AppFonts.semiBold,
            color: context.mutedColor,
          ),
        ),
        const SizedBox(height: 10),
        _DetailRow(
          label: l10n.historyOrderedOn,
          value: order.date,
          valueStyle: AppFonts.heading4.copyWith(
            fontWeight: AppFonts.semiBold,
            color: context.mutedColor,
          ),
        ),
        if (order.session != null) ...[
          const SizedBox(height: 8),
          _DetailRow(
            label: l10n.historyMealSession,
            value: order.session!,
            valueStyle: AppFonts.heading4.copyWith(
              fontWeight: AppFonts.semiBold,
              color: context.mutedColor,
            ),
          ),
        ],
        const SizedBox(height: 8),
        _DetailRow(
          label: l10n.historyStatus,
          value: _statusLabel(l10n, order),
          valueStyle: AppFonts.heading4.copyWith(
            fontWeight: AppFonts.semiBold,
            color: _statusColor(order.status),
          ),
        ),
      ],
    );
  }
}

// One dish within an order

class _OrderLineRow extends StatelessWidget {
  const _OrderLineRow({required this.line});

  final OrderLine line;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Quantity badge, so "×2" is readable at a glance rather than buried
        // in the dish name.
        Container(
          constraints: const BoxConstraints(minWidth: 28),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          // decoration: BoxDecoration(
          //   color: AppColors.primary.withValues(alpha: 0.1),
          //   borderRadius: BorderRadius.circular(6),
          // ),
          child: Text(
            '×${line.quantity}',
            textAlign: TextAlign.center,
            style: AppFonts.heading5.copyWith(
              fontSize: 11,
              fontWeight: AppFonts.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.heading3.copyWith(
                  fontSize: 13,
                  fontWeight: AppFonts.semiBold,
                  color: context.textColor,
                ),
              ),
              // Only worth showing the unit price when more than one was
              // bought; otherwise it just repeats the line total.
              if (line.unitPrice != null && line.quantity > 1)
                Text(
                  '\$${line.unitPrice!.toStringAsFixed(2)} each',
                  style: AppFonts.heading5.copyWith(
                    fontSize: 11,
                    color: context.mutedColor,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          line.lineTotal == null
              ? '—'
              : '\$${line.lineTotal!.toStringAsFixed(2)}',
          style: AppFonts.heading3.copyWith(
            fontSize: 13,
            fontWeight: AppFonts.bold,
            color: line.lineTotal == null
                ? context.mutedColor
                : AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// Detail row helper

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.heading4.copyWith(color: context.mutedColor),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style:
                valueStyle ??
                AppFonts.heading4.copyWith(fontWeight: AppFonts.semiBold),
          ),
        ),
      ],
    );
  }
}

// Sorted order list

class _OrderList extends StatelessWidget {
  const _OrderList({required this.sorted});

  final List<OrderRecord> sorted;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.paddingOf(context).bottom + 50),
      itemCount: sorted.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _OrderCard(order: sorted[index]),
      ),
    );
  }
}

