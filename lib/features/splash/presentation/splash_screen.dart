import 'package:flutter/material.dart';

/// O1 — Splash. Router, `AuthController.isInitializing` bitene kadar burada
/// tutar. Geçici görünüm; tasarımı (logo animasyonu) G2 uygular.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
