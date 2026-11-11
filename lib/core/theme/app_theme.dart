import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryCyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryCyan,
        surface: AppColors.backgroundSurface,
        error: AppColors.danger,
      ),
      fontFamily: 'Roboto',
      useMaterial3: true,
    );
  }
}

