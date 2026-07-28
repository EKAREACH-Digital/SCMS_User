import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class CouponExpiredOverlay extends StatelessWidget {
  const CouponExpiredOverlay({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.timer_off_rounded, color: Color(0xFFE53935), size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.couponExpiredTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.text),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.couponExpiredBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.mutedText, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.couponExpiredAction,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
