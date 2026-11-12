import 'package:flutter/foundation.dart';

import '../../../core/constants/help_type.dart';
import '../../../core/utils/priority_policy.dart';

/// Yardım çağrısı oluşturma taslağı (§3.2, §5.2).
@immutable
class HelpRequestDraft {
  const HelpRequestDraft({
    required this.type,
    this.peopleCount = 1,
    this.addressText,
    this.description,
  }) : assert(peopleCount >= 1, 'Kişi sayısı en az 1 olmalıdır.');

  /// Çağrı türü (§4 Kural 1).
  final HelpType type;

  /// Etkilenen kişi sayısı (varsayılan 1).
  final int peopleCount;

  /// Adres tarifi (en fazla 300 karakter).
  final String? addressText;

  /// Durum açıklaması (en fazla 500 karakter).
  final String? description;

  /// Kural 1'e göre hesaplanan öncelik seviyesi (1: Kritik, 2: Acil, 3: Normal).
  int get priority => PriorityPolicy.calculate(type);

  HelpRequestDraft copyWith({
    HelpType? type,
    int? peopleCount,
    String? addressText,
    String? description,
  }) {
    return HelpRequestDraft(
      type: type ?? this.type,
      peopleCount: peopleCount ?? this.peopleCount,
      addressText: addressText ?? this.addressText,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HelpRequestDraft &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          peopleCount == other.peopleCount &&
          addressText == other.addressText &&
          description == other.description;

  @override
  int get hashCode => Object.hash(type, peopleCount, addressText, description);

  @override
  String toString() =>
      'HelpRequestDraft(type: $type, peopleCount: $peopleCount, priority: $priority, address: $addressText)';
}
