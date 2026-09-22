import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import '../../widgets/settings_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const routeName = '/about';
  static const _appVersion = '1.0.0 (1)';

  void _comingSoon(BuildContext context, String label) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Column(
        children: [
          const SettingsHeader(title: 'About'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                // App identity
                SettingsFadeIn(
                  index: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.greenDark,
                                AppTheme.primaryLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.green.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Smart Canteen',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: context.textColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version $_appVersion',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.mutedColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SettingsFadeIn(
                  index: 1,
                  child: SettingsSection(
                    title: 'App Info',
                    children: [
                      SettingsTile(
                        icon: Icons.verified_outlined,
                        title: 'Version',
                        subtitle: 'You are up to date',
                        trailing: Text(
                          _appVersion,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: context.mutedColor,
                          ),
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'How we handle your data',
                        onTap: () => _comingSoon(context, 'Privacy Policy'),
                      ),
                      SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        subtitle: 'Our terms & conditions',
                        onTap: () => _comingSoon(context, 'Terms of Service'),
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                SettingsFadeIn(
                  index: 2,
                  child: SettingsSection(
                    title: 'Developer',
                    children: [
                      const SettingsTile(
                        icon: Icons.code_rounded,
                        title: 'Built by',
                        subtitle: 'SCMS Team — Ekreach Digital',
                      ),
                      SettingsTile(
                        icon: Icons.mail_outline_rounded,
                        title: 'Contact',
                        subtitle: 'sokhunmonys@cadt.edu.kh',
                        onTap: () => _comingSoon(context, 'Contact'),
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                SettingsFadeIn(
                  index: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Text(
                      '© 2026 Smart Canteen Management System\nBy Ekreach Digital. \nAll rights reserved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.5,
                        color: context.mutedColor,
                      ),
                    ),
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
