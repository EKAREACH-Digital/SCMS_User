import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

/// Horizontal two-step progress bar used on the Register flow.
///
/// [currentStep] — 1-based index of the active step (1 or 2).
/// [totalSteps]  — total number of steps (defaults to 2).
class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 2,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isCompleted = stepNumber < currentStep;
        final isActive = stepNumber == currentStep;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepBar(isActive: isActive, isCompleted: isCompleted),
                const SizedBox(height: 6),
                Text(
                  'Step $stepNumber',
                  style: AppFonts.heading5.copyWith(
                    color: isActive || isCompleted
                        ? AppColors.primary
                        : AppColors.mutedText,
                    fontWeight: isActive ? AppFonts.semiBold : AppFonts.regular,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.isActive, required this.isCompleted});

  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      decoration: BoxDecoration(
        color: isActive || isCompleted ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
