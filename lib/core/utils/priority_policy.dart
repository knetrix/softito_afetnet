// Önceliği (triage) hesaplayan kural:
// Enkaz ve Tıbbi = 1 (Kritik), Barınma/Isınma/Bebek Maması = 2 (Acil), Su ve Diğer = 3 (Normal).

import '../constants/help_type.dart';

/// AfetNet Öncelik (Triage) Politikası (PROJECT_NEW.md §4 Kural 1).
///
/// Öncelik değeri (1: Kritik, 2: Acil, 3: Normal) yalnızca bu sınıf üzerinden
/// hesaplanır ve başka hiçbir yerde doğrudan türetilmez.
abstract final class PriorityPolicy {
  /// Kritik öncelik seviyesi (Enkaz altında, Tıbbi müdahale).
  static const int critical = 1;

  /// Acil öncelik seviyesi (Barınma, Isınma, Bebek maması).
  static const int urgent = 2;

  /// Normal öncelik seviyesi (Su, Diğer).
  static const int normal = 3;

  /// İhtiyaç türüne göre Kural 1 öncelik seviyesini (1, 2 veya 3) döndürür.
  static int calculate(HelpType type) {
    switch (type) {
      case HelpType.debris:
      case HelpType.medical:
        return critical;
      case HelpType.shelter:
      case HelpType.heating:
      case HelpType.babyFood:
        return urgent;
      case HelpType.water:
      case HelpType.other:
        return normal;
    }
  }

  /// İki öncelik seviyesinin en yükseğini (sayısal olarak küçük olanı: 1 > 2 > 3)
  /// döndürür (PROJECT_NEW.md §4 Kural 2 - Mükerrer birleştirme).
  static int highest(int a, int b) {
    return a <= b ? a : b;
  }
}
