import 'package:afetnet/core/theme/app_theme.dart';
import 'package:afetnet/features/assembly_points/data/default_assembly_points.dart';
import 'package:afetnet/features/assembly_points/domain/assembly_point.dart';
import 'package:afetnet/features/assembly_points/domain/assembly_points_repository.dart';
import 'package:afetnet/features/assembly_points/presentation/assembly_points_controller.dart';
import 'package:afetnet/features/assembly_points/presentation/assembly_points_screen.dart';
import 'package:afetnet/features/assembly_points/presentation/widgets/assembly_point_card.dart';
import 'package:afetnet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class _FakeAssemblyRepo implements AssemblyPointsRepository {
  _FakeAssemblyRepo([List<AssemblyPoint>? points])
      : _points = points ?? DefaultAssemblyPoints.list;

  final List<AssemblyPoint> _points;

  @override
  Stream<List<AssemblyPoint>> watchAssemblyPoints() => Stream.value(_points);

  @override
  Future<List<AssemblyPoint>> getAssemblyPoints() async => _points;
}

Widget _wrapScreen({
  required AssemblyPointsController controller,
  Future<bool> Function(Uri uri)? urlLauncher,
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
    home: AssemblyPointsScreen(
      controller: controller,
      urlLauncher: urlLauncher,
      tileLayer: const SizedBox.shrink(),
    ),
  );
}

void main() {
  testWidgets('AssemblyPointsScreen harita, filtre chip’leri ve en yakın 3 alan çubuğunu açar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = _FakeAssemblyRepo();
    final ctrl = AssemblyPointsController(
      repository: repo,
      initialUserLocation: const LatLng(36.2025, 36.1610),
    );
    addTearDown(ctrl.dispose);

    await tester.pumpWidget(_wrapScreen(controller: ctrl));
    await tester.pumpAndSettle();

    // Filtre çipleri
    expect(find.text('Tümü'), findsOneWidget);
    expect(find.text('Toplanma Alanı'), findsOneWidget);
    expect(find.text('Sahra Hastanesi'), findsOneWidget);
    expect(find.text('Barınma / Çadır'), findsOneWidget);

    // En yakın 3 alan çubuğu
    expect(find.text('En Yakın 3 Alan'), findsOneWidget);
    expect(find.text('Antakya Atatürk Parkı Toplanma Alanı'), findsOneWidget);
  });

  testWidgets('AssemblyPointsScreen listeden veya haritadan bir alan seçildiğinde detay kartını gösterir ve yol tarifi açar', (tester) async {
    final repo = _FakeAssemblyRepo();
    final ctrl = AssemblyPointsController(
      repository: repo,
      initialUserLocation: const LatLng(36.2025, 36.1610),
    );
    addTearDown(ctrl.dispose);

    Uri? openedUri;
    await tester.pumpWidget(
      _wrapScreen(
        controller: ctrl,
        urlLauncher: (uri) async {
          openedUri = uri;
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    // En yakın kartlardan birine tıkla
    final cardItem = find.text('Antakya Atatürk Parkı Toplanma Alanı');
    await tester.tap(cardItem);
    await tester.pumpAndSettle();

    // Detay kartı açıldı mı?
    expect(find.byType(AssemblyPointCard), findsOneWidget);
    expect(find.text('Yol Tarifi Al'), findsOneWidget);
    expect(find.text('Temiz Su'), findsOneWidget);

    // Yol tarifi al butonuna tıkla
    await tester.tap(find.text('Yol Tarifi Al'));
    await tester.pumpAndSettle();

    expect(openedUri, isNotNull);
    expect(openedUri.toString(), contains('google.com/maps/dir/'));
  });

  testWidgets('AssemblyPointsScreen 360x640 ve 1.3x metin ölçeğinde taşma olmadan açılır', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = _FakeAssemblyRepo();
    final ctrl = AssemblyPointsController(
      repository: repo,
      initialUserLocation: const LatLng(36.2025, 36.1610),
    );
    addTearDown(ctrl.dispose);

    await tester.pumpWidget(_wrapScreen(controller: ctrl, textScale: 1.3));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
