import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

class SmartCanteenTextField extends StatefulWidget {
  const SmartCanteenTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.controller,
    this.keyboardType,
    this.borderRadius,
  });

  final String label;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  /// Overrides the theme's input border radius when provided.
  final BorderRadius? borderRadius;

  @override
  State<SmartCanteenTextField> createState() => _SmartCanteenTextFieldState();
}

class _SmartCanteenTextFieldState extends State<SmartCanteenTextField>
    with SingleTickerProviderStateMixin {
  late bool _obscure;
  late FocusNode _focusNode;
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _focusNode = FocusNode();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeOutCubic),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusController.forward();
      } else {
        _focusController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputTheme = Theme.of(context).inputDecorationTheme;
    final inputBorder = inputTheme.enabledBorder ?? inputTheme.border;
    final themeBorderRadius = inputBorder is OutlineInputBorder
        ? inputBorder.borderRadius
        : BorderRadius.zero;
    final effectiveRadius = widget.borderRadius ?? themeBorderRadius;

    OutlineInputBorder overrideBorder(InputBorder? base) {
      if (base is OutlineInputBorder) {
        return base.copyWith(borderRadius: effectiveRadius);
      }
      return OutlineInputBorder(borderRadius: effectiveRadius);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppFonts.heading3.copyWith(
            color: AppColors.primary,
            fontWeight: AppFonts.semiBold,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: effectiveRadius,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: 0.1 * _focusAnimation.value,
                    ),
                    blurRadius: 8 * _focusAnimation.value,
                    offset: Offset(0, 2 * _focusAnimation.value),
                  ),
                ],
              ),
              child: TextFormField(
                focusNode: _focusNode,
                controller: widget.controller,
                obscureText: _obscure,
                keyboardType: widget.keyboardType,
                style: AppFonts.heading3.copyWith(
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: inputTheme.hintStyle,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.obscureText
                      ? GestureDetector(
                          onTap: () => setState(() => _obscure = !_obscure),
                          child: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.mutedText,
                            size: 20,
                          ),
                        )
                      : widget.suffixIcon,
                  contentPadding: inputTheme.contentPadding,
                  border: overrideBorder(inputTheme.border),
                  enabledBorder: overrideBorder(inputTheme.enabledBorder),
                  focusedBorder: overrideBorder(inputTheme.focusedBorder),
                  filled: inputTheme.filled,
                  fillColor: inputTheme.fillColor,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
