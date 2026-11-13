// O1 Splash (açılış) ekranı. Firebase başlarken ve oturum kontrol edilirken gösterilir;
// ardından router kullanıcıyı Onboarding, Giriş veya rolüne göre ana ekrana gönderir.

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../onboarding/screens/splash_screen.dart' as onboarding_splash;

/// O1 — Splash Ekranı (§3.1).
/// Logo ve radar animasyonu, "AfetNet — Canlı Kriz Yönetimi Ağı", yüklenme göstergesi.
/// Router `AuthController.isInitializing` bitince otomatik olarak sonraki ekrana (Onboarding, Login veya Ana Sayfa) yönlendirir.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    // Radar çizimleri koyu zemin için tasarlandı; sistem teması açık olsa da
    // Splash ve Onboarding koyu temada gösterilir (okunabilirlik, T15 uyarısı).
    return Theme(
      data: AppTheme.dark(),
      child: const onboarding_splash.SplashScreen(),
    );
  }
}
