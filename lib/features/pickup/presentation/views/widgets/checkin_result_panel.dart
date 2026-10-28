import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/pickup/domain/entities/pickup_checkin.dart';
import 'package:smart_canteen_user_frontend/features/pickup/presentation/views/widgets/pickup_order_row.dart';
import 'package:smart_canteen_user_frontend/l10n/app_localizations.dart';

/// Full-height bottom sheet showing the result of a successful check-in.
///
/// Lists every order at the branch as a [PickupResultCard]. The drag handle
/// and X button at the top let the user dismiss the sheet; "Scan Again" at
/// the bottom explicitly resets the scanner via [onScanAgain].
class CheckinResultPanel extends StatelessWidget {
  const CheckinResultPanel({
    required this.checkin,
    required this.onScanAgain,
    super.key,
  });

  final PickupCheckin checkin;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.85,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header row: X button + title
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textSecondary,
                ),
                Expanded(
                  child: Text(
                    l10n.pickupResultTitle,
                    style: AppFonts.heading2,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Spacer to balance the X button so the title stays centered.
                const SizedBox(width: 42),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Order cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              itemCount: checkin.orders.length,
              itemBuilder: (_, index) => PickupResultCard(
                order: checkin.orders[index],
                counter: checkin.counter,
                checkedInAt: checkin.checkedInAt,
              ),
            ),
          ),

          SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
        ],
      ),
    );
  }
}
