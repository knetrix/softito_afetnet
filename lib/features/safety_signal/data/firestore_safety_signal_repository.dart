import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/app_config.dart';
import '../domain/safety_signal.dart';
import '../domain/safety_signal_repository.dart';

class FirestoreSafetySignalRepository implements SafetySignalRepository {
  FirestoreSafetySignalRepository({
    FirebaseFirestore? firestore,
    Duration? offlineTimeout,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _offlineTimeout = offlineTimeout ?? AppConfig.offlineTimeout;

  final FirebaseFirestore _db;
  final Duration _offlineTimeout;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('safety_signals').doc(uid);

  @override
  Stream<SafetySignal?> watchSignal(String uid) {
    return _doc(uid)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => _fromDoc(uid, snap));
  }

  @override
  Future<SignalDelivery> sendDanger(
    String uid,
    double latitude,
    double longitude,
  ) async {
    final ref = _doc(uid);
    final geo = GeoPoint(latitude, longitude);
    final hash = GeoFirePoint(geo).geohash.substring(0, 8);

    final completer = Completer<SignalDelivery>();
    // Dinleyici set()'ten önce açılır; böylece eski önbellek 'safe' kaydı
    // sunucu onayı sanılmaz ve hızlı sunucu cevabı kaçırılmaz.
    final sub = ref.snapshots(includeMetadataChanges: true).listen(
      (snap) {
        final data = snap.data();
        if (snap.exists &&
            data?['state'] == SafetySignalState.danger.name &&
            !snap.metadata.hasPendingWrites &&
            !completer.isCompleted) {
          completer.complete(SignalDelivery.confirmed);
        }
      },
      onError: (Object _) {
        if (!completer.isCompleted) {
          completer.complete(SignalDelivery.pending);
        }
      },
    );

    // Çevrimdışıyken set() tamamlanmaz; await edilmez (Kural 8).
    unawaited(
      ref.set({
        'state': SafetySignalState.danger.name,
        'location': geo,
        'geohash': hash,
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((Object _) {}),
    );

    try {
      return await completer.future.timeout(
        _offlineTimeout,
        onTimeout: () => SignalDelivery.pending,
      );
    } finally {
      await sub.cancel();
    }
  }

  @override
  Future<void> sendSafe(String uid) async {
    final ref = _doc(uid);
    // Çevrimdışıyken de UI'ın takılmaması için yazımı kuyruğa bırakır;
    // yerel önbellek anında güncellenir ve bağlantı gelince sunucuya gider.
    unawaited(
      ref
          .set(
            {
              'state': SafetySignalState.safe.name,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          )
          .catchError((Object _) {}),
    );
  }

  SafetySignal? _fromDoc(
    String uid,
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final d = snap.data();
    if (!snap.exists || d == null) return null;

    final geo = d['location'] as GeoPoint?;
    final stateName = d['state'] as String?;
    final state = SafetySignalState.values.asNameMap()[stateName] ??
        SafetySignalState.safe;

    return SafetySignal(
      uid: uid,
      state: state,
      location: geo != null
          ? LatLng(geo.latitude, geo.longitude)
          : const LatLng(0, 0),
      geohash: d['geohash'] as String? ?? '',
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      handledBy: d['handledBy'] as String?,
      handledAt: (d['handledAt'] as Timestamp?)?.toDate(),
      hasPendingWrites: snap.metadata.hasPendingWrites,
    );
  }
}

