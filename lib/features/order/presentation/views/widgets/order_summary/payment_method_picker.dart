import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

/// Available payment methods shown in the cart screen.
enum CartPaymentMethod { bakong, abaPay }

/// Radio-style payment method picker.
class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final CartPaymentMethod selected;
  final ValueChanged<CartPaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: AppFonts.heading2.copyWith(color: context.textColor),
        ),
        const SizedBox(height: 12),
        _MethodTile(
          label: 'BAKONG',
          icon: Icons.account_balance_wallet_outlined,
          value: CartPaymentMethod.bakong,
          selected: selected,
          onTap: () => onChanged(CartPaymentMethod.bakong),
        ),
        const SizedBox(height: 8),
        _MethodTile(
          label: 'ABA PAY',
          icon: Icons.credit_card_outlined,
          value: CartPaymentMethod.abaPay,
          selected: selected,
          onTap: () => onChanged(CartPaymentMethod.abaPay),
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final CartPaymentMethod value;
  final CartPaymentMethod selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.07)
              : context.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppFonts.heading3.copyWith(
                  color: context.textColor,
                  fontWeight: isSelected ? AppFonts.semiBold : AppFonts.regular,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 6 : 1.5,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
