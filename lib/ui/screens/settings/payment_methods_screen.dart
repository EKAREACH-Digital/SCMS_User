import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../ui/states/payment_methods_state.dart';
import '../../widgets/add_card_sheet.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/smart_canteen_button.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  static const routeName = '/payment-methods';

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
