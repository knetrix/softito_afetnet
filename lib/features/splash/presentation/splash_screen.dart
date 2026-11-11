import 'package:flutter/material.dart';

import '../../onboarding/screens/splash_screen.dart' as onboarding_splash;

/// O1 — Splash Ekranı (§3.1).
/// Logo ve radar animasyonu, "AfetNet — Canlı Kriz Yönetimi Ağı", yüklenme göstergesi.
/// Router `AuthController.isInitializing` bitince otomatik olarak sonraki ekrana (Onboarding, Login veya Ana Sayfa) yönlendirir.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const onboarding_splash.SplashScreen();
  }
}
