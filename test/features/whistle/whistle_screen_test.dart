import 'package:afetnet/core/theme/app_theme.dart';
import 'package:afetnet/features/whistle/presentation/whistle_controller.dart';
import 'package:afetnet/features/whistle/presentation/whistle_screen.dart';
import 'package:afetnet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _WidgetFakeWhistleBackend implements WhistleAudioBackend {
  @override
  Future<void> configureAndPlayLoop(String assetPath) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  testWidgets('WhistleScreen 360x640 ve büyük yazıda beklemeden çalmaya geçer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = WhistleController(backend: _WidgetFakeWhistleBackend());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.8),
          ),
          child: child!,
        ),
        home: WhistleScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('DÜDÜK'), findsOneWidget);
    expect(find.text('BAŞLATMAK İÇİN DOKUNUN'), findsOneWidget);

    await tester.tap(find.textContaining('DÜDÜK'));
    await tester.pump();

    expect(find.textContaining('ÇALIYOR'), findsOneWidget);
    expect(find.textContaining('Siren aktif'), findsOneWidget);
    expect(find.text('DURDURMAK İÇİN TEKRAR DOKUNUN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

