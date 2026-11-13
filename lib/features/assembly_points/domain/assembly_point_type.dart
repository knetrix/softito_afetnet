// Toplanma noktası türleri: toplanma alanı, sahra hastanesi, barınma (çadır) alanı.

/// Toplanma Noktası Türleri.
enum AssemblyPointType {
  /// Genel Toplanma Alanı (park, meydan, okul bahçesi vb.)
  assembly,

  /// Sahra Hastanesi / Acil Tıbbi Müdahale Merkezi
  fieldHospital,

  /// Çadır Kent / Geçici Barınma Alanı
  shelter,
}
