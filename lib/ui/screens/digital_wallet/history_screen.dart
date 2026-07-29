import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/order/order_repository.dart';
import '../../../data/repositories/wallet/wallet_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/food_item.dart';
import '../../../theme/app_theme.dart';
import '../../../ui/states/order_history_state.dart';

// ── Shared color cues ──────────────────────────────────────────────────────
const Color _kRed = Color(0xFFE53935); // expenses
const Color _kGray = Color(0xFF9E9E9E); // pending / neutral

/// [OrderRecord.status] carries the English token the state layer produces
/// ('Completed' / 'Pending' / 'Failed'), which is also what the comparisons in
/// this file branch on. Translate it only at the point of display.
String _statusLabel(AppLocalizations l10n, OrderRecord record) =>
    switch (record.status) {
      // A finished meal order is "Redeemed" — the same word the staff
      // dashboard uses when it scans the ticket. A finished top-up is just
      // "Completed"; nothing was redeemed.
      'Completed' => record.type == 'deposit'
          ? l10n.statusCompleted
          : l10n.statusRedeemed,
      'Failed' => l10n.statusFailed,
      _ => l10n.statusPending,
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

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _SortBy _sort = _SortBy.newest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  /// Fetches history. Also the retry action on the error state.
  Future<void> _load() {
    return context.read<OrderHistoryState>().loadFromBackend(
          context.read<OrderRepository>(),
          context.read<WalletRepository>(),
        );
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
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        current: _sort,
        onSelected: (s) => setState(() => _sort = s),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderHistoryState>();
    final orders = state.orders;
    final sorted = _sorted(orders);

    final spent = orders
        .where((o) => o.type == 'order' && o.status != 'Failed')
        .fold<double>(0, (sum, o) => sum + o.total);
    final topUps = orders
        .where((o) => o.type == 'deposit' && o.status != 'Failed')
        .fold<double>(0, (sum, o) => sum + o.total);

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
                ? _buildList(sorted, spent, topUps)
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

  Widget _buildList(List<OrderRecord> sorted, double spent, double topUps) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      // +1 for the summary card pinned at the top of the list.
      itemCount: sorted.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _FadeInItem(
            index: 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SummaryCard(spent: spent, topUps: topUps),
            ),
          );
        }
        final order = sorted[index - 1];
        return _FadeInItem(
          key: ValueKey('${_sort}_${order.id}'),
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OrderCard(order: order),
          ),
        );
      },
    );
  }
}

// ── Animated gradient header ───────────────────────────────────────────────

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
            AppTheme.green.withValues(alpha: isDark ? 0.18 : 0.12),
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
            builder: (context, t, child) => Opacity(
              opacity: t,
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
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: context.textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)!.historySubtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
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
                                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: widget.isSortActive ? null : context.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: widget.isSortActive
                                ? AppTheme.green.withValues(alpha: 0.35)
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

// ── Spent vs top-ups summary chart ─────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.spent, required this.topUps});

  final double spent;
  final double topUps;

  @override
  Widget build(BuildContext context) {
    final total = spent + topUps;
    final spentFraction = total <= 0 ? 0.0 : spent / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: AppLocalizations.of(context)!.historyTotalSpent,
                  amount: spent,
                  color: _kRed,
                  icon: Icons.south_west_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: context.borderColor,
              ),
              Expanded(
                child: _SummaryStat(
                  label: AppLocalizations.of(context)!.historyTopUps,
                  amount: topUps,
                  color: AppTheme.green,
                  icon: Icons.north_east_rounded,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Proportional bar: red (spent) vs green (top-ups), animates in.
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: spentFraction),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                builder: (context, fraction, _) {
                  return Row(
                    children: [
                      if (fraction > 0)
                        Expanded(
                          flex: (fraction * 1000).round(),
                          child: Container(color: _kRed.withValues(alpha: 0.85)),
                        ),
                      if (fraction < 1)
                        Expanded(
                          flex: ((1 - fraction) * 1000).round(),
                          child: Container(
                            color: AppTheme.green.withValues(alpha: 0.85),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.alignEnd = false,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.mutedColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ── Transaction card ───────────────────────────────────────────────────────

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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailsSheet(order: widget.order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isDeposit = order.type == 'deposit';
    final isPending = order.status == 'Pending';
    final isFailed = order.status == 'Failed';
    final isCompleted = order.status == 'Completed';

    // Color cues: green = income/top-up, red = expense, gray = pending.
    final statusColor = isCompleted
        ? (isDeposit ? AppTheme.green : _kRed)
        : isFailed
            ? _kRed
            : _kGray;

    final amountColor = isFailed
        ? _kGray
        : isPending
            ? _kGray
            : isDeposit
                ? AppTheme.green
                : _kRed;
    final amountLabel = isDeposit
        ? '+\$${order.total.toStringAsFixed(2)}'
        : '-\$${order.total.toStringAsFixed(2)}';

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
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
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            splashColor: AppTheme.green.withValues(alpha: 0.12),
            highlightColor: AppTheme.green.withValues(alpha: 0.05),
            onTap: _openDetails,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: isDeposit
                          ? const _DepositThumbnail()
                          : _FoodThumbnail(order: order),
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
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
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
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: context.mutedColor,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        amountLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: amountColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _StatusBadge(
                        label: _statusLabel(
                            AppLocalizations.of(context)!, order),
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
            style: TextStyle(
              fontSize: 10,
              color: widget.color,
              fontWeight: FontWeight.w700,
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
        return Opacity(opacity: 0.65 + 0.35 * t, child: child);
      },
      child: pill,
    );
  }
}

// ── Loading state ──────────────────────────────────────────────────────────

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
          color: AppTheme.green,
        ),
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────

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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.mutedColor,
                fontWeight: FontWeight.w400,
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
    HapticFeedback.selectionClick();
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
            colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.green.withValues(alpha: _busy ? 0.15 : 0.35),
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
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
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

// ── Empty state ────────────────────────────────────────────────────────────

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
              color: AppTheme.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: AppTheme.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.historyEmptyTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.historyEmptyBody,
            style: TextStyle(
              fontSize: 13,
              color: context.mutedColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Thumbnails ─────────────────────────────────────────────────────────────

class _FoodThumbnail extends StatelessWidget {
  const _FoodThumbnail({required this.order});
  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
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
          color: AppTheme.green,
          size: 22,
        ),
      ),
    );
  }
}

class _DepositThumbnail extends StatelessWidget {
  const _DepositThumbnail();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.green.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(
          Icons.account_balance_wallet_rounded,
          color: AppTheme.green,
          size: 26,
        ),
      ),
    );
  }
}

// ── View Details modal ─────────────────────────────────────────────────────

class _DetailsSheet extends StatelessWidget {
  const _DetailsSheet({required this.order});
  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    final isDeposit = order.type == 'deposit';
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: isDeposit
                        ? const _DepositThumbnail()
                        : _FoodThumbnail(order: order),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isDeposit
                        ? AppLocalizations.of(context)!.historyTopUpDetails
                        : AppLocalizations.of(context)!.historyOrderDetails,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: context.textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            isDeposit
                ? _DepositDetails(order: order)
                : _FoodOrderDetails(order: order),
          ],
        ),
      ),
    );
  }
}

// ── Sort options bottom sheet ──────────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current, required this.onSelected});

  final _SortBy current;
  final ValueChanged<_SortBy> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
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
              ? AppTheme.green.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.green : context.borderColor,
            width: selected ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppTheme.green : context.mutedColor,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppTheme.green : context.textColor,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.green, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Expanded breakdown for food orders ─────────────────────────────────────

class _FoodOrderDetails extends StatelessWidget {
  const _FoodOrderDetails({required this.order});
  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(
          label: l10n.historyItems,
          value: order.items,
          valueStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.green,
          ),
        ),
        const SizedBox(height: 10),
        _DetailRow(
          label: l10n.historyTotalAmount,
          value: '\$${order.total.toStringAsFixed(2)}',
          valueStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.green,
          ),
        ),
        const SizedBox(height: 8),
        _DetailRow(
          label: l10n.historyInKhr,
          value: '៛${(order.total * 4000).toStringAsFixed(0)}',
          valueStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.mutedColor,
          ),
        ),
        const SizedBox(height: 10),
        _DetailRow(
          label: l10n.historyPaymentMethod,
          value: l10n.historyMethodWallet,
          valueStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.green,
          ),
        ),
        const SizedBox(height: 8),
        _DetailRow(
          label: l10n.historyStatus,
          value: _statusLabel(l10n, order),
          valueStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: order.status == 'Completed'
                ? AppTheme.green
                : order.status == 'Failed'
                    ? _kRed
                    : _kGray,
          ),
        ),
      ],
    );
  }
}

// ── Expanded breakdown for deposits ────────────────────────────────────────

class _DepositDetails extends StatelessWidget {
  const _DepositDetails({required this.order});
  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.green,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            l10n.historyTopUpSuccessful,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _DetailRow(
          label: l10n.historyAmountAdded,
          value: '+\$${order.total.toStringAsFixed(2)}',
          valueStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.green,
          ),
        ),
        const SizedBox(height: 8),
        _DetailRow(
          label: l10n.historyInKhr,
          value: '+៛${(order.total * 4000).toStringAsFixed(0)}',
          valueStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.mutedColor,
          ),
        ),
        const SizedBox(height: 10),
        _DetailRow(
          label: l10n.historyPaymentMethod,
          value: l10n.historyMethodBankTransfer,
          valueStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.green,
          ),
        ),
        const SizedBox(height: 8),
        _DetailRow(
          label: l10n.historyTransactionId,
          value: order.id.length >= 8
              ? order.id.substring(0, 8).toUpperCase()
              : order.id.toUpperCase(),
          valueStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: context.mutedColor,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// ── Detail row helper ──────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

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
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.mutedColor,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

// ── Staggered fade-in wrapper for list items ───────────────────────────────

class _FadeInItem extends StatefulWidget {
  const _FadeInItem({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_FadeInItem> createState() => _FadeInItemState();
}

class _FadeInItemState extends State<_FadeInItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    // Stagger by index, capped so long lists don't lag.
    final delay = Duration(milliseconds: 60 * (widget.index.clamp(0, 8)));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
