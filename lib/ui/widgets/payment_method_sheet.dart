import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'smart_canteen_button.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _BankOption {
  const _BankOption({
    required this.name,
    required this.tagline,
    required this.shortCode,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
    required this.brandColor,
    this.logoAsset,
  });

  final String name;
  final String tagline;
  final String shortCode;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;
  final Color brandColor;

  /// Brand logo asset; when set it replaces the icon/short-code badge.
  final String? logoAsset;
}

const _kOptions = [
  // ── Banks ─────────────────────────────────────────────────────────────────
  _BankOption(
    name: 'Pay with Bakong',
    tagline: 'Secure QR payment via NBC Bakong',
    shortCode: 'BK',
    icon: Icons.qr_code_2,
    gradientStart: Color(0xFFC62828),
    gradientEnd: Color(0xFFEF5350),
    brandColor: Color(0xFFC62828),
    logoAsset: 'asset/payment method/bakong.png',
  ),
  _BankOption(
    name: 'Pay with ABA Pay',
    tagline: 'Instant transfer via ABA Mobile',
    shortCode: 'ABA',
    icon: Icons.phone_android_rounded,
    gradientStart: Color(0xFF1565C0),
    gradientEnd: Color(0xFF42A5F5),
    brandColor: Color(0xFF1565C0),
    logoAsset: 'asset/payment method/aba.png',
  ),
  _BankOption(
    name: 'Pay with ACLEDA',
    tagline: 'Secure payment via ACLEDA iTech',
    shortCode: 'ACL',
    icon: Icons.account_balance_rounded,
    gradientStart: Color(0xFF1A237E),
    gradientEnd: Color(0xFF3949AB),
    brandColor: Color(0xFF1A237E),
    logoAsset: 'asset/payment method/acleda.png',
  ),
];

// ── Sheet root ────────────────────────────────────────────────────────────────

class PaymentMethodSheet extends StatefulWidget {
  const PaymentMethodSheet({
    super.key,
    required this.totalAmount,
    required this.onConfirm,
  });

  final double totalAmount;
  final Function(String paymentMethod) onConfirm;

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  int? _selected;

  void _pick(int index) {
    if (_selected == index) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            // ── Drag handle ──────────────────────────────────────────────────
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // ── Title + subtitle ─────────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.walletChoosePaymentMethod,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: context.textColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.walletPaymentPrompt,
                    style: TextStyle(fontSize: 12.5, color: context.mutedColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Total amount row ─────────────────────────────────────────────
            _TotalAmountRow(amount: widget.totalAmount),
            const SizedBox(height: 16),

            // ── Options (wallet first, then "or pay with bank", then banks) ──
            for (int i = 0; i < _kOptions.length; i++) ...[
              _PaymentCard(
                option: _kOptions[i],
                selected: _selected == i,
                onTap: () => _pick(i),
              ),
              if (i < _kOptions.length - 1) const SizedBox(height: 10),
            ],
            const SizedBox(height: 24),

            // ── Confirm button ───────────────────────────────────────────────
            AnimatedOpacity(
              opacity: _selected != null ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: _selected == null,
                child: SmartCanteenButton(
                  label: 'Confirm Payment',
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onConfirm(_kOptions[_selected!].shortCode);
                  },
                  height: 52,
                  radius: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Total amount row ──────────────────────────────────────────────────────────

class _TotalAmountRow extends StatelessWidget {
  const _TotalAmountRow({required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 17,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context)!.walletTotalAmount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.mutedColor,
            ),
          ),
          const Spacer(),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment option card ───────────────────────────────────────────────────────

class _PaymentCard extends StatefulWidget {
  const _PaymentCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _BankOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<_PaymentCard> {
  bool _pressing = false;

  double get _scale {
    if (_pressing) return 0.965;
    return widget.selected ? 1.022 : 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final opt = widget.option;
    final sel = widget.selected;

    return AnimatedScale(
      scale: _scale,
      duration: Duration(milliseconds: _pressing ? 80 : 280),
      curve: _pressing ? Curves.easeOut : Curves.easeOutBack,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressing = true),
        onTapUp: (_) => setState(() => _pressing = false),
        onTapCancel: () => setState(() => _pressing = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          // ← smaller padding + more rounded
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: sel
                ? AppTheme.primary.withValues(alpha: 0.04)
                : context.cardColor,
            borderRadius: BorderRadius.circular(16), // ← more rounded
            border: Border.all(
              color: sel ? AppTheme.primary : context.borderColor,
              width: sel ? 2.0 : 1.2,
            ),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // ── Logo badge ───────────────────────────────────────────────
              _LogoBadge(option: opt, selected: sel),
              const SizedBox(width: 13),

              // ── Text block ───────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: sel ? AppTheme.primary : context.textColor,
                      ),
                      child: Text(opt.name),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      opt.tagline,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: context.mutedColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // ── Checkmark / chevron ──────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: sel
                    ? Container(
                        key: const ValueKey('check'),
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      )
                    : Container(
                        key: const ValueKey('arrow'),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: context.mutedColor,
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

// ── Logo badge ────────────────────────────────────────────────────────────────

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.option, required this.selected});

  final _BankOption option;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    // Brand logos sit on a clean white chip so they stay recognizable.
    if (option.logoAsset != null) {
      return Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(8),
        // A circular BoxDecoration clips the decoration, not the child — a
        // logo with an opaque square background would spill past the circle
        // without this.
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : option.brandColor.withValues(alpha: 0.15),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: option.brandColor.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(option.logoAsset!, fit: BoxFit.contain),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: 50, // ← smaller (was 58)
      height: 50,
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                colors: [AppTheme.greenDark, AppTheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [option.gradientStart, option.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (selected ? AppTheme.primary : option.brandColor).withValues(
              alpha: 0.35,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(option.icon, size: 20, color: Colors.white),
          const SizedBox(height: 2),
          Text(
            option.shortCode,
            style: const TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
