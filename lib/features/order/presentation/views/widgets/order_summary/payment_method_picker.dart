import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/constants/images_constant.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Available payment methods shown in the cart screen.
enum CartPaymentMethod { bakong, abaPay }

/// Radio-style payment method picker with bank logos.
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
          AppLocalizations.of(context)!.cartSelectPaymentMethod,
          style: AppFonts.heading2.copyWith(
            color: AppColors.primary,
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: 12),
        _MethodTile(
          logo: ImageConst.bakong,
          label: 'BAKONG',
          subtitle: 'ទូទាត់តាម បាគង',
          value: CartPaymentMethod.bakong,
          selected: selected,
          onTap: () => onChanged(CartPaymentMethod.bakong),
        ),
        const SizedBox(height: 8),
        _MethodTile(
          logo: ImageConst.aba,
          label: 'ABA PAY',
          subtitle: 'ទូទាត់តាម ABA',
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
    required this.logo,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String logo;
  final String label;
  final String subtitle;
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                logo,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppFonts.heading3.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppFonts.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppFonts.heading4.copyWith(
                      color: context.mutedColor,
                    ),
                  ),
                ],
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
