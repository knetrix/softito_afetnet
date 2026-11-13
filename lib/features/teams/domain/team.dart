// "domain" katmanı: ekip modeli: ad, tür (arama kurtarma, sağlık, itfaiye, lojistik), lider, kişi sayısı,
// konum ve durum (Boşta / Görevde).

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// `teams/{teamId}.type` değerleri.
enum TeamType { searchRescue, medical, fire, logistics }

/// `teams/{teamId}.status` değerleri.
enum TeamStatus { available, onDuty }

/// `teams/{teamId}` belgesinin domain modeli.
///
/// Ekip kayıtları seed verisi ve Console'dan girilir; uygulama yalnızca
/// `status` ve `currentTask` alanlarını görev akışında günceller.
@immutable
class Team {
  const Team({
    required this.id,
    required this.name,
    required this.type,
    required this.leaderName,
    required this.memberCount,
    required this.status,
    this.location,
    this.geohash,
    this.locationText,
    this.currentTask,
    this.updatedAt,
  });

  final String id;
  final String name;
  final TeamType type;
  final String leaderName;
  final int memberCount;
  final TeamStatus status;
  final LatLng? location;
  final String? geohash;
  final String? locationText;

  /// Ekibin üzerindeki olayın id'si (`incidents/{id}`). Metin yerine id
  /// tutulur; ekranda olay türü ve görev durumu cihaz dilinde gösterilir.
  final String? currentTask;
  final DateTime? updatedAt;

  // Ekip boşta mı.
  bool get isAvailable => status == TeamStatus.available;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team &&
          other.id == id &&
          other.name == name &&
          other.type == type &&
          other.leaderName == leaderName &&
          other.memberCount == memberCount &&
          other.status == status &&
          other.location == location &&
          other.locationText == locationText &&
          other.currentTask == currentTask;

  // == ile birlikte kullanılır: içerikleri aynı olan iki nesne aynı hash değerini üretir.
  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    leaderName,
    memberCount,
    status,
    location,
    locationText,
    currentTask,
  );
}
