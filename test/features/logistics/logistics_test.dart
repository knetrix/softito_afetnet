import 'package:afetnet/core/theme/app_theme.dart';
import 'package:afetnet/features/logistics/domain/inventory_item.dart';
import 'package:afetnet/features/logistics/domain/logistics_repository.dart';
import 'package:afetnet/features/logistics/presentation/widgets/stock_movement_sheet.dart';
import 'package:afetnet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

InventoryItem item({int quantity = 70, int target = 200, int critical = 25}) =>
    InventoryItem(
      id: 'water',
      name: 'İçme Suyu',
      unit: 'koli',
      category: 'water',
      quantity: quantity,
      targetLevel: target,
      criticalLevel: critical,
    );

Widget _wrap(Widget child, {Locale locale = const Locale('tr')}) => MaterialApp(
  theme: AppTheme.light(),
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('stok etiketi', () {
    test('quantity <= criticalLevel → Kritik', () {
      expect(item(quantity: 25).level, StockLevel.critical);
      expect(item(quantity: 20).level, StockLevel.critical);
    });

    test('quantity < targetLevel × 0.5 → Orta', () {
      expect(item(quantity: 26).level, StockLevel.medium);
      expect(item(quantity: 99).level, StockLevel.medium);
    });

    test('diğer → Yeterli', () {
      expect(item(quantity: 100).level, StockLevel.sufficient);
    });

    test('stok düzeyi % en fazla %100', () {
      expect(item(quantity: 50).ratio, 0.25);
      expect(item(quantity: 400).ratio, 1.0);
    });
  });

  group('Stok giriş/çıkış sheet\'i', () {
    testWidgets('stoktan fazla çıkış reddedilir, kaydedilmez', (tester) async {
      var saved = false;
      await tester.pumpWidget(
        _wrap(
          StockMovementSheet(
            item: item(quantity: 8, critical: 2),
            onSave: (_, _) async => saved = true,
          ),
        ),
      );
      await tester.tap(find.text('Çıkış'));
      await tester.enterText(find.byType(TextFormField), '20');
      await tester.tap(find.text('Stok Çıkışı Yap'));
      await tester.pump();

      expect(find.text('Yetersiz stok.'), findsOneWidget);
      expect(saved, isFalse);
    });

    testWidgets(
      'Transaction eksi stoğu reddederse (başkası düşmüş) hata gösterilir',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            StockMovementSheet(
              item: item(),
              onSave: (_, _) async => throw const InsufficientStockException(),
            ),
          ),
        );
        await tester.tap(find.text('Çıkış'));
        await tester.enterText(find.byType(TextFormField), '50');
        await tester.tap(find.text('Stok Çıkışı Yap'));
        await tester.pumpAndSettle();

        expect(find.text('Yetersiz stok.'), findsOneWidget);
      },
    );

    testWidgets('İngilizcede Türkçe metin kalmaz', (tester) async {
      await tester.pumpWidget(
        _wrap(
          StockMovementSheet(item: item(), onSave: (_, _) async {}),
          locale: const Locale('en'),
        ),
      );
      expect(find.text('Stock Movement'), findsOneWidget);
      expect(find.text('In'), findsOneWidget);
      expect(find.text('Out'), findsOneWidget);
      expect(find.text('Current Stock'), findsOneWidget);
      expect(find.text('Record Stock In'), findsOneWidget);
      expect(find.textContaining('Stok'), findsNothing);
    });
  });
}
