import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/utils/password_validator.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/widgets/settings_widgets.dart';
import 'package:smart_canteen_user_frontend/core/widgets/app_button.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/widgets/change_password/password_field.dart';

/// Lets a signed-in user with a password replace it. Only reachable from
/// Settings when the account has a password — Google-only accounts see
/// "Set a Password" instead.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateNew(String? value) {
    final password = value ?? '';
    if (password == _currentController.text) {
      return 'New password must be different from the current one.';
    }
    return validateNewPassword(password);
  }

  String? _validateConfirm(String? value) =>
      value == _newController.text ? null : 'Passwords do not match.';

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final auth = context.read<AuthViewModel>();
    final router = GoRouter.of(context);

    unawaited(HapticFeedback.mediumImpact());
    setState(() => _saving = true);

    // POST /auth/password/change — via AuthViewModel.changePassword.
    final error = await auth.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );
    if (!mounted) return;

    if (error != null) {
      setState(() => _saving = false);
      _showSnack(error, isError: true);
      return;
    }
    router.pop();
    _showSnack('Password changed');
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.accentRed : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Column(
        children: [
          const SettingsHeader(title: 'Change Password'),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  SettingsFadeIn(
                    index: 0,
                    child: PasswordField(
                      label: 'Current Password',
                      hint: 'Enter your current password',
                      controller: _currentController,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter your current password.'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SettingsFadeIn(
                    index: 1,
                    child: PasswordField(
                      label: 'New Password',
                      hint: 'At least 8 characters',
                      controller: _newController,
                      validator: _validateNew,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SettingsFadeIn(
                    index: 2,
                    child: PasswordField(
                      label: 'Confirm New Password',
                      hint: 'Re-enter the new password',
                      controller: _confirmController,
                      validator: _validateConfirm,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // const _PasswordHint(),
                  const SizedBox(height: 36),
                  SettingsFadeIn(
                    index: 3,
                    child: _SaveButton(saving: _saving, onPressed: _save),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Backend password rule, shown up front so users don't learn it by failing
class _PasswordHint extends StatelessWidget {
  const _PasswordHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Use 8+ characters with an uppercase letter, a lowercase letter and a number.',
      style: AppFonts.heading4.copyWith(color: context.mutedColor),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saving, required this.onPressed});

  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: saving ? 'Saving…' : 'Update Password',
      // gradient: const LinearGradient(
      //   colors: [AppColors.primaryDark, AppColors.primaryLight],
      //   begin: Alignment.topLeft,
      //   end: Alignment.bottomRight,
      // ),
      leading: saving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
              ),
            )
          : null,
      onPressed: saving ? null : onPressed,
    );
  }
}
