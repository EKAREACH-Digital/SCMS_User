import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class MenuChip extends StatelessWidget {
  const MenuChip({super.key, required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : context.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
