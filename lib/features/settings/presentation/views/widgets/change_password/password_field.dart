import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

/// Labelled password input with a show/hide toggle, styled like the Edit
/// Profile fields so the two Settings forms match.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppFonts.heading3.copyWith(
            color: AppColors.primary,
            fontWeight: AppFonts.semiBold,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _obscure,
          textInputAction: widget.textInputAction,
          autocorrect: false,
          enableSuggestions: false,
          style: AppFonts.heading3.copyWith(color: context.textColor),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: context.mutedColor,
              size: 20,
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.mutedColor,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
