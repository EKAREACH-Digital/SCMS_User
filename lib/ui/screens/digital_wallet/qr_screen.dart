import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/dtos/order_dto.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../ui/states/meal_coupons_state.dart';
import '../../../ui/states/order_history_state.dart';
import '../../../ui/states/user_profile_state.dart';
import '../../widgets/smart_canteen_widgets.dart';

// ── Screen-scoped palette (green theme) ──────────────────────────────────────
const Color _kGreen = Color(0xFF4CAF50); // AppTheme.green
const Color _kGreenMid = Color(0xFF388E3C);
const Color _kGreenDeep = Color(0xFF2E7D32);
const Color _kMint = Color(0xFFC8E6C9); // light mint accent

// ─────────────────────────────────────────────────────────────────────────────
// QrScreen
// ─────────────────────────────────────────────────────────────────────────────

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});
  static const routeName = '/qr';

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen>
    with TickerProviderStateMixin {
  /// Selected filter: [kAllSessions] or a MealSession key. Defaults to showing
  /// everything — filtering by the session that happens to be open right now
  /// hid tickets the user had just bought, especially all-day drinks, which are
  /// filed under the nearest meal session rather than the current one.
  String _session = kAllSessions;
  int _couponIndex = 0;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // Refresh icon spin
  late final AnimationController _spinCtrl;

  // Entrance fade-in for the ticket card
  late final AnimationController _entranceCtrl;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.elasticOut),
    );
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceFade =
        CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeInOut);
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceCtrl.forward();
        context.read<MealCouponsState>().fetchActive();
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _spinCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _refreshQr() {
    HapticFeedback.mediumImpact();
    _pulseCtrl.forward(from: 0);
    _spinCtrl.forward(from: 0);
    context.read<MealCouponsState>().fetchActive();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.qrRefreshed),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _kGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _showReceiptSheet(BuildContext ctx, OrderRecord order) {
    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReceiptSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderHistoryState>().orders;
    final latest = orders.isNotEmpty ? orders.first : null;

    // Active coupons for the selected filter; each is a scannable QR.
    final mealCoupons = context.watch<MealCouponsState>();
    final sessionCoupons = _session == kAllSessions
        ? mealCoupons.activeAll
        : mealCoupons.forSession(_session);
    final index = sessionCoupons.isEmpty
        ? 0
        : _couponIndex.clamp(0, sessionCoupons.length - 1);
    final CouponDto? coupon =
        sessionCoupons.isNotEmpty ? sessionCoupons[index] : null;
    // "Paid/active" = there's a live coupon to show for this session.
    final isPaid = coupon != null;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.qrTitle,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              _fmtDate(DateTime.now()),
              style: TextStyle(
                fontSize: 11,
                color: context.mutedColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            // ── Ticket card (fade + slide in on load) ────────────────────────
            FadeTransition(
              opacity: _entranceFade,
              child: SlideTransition(
                position: _entranceSlide,
                child: _TicketCard(
                  userName: context.watch<UserProfileState>().name,
                  sessionLabel: _sessionLabel(coupon?.mealSession ?? _session),
                  isPaid: isPaid,
                  pulseAnim: _pulseAnim,
                  qrData: coupon?.qrToken,
                  subtitle: coupon != null
                      ? '${coupon.menuItemName ?? 'Meal ticket'}'
                          '${coupon.couponCode != null ? '  ·  ${coupon.couponCode}' : ''}'
                      : _session == kAllSessions
                          ? 'No active tickets yet'
                          : 'No active ticket for this session',
                ),
              ),
            ),
            // ── Ticket pager (when a session has more than one) ──────────────
            if (sessionCoupons.length > 1) ...[
              const SizedBox(height: 12),
              _CouponPager(
                count: sessionCoupons.length,
                index: index,
                onChanged: (i) => setState(() => _couponIndex = i),
              ),
            ],
            const SizedBox(height: 20),
            // ── Session selector ─────────────────────────────────────────────
            _SessionSelector(
              selected: _session,
              onSelect: (s) => setState(() {
                _session = s;
                _couponIndex = 0;
              }),
            ),
            const SizedBox(height: 20),
            // ── Order summary ────────────────────────────────────────────────
            if (latest != null)
              _OrderSummaryCard(order: latest)
            else
              _EmptyOrderCard(),
            const SizedBox(height: 24),
            // ── Primary action — pill gradient with ripple ───────────────────
            SmartCanteenButton(
              label: 'Refresh QR Code',
              leading: RotationTransition(
                turns: _spinCtrl,
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              gradient: const LinearGradient(
                colors: [_kGreen, _kGreenDeep],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              height: 54,
              onPressed: _refreshQr,
            ),
            const SizedBox(height: 12),
            // ── Secondary action — outlined green ────────────────────────────
            if (latest != null)
              _OutlinedReceiptButton(
                onPressed: () => _showReceiptSheet(context, latest),
              ),
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime dt) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  const d = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${d[dt.weekday - 1]}, ${m[dt.month - 1]} ${dt.day}, ${dt.year}';
}

/// Sentinel for "show every active ticket" rather than one meal session.
const kAllSessions = 'all';

String _sessionLabel(String key) => switch (key) {
      kAllSessions => 'All tickets',
      'breakfast' => 'Breakfast',
      'lunch' => 'Lunch',
      'dinner' => 'Dinner',
      _ => key,
    };

/// Dot pager to switch between multiple tickets in the same session.
class _CouponPager extends StatelessWidget {
  const _CouponPager({
    required this.count,
    required this.index,
    required this.onChanged,
  });

  final int count;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: _kGreen),
          onPressed: index > 0 ? () => onChanged(index - 1) : null,
        ),
        Text(
          AppLocalizations.of(context)!.qrTicketOfCount(index + 1, count),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: _kGreen),
          onPressed: index < count - 1 ? () => onChanged(index + 1) : null,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Outlined "View Receipt" button — green border, ripple, press elevation
// ─────────────────────────────────────────────────────────────────────────────

class _OutlinedReceiptButton extends StatefulWidget {
  const _OutlinedReceiptButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_OutlinedReceiptButton> createState() => _OutlinedReceiptButtonState();
}

class _OutlinedReceiptButtonState extends State<_OutlinedReceiptButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(27),
        child: InkWell(
          borderRadius: BorderRadius.circular(27),
          splashColor: _kGreen.withValues(alpha: 0.12),
          highlightColor: _kGreen.withValues(alpha: 0.06),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () {
            setState(() => _pressed = false);
            HapticFeedback.selectionClick();
            widget.onPressed();
          },
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(27),
              border: Border.all(color: _kGreen, width: 1.6),
              boxShadow: _pressed
                  ? []
                  : [
                      BoxShadow(
                        color: _kGreen.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long_outlined,
                    size: 18, color: _kGreen),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.qrViewReceipt,
                  style: const TextStyle(
                    color: _kGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.3,
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

// ─────────────────────────────────────────────────────────────────────────────
// Ticket Card — navy gradient with user info, tear line, and QR code
// ─────────────────────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.userName,
    required this.sessionLabel,
    required this.isPaid,
    required this.pulseAnim,
    required this.qrData,
    required this.subtitle,
  });

  final String userName;
  final String sessionLabel;
  final bool isPaid;
  final Animation<double> pulseAnim;

  /// The coupon's `qr_token` — encoded verbatim so the canteen scanner can
  /// redeem it. Null when there's no active ticket for this session.
  final String? qrData;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Mint → deep green gradient (#4CAF50 → #2E7D32)
        gradient: const LinearGradient(
          colors: [_kGreen, _kGreenMid, _kGreenDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kGreenDeep.withValues(alpha: 0.4),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── User info ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kMint.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kMint.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: _kMint,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Session badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _kMint.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _kMint.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sessionLabel == 'Breakfast'
                            ? Icons.wb_sunny_outlined
                            : sessionLabel == 'Dinner'
                                ? Icons.nightlight_outlined
                                : Icons.lunch_dining_outlined,
                        color: _kMint,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sessionLabel,
                        style: const TextStyle(
                          color: _kMint,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Tear-line ───────────────────────────────────────────────────
          SizedBox(
            height: 22,
            width: double.infinity,
            child: CustomPaint(
              painter: _TearLinePainter(bgColor: context.bgColor),
            ),
          ),
          // ── QR code section ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ScaleTransition(
                      scale: pulseAnim,
                      child: Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            // Soft mint glow when the ticket is active (paid)
                            if (isPaid)
                              BoxShadow(
                                color: _kMint.withValues(alpha: 0.85),
                                blurRadius: 36,
                                spreadRadius: 2,
                              ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: qrData != null
                            ? QrImageView(
                                data: qrData!,
                                version: QrVersions.auto,
                                gapless: false,
                                // Solid black on white — maximum scan contrast.
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black,
                                ),
                              )
                            : const _QrPlaceholder(),
                      ),
                    ),
                    // Status badge anchored to QR top-right
                    Positioned(
                      top: -10,
                      right: -10,
                      child: _StatusBadge(isPaid: isPaid),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Glass-morphism helper panel
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.qrHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Tear-line painter — dashed line + half-circle notches in bgColor
// ─────────────────────────────────────────────────────────────────────────────

class _TearLinePainter extends CustomPainter {
  const _TearLinePainter({required this.bgColor});
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;

    // Half-circle notches (background color painted over the navy card edges)
    final notchPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, midY), 11, notchPaint);
    canvas.drawCircle(Offset(size.width, midY), 11, notchPaint);

    // Dashed line between notches
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dashW = 6.0;
    const gap = 4.5;
    double x = 14.0;
    while (x < size.width - 14) {
      canvas.drawLine(Offset(x, midY), Offset(x + dashW, midY), dashPaint);
      x += dashW + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TearLinePainter old) => old.bgColor != bgColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatefulWidget {
  const _StatusBadge({required this.isPaid});
  final bool isPaid;

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _start();
  }

  void _start() {
    // Fade/scale in, then gently pulse while paid.
    if (widget.isPaid) {
      _ctrl.forward().then((_) {
        if (mounted) _ctrl.repeat(reverse: true, min: 0.7, max: 1.0);
      });
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_StatusBadge old) {
    super.didUpdateWidget(old);
    if (widget.isPaid != old.isPaid) {
      _ctrl
        ..stop()
        ..reset();
      _start();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = widget.isPaid;
    final color = isPaid ? AppTheme.green : const Color(0xFFFF9800);
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle_rounded : Icons.access_time_rounded,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isPaid ? 'PAID' : 'PENDING',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );

    if (!isPaid) return badge;
    // Paid → fade in then gentle pulse.
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(scale: _scale, child: badge),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QR Placeholder — navy dots on white background
// ─────────────────────────────────────────────────────────────────────────────

class _QrPlaceholder extends StatelessWidget {
  const _QrPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _QrPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kGreen
      ..style = PaintingStyle.fill;

    const cols = 19;
    final cell = size.width / cols;

    const pattern = [
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1],
      [0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0],
      [1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1],
    ];

    for (int r = 0; r < pattern.length; r++) {
      for (int c = 0; c < pattern[r].length; c++) {
        if (pattern[r][c] == 1) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                c * cell + 1,
                r * cell + 1,
                cell - 2,
                cell - 2,
              ),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Session Selector
// ─────────────────────────────────────────────────────────────────────────────

class _SessionSelector extends StatelessWidget {
  const _SessionSelector({
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final total = context.watch<MealCouponsState>().activeAll.length;
    return Column(
      children: [
        // Full width rather than a fourth chip in the row: four of these side
        // by side leaves no room for the label and time to breathe.
        _AllTicketsChip(
          count: total,
          isSelected: selected == kAllSessions,
          onTap: () => onSelect(kAllSessions),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _SessionChip(
              icon: Icons.wb_sunny_outlined,
              label: 'Breakfast',
              time: '7 – 9 AM',
              isSelected: selected == 'breakfast',
              onTap: () => onSelect('breakfast'),
            ),
            const SizedBox(width: 10),
            _SessionChip(
              icon: Icons.lunch_dining_outlined,
              label: 'Lunch',
              time: '11 AM – 1 PM',
              isSelected: selected == 'lunch',
              onTap: () => onSelect('lunch'),
            ),
            const SizedBox(width: 10),
            _SessionChip(
              icon: Icons.nightlight_outlined,
              label: 'Dinner',
              time: '3 – 5 PM',
              isSelected: selected == 'dinner',
              onTap: () => onSelect('dinner'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Full-width "show everything" filter, with a live count so the user can see
/// at a glance whether they have any tickets at all.
class _AllTicketsChip extends StatelessWidget {
  const _AllTicketsChip({
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [_kGreen, _kGreenDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : context.borderColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _kGreen.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEAF6EB) : context.cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.confirmation_number_outlined,
                size: 18,
                color: isSelected ? _kGreenDeep : context.mutedColor,
              ),
              const SizedBox(width: 10),
              Text(
                'All tickets',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? _kGreenDeep : context.textColor,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _kGreenDeep.withValues(alpha: 0.12)
                      : context.borderColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? _kGreenDeep : context.mutedColor,
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

class _SessionChip extends StatelessWidget {
  const _SessionChip({
    required this.icon,
    required this.label,
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedScale(
          scale: isSelected ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(2), // space for gradient border
            decoration: BoxDecoration(
              // Gradient border when selected
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [_kGreen, _kGreenDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : context.borderColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _kGreen.withValues(alpha: 0.28)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Opaque light-green fill when selected so the green text stays
                // readable inside the gradient border.
                color: isSelected
                    ? const Color(0xFFEAF6EB)
                    : context.cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? _kGreen : context.mutedColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: isSelected ? _kGreen : context.textColor,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 9,
                            color: context.mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _kGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Order Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});
  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    final items = order.items
        .split(', ')
        .where((s) => s.isNotEmpty)
        .toList();

    return FancyCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _kGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_outlined,
                      color: _kGreen,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.qrOrderSummary,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
              Text(
                order.date,
                style: TextStyle(fontSize: 11, color: context.mutedColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Item list
          ...items.map((raw) => _ItemRow(raw: raw)),
          // Gradient divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _kGreen.withValues(alpha: 0.0),
                  _kGreen.withValues(alpha: 0.45),
                  _kGreen.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Total — counts up on load
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.qrTotalPaid,
                style: TextStyle(fontSize: 13, color: context.mutedColor),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: order.total),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
                builder: (context, value, _) => Text(
                  '\$${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Payment method
          _DetailRow(
            label: 'Payment Method',
            value: 'Wallet',
            icon: Icons.account_balance_wallet_rounded,
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.raw});
  final String raw;

  @override
  Widget build(BuildContext context) {
    final parts = raw.split(' ×');
    final name = parts[0].trim();
    final qty = parts.length > 1 ? parts[1] : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: _kMint,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.textColor,
              ),
            ),
          ),
          if (qty != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '×$qty',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _kGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: context.textColor,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: context.mutedColor),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: _kGreen),
              const SizedBox(width: 5),
            ],
            Text(value, style: defaultStyle),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty order placeholder
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyOrderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FancyCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 40,
            color: context.borderColor,
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.qrEmptyTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.mutedColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.qrEmptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: context.mutedColor),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Receipt Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ReceiptSheet extends StatelessWidget {
  const _ReceiptSheet({required this.order});
  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, ctrl) {
        return Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: context.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _kGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: _kGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.qrReceiptTitle,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: context.textColor,
                          ),
                        ),
                        Text(
                          order.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Items block
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: order.items
                        .split(', ')
                        .where((s) => s.isNotEmpty)
                        .map((raw) {
                      final parts = raw.split(' ×');
                      final name = parts[0].trim();
                      final qty =
                          parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.textColor,
                                ),
                              ),
                            ),
                            Text(
                              '×$qty',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.mutedColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: context.borderColor),
                const SizedBox(height: 16),
                _ReceiptRow(
                  label: 'Total',
                  value: '\$${order.total.toStringAsFixed(2)}',
                  valueColor: AppTheme.green,
                  isBold: true,
                ),
                const SizedBox(height: 12),
                _ReceiptRow(
                  label: 'Status',
                  value: order.status,
                  valueColor: order.status == 'Completed'
                      ? AppTheme.green
                      : const Color(0xFFFF9800),
                ),
                const SizedBox(height: 12),
                const _ReceiptRow(
                  label: 'Payment Method',
                  value: 'Wallet',
                ),
                const SizedBox(height: 12),
                _ReceiptRow(
                  label: 'Reference',
                  value: '#SC${order.date.hashCode.abs() % 90000 + 10000}',
                ),
                const SizedBox(height: 32),
                SmartCanteenButton(
                  label: 'Close',
                  fillColor: _kGreen,
                  height: 52,
                  radius: 16,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: context.mutedColor),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? context.textColor,
          ),
        ),
      ],
    );
  }
}
