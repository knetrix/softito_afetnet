// "domain" katmanı: panik sinyali modeli. Durum (TEHLİKEDEYİM / GÜVENDEYİM), konum, zaman,
// "Ulaşıldı" bilgisi ve sinyalin sunucuya ulaşıp ulaşmadığı.

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// `safety_signals/{uid}.state` değerleri (PROJECT_NEW.md §5.3).
enum SafetySignalState { danger, safe }

/// Sunucu onayı sonucu (PROJECT_NEW.md §4 Kural 8).
enum SignalDelivery {
  /// Sunucu yazımı onayladı (`hasPendingWrites == false`).
  confirmed,

  /// 10 sn içinde onay gelmedi; Firestore kuyruğunda bekliyor.
  pending,
}

/// `safety_signals/{uid}` belgesinin domain modeli (PROJECT_NEW.md §5.3).
@immutable
class SafetySignal {
  const SafetySignal({
    required this.uid,
    required this.state,
    required this.location,
    required this.geohash,
    required this.updatedAt,
    this.handledBy,
    this.handledAt,
    this.hasPendingWrites = false,
  });

  final String uid;
  final SafetySignalState state;
  final LatLng location;
  final String geohash;
  final DateTime updatedAt;
  final String? handledBy;
  final DateTime? handledAt;

  /// Firestore yerel kuyruğunda sunucu onayı bekliyorsa `true`.
  final bool hasPendingWrites;

  // Sinyal TEHLİKEDEYİM mi.
  bool get isDanger => state == SafetySignalState.danger;
  // Sinyal sunucuya ulaştı mı.
  bool get isConfirmed => !hasPendingWrites;

  /// Yetkili "Ulaşıldı" işaretlediyse `true`. Yeni panik bu alanları
  /// sildiği için kayıt her zaman son sinyale aittir.
  bool get isHandled => handledBy != null;

  @override
  bool operator ==(Object other) =>
      other is SafetySignal &&
      other.uid == uid &&
      other.state == state &&
      other.location == location &&
      other.geohash == geohash &&
      other.updatedAt == updatedAt &&
      other.handledBy == handledBy &&
      other.handledAt == handledAt &&
      other.hasPendingWrites == hasPendingWrites;

  // == ile birlikte kullanılır: içerikleri aynı olan iki nesne aynı hash değerini üretir.
  @override
  int get hashCode => Object.hash(
        uid,
        state,
        location,
        geohash,
        updatedAt,
        handledBy,
        handledAt,
        hasPendingWrites,
      );
}

