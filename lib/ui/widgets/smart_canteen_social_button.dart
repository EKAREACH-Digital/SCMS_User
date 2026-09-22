import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SmartCanteenSocialButton extends StatefulWidget {
  const SmartCanteenSocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.brandColor = AppTheme.green,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onTap;

  /// Brand accent used for the outline and label (e.g. Google blue).
  final Color brandColor;

  @override
  State<SmartCanteenSocialButton> createState() =>
      _SmartCanteenSocialButtonState();
}

class _SmartCanteenSocialButtonState extends State<SmartCanteenSocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _borderColorAnimation = ColorTween(
      begin: widget.brandColor.withValues(alpha: 0.35),
      end: widget.brandColor.withValues(alpha: 0.8),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _handlePress,
          child: AnimatedBuilder(
            animation: _borderColorAnimation,
            builder: (context, child) {
              return Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _borderColorAnimation.value ??
                        widget.brandColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.brandColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.icon,
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.brandColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
