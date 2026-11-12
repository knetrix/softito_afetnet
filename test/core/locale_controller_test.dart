import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:afetnet/core/services/locale_controller.dart';
import 'package:afetnet/core/widgets/language_selector.dart';
import 'package:afetnet/l10n/app_localizations.dart';

void main() {
  setUp(() => LocaleController.current = LocaleController.turkish);

  test('kayıtlı seçim yoksa cihaz dili ne olursa olsun Türkçe', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = LocaleController();
    await controller.load();
    expect(controller.locale, LocaleController.turkish);
  });

  test('İngilizce seçimi saklanır ve sonraki açılışta yüklenir', () async {
    SharedPreferences.setMockInitialValues({});
    await LocaleController().setLocale(LocaleController.english);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocaleController.prefsKey), 'en');

    LocaleController.current = LocaleController.turkish;
    final reopened = LocaleController();
    await reopened.load();
    expect(reopened.locale, LocaleController.english);
    expect(LocaleController.current, LocaleController.english);
  });

  testWidgets('Profil seçicisi uygulama dilini değiştirir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = LocaleController();
    await controller.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: ListenableBuilder(
          listenable: controller,
          builder: (_, _) => MaterialApp(
            locale: controller.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: LanguageSelector()),
          ),
        ),
      ),
    );
    expect(find.text('Dil'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(controller.locale, LocaleController.english);
  });
}
