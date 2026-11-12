import 'package:flutter/foundation.dart';

/// Çağrıya atanan ekip ve sorumlu lider özeti (PROJECT_NEW.md §4 Kural 6).
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

  @override
  int get hashCode => Object.hash(id, name, leaderName);
}
