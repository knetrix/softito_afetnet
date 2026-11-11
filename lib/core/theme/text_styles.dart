import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gömülü yazı tipi aileleri (§3.4, `assets/fonts/`, pubspec `fonts:`).
abstract final class AppFonts {
  static const heading = 'SpaceGrotesk';
  static const body = 'Inter';
  static const mono = 'JetBrainsMono';
}

/// AfetNet Tipografi Stilleri (§3.4)
/// Space Grotesk (başlık), Inter (gövde), JetBrains Mono (etiket)
abstract final class AppTextStyles {
  // Başlıklar
  static const TextStyle displayTitle = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: AppFonts.heading,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Gövde metinleri
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  // Etiket ve kod metinleri (JetBrains Mono tarzı)
  static const TextStyle badgeText = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static const TextStyle monoLabel = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle statusText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
