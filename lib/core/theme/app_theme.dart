import 'package:flutter/material.dart';

class AppColors {
  static const orangeCapiba = Color(0xFFDD4319);
  static const greenCapiba = Color(0xFF3F7D58);
  static const yellowCapiba = Color(0xFFEF9651);

  static const background = Color(0xFFFFFFFF);
  static const backgroundSecondary = Color(0xFFF8F8F8);
  static const foreground = Color(0xFF171717);
  static const textColor = Color(0xFF524E4E);
  static const borderColor = Color(0xFFEBEBEB);

  static const skeletonBase = Color(0xFFE0E0E0);
  static const skeletonShimmer = Color(0xFFF0F0F0);

  static const primary = greenCapiba;
}

class AppFonts {
  static const title = 'Fredoka';
  static const body = 'Inter';
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.greenCapiba,
      primary: AppColors.greenCapiba,
      secondary: AppColors.orangeCapiba,
      tertiary: AppColors.yellowCapiba,
      surface: AppColors.background,
      onSurface: AppColors.foreground,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppFonts.body,
      iconTheme: const IconThemeData(size: 24),
    );

    return base.copyWith(
      iconTheme: const IconThemeData(size: 24),
      textTheme: base.textTheme
          .apply(
            bodyColor: AppColors.textColor,
            displayColor: AppColors.foreground,
          )
          .copyWith(
            bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 16),
            bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 14),
            bodySmall: base.textTheme.bodySmall?.copyWith(fontSize: 13),
            labelLarge: base.textTheme.labelLarge?.copyWith(fontSize: 14),
            labelMedium: base.textTheme.labelMedium?.copyWith(fontSize: 13),
            displayLarge: base.textTheme.displayLarge?.copyWith(
              fontFamily: AppFonts.title,
            ),
            displayMedium: base.textTheme.displayMedium?.copyWith(
              fontFamily: AppFonts.title,
            ),
            displaySmall: base.textTheme.displaySmall?.copyWith(
              fontFamily: AppFonts.title,
            ),
            headlineLarge: base.textTheme.headlineLarge?.copyWith(
              fontFamily: AppFonts.title,
            ),
            headlineMedium: base.textTheme.headlineMedium?.copyWith(
              fontFamily: AppFonts.title,
            ),
            headlineSmall: base.textTheme.headlineSmall?.copyWith(
              fontFamily: AppFonts.title,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.title,
            ),
          ),
      dividerColor: AppColors.borderColor,
    );
  }
}
