// Çağrı, olay ve görevlerin alabileceği durumlar.
// Akış: pending (beklemede) → assigned (atandı) → enRoute (yola çıktı) → onSite (olay yerinde) → resolved (çözüldü).

/// AfetNet Çağrı, Görev ve Olay Durumları.
///
/// Firestore `help_requests.status`, `incidents.status` ve `assignments.status`
/// alanlarına `name` değeri olarak yazılır.
enum CaseStatus {
  /// Beklemede (Yeni açılmış çağrı / olay)
  pending,

  /// Ekip atandı
  assigned,

  /// Ekip yola çıktı
  enRoute,

  /// Ekip olay yerinde
  onSite,

  /// Kurtarıldı / Çözüldü (Olay kapandı)
  resolved,

  /// İptal edildi (Yalnızca afetzede tarafından çağrı kapatıldığında)
  cancelled,
}
