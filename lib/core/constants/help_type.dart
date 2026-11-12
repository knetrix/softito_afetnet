/// AfetNet İhtiyaç / Yardım Türleri (PROJECT_NEW.md §4 Kural 1, §5.2).
///
/// Firestore `help_requests.type` ve `incidents.type` alanlarına `name` olarak yazılır.
enum HelpType {
  /// Enkaz Altında (Öncelik: 1 - Kritik)
  debris,

  /// Tıbbi Müdahale (Öncelik: 1 - Kritik)
  medical,

  /// Barınma / Çadır (Öncelik: 2 - Acil)
  shelter,

  /// Isınma (Öncelik: 2 - Acil)
  heating,

  /// Bebek Maması / Çocuk İhtiyacı (Öncelik: 2 - Acil)
  babyFood,

  /// İçme / Kullanma Suyu (Öncelik: 3 - Normal)
  water,

  /// Diğer İhtiyaçlar (Öncelik: 3 - Normal)
  other,
}
