import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/assembly_point.dart';
import '../domain/assembly_points_repository.dart';
import 'default_assembly_points.dart';

/// Firestore Toplanma Alanları Deposu (PROJECT_NEW.md §5.3: assembly_points/{pointId}).
class FirestoreAssemblyPointsRepository implements AssemblyPointsRepository {
  FirestoreAssemblyPointsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('assembly_points');

  @override
  Stream<List<AssemblyPoint>> watchAssemblyPoints() {
    return _collection.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return DefaultAssemblyPoints.list;
      }
      return snapshot.docs
          .map((doc) => AssemblyPoint.fromJson(doc.id, doc.data()))
          .toList();
    }).handleError((_) {
      // Çevrimdışı veya hata durumunda varsayılan güvenli listeyi dön
      return DefaultAssemblyPoints.list;
    });
  }

  @override
  Future<List<AssemblyPoint>> getAssemblyPoints() async {
    try {
      final snap = await _collection.get();
      if (snap.docs.isEmpty) {
        return DefaultAssemblyPoints.list;
      }
      return snap.docs
          .map((doc) => AssemblyPoint.fromJson(doc.id, doc.data()))
          .toList();
    } catch (_) {
      return DefaultAssemblyPoints.list;
    }
  }
}
