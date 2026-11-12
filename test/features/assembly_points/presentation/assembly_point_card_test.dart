import 'package:afetnet/core/theme/app_theme.dart';
import 'package:afetnet/features/assembly_points/domain/assembly_point.dart';
import 'package:afetnet/features/assembly_points/domain/assembly_point_type.dart';
import 'package:afetnet/features/assembly_points/domain/assembly_service.dart';
import 'package:afetnet/features/assembly_points/presentation/widgets/assembly_point_card.dart';
import 'package:afetnet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

Widget _buildCard({
  required AssemblyPoint point,
  LatLng? userLocation,
  VoidCallback? onClose,
  void Function(AssemblyPoint)? onGetDirections,
  bool isNearest = false,
  double textScale = 1.0,
}) {
  return MaterialApp(
    theme: AppTheme.dark(),
    locale: const Locale('tr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
      ),
      child: child!,
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AssemblyPointCard(
          point: point,
          userLocation: userLocation,
          onClose: onClose,
          isNearest: isNearest,
          onGetDirections: onGetDirections ?? (_) {},
        ),
      ),
    ),
  );
}

void main() {
  final samplePoint = AssemblyPoint(
    id: 'ap_1',
    name: 'Antakya Atatürk Parkı Toplanma Alanı',
    type: AssemblyPointType.assembly,
    description: 'Temiz su tankeri ve sahra mutfağı mevcut.',
    location: const LatLng(36.2025, 36.1610),
    geohash: 'sy72wxy1',
    capacity: 2500,
    currentCount: 850,
    services: const [
      AssemblyService.water,
      AssemblyService.food,
      AssemblyService.tent,
    ],
    isOpen: true,
    updatedAt: DateTime.now(),
  );

  testWidgets('AssemblyPointCard nokta detaylarını, doluluk ve hizmetleri eksiksiz gösterir', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildCard(
        point: samplePoint,
        userLocation: const LatLng(36.2000, 36.1600),
        isNearest: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Antakya Atatürk Parkı Toplanma Alanı'), findsOneWidget);
    expect(find.text('Toplanma Alanı'), findsOneWidget);
    expect(find.text('Açık'), findsOneWidget);
    expect(find.text('En Yakın'), findsOneWidget);
    expect(find.textContaining('Doluluk: %34'), findsOneWidget);
    expect(find.text('850 / 2500 Kişi'), findsOneWidget);
    expect(find.text('Temiz Su'), findsOneWidget);
    expect(find.text('Sıcak Yemek'), findsOneWidget);
    expect(find.text('Barınma'), findsOneWidget);
    expect(find.text('Yol Tarifi Al'), findsOneWidget);
  });

  testWidgets('AssemblyPointCard Yol Tarifi butonuna basıldığında callback tetiklenir', (tester) async {
    AssemblyPoint? directedPoint;

    await tester.pumpWidget(
      _buildCard(
        point: samplePoint,
        onGetDirections: (pt) => directedPoint = pt,
      ),
    );
    await tester.pumpAndSettle();

    final btn = find.text('Yol Tarifi Al');
    await tester.tap(btn);
    await tester.pumpAndSettle();

    expect(directedPoint?.id, 'ap_1');
  });

  testWidgets('AssemblyPointCard 360x640 ve 1.3x metin ölçeğinde taşma olmadan çizilir', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildCard(
        point: samplePoint,
        userLocation: const LatLng(36.2000, 36.1600),
        isNearest: true,
        textScale: 1.3,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
