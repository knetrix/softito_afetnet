import 'dart:async';

import 'package:afetnet/core/constants/case_status.dart';
import 'package:afetnet/core/constants/help_type.dart';
import 'package:afetnet/features/live_feed/domain/incident.dart';
import 'package:afetnet/features/live_feed/domain/incident_summary.dart';
import 'package:afetnet/features/live_feed/domain/live_feed_repository.dart';
import 'package:afetnet/features/safety_signal/domain/safety_signal.dart';
import 'package:afetnet/features/teams/domain/assignment.dart';
import 'package:afetnet/features/teams/domain/team.dart';
import 'package:afetnet/features/teams/domain/teams_repository.dart';
import 'package:latlong2/latlong.dart';

// Yalnızca test verisi; uygulamada uydurma kayıt yoktur (veri Firestore'dan gelir).

Incident testIncident({
  String id = 'inc1',
  int priority = 1,
  HelpType type = HelpType.debris,
  String? assignedTeamId,
  CaseStatus status = CaseStatus.pending,
  int requestCount = 1,
  LatLng location = const LatLng(36.2025, 36.1610),
}) => Incident(
  id: id,
  location: location,
  geohash: 'sy3tyy6u',
  type: type,
  priority: priority,
  requestCount: requestCount,
  primaryRequestId: 'req-$id',
  status: status,
  isOpen: true,
  createdAt: DateTime(2026, 11, 12, 10),
  assignedTeamId: assignedTeamId,
);

Team testTeam({
  String id = 't1',
  String name = 'Arama Kurtarma Tim 4',
  TeamStatus status = TeamStatus.available,
  TeamType type = TeamType.searchRescue,
  LatLng? location = const LatLng(36.21, 36.16),
  String? currentTask,
  int memberCount = 6,
}) => Team(
  id: id,
  name: name,
  type: type,
  leaderName: 'Ayşe K.',
  memberCount: memberCount,
  status: status,
  location: location,
  locationText: 'Merkez Park',
  currentTask: currentTask,
);

SafetySignal testSignal({
  String uid = 'u1',
  DateTime? updatedAt,
  String? handledBy,
}) => SafetySignal(
  uid: uid,
  state: SafetySignalState.danger,
  location: const LatLng(36.20, 36.15),
  geohash: 'sy3tyy00',
  updatedAt: updatedAt ?? DateTime(2026, 11, 12, 10),
  handledBy: handledBy,
);

class FakeLiveFeedRepository implements LiveFeedRepository {
  final incidents = StreamController<List<Incident>>.broadcast();
  final signals = StreamController<List<SafetySignal>>.broadcast();
  final Map<String, IncidentSummary> summaries = {};
  final List<String> closed = [];
  final List<(String, String)> handled = [];
  bool closeResult = true;

  @override
  Stream<List<Incident>> watchOpenIncidents() => incidents.stream;

  @override
  Stream<List<SafetySignal>> watchDangerSignals() => signals.stream;

  @override
  Future<IncidentSummary> fetchSummary(Incident incident) async =>
      summaries[incident.id] ?? const IncidentSummary();

  IncidentDetail detail = const IncidentDetail(
    fullName: 'Test Kişi',
    phone: '+905321234567',
  );

  @override
  Future<IncidentDetail> fetchDetail(Incident incident) async => detail;

  @override
  Future<bool> closeIncident(Incident incident) async {
    closed.add(incident.id);
    return closeResult;
  }

  @override
  Future<bool> markSignalHandled({
    required String signalUid,
    required String officialUid,
  }) async {
    handled.add((signalUid, officialUid));
    return markDelivered;
  }

  /// `false`: sunucu onayı gelmedi (internet yok) gibi davranır.
  bool markDelivered = true;

  void dispose() {
    incidents.close();
    signals.close();
  }
}

class FakeTeamsRepository implements TeamsRepository {
  final teams = StreamController<List<Team>>.broadcast();
  final assignments = StreamController<List<Assignment>>.broadcast();
  final List<(String, String)> assigned = [];
  final List<String> advanced = [];

  @override
  Stream<List<Team>> watchTeams() => teams.stream;

  @override
  Stream<List<Assignment>> watchActiveAssignments() => assignments.stream;

  @override
  Future<void> assignTeam({
    required Incident incident,
    required Team team,
    required String officialUid,
  }) async => assigned.add((incident.id, team.id));

  @override
  Future<CaseStatus> advanceAssignment({
    required Assignment assignment,
    required String officialUid,
  }) async {
    advanced.add(assignment.id);
    return assignment.nextStatus!;
  }

  void dispose() {
    teams.close();
    assignments.close();
  }
}
