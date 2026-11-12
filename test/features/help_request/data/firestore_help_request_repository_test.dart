import 'package:afetnet/core/constants/case_status.dart';
import 'package:afetnet/core/constants/help_type.dart';
import 'package:afetnet/features/help_request/data/firestore_help_request_repository.dart';
import 'package:afetnet/features/help_request/domain/help_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

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

    test('pickMatchingIncident yalnızca açık ve 50 m içindeki olayı seçer', () {
      const p = GeoPoint(36.2023, 36.1604);
      // Mesafe: id'nin sonundaki sayı (metre).
      double byId(double _, double _, double lat, double _) => lat;
      (String, Map<String, dynamic>) incident(String id, bool open, double m) =>
          (id, {'isOpen': open, 'location': GeoPoint(m, 0)});

      expect(
        FirestoreHelpRequestRepository.pickMatchingIncident(
          p,
          [incident('kapali-10', false, 10), incident('uzak-55', true, 55), incident('acik-45', true, 45)],
          byId,
        ),
        'acik-45',
      );
      expect(
        FirestoreHelpRequestRepository.pickMatchingIncident(
          p,
          [incident('kapali-10', false, 10), incident('uzak-51', true, 51)],
          byId,
        ),
        isNull,
      );
      expect(
        FirestoreHelpRequestRepository.pickMatchingIncident(
          p,
          [incident('sinir-50', true, 50)],
          byId,
        ),
        'sinir-50',
      );
    });

    test('latestActive çözülmüş/iptal çağrıları atlar, en yenisini seçer', () {
      HelpRequest req(String id, CaseStatus status, int hour) => HelpRequest(
            id: id,
            createdBy: 'u1',
            type: HelpType.water,
            priority: 3,
            status: status,
            peopleCount: 1,
            location: const LatLng(36.2, 36.16),
            geohash: 'sy3tyy6u',
            createdAt: DateTime(2026, 11, 12, hour),
          );

      expect(
        FirestoreHelpRequestRepository.latestActive([
          req('eski', CaseStatus.pending, 9),
          req('yeni-iptal', CaseStatus.cancelled, 12),
          req('orta', CaseStatus.assigned, 10),
          req('kurtarildi', CaseStatus.resolved, 11),
        ])?.id,
        'orta',
      );
      expect(
        FirestoreHelpRequestRepository.latestActive([
          req('iptal', CaseStatus.cancelled, 9),
        ]),
        isNull,
      );
    });
  });
}
