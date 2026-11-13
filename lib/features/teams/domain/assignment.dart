// Görev ataması modeli ve ileri-yönlü durum akışı.

import 'package:flutter/foundation.dart';

import '../../../core/constants/case_status.dart';

/// `assignments/{assignmentId}` belgesinin domain modeli (PROJECT_NEW.md §5.3).
///
/// `status` yalnızca `assigned`, `enRoute`, `onSite`, `resolved` değerlerini
/// alır (Kural 6).
@immutable
class Assignment {
  const Assignment({
    required this.id,
    required this.incidentId,
    required this.teamId,
    required this.status,
    required this.assignedBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String incidentId;
  final String teamId;
  final CaseStatus status;
  final String assignedBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => AssignmentFlow.isActive(status);

  /// Bir sonraki adım; görev bittiyse `null`.
  CaseStatus? get nextStatus => AssignmentFlow.next(status);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Assignment &&
          other.id == id &&
          other.incidentId == incidentId &&
          other.teamId == teamId &&
          other.status == status;

  @override
  int get hashCode => Object.hash(id, incidentId, teamId, status);
}

/// Görev durumu akışı (PROJECT_NEW.md §4 Kural 6).
///
/// `assigned → enRoute → onSite → resolved`; geri adım ve atlama yoktur.
abstract final class AssignmentFlow {
  /// Görev durumlarının sırası.
  static const steps = [
    CaseStatus.assigned,
    CaseStatus.enRoute,
    CaseStatus.onSite,
    CaseStatus.resolved,
  ];

  /// Görevde hâlâ iş varsa (`resolved` değilse) `true`.
  static bool isActive(CaseStatus status) =>
      steps.contains(status) && status != CaseStatus.resolved;

  /// [current]'tan sonraki adım. `resolved`'dan veya görev dışı bir
  /// durumdan (`pending`, `cancelled`) ilerlenemez: `null` döner.
  static CaseStatus? next(CaseStatus current) {
    final i = steps.indexOf(current);
    if (i < 0 || i == steps.length - 1) return null;
    return steps[i + 1];
  }

  /// [from]'dan [to]'ya geçiş yalnızca tam bir ileri adımsa geçerlidir.
  static bool canMove(CaseStatus from, CaseStatus to) => next(from) == to;
}
