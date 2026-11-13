// Öncelik ve durum renkleri (ThemeExtension).

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// AfetNet Durum Renkleri ThemeExtension (§3.4, T14)
/// Öncelik, düdük, panik pini ve stok durum renklerini tek yerde tutar.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.critical,
    required this.urgent,
    required this.normal,
    required this.whistle,
    required this.panic,
  });

  /// 🔴 Kritik öncelik (1: Enkaz, Tıbbi), Düdük çalıyor, Panik aktif
  final Color critical;

  /// 🟠 Acil öncelik (2: Barınma, Isınma, Bebek Maması), Orta stok
  final Color urgent;

  /// 🟢 Normal öncelik (3: Su, Diğer), Yeterli stok, Boşta ekip
  final Color normal;

  /// 🟠 Düdük bekleme durumu
  final Color whistle;

  /// 🟣 Yetkili haritasında mor panik sinyali pini
  final Color panic;

  /// Koyu tema için varsayılan durum renkleri
  static const dark = AppStatusColors(
    critical: AppColors.danger,
    urgent: AppColors.warning,
    normal: AppColors.success,
    whistle: AppColors.whistle,
    panic: AppColors.panic,
  );

  /// Açık tema için durum renkleri (okunabilirlik ve kontrast ayarlı)
  static const light = AppStatusColors(
    critical: Color(0xFFE11D48),
    urgent: Color(0xFFD97706),
    normal: Color(0xFF059669),
    whistle: Color(0xFFEA580C),
    panic: Color(0xFF9333EA),
  );

  /// Öncelik seviyesine (1, 2, 3) göre renk döndüren yardımcı metot (§4 Kural 1).
  Color forPriority(int priority) {
    switch (priority) {
      case 1:
        return critical;
      case 2:
        return urgent;
      case 3:
      default:
        return normal;
    }
  }

  @override
  AppStatusColors copyWith({
    Color? critical,
    Color? urgent,
    Color? normal,
    Color? whistle,
    Color? panic,
  }) {
    return AppStatusColors(
      critical: critical ?? this.critical,
      urgent: urgent ?? this.urgent,
      normal: normal ?? this.normal,
      whistle: whistle ?? this.whistle,
      panic: panic ?? this.panic,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      critical: Color.lerp(critical, other.critical, t) ?? critical,
      urgent: Color.lerp(urgent, other.urgent, t) ?? urgent,
      normal: Color.lerp(normal, other.normal, t) ?? normal,
      whistle: Color.lerp(whistle, other.whistle, t) ?? whistle,
      panic: Color.lerp(panic, other.panic, t) ?? panic,
    );
  }
}

