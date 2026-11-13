import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:afetnet/core/theme/app_theme.dart';
import 'package:afetnet/features/onboarding/screens/splash_screen.dart';

// Eski prototip splash'i (G2 kendi adımında features/splash/ ile değiştirir).
void main() {
  testWidgets('SplashScreen renders title, subtitle, and status text', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.darkTheme, home: const SplashScreen()));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('AfetNet'), findsOneWidget);
    expect(find.text('Canlı Kriz Yönetimi Ağı'), findsOneWidget);
    expect(find.text('AfetNet protokolü hazır.'), findsOneWidget);
  });
}
