// "domain" katmanı: anons türleri (Acil Tahliye / Artçı Sarsıntı) ve anons gönderme sözleşmesi.

import 'package:latlong2/latlong.dart';

/// `broadcasts/{id}.type` değerleri (PROJECT_NEW.md §5.3).
enum BroadcastType { evacuation, aftershock }

/// Tahliye Anonsu repository arayüzü (PROJECT_NEW.md §4 Kural 10).
abstract interface class BroadcastRepository {
  /// Anonsu `broadcasts` koleksiyonuna yazar. Merkez yetkilinin konumudur;
  /// yarıçap 100–20000 m (§5.5).
  Future<void> send({
    required BroadcastType type,
    required String title,
    required String body,
    required LatLng center,
    required int radiusMeters,
    required String createdBy,
  });
}
