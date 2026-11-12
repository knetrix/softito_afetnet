import 'package:afetnet/features/assembly_points/domain/assembly_point.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afetnet/features/assembly_points/domain/assembly_point_type.dart';
import 'package:afetnet/features/assembly_points/domain/assembly_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('AssemblyPoint Entity', () {
    final samplePoint = AssemblyPoint(
      id: 'ap_1',
      name: 'Atatürk Parkı',
      type: AssemblyPointType.assembly,
      location: const LatLng(36.2000, 36.1600),
      geohash: 'sy72wxyz',
      capacity: 1000,
      currentCount: 650,
      services: const [
        AssemblyService.water,
        AssemblyService.food,
        AssemblyService.tent,
      ],
      isOpen: true,
      updatedAt: DateTime(2026, 11, 12, 10, 0),
      description: 'Geniş toplanma alanı',
    );

    test('occupancyRate ve occupancyPercentage doğru hesaplanır', () {
      expect(samplePoint.occupancyRate, closeTo(0.65, 0.01));
      expect(samplePoint.occupancyPercentage, 65);

      final fullPoint = samplePoint.copyWith(currentCount: 1200);
      expect(fullPoint.occupancyRate, 1.0);
      expect(fullPoint.occupancyPercentage, 100);

      final zeroCapacity = samplePoint.copyWith(capacity: 0);
      expect(zeroCapacity.occupancyRate, 0.0);
      expect(zeroCapacity.occupancyPercentage, 0);
    });

    test('distanceInMeters ve formatDistance doğru sonuç verir', () {
      // Çok yakın bir nokta (~100-200m)
      const nearPos = LatLng(36.2010, 36.1610);
      final distMeters = samplePoint.distanceInMeters(nearPos);
      expect(distMeters, greaterThan(50));
      expect(distMeters, lessThan(500));
      expect(samplePoint.formatDistance(nearPos), endsWith(' m'));

      // Uzak bir nokta (> 1 km)
      const farPos = LatLng(36.2500, 36.2000);
      expect(samplePoint.formatDistance(farPos), endsWith(' km'));
    });

    test('fromJson ve toJson serileştirme doğruluğu', () {
      final json = samplePoint.toJson();
      final restored = AssemblyPoint.fromJson('ap_1', json);

      expect(restored.id, samplePoint.id);
      expect(restored.name, samplePoint.name);
      expect(restored.type, samplePoint.type);
      expect(restored.capacity, samplePoint.capacity);
      expect(restored.currentCount, samplePoint.currentCount);
      expect(restored.services, contains(AssemblyService.water));
      expect(restored.isOpen, samplePoint.isOpen);
    });
  });

  test('konumu olmayan belge atlanır, bilinmeyen hizmet gösterilmez', () {
    expect(AssemblyPoint.tryFromJson('x', {'name': 'Konumsuz'}), isNull);
    final p = AssemblyPoint.tryFromJson('y', {
      'name': 'Nokta',
      'location': const GeoPoint(36.2, 36.16),
      'services': ['water', 'wifi'],
    });
    expect(p, isNotNull);
    expect(p!.services, [AssemblyService.water]);
  });
}
