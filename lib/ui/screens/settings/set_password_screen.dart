import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../../ui/states/user_profile_state.dart';
import '../../utils/password_validator.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/smart_canteen_button.dart';
import '../../widgets/smart_canteen_text_field.dart';
import '../login/view_model/auth_view_model.dart';

/// Lets an account created with Google add a password, so the user can also
/// sign in with their email address on another device. Only reachable while
/// `UserProfileState.canUseEmailPassword` is false — once a password exists,
/// changing it is a different flow.
class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  static const routeName = '/set-password';

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;

    final password = _passwordController.text;
    final problem = validateNewPassword(password);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    if (password != _confirmController.text) {
      setState(() => _error = 'The two passwords do not match.');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _saving = true;
      _error = null;
    });

    final message = await context.read<AuthViewModel>().setPassword(password);
    if (!mounted) return;

    if (message != null) {
      setState(() {
        _saving = false;
        _error = message;
      });
      return;
    }

    // Flip the flag so the Settings entry disappears immediately.
    context.read<UserProfileState>().markPasswordSet();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password set — you can now log in with your email'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<UserProfileState>().email;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Column(
        children: [
          const SettingsHeader(title: 'Set a Password'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                SettingsFadeIn(index: 0, child: _ExplainerCard(email: email)),
                const SizedBox(height: 26),
                SettingsFadeIn(
                  index: 1,
                  child: SmartCanteenTextField(
                    controller: _passwordController,
                    label: 'New Password',
                    hintText: 'At least 8 characters',
                    obscureText: _obscure,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppTheme.green,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: context.mutedColor,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SettingsFadeIn(
                  index: 2,
                  child: SmartCanteenTextField(
                    controller: _confirmController,
                    label: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    obscureText: _obscure,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppTheme.green,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const _RequirementsHint(),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(message: _error!),
                ],
                const SizedBox(height: 30),
                SettingsFadeIn(
                  index: 3,
                  child: SmartCanteenButton(
                    label: _saving ? 'Saving…' : 'Set Password',
                    gradient: const LinearGradient(
                      colors: [AppTheme.greenDark, AppTheme.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    leading: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                    onPressed: _saving ? null : _save,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplainerCard extends StatelessWidget {
  const _ExplainerCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.green.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.green.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key_outlined, color: AppTheme.green, size: 20),
              const SizedBox(width: 10),
              Text(
                'Log In without Google',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Your account was created with Google, so it has no password yet. '
            'Set one to also log in with your email on any device.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: context.mutedColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.mail_outline_rounded,
                size: 16,
                color: context.mutedColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'This stays your sign-in email. Google sign-in keeps working too.',
            style: TextStyle(fontSize: 11.5, color: context.mutedColor),
          ),
        ],
      ),
    );
  }
}

class _RequirementsHint extends StatelessWidget {
  const _RequirementsHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 15, color: context.mutedColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Use at least 8 characters with an uppercase letter, a lowercase '
            'letter, and a number.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: context.mutedColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE53935).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE53935), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFC62828),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
