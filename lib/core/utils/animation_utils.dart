import 'package:flutter/material.dart';

class AnimationUtils {
  /// Fade + slide-up page transition, for a GoRouter `CustomTransitionPage`.
  static RouteTransitionsBuilder fadeSlideUp({
    Curve fadeCurve = Curves.easeOut,
  }) {
    return (_, animation, _, child) {
      final fade = CurvedAnimation(parent: animation, curve: fadeCurve);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    };
  }

  /// Elastic scale-in for hero elements (e.g. logo splash).
  static Animation<double> elasticScale(AnimationController controller) {
    return Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
  }

  /// Standard card appear duration used across the app.
  static const Duration cardAppear = Duration(milliseconds: 200);

  /// Standard page transition duration.
  static const Duration pageTransition = Duration(milliseconds: 300);

  /// Standard reverse (pop) page transition duration.
  static const Duration pageTransitionReverse = Duration(milliseconds: 250);
}
