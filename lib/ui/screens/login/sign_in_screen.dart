import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/exceptions/api_exception.dart';
import '../../../model/user/user.dart';
import '../../../theme/app_theme.dart';
import '../../../ui/utils/async_value.dart';
import '../../widgets/smart_canteen_widgets.dart';
import '../home/home_screen.dart';
import 'complete_profile_screen.dart';
import 'forgot_password_screen.dart';
import 'view_model/auth_view_model.dart';

/// Brand gradient used for the primary action buttons (#4CAF50 → #81C784).
const _primaryGradient = LinearGradient(
  colors: [AppTheme.green, Color(0xFF81C784)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const _googleBlue = Color(0xFF4285F4);
const _microsoftBlue = Color(0xFF0078D4);

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$feature — coming soon'),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppTheme.green,
    ),
  );
}

/// Turns a caught error into copy a user can act on. [ApiException] carries
/// the backend's actual message (see backend `AllExceptionsFilter`); anything
/// else (timeouts, no connection, Google Sign-In failures) gets a fallback.
String _describeError(Object error) {
  if (error is ApiException) return error.message;
  return 'Something went wrong. Please try again.';
}

/// Where to send the user after a successful sign-in. Accounts with an
/// incomplete profile (missing name, phone, or school — typical for a freshly
/// created Google account) first pass through onboarding; everyone else goes
/// straight to the app.
void _routeAfterAuth(BuildContext context, User user) {
  if (user.needsProfileCompletion) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CompleteProfileScreen(user: user),
      ),
    );
  } else {
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.initialIsLogin = true});

  static const routeName = '/sign-in';
  final bool initialIsLogin;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late bool _isLogin;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Soft gradient backdrop — light green fading into white.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.greenSurface, Color(0xFFF7F8FA)],
            begin: Alignment.topCenter,
            end: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Header — food badge + title + tagline
                _AuthHeader(isLogin: _isLogin),
                const SizedBox(height: 28),
                // Floating form card with a soft shadow for depth
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.green.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tab switch
                      SmartCanteenAuthSwitch(
                        isLoginSelected: _isLogin,
                        onLoginTap: () => setState(() => _isLogin = true),
                        onSignUpTap: () => setState(() => _isLogin = false),
                      ),
                      const SizedBox(height: 28),
                      // Form content — fade + slide transition
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder: (child, animation) {
                          final isLoginForm =
                              child.key == const ValueKey('login');
                          final slideOffset = Offset(
                            isLoginForm ? -0.25 : 0.25,
                            0.0,
                          );

                          return ClipRect(
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: slideOffset,
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                          );
                        },
                        layoutBuilder: (currentChild, previousChildren) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            children: [...previousChildren, ?currentChild],
                          );
                        },
                        child: _isLogin
                            ? _LoginForm(
                                key: const ValueKey('login'),
                                rememberMe: _rememberMe,
                                onRememberMeChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                                onLogin: () => Navigator.pushReplacementNamed(
                                  context,
                                  HomeScreen.routeName,
                                ),
                              )
                            : _SignUpForm(
                                key: const ValueKey('signup'),
                                onSignUp: () => Navigator.pushReplacementNamed(
                                  context,
                                  HomeScreen.routeName,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header (badge + title + tagline) ─────────────────────────────────────────

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.isLogin});

  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Minimal food-themed badge
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.green.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        // Title — large, bold, animates with the active tab
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.15),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            ),
          ),
          child: Text(
            isLogin ? 'Welcome Back' : 'Create Account',
            key: ValueKey(isLogin),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.greenDark,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Tagline — lighter weight
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Text(
            isLogin
                ? 'Fresh meals are waiting for you'
                : 'Join us and start your meal journey',
            key: ValueKey(isLogin),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.text.withValues(alpha: 0.5),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Inline error banner ───────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
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

// ── Login form ──────────────────────────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  const _LoginForm({
    super.key,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onLogin,
  });

  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onLogin;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(
    Future<void> Function(AuthViewModel) action, {
    void Function(User user)? onSuccess,
  }) async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final authViewModel = context.read<AuthViewModel>();
    await action(authViewModel);
    if (!mounted) return;

    final state = authViewModel.loginState;
    setState(() {
      _isSubmitting = false;
      _error = state is AsyncError<User> ? _describeError(state.error) : null;
    });

    if (state is AsyncData<User>) {
      if (onSuccess != null) {
        onSuccess(state.data);
      } else {
        widget.onLogin();
      }
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    await _submit((vm) => vm.login(email: email, password: password));
  }

  Future<void> _handleGoogleLogin() async {
    await _submit(
      (vm) => vm.loginWithGoogle(),
      onSuccess: (user) => _routeAfterAuth(context, user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          _ErrorBanner(message: _error!),
          const SizedBox(height: 16),
        ],
        SmartCanteenTextField(
          controller: _emailController,
          label: 'Email Address',
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            Icons.mail_outline,
            color: AppTheme.green,
            size: 20,
          ),
        ),
        const SizedBox(height: 18),
        SmartCanteenTextField(
          controller: _passwordController,
          label: 'Password',
          hintText: 'Enter your password',
          obscureText: true,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: AppTheme.green,
            size: 20,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: widget.rememberMe,
              activeColor: AppTheme.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: const BorderSide(color: Color(0xFFE8E8E8), width: 1.5),
              onChanged: widget.onRememberMeChanged,
            ),
            const Text(
              'Remember me',
              style: TextStyle(
                color: AppTheme.mutedText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _ForgotPasswordButton(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  // Carry over whatever email was already typed.
                  builder: (_) => ForgotPasswordScreen(
                    initialEmail: _emailController.text.trim(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SmartCanteenButton(
          label: _isSubmitting ? 'Signing in…' : 'Log In',
          onPressed: _isSubmitting ? null : _handleLogin,
          gradient: _primaryGradient,
        ),
        const SizedBox(height: 24),
        const SmartCanteenDividerText(label: 'OR CONTINUE WITH'),
        const SizedBox(height: 20),
        _SocialRow(
          suffix: 'Sign-In',
          isBusy: _isSubmitting,
          onGoogleTap: () => _handleGoogleLogin(),
        ),
      ],
    );
  }
}

// ── Sign-up form ────────────────────────────────────────────────────────────

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({super.key, required this.onSignUp});

  final VoidCallback onSignUp;

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit({
    required Future<void> Function(AuthViewModel) action,
    required AsyncValue<User> Function(AuthViewModel) stateOf,
    void Function(User user)? onSuccess,
  }) async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final authViewModel = context.read<AuthViewModel>();
    await action(authViewModel);
    if (!mounted) return;

    final state = stateOf(authViewModel);
    setState(() {
      _isSubmitting = false;
      _error = state is AsyncError<User> ? _describeError(state.error) : null;
    });

    if (state is AsyncData<User>) {
      if (onSuccess != null) {
        onSuccess(state.data);
      } else {
        widget.onSignUp();
      }
    }
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    await _submit(
      action: (vm) =>
          vm.register(email: email, password: password, fullName: name),
      stateOf: (vm) => vm.registerState,
    );
  }

  Future<void> _handleGoogleSignUp() async {
    await _submit(
      action: (vm) => vm.loginWithGoogle(),
      stateOf: (vm) => vm.loginState,
      onSuccess: (user) => _routeAfterAuth(context, user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          _ErrorBanner(message: _error!),
          const SizedBox(height: 16),
        ],
        SmartCanteenTextField(
          controller: _nameController,
          label: 'Full Name',
          hintText: 'Enter your full name',
          prefixIcon: const Icon(
            Icons.person_outline,
            color: AppTheme.green,
            size: 20,
          ),
        ),
        const SizedBox(height: 18),
        SmartCanteenTextField(
          controller: _emailController,
          label: 'Email Address',
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            Icons.mail_outline,
            color: AppTheme.green,
            size: 20,
          ),
        ),
        const SizedBox(height: 18),
        SmartCanteenTextField(
          controller: _passwordController,
          label: 'Password',
          hintText: 'Enter your password',
          obscureText: true,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: AppTheme.green,
            size: 20,
          ),
        ),
        const SizedBox(height: 18),
        SmartCanteenTextField(
          controller: _confirmController,
          label: 'Confirm Password',
          hintText: 'Re-enter your password',
          obscureText: true,
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: AppTheme.green,
            size: 20,
          ),
        ),
        const SizedBox(height: 24),
        SmartCanteenButton(
          label: _isSubmitting ? 'Signing up…' : 'Sign Up',
          onPressed: _isSubmitting ? null : _handleSignUp,
          gradient: _primaryGradient,
        ),
        const SizedBox(height: 24),
        const SmartCanteenDividerText(label: 'OR CONTINUE WITH'),
        const SizedBox(height: 20),
        _SocialRow(
          suffix: 'Sign-Up',
          isBusy: _isSubmitting,
          onGoogleTap: () => _handleGoogleSignUp(),
        ),
      ],
    );
  }
}

// ── Shared social button row ─────────────────────────────────────────────────

class _SocialRow extends StatelessWidget {
  const _SocialRow({
    required this.suffix,
    required this.onGoogleTap,
    this.isBusy = false,
  });

  final String suffix;
  final VoidCallback onGoogleTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SmartCanteenSocialButton(
          label: 'Google',
          brandColor: _googleBlue,
          icon: _socialIcon('asset/auth_logo/google.png'),
          onTap: isBusy ? null : onGoogleTap,
        ),
        const SizedBox(width: 14),
        SmartCanteenSocialButton(
          label: 'Microsoft',
          brandColor: _microsoftBlue,
          icon: const _MicrosoftLogo(),
          onTap: isBusy
              ? null
              : () => _showComingSoon(context, 'Microsoft $suffix'),
        ),
      ],
    );
  }
}

// ── Forgot Password Button with Micro-interaction ──────────────────────────

class _ForgotPasswordButton extends StatefulWidget {
  const _ForgotPasswordButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ForgotPasswordButton> createState() => _ForgotPasswordButtonState();
}

class _ForgotPasswordButtonState extends State<_ForgotPasswordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: AppTheme.green,
      end: AppTheme.green.withValues(alpha: 0.7),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverOrTap() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: _onHoverOrTap,
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return Text(
              'Forgot Password?',
              style: TextStyle(
                color: _colorAnimation.value,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The Microsoft mark — four squares in a 2×2 grid, in its brand colours.
/// Drawn inline rather than loaded from an image so the button always renders
/// the correct logo without depending on a bundled asset.
class _MicrosoftLogo extends StatelessWidget {
  const _MicrosoftLogo();

  /// Matches the 22px Google asset beside it, trimmed slightly since solid
  /// squares read heavier than a glyph.
  static const size = 20.0;

  static const _red = Color(0xFFF25022);
  static const _green = Color(0xFF7FBA00);
  static const _blue = Color(0xFF00A4EF);
  static const _yellow = Color(0xFFFFB900);

  @override
  Widget build(BuildContext context) {
    // A hair of space between the squares, as in the real mark.
    final square = (size - 2) / 2;
    Widget tile(Color color) =>
        SizedBox(width: square, height: square, child: ColoredBox(color: color));

    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [tile(_red), tile(_green)],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [tile(_blue), tile(_yellow)],
          ),
        ],
      ),
    );
  }
}

Widget _socialIcon(String assetPath) {
  return Image.asset(
    assetPath,
    width: 22,
    height: 22,
    fit: BoxFit.contain,
    // A missing asset must never blow up the layout — fall back to a plain icon.
    errorBuilder: (_, _, _) =>
        const Icon(Icons.login, size: 20, color: AppTheme.mutedText),
  );
}
