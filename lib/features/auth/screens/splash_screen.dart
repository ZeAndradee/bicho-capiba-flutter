import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orangeCapiba,
      body: Center(
        child: Image.asset('assets/images/BichoOnlyLogo.png', height: 96),
      ),
    );
  }
}
