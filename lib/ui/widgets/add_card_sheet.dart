import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../states/payment_methods_state.dart';
import 'smart_canteen_button.dart';

/// The single add-card form, shared by Settings › Payment Methods and the
/// checkout payment screen. Both entry points write to [PaymentMethodsState],
/// so a card saved from either place is immediately visible in the other.
class AddCardSheet extends StatefulWidget {
  const AddCardSheet({super.key});

  /// Presents the sheet and resolves to the saved card, or null if dismissed.
  /// Callers that need to act on the new card (selecting it for a pending
  /// checkout, say) can await this; Settings simply ignores the result.
  static Future<SavedCard?> show(BuildContext context) {
    HapticFeedback.selectionClick();
    return showModalBottomSheet<SavedCard>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddCardSheet(),
    );
  }

  @override
  State<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<AddCardSheet> {
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

    // Resolved before the pop: afterwards this element is defunct and the
    // messenger can no longer be looked up from its context.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context, card);
    messenger.showSnackBar(
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
