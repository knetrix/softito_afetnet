// Çağrıya atanan ekibin adı ve sorumlu lideri (afetzedenin kartında gösterilir).

import 'package:flutter/foundation.dart';

/// Çağrıya atanan ekip ve sorumlu lider özeti.
@immutable
class AssignedTeamInfo {
  const AssignedTeamInfo({
    required this.id,
    required this.name,
    required this.leaderName,
  });

  final String id;
  final String name;
  final String leaderName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignedTeamInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          leaderName == other.leaderName;

  // == ile birlikte kullanılır: içerikleri aynı olan iki nesne aynı hash değerini üretir.
  @override
  int get hashCode => Object.hash(id, name, leaderName);
}
