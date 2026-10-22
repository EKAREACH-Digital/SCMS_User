import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

/// A labelled dropdown field that matches the SmartCanteenTextField style.
///
/// [label]       — text shown above the field.
/// [hint]        — placeholder when no value is selected.
/// [value]       — the currently selected value (or null).
/// [items]       — list of `(id, displayName)` pairs.
/// [onChanged]   — called with the selected id when the user picks an option.
/// [prefixIcon]  — optional leading icon inside the field.
/// [isLoading]   — when true, shows a spinner instead of the dropdown arrow.
/// [errorText]   — when non-null, shows an inline error below the field.
class AppDropdown extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.isLoading = false,
    this.errorText,
  });

  final String label;
  final String hint;
  final String? value;
  final List<(String id, String name)> items;
  final ValueChanged<String?> onChanged;
  final Widget? prefixIcon;
  final bool isLoading;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.heading3.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        isLoading
            ? _LoadingBox()
            : DropdownButtonFormField<String>(
                initialValue: value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary,
                ),
                hint: Text(
                  hint,
                  style: AppFonts.heading3.copyWith(color: AppColors.mutedText),
                ),
                items: [
                  for (final (id, name) in items)
                    DropdownMenuItem(
                      value: id,
                      child: Text(
                        name,
                        style: AppFonts.heading3.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ),
                ],
                onChanged: onChanged,
                decoration: InputDecoration(
                  prefixIcon: prefixIcon,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  filled: true,
                  fillColor: context.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  errorText: errorText,
                ),
              ),
      ],
    );
  }
}

class _LoadingBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading…',
            style: AppFonts.heading3.copyWith(color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
