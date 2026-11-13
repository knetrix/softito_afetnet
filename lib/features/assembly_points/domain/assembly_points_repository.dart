// Toplanma alanları repository arayüzü.

import 'assembly_point.dart';

/// Toplanma Alanları Depo Arayüzü (PROJECT_NEW.md §3.1 A2, §5.3).
abstract class AssemblyPointsRepository {
  /// Tüm toplanma alanlarını canlı akış olarak dinler.
  Stream<List<AssemblyPoint>> watchAssemblyPoints();

  /// Tüm toplanma alanlarını tek seferlik çeker.
  Future<List<AssemblyPoint>> getAssemblyPoints();
}
