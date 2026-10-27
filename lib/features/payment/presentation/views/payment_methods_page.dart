import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/dialog/app_dialog.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/widgets/settings_widgets.dart';
import 'package:smart_canteen_user_frontend/core/widgets/app_button.dart';
import 'package:smart_canteen_user_frontend/features/payment/domain/entities/saved_card.dart';
import 'package:smart_canteen_user_frontend/features/payment/presentation/viewmodels/payment_methods_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/payment/presentation/views/widgets/add_card_sheet.dart';

/// [Deprecated_File]
///  Left over from before refactor

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PaymentMethodsViewModel>();
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
              child: AppButton(
                label: 'Add New Card',
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                leading: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () => AddCardSheet.show(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    PaymentMethodsViewModel state,
    SavedCard card,
  ) async {
    final confirmed = await AppDialog.show(
      context,
      title: 'Remove Card',
      body: Text(
        'Remove the ${card.brand.label} card ending in ${card.last4}?',
        style: AppFonts.heading3.copyWith(
          color: context.mutedColor,
          height: 1.4,
        ),
      ),
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (confirmed == true) {
      unawaited(HapticFeedback.mediumImpact());
      state.removeCard(card.id);
    }
  }
}

// Card visual

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
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.primaryLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
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
                    style: AppFonts.heading2.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: AppFonts.bold,
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
                      child: Text(
                        'Default',
                        style: AppFonts.heading5.copyWith(
                          color: Colors.white,
                          fontWeight: AppFonts.bold,
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
                style: AppFonts.heading1.copyWith(
                  color: Colors.white,
                  fontWeight: AppFonts.semiBold,
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
                          style: AppFonts.heading5.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 9,
                            fontWeight: AppFonts.semiBold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          card.holder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.heading3.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: AppFonts.semiBold,
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
                        style: AppFonts.heading5.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: AppFonts.semiBold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        card.expiry,
                        style: AppFonts.heading3.copyWith(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: AppFonts.semiBold,
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
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card_off_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No cards saved',
            style: AppFonts.heading2.copyWith(
              fontWeight: AppFonts.bold,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add a card to pay faster at checkout',
            style: AppFonts.heading3.copyWith(
              fontSize: 13,
              color: context.mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}
