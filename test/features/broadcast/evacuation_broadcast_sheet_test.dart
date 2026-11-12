import 'dart:async';

import 'package:afetnet/core/config/app_config.dart';
import 'package:afetnet/core/services/location_service.dart';
import 'package:afetnet/core/theme/app_theme.dart';
import 'package:afetnet/features/broadcast/domain/broadcast_repository.dart';
import 'package:afetnet/features/broadcast/presentation/evacuation_broadcast_sheet.dart';
import 'package:afetnet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class _FakeLocation extends LocationService {
  _FakeLocation(this.position);

  LatLng? position;

  @override
  LatLng? get currentPosition => position;
  @override
  String? get currentLabel => null;
  @override
  LocationStatus get status => LocationStatus.values.first;
  @override
  bool get isFetching => false;
  @override
  Future<void> loadCached() async {}
  @override
  Future<LocationSnapshot?> refresh() async => null;
  @override
  Future<LatLng?> resolveCoordinates() async => position;
}

class _FakeRepo implements BroadcastRepository {
  final sent = <Map<String, Object>>[];
  Completer<void>? hold;

  @override
  Future<void> send({
    required BroadcastType type,
    required String title,
    required String body,
    required LatLng center,
    required int radiusMeters,
    required String createdBy,
  }) async {
    sent.add({
      'type': type,
      'title': title,
      'body': body,
      'center': center,
      'radius': radiusMeters,
      'by': createdBy,
    });
    await hold?.future;
  }
}

void main() {
  late _FakeRepo repo;
  BroadcastSendResult? result;

  setUp(() {
    repo = _FakeRepo();
    result = null;
  });

  Future<void> open(
    WidgetTester tester,
    LocationService location, {
    Locale locale = const Locale('tr'),
  }) async {
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  result = await EvacuationBroadcastSheet.show(
                    context,
                    repository: repo,
                    locationService: location,
                    officialUid: 'off1',
                  ),
              child: const Text('aç'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'tür, mesaj ve yarıçapla gönderir; merkez yetkilinin konumudur (Kural 10)',
    (tester) async {
      await open(tester, _FakeLocation(const LatLng(36.2025, 36.161)));

      expect(find.text('36.20250, 36.16100'), findsOneWidget);
      await tester.tap(find.text('Artçı Sarsıntı'));
      await tester.enterText(
        find.byType(TextFormField),
        'Binalardan uzak durun',
      );
      await tester.tap(find.text('Gönder'));
      await tester.pumpAndSettle();

      expect(repo.sent, hasLength(1));
      final s = repo.sent.single;
      expect(s['type'], BroadcastType.aftershock);
      expect(s['title'], 'Artçı Sarsıntı');
      expect(s['center'], const LatLng(36.2025, 36.161));
      expect(s['radius'], 3000);
      expect(s['by'], 'off1');
      expect(result, BroadcastSendResult.sent);
    },
  );

  testWidgets('konum alınamazsa gönderilemez', (tester) async {
    await open(tester, _FakeLocation(null));

    expect(
      find.text("Konum alınamadı. Konum iznini ve GPS'i kontrol edin."),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField), 'Tahliye');
    await tester.tap(find.text('Gönder'));
    await tester.pumpAndSettle();
    expect(repo.sent, isEmpty);
  });

  testWidgets('mesaj boşsa gönderilmez', (tester) async {
    await open(tester, _FakeLocation(const LatLng(36.2, 36.16)));
    await tester.tap(find.text('Gönder'));
    await tester.pumpAndSettle();
    expect(repo.sent, isEmpty);
    expect(find.text('Bu alan zorunludur.'), findsOneWidget);
  });

  testWidgets(
    'internet yokken 10 sn sonra sheet kapanır, anons kuyrukta kalır',
    (tester) async {
      repo.hold = Completer<void>();
      await open(tester, _FakeLocation(const LatLng(36.2, 36.16)));
      await tester.enterText(find.byType(TextFormField), 'Tahliye');
      await tester.tap(find.text('Gönder'));
      await tester.pump(AppConfig.offlineTimeout + const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(result, BroadcastSendResult.queued);
      repo.hold!.complete();
    },
  );

  test('yasal sayfa adresi uygulama diline göre (§7)', () {
    expect(
      AppConfig.legalUrl(AppConfig.kvkkPage, const Locale('tr')),
      'https://afetnet-softito.web.app/legal/kvkk-tr.html',
    );
    expect(
      AppConfig.legalUrl(AppConfig.privacyPage, const Locale('de')),
      'https://afetnet-softito.web.app/legal/privacy-en.html',
    );
  });
}
