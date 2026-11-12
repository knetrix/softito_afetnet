import 'dart:async';

import 'package:afetnet/features/assembly_points/domain/assembly_point.dart';
import 'package:afetnet/features/assembly_points/domain/assembly_point_type.dart';
import 'package:afetnet/features/assembly_points/domain/assembly_points_repository.dart';
import 'package:afetnet/features/assembly_points/domain/assembly_service.dart';
import 'package:afetnet/features/assembly_points/presentation/assembly_points_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class _FakeAssemblyPointsRepository implements AssemblyPointsRepository {
  final _streamController = StreamController<List<AssemblyPoint>>.broadcast();

  @override
  Stream<List<AssemblyPoint>> watchAssemblyPoints() => _streamController.stream;

  @override
  Future<List<AssemblyPoint>> getAssemblyPoints() async => [];

  void emit(List<AssemblyPoint> list) => _streamController.add(list);

  void close() => _streamController.close();
}

void main() {
  group('AssemblyPointsController', () {
    late _FakeAssemblyPointsRepository repo;

    final p1 = AssemblyPoint(
      id: 'p1',
      name: 'Nokta 1 - Çok Yakın',
      type: AssemblyPointType.assembly,
      location: const LatLng(36.2001, 36.1601),
      geohash: 'sy72wxy1',
      capacity: 1000,
      currentCount: 300,
      services: const [AssemblyService.water],
      isOpen: true,
      updatedAt: DateTime.now(),
    );

    final p2 = AssemblyPoint(
      id: 'p2',
      name: 'Nokta 2 - Orta Uzak',
      type: AssemblyPointType.fieldHospital,
      location: const LatLng(36.2050, 36.1650),
      geohash: 'sy72wxy2',
      capacity: 500,
      currentCount: 400,
      services: const [AssemblyService.health],
      isOpen: true,
      updatedAt: DateTime.now(),
    );

    final p3 = AssemblyPoint(
      id: 'p3',
      name: 'Nokta 3 - Uzak',
      type: AssemblyPointType.shelter,
      location: const LatLng(36.2100, 36.1700),
      geohash: 'sy72wxy3',
      capacity: 1500,
      currentCount: 1200,
      services: const [AssemblyService.tent],
      isOpen: true,
      updatedAt: DateTime.now(),
    );

    final p4 = AssemblyPoint(
      id: 'p4',
      name: 'Nokta 4 - En Uzak',
      type: AssemblyPointType.assembly,
      location: const LatLng(36.2500, 36.2000),
      geohash: 'sy72wxy4',
      capacity: 2000,
      currentCount: 500,
      services: const [AssemblyService.water, AssemblyService.food],
      isOpen: true,
      updatedAt: DateTime.now(),
    );

    setUp(() {
      repo = _FakeAssemblyPointsRepository();
    });

    tearDown(() {
      repo.close();
    });

    test('watchAssemblyPoints verilerini dinler ve listeler', () async {
      final ctrl = AssemblyPointsController(
        repository: repo,
        initialUserLocation: const LatLng(36.2000, 36.1600),
      );
      addTearDown(ctrl.dispose);

      repo.emit([p1, p2, p3, p4]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(ctrl.points.length, 4);
      expect(ctrl.isLoading, isFalse);
    });

    test('filteredPoints kullanıcı konumuna göre mesafeye göre sıralanır', () async {
      final ctrl = AssemblyPointsController(
        repository: repo,
        initialUserLocation: const LatLng(36.2000, 36.1600),
      );
      addTearDown(ctrl.dispose);

      repo.emit([p4, p3, p1, p2]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final sorted = ctrl.filteredPoints;
      expect(sorted.first.id, 'p1');
      expect(sorted[1].id, 'p2');
      expect(sorted[2].id, 'p3');
      expect(sorted.last.id, 'p4');
    });

    test('nearestThreePoints ilk 3 en yakın alanı döndürür (PROJECT_NEW.md 5. Madde)', () async {
      final ctrl = AssemblyPointsController(
        repository: repo,
        initialUserLocation: const LatLng(36.2000, 36.1600),
      );
      addTearDown(ctrl.dispose);

      repo.emit([p1, p2, p3, p4]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final top3 = ctrl.nearestThreePoints;
      expect(top3.length, 3);
      expect(top3.map((e) => e.id), ['p1', 'p2', 'p3']);
    });

    test('setFilter tür filtresine göre listeyi süzer', () async {
      final ctrl = AssemblyPointsController(
        repository: repo,
        initialUserLocation: const LatLng(36.2000, 36.1600),
      );
      addTearDown(ctrl.dispose);

      repo.emit([p1, p2, p3, p4]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      ctrl.setFilter(AssemblyPointType.fieldHospital);
      expect(ctrl.filteredPoints.length, 1);
      expect(ctrl.filteredPoints.first.id, 'p2');

      ctrl.setFilter(null);
      expect(ctrl.filteredPoints.length, 4);
    });

    test('buildNavigationUrl geçerli google maps yönlendirme linki üretir', () {
      final url = AssemblyPointsController.buildNavigationUrl(p1);
      expect(url, contains('google.com/maps/dir/'));
      expect(url, contains('destination=36.2001,36.1601'));
    });
  });
}
