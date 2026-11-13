// "domain" katmanı: olay (incident) modeli. 50 m içinden gelen çağrılar tek bir olay dosyasında birleşir;
// requestCount kaç çağrı bağlandığını, priority en yüksek önceliği tutar.

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/case_status.dart';
import '../../../core/constants/help_type.dart';

/// AfetNet Olay Varlığı.
///
/// 50 m içindeki mükerrer yardım çağrıları aynı olay altında birleşir.
@immutable
class Incident {
  const Incident({
    required this.id,
    required this.location,
    required this.geohash,
    required this.type,
    required this.priority,
    required this.requestCount,
    required this.primaryRequestId,
    required this.status,
    required this.isOpen,
    required this.createdAt,
    this.assignedTeamId,
    this.updatedAt,
    this.resolvedAt,
  });

  final String id;
  final LatLng location;
  final String geohash;
  final HelpType type;
  final int priority;
  final int requestCount;
  final String primaryRequestId;
  final CaseStatus status;
  final bool isOpen;
  final DateTime createdAt;
  final String? assignedTeamId;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  /// Görev atanmamış olay doğrudan kapatılabilir.
  bool get canBeClosedDirectly => assignedTeamId == null;

  // Nesnenin bir kopyasını oluşturur; yalnızca verilen alanlar değişir, orijinal nesne olduğu gibi kalır.
  Incident copyWith({
    String? id,
    LatLng? location,
    String? geohash,
    HelpType? type,
    int? priority,
    int? requestCount,
    String? primaryRequestId,
    CaseStatus? status,
    bool? isOpen,
    DateTime? createdAt,
    String? assignedTeamId,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return Incident(
      id: id ?? this.id,
      location: location ?? this.location,
      geohash: geohash ?? this.geohash,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      requestCount: requestCount ?? this.requestCount,
      primaryRequestId: primaryRequestId ?? this.primaryRequestId,
      status: status ?? this.status,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt ?? this.createdAt,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Incident &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isOpen == other.isOpen &&
          status == other.status &&
          requestCount == other.requestCount &&
          priority == other.priority;

  // == ile birlikte kullanılır: içerikleri aynı olan iki nesne aynı hash değerini üretir.
  @override
  int get hashCode => Object.hash(id, isOpen, status, requestCount, priority);
}
