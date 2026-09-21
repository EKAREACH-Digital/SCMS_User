import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../states/payment_methods_state.dart';
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
  bool _hasSavedCard = true;
  SavedCard _savedCard = const SavedCard(
    id: 'mock-visa',
    brand: CardBrand.visa,
    last4: '4242',
    holder: 'Sokhunmony Soun',
    expiry: '08/27',
  );

  Future<void> _openAddCard() async {
    final card = await Navigator.push<SavedCard>(
      context,
      MaterialPageRoute(builder: (_) => const AddCardScreen()),
    );
    if (!mounted || card == null) return;
    setState(() {
      _hasSavedCard = true;
      _savedCard = card;
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
            subtitle: _hasSavedCard ? 'Saved Card' : 'Add a saved card',
            icon: Icons.credit_card_rounded,
            selected: _selectedMethod == _PaymentMethod.card,
            onTap: !_hasSavedCard
                ? _openAddCard
                : () => setState(() => _selectedMethod = _PaymentMethod.card),
            child: !_hasSavedCard
                ? _AddCardTile(onTap: _openAddCard)
                : _SavedCardTile(card: _savedCard),
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
  const _SavedCardTile({required this.card});

  final SavedCard card;

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
        ],
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

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  void _saveCard() {
    final digits = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
    final last4 = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : '4242';
    Navigator.pop(
      context,
      SavedCard(
        id: 'mock-${DateTime.now().microsecondsSinceEpoch}',
        brand: CardBrand.visa,
        last4: last4,
        holder: _holderController.text.trim().isEmpty
            ? 'Cardholder'
            : _holderController.text.trim(),
        expiry: _expiryController.text.trim().isEmpty
            ? '08/27'
            : _expiryController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Add Card'),
        backgroundColor: context.bgColor,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Enter your card details. This is a local mock form for now.',
            style: TextStyle(color: context.mutedColor, fontSize: 14),
          ),
          const SizedBox(height: 22),
          _CardField(
            label: 'Card number',
            hint: '1234 5678 9012 3456',
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _CardField(
                  label: 'Expiry',
                  hint: 'MM/YY',
                  controller: _expiryController,
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CardField(
                  label: 'CVV',
                  hint: '123',
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CardField(
            label: 'Cardholder name',
            hint: 'Name on card',
            controller: _holderController,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _saveCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save Card'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: context.cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primaryDark, width: 1.3),
        ),
      ),
    );
  }
}
