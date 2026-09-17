import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class SmartCanteenNavigationBarButton extends StatelessWidget {
  const SmartCanteenNavigationBarButton({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static List<String> _labels(AppLocalizations l10n) => [
    l10n.navHome,
    l10n.navMenu,
    l10n.navQrPay,
    l10n.navHistory,
    l10n.navSettings,
  ];
  static const _icons = [
    Icons.home_rounded,
    Icons.restaurant_menu_rounded,
    Icons.qr_code_2,
    Icons.receipt_long_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: List.generate(5, (i) {
            final isSelected = i == currentIndex;

            // QR center elevated button
            if (i == 2) {
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(i);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.greenDark,
                                AppTheme.primaryLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.green.withValues(alpha: 0.45),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.qr_code_2,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AppLocalizations.of(context)!.navQrPay,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(i);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          // Soft gradient ring on the active tab
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppTheme.green.withValues(alpha: 0.18),
                                    AppTheme.green.withValues(alpha: 0.08),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.green.withValues(alpha: 0.4)
                                : Colors.transparent,
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.green.withValues(
                                      alpha: 0.32,
                                    ),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                ]
                              : [],
                        ),
                        // Smooth icon color transition between states
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0,
                            end: isSelected ? 1 : 0,
                          ),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          builder: (context, t, _) => Icon(
                            _icons[i],
                            size: 22,
                            color: Color.lerp(
                              context.mutedColor,
                              AppTheme.green,
                              t,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? AppTheme.green
                              : context.mutedColor,
                        ),
                        child: Text(_labels(AppLocalizations.of(context)!)[i]),
                      ),
                      const SizedBox(height: 3),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 16 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
