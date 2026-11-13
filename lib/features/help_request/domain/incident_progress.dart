// Çağrının bağlı olduğu olayın son durumu ve atanan ekip (afetzedenin kartı bunu gösterir).

import 'package:flutter/foundation.dart';

import '../../../core/constants/case_status.dart';

/// Çağrının bağlı olduğu olayın görev durumu (PROJECT_NEW.md §4 Kural 6).
///
/// Ekip atandıktan sonra aynı olaya birleşen çağrı, kurallar gereği
/// `pending` olarak açılır (§5.5) ve yetkili görevi bir sonraki adıma
/// taşıyana kadar öyle kalır. Bu süre boyunca afetzedenin kartı durumu ve
/// ekibi olaydan okur; olay belgesi kişisel veri içermez ve herkes okuyabilir.
@immutable
class IncidentProgress {
  const IncidentProgress({required this.status, this.assignedTeamId});

  final CaseStatus status;
  final String? assignedTeamId;

  @override
  bool operator ==(Object other) =>
      other is IncidentProgress &&
      other.status == status &&
      other.assignedTeamId == assignedTeamId;

  // == ile birlikte kullanılır: içerikleri aynı olan iki nesne aynı hash değerini üretir.
  @override
  int get hashCode => Object.hash(status, assignedTeamId);
}
