import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/help_type.dart';
import '../../../core/utils/priority_policy.dart';

/// Yardım çağrısı oluşturma ve kuyruk taslağı (§3.2, §4 Kural 1, Kural 4, §5.2).
@immutable
class HelpRequestDraft {
  HelpRequestDraft({
    String? id,
    required this.type,
    this.peopleCount = 1,
    this.addressText,
    this.description,
    this.location,
    this.createdBy,
    this.fullName,
    this.phone,
    this.createdOffline = false,
  })  : id = id ?? const Uuid().v4(),
        assert(peopleCount >= 1, 'Kişi sayısı en az 1 olmalıdır.');

  /// İstemcide üretilen benzersiz çağrı kimliği (Kural 4, idempotency).
  final String id;

  /// Çağrı türü (§4 Kural 1).
  final HelpType type;

  /// Etkilenen kişi sayısı (varsayılan 1).
  final int peopleCount;

  /// Adres tarifi (en fazla 300 karakter).
  final String? addressText;

  /// Durum açıklaması (en fazla 500 karakter).
  final String? description;

  /// Çağrının açıldığı coğrafi konum.
  final LatLng? location;

  /// Çağrıyı oluşturan kullanıcının uid'si.
  final String? createdBy;

  /// `private/contact` için çağrı anında kopyalanan ad soyad (§5.2).
  final String? fullName;

  /// `private/contact` için çağrı anında kopyalanan telefon numarası (§5.2).
  final String? phone;

  /// Hive çevrimdışı kuyruğundan geldiyse true (Kural 4).
  final bool createdOffline;

  /// Kural 1'e göre hesaplanan öncelik seviyesi (1: Kritik, 2: Acil, 3: Normal).
  int get priority => PriorityPolicy.calculate(type);

  HelpRequestDraft copyWith({
    String? id,
    HelpType? type,
    int? peopleCount,
    String? addressText,
    String? description,
    LatLng? location,
    String? createdBy,
    String? fullName,
    String? phone,
    bool? createdOffline,
  }) {
    return HelpRequestDraft(
      id: id ?? this.id,
      type: type ?? this.type,
      peopleCount: peopleCount ?? this.peopleCount,
      addressText: addressText ?? this.addressText,
      description: description ?? this.description,
      location: location ?? this.location,
      createdBy: createdBy ?? this.createdBy,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      createdOffline: createdOffline ?? this.createdOffline,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'peopleCount': peopleCount,
        'addressText': addressText,
        'description': description,
        'latitude': location?.latitude,
        'longitude': location?.longitude,
        'createdBy': createdBy,
        'fullName': fullName,
        'phone': phone,
        'createdOffline': createdOffline,
      };

  factory HelpRequestDraft.fromJson(Map<String, dynamic> json) {
    final lat = json['latitude'] as num?;
    final lng = json['longitude'] as num?;
    return HelpRequestDraft(
      id: json['id'] as String?,
      type: HelpType.values.byName(json['type'] as String),
      peopleCount: json['peopleCount'] as int? ?? 1,
      addressText: json['addressText'] as String?,
      description: json['description'] as String?,
      location: lat != null && lng != null
          ? LatLng(lat.toDouble(), lng.toDouble())
          : null,
      createdBy: json['createdBy'] as String?,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      createdOffline: json['createdOffline'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HelpRequestDraft &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          peopleCount == other.peopleCount &&
          addressText == other.addressText &&
          description == other.description &&
          location == other.location &&
          createdBy == other.createdBy &&
          createdOffline == other.createdOffline;

  @override
  int get hashCode => Object.hash(
        id,
        type,
        peopleCount,
        addressText,
        description,
        location,
        createdBy,
        createdOffline,
      );

  @override
  String toString() =>
      'HelpRequestDraft(id: $id, type: $type, peopleCount: $peopleCount, priority: $priority, offline: $createdOffline)';
}
