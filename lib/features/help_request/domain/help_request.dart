// Yardım çağrısı modeli (help_requests/{id}).

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/case_status.dart';
import '../../../core/constants/help_type.dart';

/// AfetNet Yardım Çağrısı Varlığı (PROJECT_NEW.md §5.2).
@immutable
class HelpRequest {
  const HelpRequest({
    required this.id,
    required this.createdBy,
    required this.type,
    required this.priority,
    required this.status,
    required this.peopleCount,
    required this.location,
    required this.geohash,
    required this.createdAt,
    this.addressText,
    this.description,
    this.photoUrls = const [],
    this.incidentId,
    this.assignedTeamId,
    this.createdOffline = false,
    this.updatedAt,
    this.resolvedAt,
  });

  final String id;
  final String createdBy;
  final HelpType type;
  final int priority;
  final CaseStatus status;
  final int peopleCount;
  final LatLng location;
  final String geohash;
  final DateTime createdAt;
  final String? addressText;
  final String? description;
  final List<String> photoUrls;
  final String? incidentId;
  final String? assignedTeamId;
  final bool createdOffline;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  // Çağrı beklemede mi.
  bool get isPending => status == CaseStatus.pending;
  // Çağrı çözüldü mü.
  bool get isResolved => status == CaseStatus.resolved;
  // Çağrı iptal edildi mi.
  bool get isCancelled => status == CaseStatus.cancelled;

  // Verilen alanları değiştirilmiş bir kopya döndürür.
  HelpRequest copyWith({
    String? id,
    String? createdBy,
    HelpType? type,
    int? priority,
    CaseStatus? status,
    int? peopleCount,
    LatLng? location,
    String? geohash,
    DateTime? createdAt,
    String? addressText,
    String? description,
    List<String>? photoUrls,
    String? incidentId,
    String? assignedTeamId,
    bool? createdOffline,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return HelpRequest(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      peopleCount: peopleCount ?? this.peopleCount,
      location: location ?? this.location,
      geohash: geohash ?? this.geohash,
      createdAt: createdAt ?? this.createdAt,
      addressText: addressText ?? this.addressText,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      incidentId: incidentId ?? this.incidentId,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      createdOffline: createdOffline ?? this.createdOffline,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HelpRequest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          createdBy == other.createdBy &&
          status == other.status &&
          incidentId == other.incidentId &&
          updatedAt == other.updatedAt;

  // Eşitlik karşılaştırması için hash değeri.
  @override
  int get hashCode => Object.hash(id, createdBy, status, incidentId, updatedAt);
}
