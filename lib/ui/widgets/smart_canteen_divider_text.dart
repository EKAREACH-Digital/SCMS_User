import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SmartCanteenDividerText extends StatelessWidget {
  const SmartCanteenDividerText({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.border, thickness: 1)),
      ],
    );
  }
}
