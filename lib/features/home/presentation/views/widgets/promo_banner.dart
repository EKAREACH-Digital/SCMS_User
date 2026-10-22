import 'dart:async';

import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/constants/images_constant.dart';
import 'package:smart_canteen_user_frontend/core/theme/app_theme.dart';

/// Auto-scrolling banner carousel shown on the home screen.
///
/// Cycles through [ImageConst.banners] every 3 seconds and shows
/// dot indicators at the bottom.
class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  static const _banners = ImageConst.banners;
  static const _autoScrollInterval = Duration(seconds: 3);

  final _controller = PageController();
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted) return;
      final next = (_current + 1) % _banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: PageView.builder(
                controller: _controller,
                itemCount: _banners.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => Image.asset(
                  _banners[i],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: _DotIndicator(
                count: _banners.length,
                current: _current,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? AppColors.onPrimary
                : AppColors.onPrimary.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
