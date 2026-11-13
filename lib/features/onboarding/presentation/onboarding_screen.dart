// O2 Onboarding ekranı: uygulamayı ilk açan kişiye 2 sayfalık tanıtım.
// "Atla" ya da "Başla" denince bir daha gösterilmez (SharedPreferences'a kaydedilir).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';
import '../screens/splash_onboarding_screen.dart';

/// O2 — Onboarding.
/// 2 sayfa (Sivil Kullanıcı ve Saha Yönetimi), 112 resmi kurum uyarısı.
/// Atla veya Başla tetiklendiğinde `completeOnboarding()` çalışır ve kullanıcı doğrudan Giriş ekranına geçer.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    // Splash ile aynı nedenle her zaman koyu temada gösterilir.
    return Theme(
      data: AppTheme.dark(),
      child: SplashOnboardingScreen(
        onCompleted: () async {
          await context.read<AuthController>().completeOnboarding();
          if (context.mounted) {
            context.go(AppRoutes.login);
          }
        },
      ),
    );
  }
}
