// "domain" katmanı: ekip ve görev işlemlerinin sözleşmesi (arayüz) ve görev hataları.

import '../../../core/constants/case_status.dart';
import '../../live_feed/domain/incident.dart';
import 'assignment.dart';
import 'team.dart';

/// Ekipler (Y2) ve görev akışı repository arayüzü.
abstract interface class TeamsRepository {
  /// Tüm ekipler (`teams`), canlı.
  Stream<List<Team>> watchTeams();

  /// Bitmemiş görevler (`assigned`, `enRoute`, `onSite`), canlı.
  Stream<List<Assignment>> watchActiveAssignments();

  /// [team]'i [incident]'e atar. `assignments` belgesi oluşturulur; olay,
  /// bağlı açık çağrılar ve ekip aynı atomik yazımda güncellenir.
  ///
  /// Olay kapanmışsa, olayda zaten aktif görev varsa veya ekip boşta
  /// değilse [AssignmentException] fırlatır.
  Future<void> assignTeam({
    required Incident incident,
    required Team team,
    required String officialUid,
  });

  /// [assignment]'ı bir sonraki adıma taşır (geri adım yoktur). `resolved`
  /// adımında olay kapanır ve ekip yeniden boşta olur.
  Future<CaseStatus> advanceAssignment({
    required Assignment assignment,
    required String officialUid,
  });
}

/// Görev atama / güncelleme reddedildiğinde fırlatılır.
class AssignmentException implements Exception {
  const AssignmentException(this.reason);

  final AssignmentFailure reason;

  // Nesneyi hata ayıklarken (print/log) okunabilir bir metne çevirir.
  @override
  String toString() => 'AssignmentException($reason)';
}

// Görev atama/güncelleme hata nedenleri.
enum AssignmentFailure {
  /// Olay kapanmış veya bulunamadı.
  incidentClosed,

  /// Olayda zaten aktif bir görev var (tek aktif görev).
  incidentAlreadyAssigned,

  /// Ekip boşta değil veya bulunamadı.
  teamBusy,

  /// Görev bitmiş veya başka biri tarafından ilerletilmiş.
  invalidTransition,
}
