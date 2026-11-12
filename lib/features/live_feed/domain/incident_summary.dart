import 'package:flutter/foundation.dart';

/// Canlı Akış kartında gösterilen, olayın ilk çağrısından (`primaryRequestId`)
/// okunan bilgiler (PROJECT_NEW.md §3.1 Y1, Kural 5).
///
/// Kartta kişisel veri olarak yalnızca ad bulunur; telefon ve tıbbi özet
/// yalnızca Detay sheet'inde okunur ([IncidentDetail]).
@immutable
class IncidentSummary {
  const IncidentSummary({
    this.fullName,
    this.peopleCount,
    this.addressText,
    this.description,
  });

  final String? fullName;
  final int? peopleCount;
  final String? addressText;
  final String? description;
}

/// Y1 Detay sheet'i: çağrı sahibinin telefonu ve tıbbi özeti (Kural 5).
@immutable
class IncidentDetail {
  const IncidentDetail({
    this.fullName,
    this.phone,
    this.bloodType,
    this.medications,
    this.conditions,
    this.birthYear,
    this.weightKg,
    this.cancelledCalls = 0,
  });

  final String? fullName;
  final String? phone;
  final String? bloodType;
  final String? medications;
  final String? conditions;
  final int? birthYear;
  final int? weightKg;

  /// Olaya bağlı çağrılardan afetzedenin iptal ettikleri. `requestCount`
  /// birleşen tüm çağrıları sayar (Kural 2); Detay'da iptaller ayrıca yazılır.
  final int cancelledCalls;

  bool get hasMedical =>
      [
        bloodType,
        medications,
        conditions,
      ].any((v) => v != null && v.isNotEmpty) ||
      birthYear != null ||
      weightKg != null;
}
