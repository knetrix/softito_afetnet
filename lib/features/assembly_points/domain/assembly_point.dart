// Toplanma alanı modeli (konum, kapasite, doluluk, hizmetler).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import 'assembly_point_type.dart';
import 'assembly_service.dart';

/// Toplanma Alanı Domain Modeli (PROJECT_NEW.md §3.1 A2, §5.3).
class AssemblyPoint {
  const AssemblyPoint({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.geohash,
    required this.capacity,
    required this.currentCount,
    required this.services,
    required this.isOpen,
    required this.updatedAt,
    this.description,
  });

  final String id;
  final String name;
  final AssemblyPointType type;
  final LatLng location;
  final String geohash;
  final int capacity;
  final int currentCount;
  final List<AssemblyService> services;
  final bool isOpen;
  final DateTime updatedAt;
  final String? description;

  /// Doluluk oranı: 0.0 - 1.0 arası değer (ör. 0.75 -> %75)
  double get occupancyRate {
    if (capacity <= 0) return 0.0;
    return (currentCount / capacity).clamp(0.0, 1.0);
  }

  /// Doluluk yüzdesi tam sayı: 0 - 100 arası (ör. 75)
  int get occupancyPercentage => (occupancyRate * 100).round();

  /// Belirli bir koordinata olan mesafeyi metre cinsinden hesaplar.
  double distanceInMeters(LatLng from) {
    const distance = Distance();
    return distance.as(LengthUnit.Meter, from, location);
  }

  /// Mesafeyi kullanıcı dostu biçimde metne dönüştürür (ör. 350 m veya 1.4 km).
  String formatDistance(LatLng from) {
    final meters = distanceInMeters(from).round();
    if (meters < 1000) {
      return '$meters m';
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return '$km km';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'description': description,
      'location': GeoPoint(location.latitude, location.longitude),
      'geohash': geohash,
      'capacity': capacity,
      'currentCount': currentCount,
      'services': services.map((s) => s.name).toList(),
      'isOpen': isOpen,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Konumu olmayan ya da geçersiz belgede `null` döner; uydurma konum üretilmez.
  static AssemblyPoint? tryFromJson(String id, Map<String, dynamic> json) {
    try {
      return AssemblyPoint.fromJson(id, json);
    } on FormatException {
      return null;
    }
  }

  factory AssemblyPoint.fromJson(String id, Map<String, dynamic> json) {
    final geo = json['location'];
    LatLng pos;
    if (geo is GeoPoint) {
      pos = LatLng(geo.latitude, geo.longitude);
    } else if (geo is Map &&
        geo['latitude'] is num &&
        geo['longitude'] is num) {
      pos = LatLng(
        (geo['latitude'] as num).toDouble(),
        (geo['longitude'] as num).toDouble(),
      );
    } else {
      throw FormatException('assembly_points/$id: location yok');
    }

    final typeStr = json['type'] as String? ?? 'assembly';
    final pointType = AssemblyPointType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => AssemblyPointType.assembly,
    );

    final rawServices = json['services'] as List<dynamic>? ?? const [];
    // Bilinmeyen hizmet gösterilmez (önce "Su" sanılıyordu).
    final parsedServices = rawServices
        .map((s) => AssemblyService.values.asNameMap()[s.toString()])
        .whereType<AssemblyService>()
        .toSet()
        .toList();

    DateTime updated;
    final rawUpdated = json['updatedAt'];
    if (rawUpdated is Timestamp) {
      updated = rawUpdated.toDate();
    } else if (rawUpdated is String) {
      updated = DateTime.tryParse(rawUpdated) ?? DateTime.now();
    } else {
      updated = DateTime.now();
    }

    return AssemblyPoint(
      id: id,
      name: json['name'] as String? ?? '',
      type: pointType,
      description: json['description'] as String?,
      location: pos,
      geohash: json['geohash'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      currentCount: (json['currentCount'] as num?)?.toInt() ?? 0,
      services: parsedServices,
      isOpen: json['isOpen'] as bool? ?? true,
      updatedAt: updated,
    );
  }

  AssemblyPoint copyWith({
    String? id,
    String? name,
    AssemblyPointType? type,
    LatLng? location,
    String? geohash,
    int? capacity,
    int? currentCount,
    List<AssemblyService>? services,
    bool? isOpen,
    DateTime? updatedAt,
    String? description,
  }) {
    return AssemblyPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      geohash: geohash ?? this.geohash,
      capacity: capacity ?? this.capacity,
      currentCount: currentCount ?? this.currentCount,
      services: services ?? this.services,
      isOpen: isOpen ?? this.isOpen,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
    );
  }
}
