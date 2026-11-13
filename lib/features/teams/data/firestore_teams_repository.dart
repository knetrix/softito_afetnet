// Ekipler ve görev akışı; her durum geçişi tek batch.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/case_status.dart';
import '../../live_feed/data/firestore_live_feed_repository.dart';
import '../../live_feed/domain/incident.dart';
import '../domain/assignment.dart';
import '../domain/team.dart';
import '../domain/teams_repository.dart';

/// Ekipler (Y2) ve görev akışı Cloud Firestore uygulaması
/// (PROJECT_NEW.md §4 Kural 6, §5.3).
///
/// Bir görev adımındaki tüm yazımlar (`assignments`, `incidents`, bağlı açık
/// `help_requests`, `teams`) tek bir atomik commit'tir. Transaction kullanılır:
/// yazımdan önce olayın, ekibin ve görevin güncel durumu okunur; böylece iki
/// yetkili aynı anda aynı olaya ekip atayamaz ve görev geri alınamaz.
class FirestoreTeamsRepository implements TeamsRepository {
  FirestoreTeamsRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _teams =>
      _db.collection('teams');
  CollectionReference<Map<String, dynamic>> get _assignments =>
      _db.collection('assignments');
  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection('incidents');
  CollectionReference<Map<String, dynamic>> get _helpRequests =>
      _db.collection('help_requests');

  @override
  Stream<List<Team>> watchTeams() {
    return _teams.snapshots().map((snap) {
      final teams = [
        for (final doc in snap.docs) teamFromMap(doc.id, doc.data()),
      ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return teams;
    });
  }

  /// Tek alanlı `whereIn` sorgusu; bileşik index gerekmez.
  @override
  Stream<List<Assignment>> watchActiveAssignments() {
    return _assignments
        .where(
          'status',
          whereIn: [
            CaseStatus.assigned.name,
            CaseStatus.enRoute.name,
            CaseStatus.onSite.name,
          ],
        )
        .snapshots()
        .map(
          (snap) => [
            for (final doc in snap.docs) ?assignmentFromMap(doc.id, doc.data()),
          ],
        );
  }

  @override
  Future<void> assignTeam({
    required Incident incident,
    required Team team,
    required String officialUid,
  }) async {
    final incidentRef = _incidents.doc(incident.id);
    final teamRef = _teams.doc(team.id);
    final linked = await _linkedRequests(incident.id);

    await _db.runTransaction<void>((tx) async {
      final incidentSnap = await tx.get(incidentRef);
      final teamSnap = await tx.get(teamRef);
      final requestSnaps = [for (final ref in linked) await tx.get(ref)];

      final incidentData = incidentSnap.data();
      if (incidentData == null || incidentData['isOpen'] != true) {
        throw const AssignmentException(AssignmentFailure.incidentClosed);
      }
      // Kural 6: bir olayda aynı anda tek aktif görev.
      if (incidentData['assignedTeamId'] != null) {
        throw const AssignmentException(
          AssignmentFailure.incidentAlreadyAssigned,
        );
      }
      final teamData = teamSnap.data();
      if (teamData == null ||
          (teamData['status'] ?? TeamStatus.available.name) !=
              TeamStatus.available.name) {
        throw const AssignmentException(AssignmentFailure.teamBusy);
      }

      const status = CaseStatus.assigned;
      tx.set(_assignments.doc(), {
        'incidentId': incident.id,
        'teamId': team.id,
        'status': status.name,
        'assignedBy': officialUid,
        'updatedBy': officialUid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(incidentRef, {
        'status': status.name,
        'assignedTeamId': team.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _updateOpenRequests(tx, requestSnaps, status, team.id);
      tx.update(teamRef, {
        'status': TeamStatus.onDuty.name,
        'currentTask': incident.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<CaseStatus> advanceAssignment({
    required Assignment assignment,
    required String officialUid,
  }) async {
    final next = AssignmentFlow.next(assignment.status);
    if (next == null) {
      throw const AssignmentException(AssignmentFailure.invalidTransition);
    }

    final assignmentRef = _assignments.doc(assignment.id);
    final incidentRef = _incidents.doc(assignment.incidentId);
    final teamRef = _teams.doc(assignment.teamId);
    final linked = await _linkedRequests(assignment.incidentId);
    final isResolved = next == CaseStatus.resolved;

    await _db.runTransaction<void>((tx) async {
      final current = await tx.get(assignmentRef);
      final requestSnaps = [for (final ref in linked) await tx.get(ref)];

      // Başka bir yetkili görevi bu arada ilerlettiyse yazım reddedilir;
      // böylece adım atlanmaz ve geri gidilmez (Kural 6).
      if (current.data()?['status'] != assignment.status.name) {
        throw const AssignmentException(AssignmentFailure.invalidTransition);
      }

      tx.update(assignmentRef, {
        'status': next.name,
        'updatedBy': officialUid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.update(incidentRef, {
        'status': next.name,
        'updatedAt': FieldValue.serverTimestamp(),
        if (isResolved) 'isOpen': false,
        if (isResolved) 'resolvedAt': FieldValue.serverTimestamp(),
      });
      _updateOpenRequests(tx, requestSnaps, next, assignment.teamId);
      tx.update(teamRef, {
        'status': isResolved
            ? TeamStatus.available.name
            : TeamStatus.onDuty.name,
        'currentTask': isResolved ? FieldValue.delete() : assignment.incidentId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    return next;
  }

  /// Olaya bağlı çağrılar. Sorgu Transaction içinde yapılamadığı için önce
  /// bulunur; durumları Transaction içinde yeniden okunur.
  Future<List<DocumentReference<Map<String, dynamic>>>> _linkedRequests(
    String incidentId,
  ) async {
    final snap = await _helpRequests
        .where('incidentId', isEqualTo: incidentId)
        .get();
    return [for (final doc in snap.docs) doc.reference];
  }

  /// İptal edilmiş ve çözülmüş çağrılara dokunulmaz (Kural 7). `assignedTeamId`
  /// her adımda yazılır: atamadan sonra olaya bağlanan çağrının kartında da
  /// ekip görünür.
  static void _updateOpenRequests(
    Transaction tx,
    List<DocumentSnapshot<Map<String, dynamic>>> requests,
    CaseStatus status,
    String teamId,
  ) {
    for (final r in requests) {
      if (!FirestoreLiveFeedRepository.isOpenRequest(r.data())) continue;
      tx.update(r.reference, {
        'status': status.name,
        'assignedTeamId': teamId,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == CaseStatus.resolved)
          'resolvedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Team teamFromMap(String id, Map<String, dynamic> d) {
    final geo = d['location'] as GeoPoint?;
    return Team(
      id: id,
      name: (d['name'] as String?)?.trim().isNotEmpty == true
          ? d['name'] as String
          : id,
      type: TeamType.values.asNameMap()[d['type']] ?? TeamType.searchRescue,
      leaderName: d['leaderName'] as String? ?? '',
      memberCount: (d['memberCount'] as num?)?.toInt() ?? 0,
      status:
          TeamStatus.values.asNameMap()[d['status']] ?? TeamStatus.available,
      location: geo == null ? null : LatLng(geo.latitude, geo.longitude),
      geohash: d['geohash'] as String?,
      locationText: d['locationText'] as String?,
      currentTask: d['currentTask'] as String?,
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Assignment? assignmentFromMap(String id, Map<String, dynamic> d) {
    final status = CaseStatus.values.asNameMap()[d['status']];
    final incidentId = d['incidentId'] as String?;
    final teamId = d['teamId'] as String?;
    if (status == null || incidentId == null || teamId == null) return null;
    return Assignment(
      id: id,
      incidentId: incidentId,
      teamId: teamId,
      status: status,
      assignedBy: d['assignedBy'] as String? ?? '',
      updatedBy: d['updatedBy'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
