import 'package:afetnet/core/constants/case_status.dart';
import 'package:afetnet/core/constants/help_type.dart';
import 'package:afetnet/features/live_feed/data/firestore_live_feed_repository.dart';
import 'package:afetnet/features/safety_signal/domain/safety_signal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirestoreLiveFeedRepository dönüşümleri', () {
    test('incidentFromMap olay alanlarını okur', () {
      final created = DateTime(2026, 11, 12, 9, 30);
      final i = FirestoreLiveFeedRepository.incidentFromMap('inc1', {
        'location': const GeoPoint(36.2, 36.1),
        'geohash': 'sy3tyy6u',
        'type': 'medical',
        'priority': 1,
        'requestCount': 3,
        'primaryRequestId': 'req1',
        'status': 'enRoute',
        'isOpen': true,
        'assignedTeamId': 't1',
        'createdAt': Timestamp.fromDate(created),
      })!;
      expect(i.type, HelpType.medical);
      expect(i.priority, 1);
      expect(i.requestCount, 3);
      expect(i.status, CaseStatus.enRoute);
      expect(i.isOpen, isTrue);
      expect(i.assignedTeamId, 't1');
      expect(i.canBeClosedDirectly, isFalse);
      expect(i.createdAt, created);
    });

    test('incidentFromMap konumsuz kaydı atlar', () {
      expect(
        FirestoreLiveFeedRepository.incidentFromMap('x', {'priority': 1}),
        isNull,
      );
    });

    test('signalFromMap ulaşıldı bilgisini okur', () {
      final s = FirestoreLiveFeedRepository.signalFromMap('u1', {
        'state': 'danger',
        'location': const GeoPoint(36.2, 36.1),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 11, 12)),
        'handledBy': 'off1',
      })!;
      expect(s.state, SafetySignalState.danger);
      expect(s.isHandled, isTrue);
    });

    test('isOpenRequest: iptal ve çözülmüş çağrıya dokunulmaz', () {
      expect(
        FirestoreLiveFeedRepository.isOpenRequest({'status': 'pending'}),
        isTrue,
      );
      expect(
        FirestoreLiveFeedRepository.isOpenRequest({'status': 'onSite'}),
        isTrue,
      );
      expect(
        FirestoreLiveFeedRepository.isOpenRequest({'status': 'cancelled'}),
        isFalse,
      );
      expect(
        FirestoreLiveFeedRepository.isOpenRequest({'status': 'resolved'}),
        isFalse,
      );
      expect(FirestoreLiveFeedRepository.isOpenRequest(null), isFalse);
    });
  });
}
