import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:smart_canteen_user_frontend/core/constants/images_constant.dart';
import 'package:smart_canteen_user_frontend/core/routes/app_routes.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/core/widgets/smart_canteen_widgets.dart';
import 'package:smart_canteen_user_frontend/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  late final Animation<double> _buttonFade;
  late final Animation<Offset> _buttonSlide;

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

    // Button: fade + slight slide up (last to appear)
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.72, 1.0, curve: Curves.easeIn),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.72, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tryAutoLogin();
    });
  }

  /// Session restore: if a token is stored and still valid, the router's
  /// redirect takes a signed-in user straight into the app. Otherwise the
  /// "Get Started" button is revealed.
  void _tryAutoLogin() => context.read<AuthViewModel>().restoreSession();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _navigateToSignIn() {
    // The fade-in transition is declared on the sign-in route itself.
    context.go(AppPaths.signIn);
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
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Image.asset(
                            ImageConst.logo,
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 44,
                      child: context.watch<AuthViewModel>().status !=
                              AuthStatus.unauthenticated
                          // Verifying a saved session — brief spinner instead of
                          // the button, so a logged-in user never sees it.
                          ? const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.primary,
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
