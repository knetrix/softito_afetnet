// Tasarımdaki renk token'ları.

import 'package:flutter/material.dart';

/// AfetNet Tasarım Sistemi Renk Token'ları (§3.4)
/// Değerler doğrudan `PROJECT_NEW.md` §3.4 tablosundan alınmıştır.
abstract final class AppColors {
  // Arka plan ve yüzey renkleri
  static const Color background = Color(0xFF0D0F12);
  static const Color surface = Color(0xFF16191E);
  static const Color surfaceHigh = Color(0xFF1E2228);

  // Açık tema için türetilen yüzeyler (T14)
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceHigh = Color(0xFFEDF2F7);

  // Ana renk ve ışıma
  static const Color primary = Color(0xFF00E1FF);
  static const Color primaryDark = Color(0xFF00B4CC);
  static const Color primaryGlow = Color(0x3300E1FF);

  // Durum renkleri
  static const Color danger = Color(0xFFFF2D55); // Panik, kritik öncelik, düdük çalıyor
  static const Color whistle = Color(0xFFFF7A00); // Düdük bekleme
  static const Color warning = Color(0xFFFFB020); // Acil öncelik, orta stok
  static const Color success = Color(0xFF1FE07A); // Normal öncelik, yeterli stok, boşta ekip
  static const Color panic = Color(0xFFA855F7); // Y1 mor panik sinyali pini

  // Metin renkleri (koyu tema)
  static const Color textPrimary = Color(0xFFEDEFF2);
  static const Color textSecondary = Color(0xFF9AA3AD);
  static const Color textMuted = Color(0xFF5F6B7A);

  // Metin renkleri (açık tema)
  static const Color lightTextPrimary = Color(0xFF121826);
  static const Color lightTextSecondary = Color(0xFF4B5565);
  static const Color lightTextMuted = Color(0xFF9AA4B2);

  // Kenarlık ve ayraçlar
  static const Color border = Color(0xFF262C36);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color borderGlow = Color(0x4000E1FF);

  // Eski kod geriye dönük uyumluluğu için alias'lar
  static const Color backgroundSurface = surface;
  static const Color backgroundLight = surfaceHigh;
  static const Color primaryCyan = primary;
  static const Color cyanLight = Color(0xFF67E8F9);
  static const Color cyanDark = primaryDark;
}
