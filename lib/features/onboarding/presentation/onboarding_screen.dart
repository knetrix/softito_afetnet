import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_controller.dart';

/// O2 — Onboarding. Geçici görünüm; 2 sayfalık tasarımı G2 uygular.
/// Atla / Başla: `completeOnboarding()` → router Giriş'e yönlendirir.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => context.read<AuthController>().completeOnboarding(),
          child: const Text('Başla'),
        ),
      ),
    );
  }
}
