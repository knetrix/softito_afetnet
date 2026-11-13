// "domain" katmanı: toplanma alanlarını getirme sözleşmesi (arayüz).
// Ekranlar Firestore'u değil bu arayüzü bilir; böylece testte sahte veri verilebilir.

import 'assembly_point.dart';

/// Toplanma Alanları Depo Arayüzü.
abstract class AssemblyPointsRepository {
  /// Tüm toplanma alanlarını canlı akış olarak dinler.
  Stream<List<AssemblyPoint>> watchAssemblyPoints();

  /// Tüm toplanma alanlarını tek seferlik çeker.
  Future<List<AssemblyPoint>> getAssemblyPoints();
}
