// Toplanma noktası türleri: toplanma alanı, sahra hastanesi, barınma (çadır) alanı.

/// Toplanma Noktası Türleri (PROJECT_NEW.md §3.1 A2, §5.3).
enum AssemblyPointType {
  /// Genel Toplanma Alanı (park, meydan, okul bahçesi vb.)
  assembly,

  /// Sahra Hastanesi / Acil Tıbbi Müdahale Merkezi
  fieldHospital,

  /// Çadır Kent / Geçici Barınma Alanı
  shelter,
}
