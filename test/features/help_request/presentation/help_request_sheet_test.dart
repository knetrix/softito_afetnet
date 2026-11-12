import 'package:afetnet/core/constants/help_type.dart';
import 'package:afetnet/core/theme/app_theme.dart';
import 'package:afetnet/features/help_request/domain/help_request_draft.dart';
import 'package:afetnet/features/help_request/presentation/sheets/help_request_sheet.dart';
import 'package:afetnet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildTestApp({
  required Widget child,
  ThemeMode mode = ThemeMode.dark,
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: mode,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('tr'), Locale('en')],
    locale: const Locale('tr'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('HelpRequestSheet (PROJECT_NEW.md §3.2, Kural 1)', () {
    testWidgets('form tür seçilmeden açılır, Gönder kapalıdır', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showHelpRequestSheet(context),
              child: const Text('Aç'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      expect(find.text('Yardım Çağrısı Ekle'), findsOneWidget);
      expect(find.text('Öncelik Seviyesi'), findsOneWidget);
      // Yanlışlıkla kritik çağrı gönderilmesin diye tür seçili gelmez.
      expect(find.text('KRİTİK'), findsNothing);
      expect(find.text('İhtiyaç türünü seçin'), findsOneWidget);
      final submit = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Gönder'),
      );
      expect(submit.onPressed, isNull);
      expect(find.text('İhtiyaç Türü'), findsOneWidget);
      expect(find.text('Etkilenen Kişi Sayısı'), findsOneWidget);
      expect(find.text('Adres Tarifi'), findsOneWidget);
      expect(find.text('Durum Açıklaması'), findsOneWidget);
      expect(find.text('Gönder'), findsOneWidget);
    });

    testWidgets('tür seçimi değiştikçe Kural 1 öncelik rozeti anlık güncellenir', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showHelpRequestSheet(context),
              child: const Text('Aç'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      // Enkaz Altında -> KRİTİK (1)
      await tester.tap(find.text('Enkaz Altında'));
      await tester.pumpAndSettle();
      expect(find.text('KRİTİK'), findsOneWidget);

      // Barınma seç -> ACİL (2)
      await tester.tap(find.text('Barınma'));
      await tester.pumpAndSettle();
      expect(find.text('ACİL'), findsOneWidget);

      // Su seç -> NORMAL (3)
      await tester.ensureVisible(find.text('Su'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Su'));
      await tester.pumpAndSettle();
      expect(find.text('NORMAL'), findsOneWidget);

      // Tıbbi Müdahale seç -> KRİTİK (1)
      await tester.tap(find.text('Tıbbi Müdahale'));
      await tester.pumpAndSettle();
      expect(find.text('KRİTİK'), findsOneWidget);

      // Bebek Maması seç -> ACİL (2)
      await tester.tap(find.text('Bebek Maması'));
      await tester.pumpAndSettle();
      expect(find.text('ACİL'), findsOneWidget);
    });

    testWidgets('kişi sayısı artırma ve azaltma stepper doğru çalışır', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showHelpRequestSheet(context),
              child: const Text('Aç'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);

      // 1 iken azalt butonu basılsa da 1'de kalır
      await tester.tap(find.byTooltip('Azalt'));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      // Artır
      await tester.tap(find.byTooltip('Artır'));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byTooltip('Artır'));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);

      // Azalt
      await tester.tap(find.byTooltip('Azalt'));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('gönderildiğinde form verileri HelpRequestDraft olarak döner', (tester) async {
      HelpRequestDraft? result;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showHelpRequestSheet(context);
              },
              child: const Text('Aç'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      // Isınma seç (Öncelik 2)
      await tester.tap(find.text('Isınma'));
      await tester.pumpAndSettle();

      // Kişi sayısını 4 yap
      await tester.tap(find.byTooltip('Artır'));
      await tester.tap(find.byTooltip('Artır'));
      await tester.tap(find.byTooltip('Artır'));
      await tester.pumpAndSettle();

      // Adres ve açıklama doldur
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Adres Tarifi'),
        'Atatürk Caddesi No: 42 Kat: 3',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Durum Açıklaması'),
        'Hava çok soğuk, battaniye ve ısıtıcı gerekli.',
      );
      await tester.pumpAndSettle();

      // Gönder
      final submitFinder = find.widgetWithText(ElevatedButton, 'Gönder');
      await tester.ensureVisible(submitFinder);
      await tester.pumpAndSettle();
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.type, HelpType.heating);
      expect(result!.priority, 2);
      expect(result!.peopleCount, 4);
      expect(result!.addressText, 'Atatürk Caddesi No: 42 Kat: 3');
      expect(result!.description, 'Hava çok soğuk, battaniye ve ısıtıcı gerekli.');
    });

    testWidgets('onSubmit callback ile gönderildiğinde başarı snackbarı gösterir', (tester) async {
      HelpRequestDraft? submittedDraft;

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showHelpRequestSheet(
                  context,
                  onSubmit: (draft) async {
                    submittedDraft = draft;
                    return true;
                  },
                );
              },
              child: const Text('Aç'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enkaz Altında'));
      await tester.pumpAndSettle();

      final submitFinder = find.widgetWithText(ElevatedButton, 'Gönder');
      await tester.ensureVisible(submitFinder);
      await tester.pumpAndSettle();
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(submittedDraft, isNotNull);
      expect(submittedDraft!.type, HelpType.debris);
      expect(submittedDraft!.priority, 1);
      expect(find.text('Yardım çağrınız alındı.'), findsOneWidget);
    });

    testWidgets('gönderim hata verirse buton takılmaz, hata mesajı gösterilir', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showHelpRequestSheet(
                context,
                onSubmit: (_) async => throw StateError('index yok'),
              ),
              child: const Text('Aç'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Su'));
      await tester.pumpAndSettle();
      final submitFinder = find.widgetWithText(ElevatedButton, 'Gönder');
      await tester.ensureVisible(submitFinder);
      await tester.pumpAndSettle();
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      // Form açık kalır, buton yeniden basılabilir, hata mesajı görünür.
      expect(find.text('Yardım Çağrısı Ekle'), findsOneWidget);
      expect(tester.widget<ElevatedButton>(submitFinder).onPressed, isNotNull);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('360x640 ekranda taşma olmadan çalışır', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        _buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showHelpRequestSheet(context),
              child: const Text('Aç'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Yardım Çağrısı Ekle'), findsOneWidget);
    });
  });
}
