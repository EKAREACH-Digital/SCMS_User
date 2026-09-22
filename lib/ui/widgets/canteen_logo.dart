import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class CanteenLogo extends StatelessWidget {
  const CanteenLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final plateSize = size;
    return SizedBox(
      width: plateSize,
      height: plateSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: plateSize * 0.98,
            height: plateSize * 0.98,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.08),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: plateSize * 0.12,
            left: plateSize * 0.10,
            child: _FoodCircle(
              size: plateSize * 0.28,
              color: const Color(0xFFFFC85C),
              borderColor: Colors.black,
            ),
          ),
          Positioned(
            bottom: plateSize * 0.16,
            left: plateSize * 0.18,
            child: _FoodSlice(size: plateSize * 0.34),
          ),
          Positioned(
            right: plateSize * 0.14,
            top: plateSize * 0.16,
            child: Transform.rotate(
              angle: math.pi / 8,
              child: Container(
                width: plateSize * 0.36,
                height: plateSize * 0.30,
                decoration: BoxDecoration(
                  color: const Color(0xFFB56D42),
                  border: Border.all(color: Colors.black, width: 4),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: plateSize * 0.08,
            right: plateSize * 0.10,
            child: Container(
              width: plateSize * 0.16,
              height: plateSize * 0.16,
              decoration: BoxDecoration(
                color: const Color(0xFF57A957),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Container(
            width: plateSize * 0.82,
            height: plateSize * 0.82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodCircle extends StatelessWidget {
  const _FoodCircle({
    required this.size,
    required this.color,
    required this.borderColor,
  });

  final double size;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 4),
      ),
    );
  }
}

class _FoodSlice extends StatelessWidget {
  const _FoodSlice({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE05A4E),
        borderRadius: BorderRadius.circular(size * 0.15),
        border: Border.all(color: Colors.black, width: 4),
      ),
    );
  }
}
