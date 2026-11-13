// Tahliye anonsunu Firestore'a yazar ve okur.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../domain/broadcast_repository.dart';

/// Tahliye Anonsu Cloud Firestore uygulaması (Kural 10, §5.3).
class FirestoreBroadcastRepository implements BroadcastRepository {
  FirestoreBroadcastRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const minRadiusMeters = 100;
  static const maxRadiusMeters = 20000;

  @override
  Future<void> send({
    required BroadcastType type,
    required String title,
    required String body,
    required LatLng center,
    required int radiusMeters,
    required String createdBy,
  }) {
    return _db.collection('broadcasts').doc().set({
      'type': type.name,
      'title': title,
      'body': body.trim(),
      'center': GeoPoint(center.latitude, center.longitude),
      'radiusMeters': radiusMeters.clamp(minRadiusMeters, maxRadiusMeters),
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
