import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../ui/states/payment_methods_state.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/smart_canteen_button.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  static const routeName = '/payment-methods';

  void _showAddCardSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddCardSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PaymentMethodsState>();
    final cards = state.cards;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Column(
        children: [
          const SettingsHeader(
            title: 'Payment Methods',
            subtitle: 'Manage your saved cards',
          ),
          Expanded(
            child: cards.isEmpty
                ? const _EmptyCards()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    itemCount: cards.length,
                    itemBuilder: (context, i) {
                      final card = cards[i];
                      return SettingsFadeIn(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _CardTile(
                            card: card,
                            isDefault: card.id == state.defaultId,
                            onSetDefault: () => state.setDefault(card.id),
                            onRemove: () =>
                                _confirmRemove(context, state, card),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: SmartCanteenButton(
                label: 'Add New Card',
                gradient: const LinearGradient(
                  colors: [AppTheme.greenDark, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                leading: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => _showAddCardSheet(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    PaymentMethodsState state,
    SavedCard card,
  ) async {
    final confirmed = await AppDialog.show(
      context,
      title: 'Remove Card',
      body: Text(
        'Remove the ${card.brand.label} card ending in ${card.last4}?',
        style: TextStyle(color: context.mutedColor, fontSize: 14, height: 1.4),
      ),
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      state.removeCard(card.id);
    }
  }
}

// ── Card visual ────────────────────────────────────────────────────────────

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.card,
    required this.isDefault,
    required this.onSetDefault,
    required this.onRemove,
  });

  final SavedCard card;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDefault ? null : onSetDefault,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppTheme.greenDark,
                AppTheme.primary,
                AppTheme.primaryLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
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
                  Icon(_brandIcon(card.brand), color: Colors.white, size: 26),
                  const SizedBox(width: 8),
                  Text(
                    card.brand.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: onRemove,
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                '•••• •••• •••• ${card.last4}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARD HOLDER',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          card.holder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPIRES',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        card.expiry,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _brandIcon(CardBrand brand) => switch (brand) {
    CardBrand.visa => Icons.credit_card_rounded,
    CardBrand.mastercard => Icons.credit_card_rounded,
    CardBrand.amex => Icons.credit_card_rounded,
    CardBrand.generic => Icons.credit_card_outlined,
  };
}

class _EmptyCards extends StatelessWidget {
  const _EmptyCards();

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
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card_off_rounded,
              size: 34,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No cards saved',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add a card to pay faster at checkout',
            style: TextStyle(fontSize: 13, color: context.mutedColor),
          ),
        ],
      ),
    );
  }
}

// ── Add card bottom sheet ──────────────────────────────────────────────────

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet();

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _holderController = TextEditingController();
  final _expiryController = TextEditingController();

  /// Collected to validate the card, then discarded with the sheet — a CVV is
  /// never stored, not even in memory beyond this form. It is the one field a
  /// card issuer treats as proof the card is in hand.
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _holderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    final digits = _numberController.text.replaceAll(RegExp(r'\D'), '');
    final card = SavedCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      brand: SavedCard.brandFromNumber(digits),
      last4: digits.substring(digits.length - 4),
      holder: _holderController.text.trim(),
      expiry: _expiryController.text.trim(),
    );
    context.read<PaymentMethodsState>().addCard(card);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card added'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Form(
            key: _formKey,
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
                  'Add New Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 18),
                _SheetField(
                  label: 'Card Number',
                  controller: _numberController,
                  hint: '1234 5678 9012 3456',
                  icon: Icons.credit_card_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    return digits.length < 13
                        ? 'Enter a valid card number'
                        : null;
                  },
                ),
                const SizedBox(height: 14),
                _SheetField(
                  label: 'Card Holder',
                  controller: _holderController,
                  hint: 'Name on card',
                  icon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter the card holder'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SheetField(
                        label: 'Expiry (MM/YY)',
                        controller: _expiryController,
                        hint: 'MM/YY',
                        icon: Icons.calendar_today_rounded,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ExpiryFormatter(),
                        ],
                        validator: (v) =>
                            RegExp(
                              r'^(0[1-9]|1[0-2])\/\d{2}$',
                            ).hasMatch(v ?? '')
                            ? null
                            : 'MM/YY',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SheetField(
                        label: 'CVV',
                        controller: _cvvController,
                        hint: '123',
                        icon: Icons.lock_outline_rounded,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        // Amex prints four digits, every other brand three.
                        validator: (v) => RegExp(r'^\d{3,4}$').hasMatch(v ?? '')
                            ? null
                            : '3–4 digits',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SmartCanteenButton(
                  label: 'Save Card',
                  gradient: const LinearGradient(
                    colors: [AppTheme.greenDark, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          validator: validator,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: context.textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: context.mutedColor, size: 20),
          ),
        ),
      ],
    );
  }
}

/// Groups card digits into blocks of four as the user types.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Inserts the "/" between month and year for expiry input.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final text = digits.length >= 3
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
