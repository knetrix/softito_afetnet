import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreBroadcastRepository {
  FirestoreBroadcastRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<String> createEvacuationBroadcast({
    required String title,
    required String message,
    required double latitude,
    required double longitude,
    required double radiusKm,
    required String createdBy,
  }) async {
    final cleanTitle = title.trim();
    final cleanMessage = message.trim();

    if (cleanTitle.isEmpty || cleanTitle.length > 100) {
      throw ArgumentError('Başlık 1-100 karakter olmalıdır.');
    }

    if (cleanMessage.isEmpty || cleanMessage.length > 500) {
      throw ArgumentError('Mesaj 1-500 karakter olmalıdır.');
    }

    if (createdBy.trim().isEmpty) {
      throw ArgumentError('Yetkili kullanıcı bulunamadı.');
    }

    if (!latitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        !longitude.isFinite ||
        longitude < -180 ||
        longitude > 180) {
      throw ArgumentError('Geçersiz koordinat.');
    }

    if (!radiusKm.isFinite || radiusKm < 0.1 || radiusKm > 20) {
      throw ArgumentError('Yarıçap 0,1-20 km arasında olmalıdır.');
    }

    final reference = _db.collection('broadcasts').doc();

    await reference.set({
      'type': 'evacuation',
      'title': cleanTitle,
      'body': cleanMessage,
      'center': GeoPoint(latitude, longitude),
      'radiusMeters': (radiusKm * 1000).round(),
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return reference.id;
  }
}
