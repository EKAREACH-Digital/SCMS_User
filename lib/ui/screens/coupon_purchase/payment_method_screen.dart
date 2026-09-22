import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../states/payment_methods_state.dart';
import '../../widgets/add_card_sheet.dart';
import 'bank_selection_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key, required this.totalAmount});

  static const routeName = '/choose-payment-method';

  final double totalAmount;

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

enum _PaymentMethod { bank, card }

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  _PaymentMethod? _selectedMethod;
  BankOption? _selectedBank;

  /// Which saved card this checkout pays with. Null means "whichever card is
  /// the account default"; picking one here does not change that default.
  String? _selectedCardId;

  /// Resolves the chosen card against the live list, falling back to the
  /// default and then to the first card, so a card removed in Settings can
  /// never stay selected here.
  SavedCard? _resolveCard(PaymentMethodsState state) {
    final cards = state.cards;
    if (cards.isEmpty) return null;
    for (final id in [_selectedCardId, state.defaultId]) {
      if (id == null) continue;
      for (final card in cards) {
        if (card.id == id) return card;
      }
    }
    return cards.first;
  }

  Future<void> _openAddCard() async {
    final card = await AddCardSheet.show(context);
    if (!mounted || card == null) return;
    setState(() {
      _selectedCardId = card.id;
      _selectedMethod = _PaymentMethod.card;
    });
  }

  Future<void> _openBankSelection() async {
    final bank = await Navigator.push<BankOption>(
      context,
      MaterialPageRoute(builder: (_) => const BankSelectionScreen()),
    );
    if (!mounted || bank == null) return;
    setState(() {
      _selectedBank = bank;
      _selectedMethod = _PaymentMethod.bank;
    });
  }

  String get _bankSubtitle {
    return switch (_selectedBank) {
      BankOption.bakong => 'Bakong selected',
      BankOption.aba => 'ABA Bank selected',
      BankOption.acleda => 'ACLEDA Bank selected',
      null => 'Pay via PayWay',
    };
  }

  String _bankAsset(BankOption bank) {
    return switch (bank) {
      BankOption.bakong => 'asset/payment method/bakong.png',
      BankOption.aba => 'asset/payment method/aba.png',
      BankOption.acleda => 'asset/payment method/acleda.png',
    };
  }

  String _bankName(BankOption bank) {
    return switch (bank) {
      BankOption.bakong => 'Bakong',
      BankOption.aba => 'ABA Bank',
      BankOption.acleda => 'ACLEDA Bank',
    };
  }

  void _continue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PayWay payment will be connected here.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethods = context.watch<PaymentMethodsState>();
    final cards = paymentMethods.cards;
    final card = _resolveCard(paymentMethods);

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Choose Payment Method'),
        backgroundColor: context.bgColor,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          Text(
            'Select how you would like to pay for this order.',
            style: TextStyle(color: context.mutedColor, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _PaymentOptionTile(
            title: 'Pay with Bank',
            subtitle: _bankSubtitle,
            icon: Icons.account_balance_rounded,
            selected: _selectedMethod == _PaymentMethod.bank,
            onTap: _openBankSelection,
            child: _selectedBank == null
                ? null
                : _SelectedBankTile(
                    name: _bankName(_selectedBank!),
                    assetPath: _bankAsset(_selectedBank!),
                    onChange: _openBankSelection,
                  ),
          ),
          const SizedBox(height: 12),
          _PaymentOptionTile(
            title: 'Pay with Card',
            subtitle: card == null
                ? 'Add a saved card'
                : '${card.brand.label} •••• ${card.last4}',
            icon: Icons.credit_card_rounded,
            selected: _selectedMethod == _PaymentMethod.card,
            onTap: card == null
                ? _openAddCard
                : () => setState(() {
                    _selectedCardId = card.id;
                    _selectedMethod = _PaymentMethod.card;
                  }),
            child: card == null
                ? _AddCardTile(onTap: _openAddCard)
                : Column(
                    children: [
                      for (final c in cards) ...[
                        _SavedCardTile(
                          card: c,
                          selected: c.id == card.id,
                          onTap: () => setState(() {
                            _selectedCardId = c.id;
                            _selectedMethod = _PaymentMethod.card;
                          }),
                        ),
                        const SizedBox(height: 8),
                      ],
                      _AddCardTile(onTap: _openAddCard),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _PaymentBottomBar(
        amount: widget.totalAmount,
        enabled: _selectedMethod != null,
        onContinue: _continue,
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.14)
                : context.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppTheme.primaryDark : context.borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppTheme.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: context.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: context.mutedColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SelectionIndicator(selected: selected),
                ],
              ),
              if (child != null) ...[const SizedBox(height: 14), child!],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? AppTheme.primaryDark : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppTheme.primaryDark : context.borderColor,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _SavedCardTile extends StatelessWidget {
  const _SavedCardTile({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final SavedCard card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppTheme.primaryDark : context.borderColor,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.credit_card_rounded, color: AppTheme.primaryDark),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.brand.label,
                      style: TextStyle(
                        color: context.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '•••• ${card.last4}',
                      style: TextStyle(color: context.mutedColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                'Exp ${card.expiry}',
                style: TextStyle(color: context.mutedColor, fontSize: 12),
              ),
              const SizedBox(width: 10),
              _SelectionIndicator(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedBankTile extends StatelessWidget {
  const _SelectedBankTile({
    required this.name,
    required this.assetPath,
    required this.onChange,
  });

  final String name;
  final String assetPath;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                Icons.account_balance_rounded,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Selected for PayWay',
                  style: TextStyle(color: context.mutedColor, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryDark,
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 36),
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _AddCardTile extends StatelessWidget {
  const _AddCardTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded, size: 19),
      label: const Text('Add Card'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryDark,
        side: const BorderSide(color: AppTheme.primaryDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _PaymentBottomBar extends StatelessWidget {
  const _PaymentBottomBar({
    required this.amount,
    required this.enabled,
    required this.onContinue,
  });

  final double amount;
  final bool enabled;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      elevation: 10,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(color: context.mutedColor, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: context.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 132,
                height: 48,
                child: ElevatedButton(
                  onPressed: enabled ? onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                    disabledBackgroundColor: context.borderColor,
                    disabledForegroundColor: context.mutedColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
