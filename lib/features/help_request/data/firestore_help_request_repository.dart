// "data" katmanı: yardım çağrılarının Firestore işlemleri.
// En önemli kısım: 50 m içindeki çağrıları tek olayda birleştiren Transaction.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/case_status.dart';
import '../../../core/constants/help_type.dart';
import '../../../core/utils/priority_policy.dart';
import '../domain/assigned_team_info.dart';
import '../domain/help_request.dart';
import '../domain/help_request_draft.dart';
import '../domain/help_request_repository.dart';
import '../domain/incident_progress.dart';

typedef DistanceCalculator = double Function(
  double startLatitude,
  double startLongitude,
  double endLatitude,
  double endLongitude,
);

/// AfetNet Cloud Firestore Yardım Çağrısı Repository Uygulaması.
class FirestoreHelpRequestRepository implements HelpRequestRepository {
  FirestoreHelpRequestRepository({
    FirebaseFirestore? firestore,
    DistanceCalculator? distanceCalculator,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _distanceBetween = distanceCalculator ?? Geolocator.distanceBetween;

  final FirebaseFirestore _db;
  final DistanceCalculator _distanceBetween;

  // help_requests koleksiyonu.
  CollectionReference<Map<String, dynamic>> get _helpRequests =>
      _db.collection('help_requests');

  // incidents koleksiyonu.
  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection('incidents');

  /// 8 haneli geohash hesabı.
  static String geohash8(GeoPoint p) =>
      GeoFirePoint(p).geohash.substring(0, 8);

  /// 7 haneli merkez hücre ve 8 komşu hücre (toplam 9 hücre).
  /// 7 haneli hücre ~153 m olduğu için 9 hücre 50 m yarıçapı her yönde kapsar.
  static List<String> searchCells(GeoPoint p) {
    final cell7 = GeoFirePoint(p).geohash.substring(0, 7);
    return [cell7, ...neighborGeohashesOf(geohash: cell7)];
  }

  /// 9 hücre üzerinde önek (prefix) sorgusu ile olayları tarar ve 50 m
  /// içindeki ilk açık olayın id'sini döndürür.
  ///
  /// Sorgu yalnızca `geohash` aralığıdır (tek alan index'i, otomatik).
  /// `isOpen` filtresi bileşik index istediği için istemcide uygulanır.
  ///
  /// Sunucudan okunur: internet yeni geldiğinde varsayılan okuma eksik yerel
  /// önbelleğe düşüyor ve açık olay bulunamadığı için mükerrer olay açılıyordu.
  /// Sunucuya ulaşılamazsa `unavailable` hatası çağrıyı kuyrukta tutar.
  Future<String?> findMatchingIncidentId(GeoPoint p) async {
    // Geohash: dünyayı kutulara bölüp her kutuya kısa bir metin kodu verir (ör. "sy7h2k3").
    // Yakın noktaların kodları aynı harflerle başlar; bu yüzden "bu kodla başlayanlar" sorgusu
    // o bölgedeki olayları getirir. 9 kutu (merkez + 8 komşu) 50 m'yi her yönde kapsar.
    final cells = searchCells(p);
    final queries = cells.map((cell) => _incidents
        .where('geohash', isGreaterThanOrEqualTo: cell)
        .where('geohash', isLessThan: '$cell~')
        .get(const GetOptions(source: Source.server)));

    // 9 sorgu aynı anda çalıştırılır ve hepsinin bitmesi beklenir.
    final snapshots = await Future.wait(queries);
    return pickMatchingIncident(
      p,
      snapshots.expand((snap) => snap.docs).map((doc) => (doc.id, doc.data())),
      _distanceBetween,
    );
  }

  /// [candidates] içinden açık (`isOpen == true`) ve [p]'ye 50 m içindeki
  /// ilk olayın id'sini seçer.
  static String? pickMatchingIncident(
    GeoPoint p,
    Iterable<(String, Map<String, dynamic>)> candidates,
    DistanceCalculator distanceBetween,
  ) {
    for (final (id, data) in candidates) {
      // Kapanmış olaylar atlanır.
      if (data['isOpen'] != true) continue;
      final loc = data['location'] as GeoPoint?;
      if (loc == null) continue;
      final distance = distanceBetween(
        p.latitude,
        p.longitude,
        loc.latitude,
        loc.longitude,
      );
      // Gerçek mesafe (metre) 50'den küçükse bu olay eşleşir.
      if (distance <= 50.0) return id;
    }
    return null;
  }

  // Çağrıyı gönderir. Transaction içinde: çevredeki açık olaylar aranır;
  // 50 m içinde olay varsa çağrı ona bağlanır (çağrı sayısı +1), yoksa yeni olay açılır.
  @override
  Future<String> submitHelpRequest(HelpRequestDraft draft) async {
    final location = draft.location;
    if (location == null) {
      throw ArgumentError('Yardım çağrısı için konum zorunludur.');
    }

    // Firestore'un konum tipi GeoPoint'tir; geohash ise yakın olay aramak için kullanılır.
    final geo = GeoPoint(location.latitude, location.longitude);
    final hash8 = geohash8(geo);

    // 1. 50 m içindeki açık olay adayını ara
    final candidateIncidentId = await findMatchingIncidentId(geo);

    // 2. Transaction içinde kontrol ve yazım
    // Transaction: içindeki okuma ve yazmalar tek bir işlem gibi çalışır. Aynı anda iki kişi
    // aynı olaya çağrı eklese bile Firestore işlemi tekrarlar, sayaç yanlış artmaz.
    return _db.runTransaction<String>((tx) async {
      final requestRef = _helpRequests.doc(draft.id);
      // Transaction'da önce okumalar (tx.get), sonra yazmalar (tx.set / tx.update) yapılır.
      final requestSnap = await tx.get(requestRef);

      // Idempotency: Kuyruk tekrar denese de çift kayıt olmaz
      if (requestSnap.exists) {
        return draft.id;
      }

      String incidentId;

      if (candidateIncidentId != null) {
        final incidentRef = _incidents.doc(candidateIncidentId);
        final incidentSnap = await tx.get(incidentRef);
        final incidentData = incidentSnap.data();

        if (incidentSnap.exists && incidentData?['isOpen'] == true) {
          // Açık olay bulundu: Çağrıyı bağla, requestCount +1, priority en yükseği
          incidentId = candidateIncidentId;
          final existingPriority =
              (incidentData!['priority'] as num?)?.toInt() ?? 3;
          final mergedPriority =
              PriorityPolicy.highest(existingPriority, draft.priority);

          tx.update(incidentRef, {
            // increment(1): değeri okumadan sunucuda 1 artırır.
            'requestCount': FieldValue.increment(1),
            'priority': mergedPriority,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Aday olay kapanmış, yeni olay aç
          final newIncidentRef = _incidents.doc();
          incidentId = newIncidentRef.id;
          tx.set(newIncidentRef, {
            'location': geo,
            'geohash': hash8,
            'type': draft.type.name,
            'priority': draft.priority,
            'requestCount': 1,
            'primaryRequestId': draft.id,
            'status': CaseStatus.pending.name,
            'isOpen': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Eşleşen olay yok: Yeni olay aç
        final newIncidentRef = _incidents.doc();
        incidentId = newIncidentRef.id;
        tx.set(newIncidentRef, {
          'location': geo,
          'geohash': hash8,
          'type': draft.type.name,
          'priority': draft.priority,
          'requestCount': 1,
          'primaryRequestId': draft.id,
          'status': CaseStatus.pending.name,
          'isOpen': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. help_requests/{requestId} belgesini yaz
      // serverTimestamp(): zamanı telefonun saatinden değil sunucunun saatinden alır.
      tx.set(requestRef, {
        'createdBy': draft.createdBy ?? '',
        'type': draft.type.name,
        'priority': draft.priority,
        'status': CaseStatus.pending.name,
        'peopleCount': draft.peopleCount,
        if (draft.addressText != null && draft.addressText!.isNotEmpty)
          'addressText': draft.addressText,
        if (draft.description != null && draft.description!.isNotEmpty)
          'description': draft.description,
        'location': geo,
        'geohash': hash8,
        'photoUrls': <String>[],
        'incidentId': incidentId,
        'createdOffline': draft.createdOffline,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. help_requests/{requestId}/private/contact belgesini yaz
      // Ad ve telefon ayrı bir alt belgede durur; güvenlik kuralları onu yalnızca sahibine
      // ve onaylı yetkiliye açar.
      final contactRef = requestRef.collection('private').doc('contact');
      tx.set(contactRef, {
        'fullName': draft.fullName ?? '',
        'phone': draft.phone ?? '',
      });

      return draft.id;
    });
  }

  /// Sorgu yalnızca `createdBy` eşitliğidir (otomatik index); `createdAt`
  /// sıralaması bileşik index istediği için istemcide yapılır. Bir afetzedenin
  /// çağrı sayısı az olduğundan maliyeti önemsizdir.
  @override
  Stream<HelpRequest?> watchActiveHelpRequest(String uid) {
    return _helpRequests
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snap) => latestActive(snap.docs.map(_fromDoc)));
  }

  /// Çözülmemiş ve iptal edilmemiş çağrılardan en yenisi.
  static HelpRequest? latestActive(Iterable<HelpRequest> requests) {
    HelpRequest? latest;
    for (final r in requests) {
      if (r.isResolved || r.isCancelled) continue;
      if (latest == null || r.createdAt.isAfter(latest.createdAt)) latest = r;
    }
    return latest;
  }

  // Çağrının bağlı olduğu olayı canlı dinler; ekip yola çıkınca afetzedenin kartı anında değişir.
  @override
  Stream<IncidentProgress?> watchIncidentProgress(String incidentId) {
    return _db.collection('incidents').doc(incidentId).snapshots().map((snap) {
      final data = snap.data();
      final status = CaseStatus.values.asNameMap()[data?['status']];
      if (data == null || status == null) return null;
      return IncidentProgress(
        status: status,
        assignedTeamId: data['assignedTeamId'] as String?,
      );
    });
  }

  // Atanan ekibin adını ve liderini okur.
  @override
  Future<AssignedTeamInfo?> fetchTeamInfo(String teamId) async {
    try {
      final snap = await _db.collection('teams').doc(teamId).get();
      if (!snap.exists || snap.data() == null) return null;
      final data = snap.data()!;
      return AssignedTeamInfo(
        id: teamId,
        name: data['name'] as String? ?? teamId,
        leaderName: data['leaderName'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  // Çağrıyı iptal eder. Güvenlik kuralı gereği afetzede yalnızca status alanını "cancelled" yapabilir.
  @override
  Future<void> cancelHelpRequest(String requestId) {
    // Kurallar gereği sahibi yalnızca `status → cancelled` yazabilir.
    return _helpRequests.doc(requestId).update({
      'status': CaseStatus.cancelled.name,
    });
  }

  // Firestore belgesini HelpRequest modeline çevirir.
  HelpRequest _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final geo = data['location'] as GeoPoint;
    final createdTs = data['createdAt'] as Timestamp?;
    final updatedTs = data['updatedAt'] as Timestamp?;
    final resolvedTs = data['resolvedAt'] as Timestamp?;

    return HelpRequest(
      id: doc.id,
      createdBy: data['createdBy'] as String? ?? '',
      type: HelpType.values.byName(data['type'] as String? ?? 'other'),
      priority: (data['priority'] as num?)?.toInt() ?? 3,
      status: CaseStatus.values.byName(data['status'] as String? ?? 'pending'),
      peopleCount: (data['peopleCount'] as num?)?.toInt() ?? 1,
      location: LatLng(geo.latitude, geo.longitude),
      geohash: data['geohash'] as String? ?? '',
      createdAt: createdTs?.toDate() ?? DateTime.now(),
      addressText: data['addressText'] as String?,
      description: data['description'] as String?,
      photoUrls: (data['photoUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      incidentId: data['incidentId'] as String?,
      assignedTeamId: data['assignedTeamId'] as String?,
      createdOffline: data['createdOffline'] as bool? ?? false,
      updatedAt: updatedTs?.toDate(),
      resolvedAt: resolvedTs?.toDate(),
    );
  }
}
