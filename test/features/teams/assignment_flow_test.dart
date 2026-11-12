import 'package:afetnet/core/constants/case_status.dart';
import 'package:afetnet/features/teams/data/firestore_teams_repository.dart';
import 'package:afetnet/features/teams/domain/assignment.dart';
import 'package:afetnet/features/teams/domain/team.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssignmentFlow — Kural 6 (görev durumu)', () {
    test(
      'adımlar Atandı → Yola Çıktı → Olay Yerinde → Kurtarıldı sırasındadır',
      () {
        expect(AssignmentFlow.steps, [
          CaseStatus.assigned,
          CaseStatus.enRoute,
          CaseStatus.onSite,
          CaseStatus.resolved,
        ]);
      },
    );

    test('next yalnızca bir ileri adım verir', () {
      expect(AssignmentFlow.next(CaseStatus.assigned), CaseStatus.enRoute);
      expect(AssignmentFlow.next(CaseStatus.enRoute), CaseStatus.onSite);
      expect(AssignmentFlow.next(CaseStatus.onSite), CaseStatus.resolved);
    });

    test('Kurtarıldı ve görev dışı durumlardan ilerlenemez', () {
      expect(AssignmentFlow.next(CaseStatus.resolved), isNull);
      expect(AssignmentFlow.next(CaseStatus.pending), isNull);
      expect(AssignmentFlow.next(CaseStatus.cancelled), isNull);
    });

    test('geri adım ve adım atlama geçersizdir', () {
      expect(
        AssignmentFlow.canMove(CaseStatus.assigned, CaseStatus.enRoute),
        isTrue,
      );
      expect(
        AssignmentFlow.canMove(CaseStatus.onSite, CaseStatus.enRoute),
        isFalse,
      );
      expect(
        AssignmentFlow.canMove(CaseStatus.resolved, CaseStatus.onSite),
        isFalse,
      );
      expect(
        AssignmentFlow.canMove(CaseStatus.assigned, CaseStatus.onSite),
        isFalse,
      );
      expect(
        AssignmentFlow.canMove(CaseStatus.assigned, CaseStatus.resolved),
        isFalse,
      );
    });

    test('isActive: Kurtarıldı ve görev dışı durumlar aktif değildir', () {
      expect(AssignmentFlow.isActive(CaseStatus.assigned), isTrue);
      expect(AssignmentFlow.isActive(CaseStatus.onSite), isTrue);
      expect(AssignmentFlow.isActive(CaseStatus.resolved), isFalse);
      expect(AssignmentFlow.isActive(CaseStatus.cancelled), isFalse);
    });
  });

  group('FirestoreTeamsRepository dönüşümleri', () {
    test('teamFromMap tüm alanları okur', () {
      final team = FirestoreTeamsRepository.teamFromMap('t1', {
        'name': 'Sağlık Ekibi 1',
        'type': 'medical',
        'leaderName': 'Dr. Deniz',
        'memberCount': 5,
        'status': 'onDuty',
        'location': const GeoPoint(36.2, 36.1),
        'locationText': 'Sahra Hastanesi',
        'currentTask': 'inc9',
      });
      expect(team.name, 'Sağlık Ekibi 1');
      expect(team.type, TeamType.medical);
      expect(team.status, TeamStatus.onDuty);
      expect(team.isAvailable, isFalse);
      expect(team.memberCount, 5);
      expect(team.location?.latitude, 36.2);
      expect(team.currentTask, 'inc9');
    });

    test(
      'teamFromMap eksik / bilinmeyen değerlerde güvenli varsayılan kullanır',
      () {
        final team = FirestoreTeamsRepository.teamFromMap('t2', {
          'type': 'xyz',
        });
        expect(team.name, 't2');
        expect(team.type, TeamType.searchRescue);
        expect(team.status, TeamStatus.available);
        expect(team.location, isNull);
      },
    );

    test('assignmentFromMap zorunlu alan yoksa kaydı atlar', () {
      final a = FirestoreTeamsRepository.assignmentFromMap('a1', {
        'incidentId': 'inc1',
        'teamId': 't1',
        'status': 'enRoute',
        'assignedBy': 'off1',
      });
      expect(a?.status, CaseStatus.enRoute);
      expect(a?.nextStatus, CaseStatus.onSite);

      expect(
        FirestoreTeamsRepository.assignmentFromMap('a2', {'teamId': 't1'}),
        isNull,
      );
    });
  });
}
