import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/local/token_storage.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/user/user.dart';
import '../../../theme/app_theme.dart';
import '../../states/notification_prefs_state.dart';
import '../../states/user_profile_state.dart';
import '../../widgets/smart_canteen_widgets.dart';
import '../login/sign_in_screen.dart';
import '../shell/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;

  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;

  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

  // While true, we're checking for a saved session; the "Get Started" button is
  // hidden until we know the user is logged out.
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Logo: elastic scale-in with a quick fade
    _logoScale = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.62, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.22, curve: Curves.easeIn),
      ),
    );

    // Title: fade + slide up
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.40, 0.65, curve: Curves.easeIn),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.55), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.40, 0.65, curve: Curves.easeOut),
          ),
        );

    // Subtitle: fade + slide up (slightly delayed)
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.55, 0.78, curve: Curves.easeIn),
      ),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.55), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.55, 0.78, curve: Curves.easeOut),
          ),
        );

    // Button: fade + slight slide up (last to appear)
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.72, 1.0, curve: Curves.easeIn),
      ),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.72, 1.0, curve: Curves.easeOut),
          ),
        );

    _ctrl.forward();
    _tryAutoLogin();
  }

  /// Session restore: if a token is stored and still valid (the API client
  /// refreshes it transparently on a 401), skip sign-in and go straight to the
  /// app. Otherwise reveal the "Get Started" button.
  Future<void> _tryAutoLogin() async {
    final authRepo = context.read<AuthRepository>();
    final profileState = context.read<UserProfileState>();
    final notificationPrefs = context.read<NotificationPrefsState>();
    final navigator = Navigator.of(context);

    final token = await TokenStorage.instance.readAccessToken();
    if (!mounted) return;
    if (token == null) {
      setState(() => _checkingSession = false);
      return;
    }

    try {
      final user = User.fromDto(await authRepo.getProfile());
      if (!mounted) return;
      profileState.setFromUser(
        id: user.id,
        name: user.fullName,
        email: user.email,
        schoolName: user.schoolName,
        canUseEmailPassword: user.canUseEmailPassword,
      );
      notificationPrefs.setFromUser(
        userId: user.id,
        orderUpdates: user.notifyOrderUpdates,
        promotions: user.notifyPromotions,
        systemAlerts: user.notifySystemAlerts,
      );
      navigator.pushReplacementNamed(AppShell.routeName);
    } catch (_) {
      // Invalid/expired session (or offline) — fall back to sign-in. Token
      // clearing on an unrecoverable 401 is handled by the API client.
      if (mounted) setState(() => _checkingSession = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 550),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => const SignInScreen(),
        transitionsBuilder: (_, animation, _, child) {
          final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
          final slide =
              Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoSize = constraints.maxWidth.clamp(240.0, 320.0) * 0.72;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: CanteenLogo(size: logoSize),
                            ),
                          ),
                          const SizedBox(height: 28),
                          FadeTransition(
                            opacity: _titleFade,
                            child: SlideTransition(
                              position: _titleSlide,
                              child: const Text(
                                'Smart Canteen',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          FadeTransition(
                            opacity: _subtitleFade,
                            child: SlideTransition(
                              position: _subtitleSlide,
                              child: Text(
                                AppLocalizations.of(context)!.splashTagline,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.mutedText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 44,
                      child: _checkingSession
                          // Verifying a saved session — brief spinner instead of
                          // the button, so a logged-in user never sees it.
                          ? const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppTheme.primary,
                                ),
                              ),
                            )
                          : FadeTransition(
                              opacity: _buttonFade,
                              child: SlideTransition(
                                position: _buttonSlide,
                                child: SizedBox(
                                  width: 180,
                                  child: SmartCanteenButton(
                                    label: 'Get Started',
                                    onPressed: _navigateToSignIn,
                                    height: 44,
                                    radius: 30,
                                    width: 180,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
