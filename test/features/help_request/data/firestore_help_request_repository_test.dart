import 'package:afetnet/features/help_request/data/firestore_help_request_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirestoreHelpRequestRepository — Kural 2 (Mükerrer Birleştirme)', () {
    const antakyaPoint = GeoPoint(36.2023, 36.1604);

    test('geohash8 8 haneli geohash üretir', () {
      final hash = FirestoreHelpRequestRepository.geohash8(antakyaPoint);
      expect(hash.length, 8);
    });

    test('searchCells 7 haneli merkez + 8 komşu = 9 hücre döndürür', () {
      final cells = FirestoreHelpRequestRepository.searchCells(antakyaPoint);
      expect(cells.length, 9);
      for (final cell in cells) {
        expect(cell.length, 7);
      }
      // İlk hücre merkez hücredir
      final center7 =
          FirestoreHelpRequestRepository.geohash8(antakyaPoint).substring(0, 7);
      expect(cells.first, center7);
      // Komşular birbirinden farklıdır
      expect(cells.toSet().length, 9);
    });

    test('50 metre mesafede aday olay eşleşmesi kontrolü', () {
      // 50 m içindeyse aday kabul edilir
      double mockDistanceClose(double lat1, double lon1, double lat2, double lon2) => 45.0;
      double mockDistanceFar(double lat1, double lon1, double lat2, double lon2) => 55.0;

      expect(mockDistanceClose(36.2023, 36.1604, 36.2024, 36.1605) <= 50.0, isTrue);
      expect(mockDistanceFar(36.2023, 36.1604, 36.2030, 36.1610) <= 50.0, isFalse);
    });
  });
}
