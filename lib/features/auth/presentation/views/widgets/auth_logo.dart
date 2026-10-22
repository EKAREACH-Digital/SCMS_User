import 'package:flutter/material.dart';

import 'package:smart_canteen_user_frontend/core/constants/images_constant.dart';

/// App logo shown at the bottom of every auth screen.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        ImageConst.logo,
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      ),
    );
  }
}
