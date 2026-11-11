import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_controller.dart';
import '../screens/splash_onboarding_screen.dart';

/// O2 — Onboarding (§3.1, §3.3).
/// 2 sayfa (Sivil Kullanıcı ve Saha Yönetimi), 112 resmi kurum uyarısı.
/// Atla veya Başla tetiklendiğinde `completeOnboarding()` çalışır ve kullanıcı Giriş'e geçer.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashOnboardingScreen(
      onCompleted: () => context.read<AuthController>().completeOnboarding(),
    );
  }
}
