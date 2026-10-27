import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/constants/images_constant.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';
import 'package:smart_canteen_user_frontend/features/settings/presentation/views/widgets/settings_widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _appVersion = '1.0.0 (1)';

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
                        // The logo artwork has a white background, so the tile
                        // stays white in dark mode too.
                        Container(
                          width: 96,
                          height: 96,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            ImageConst.logo,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'កង់ទីន | La Cantine',
                          style: AppFonts.heading1.copyWith(
                            fontWeight: AppFonts.bold,
                            color: context.textColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version $_appVersion',
                          style: AppFonts.heading3.copyWith(
                            color: context.mutedColor,
                            fontWeight: AppFonts.medium,
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
                          style: AppFonts.heading4.copyWith(
                            fontSize: 12.5,
                            fontWeight: AppFonts.semiBold,
                            color: context.mutedColor,
                          ),
                        ),
                      ),
                      // SettingsTile(
                      //   icon: Icons.privacy_tip_outlined,
                      //   title: 'Privacy Policy',
                      //   subtitle: 'How we handle your data',
                      //   onTap: () => _comingSoon(context, 'Privacy Policy'),
                      // ),
                      // SettingsTile(
                      //   icon: Icons.description_outlined,
                      //   title: 'Terms of Service',
                      //   subtitle: 'Our terms & conditions',
                      //   onTap: () => _comingSoon(context, 'Terms of Service'),
                      //   isLast: true,
                      // ),
                    ],
                  ),
                ),

                const SettingsFadeIn(
                  index: 2,
                  child: SettingsSection(
                    title: 'Developer',
                    children: [
                      SettingsTile(
                        icon: Icons.code_rounded,
                        title: 'Built by',
                        subtitle: 'SCMS Team — Ekreach Digital',
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
                      style: AppFonts.heading5.copyWith(
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
