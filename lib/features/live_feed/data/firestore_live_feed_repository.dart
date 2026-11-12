import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/case_status.dart';
import '../../../core/constants/help_type.dart';
import '../../safety_signal/domain/safety_signal.dart';
import '../domain/incident.dart';
import '../domain/incident_summary.dart';
import '../domain/live_feed_repository.dart';

/// Canlı Akış (Y1) Cloud Firestore uygulaması (PROJECT_NEW.md §4, §5.3, §5.4).
class FirestoreLiveFeedRepository implements LiveFeedRepository {
  FirestoreLiveFeedRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection('incidents');

  CollectionReference<Map<String, dynamic>> get _helpRequests =>
      _db.collection('help_requests');

  /// Index: `incidents` — `isOpen ASC, priority ASC, createdAt ASC` (§5.4).
  @override
  Stream<List<Incident>> watchOpenIncidents() {
    return _incidents
        .where('isOpen', isEqualTo: true)
        .orderBy('priority')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => [
            for (final doc in snap.docs) ?incidentFromMap(doc.id, doc.data()),
          ],
        );
  }

  /// Index: `safety_signals` — `state ASC, updatedAt DESC` (§5.4).
  @override
  Stream<List<SafetySignal>> watchDangerSignals() {
    return _db
        .collection('safety_signals')
        .where('state', isEqualTo: SafetySignalState.danger.name)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => [
            for (final doc in snap.docs) ?signalFromMap(doc.id, doc.data()),
          ],
        );
  }

  @override
  Future<IncidentSummary> fetchSummary(Incident incident) async {
    final requestRef = _helpRequests.doc(incident.primaryRequestId);
    final results = await Future.wait([
      requestRef.get(),
      requestRef.collection('private').doc('contact').get(),
    ]);
    final request = results[0].data();
    final contact = results[1].data();
    return IncidentSummary(
      fullName: _nonEmpty(contact?['fullName']),
      peopleCount: (request?['peopleCount'] as num?)?.toInt(),
      addressText: _nonEmpty(request?['addressText']),
      description: _nonEmpty(request?['description']),
    );
  }

  @override
  Future<IncidentDetail> fetchDetail(Incident incident) async {
    final requestRef = _helpRequests.doc(incident.primaryRequestId);
    final results = await Future.wait([
      requestRef.get(),
      requestRef.collection('private').doc('contact').get(),
    ]);
    final createdBy = results[0].data()?['createdBy'] as String?;
    final contact = results[1].data();

    Map<String, dynamic>? medical;
    if (createdBy != null && createdBy.isNotEmpty) {
      try {
        final userContact = await _db
            .collection('users')
            .doc(createdBy)
            .collection('private')
            .doc('contact')
            .get();
        medical = userContact.data()?['medical'] as Map<String, dynamic>?;
      } on FirebaseException {
        // Tıbbi bilgi okunamazsa telefon yine gösterilir.
      }
    }

    return IncidentDetail(
      fullName: _nonEmpty(contact?['fullName']),
      phone: _nonEmpty(contact?['phone']),
      bloodType: _nonEmpty(medical?['bloodType']),
      medications: _nonEmpty(medical?['medications']),
      conditions: _nonEmpty(medical?['conditions']),
      birthYear: (medical?['birthYear'] as num?)?.toInt(),
      weightKg: (medical?['weightKg'] as num?)?.toInt(),
    );
  }

  @override
  Future<bool> closeIncident(Incident incident) async {
    final incidentRef = _incidents.doc(incident.id);
    // Sorgu Transaction içinde yapılamaz; bağlı çağrılar önce bulunur, durumları
    // Transaction içinde yeniden okunur (iptal edilen çağrıya dokunulmaz, Kural 7).
    final linked = await _helpRequests
        .where('incidentId', isEqualTo: incident.id)
        .get();

    return _db.runTransaction<bool>((tx) async {
      final snap = await tx.get(incidentRef);
      final data = snap.data();
      if (data == null ||
          data['isOpen'] != true ||
          data['assignedTeamId'] != null) {
        return false;
      }

      final requestSnaps = [
        for (final doc in linked.docs) await tx.get(doc.reference),
      ];

      tx.update(incidentRef, {
        'status': CaseStatus.resolved.name,
        'isOpen': false,
        'updatedAt': FieldValue.serverTimestamp(),
        'resolvedAt': FieldValue.serverTimestamp(),
      });
      for (final r in requestSnaps) {
        if (!isOpenRequest(r.data())) continue;
        tx.update(r.reference, {
          'status': CaseStatus.resolved.name,
          'updatedAt': FieldValue.serverTimestamp(),
          'resolvedAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    });
  }

  @override
  Future<void> markSignalHandled({
    required String signalUid,
    required String officialUid,
  }) {
    // §5.5: Yetkili yalnızca `handledBy == auth.uid` ve `handledAt` yazar.
    return _db.collection('safety_signals').doc(signalUid).update({
      'handledBy': officialUid,
      'handledAt': FieldValue.serverTimestamp(),
    });
  }

  /// Yetkilinin güncelleyebileceği çağrı: var, iptal edilmemiş ve çözülmemiş.
  static bool isOpenRequest(Map<String, dynamic>? data) {
    if (data == null) return false;
    final status = data['status'] as String?;
    return status != CaseStatus.cancelled.name &&
        status != CaseStatus.resolved.name;
  }

  /// `incidents/{id}` belgesini modele çevirir; konumu olmayan kayıt atlanır.
  static Incident? incidentFromMap(String id, Map<String, dynamic> d) {
    final geo = d['location'] as GeoPoint?;
    if (geo == null) return null;
    return Incident(
      id: id,
      location: LatLng(geo.latitude, geo.longitude),
      geohash: d['geohash'] as String? ?? '',
      type: HelpType.values.asNameMap()[d['type']] ?? HelpType.other,
      priority: (d['priority'] as num?)?.toInt() ?? 3,
      requestCount: (d['requestCount'] as num?)?.toInt() ?? 1,
      primaryRequestId: d['primaryRequestId'] as String? ?? '',
      status: CaseStatus.values.asNameMap()[d['status']] ?? CaseStatus.pending,
      isOpen: d['isOpen'] == true,
      // Sunucu zamanı henüz yazılmadıysa (yerel önbellek) şimdiki zaman.
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedTeamId: d['assignedTeamId'] as String?,
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
      resolvedAt: (d['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// `safety_signals/{uid}` belgesini modele çevirir; konumu olmayan atlanır.
  static SafetySignal? signalFromMap(String uid, Map<String, dynamic> d) {
    final geo = d['location'] as GeoPoint?;
    if (geo == null) return null;
    return SafetySignal(
      uid: uid,
      state:
          SafetySignalState.values.asNameMap()[d['state']] ??
          SafetySignalState.safe,
      location: LatLng(geo.latitude, geo.longitude),
      geohash: d['geohash'] as String? ?? '',
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      handledBy: d['handledBy'] as String?,
      handledAt: (d['handledAt'] as Timestamp?)?.toDate(),
    );
  }

  static String? _nonEmpty(Object? v) {
    final s = (v as String?)?.trim();
    return (s == null || s.isEmpty) ? null : s;
  }
}
