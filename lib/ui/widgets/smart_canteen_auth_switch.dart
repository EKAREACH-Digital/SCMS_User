import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SmartCanteenAuthSwitch extends StatelessWidget {
  const SmartCanteenAuthSwitch({
    super.key,
    required this.isLoginSelected,
    required this.onLoginTap,
    required this.onSignUpTap,
  });

  final bool isLoginSelected;
  final VoidCallback onLoginTap;
  final VoidCallback onSignUpTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _AuthSwitchItem(
              label: 'Log In',
              selected: isLoginSelected,
              onTap: onLoginTap,
            ),
          ),
          Expanded(
            child: _AuthSwitchItem(
              label: 'Sign Up',
              selected: !isLoginSelected,
              onTap: onSignUpTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthSwitchItem extends StatefulWidget {
  const _AuthSwitchItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_AuthSwitchItem> createState() => _AuthSwitchItemState();
}

class _AuthSwitchItemState extends State<_AuthSwitchItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_AuthSwitchItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: widget.selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            color: widget.selected ? Colors.white : AppTheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
