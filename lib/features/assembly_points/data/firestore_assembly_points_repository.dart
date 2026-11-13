// Toplanma alanlarını Firestore'dan okur.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/assembly_point.dart';
import '../domain/assembly_points_repository.dart';

/// Firestore Toplanma Alanları Deposu (PROJECT_NEW.md §5.3: assembly_points/{pointId}).
///
/// Koleksiyon boşsa boş liste döner; uygulama içinde uydurma nokta gösterilmez
/// (var olmayan bir alan insanları yanlış yere gönderebilir). Demo verisini
/// G6 Firestore'a yazar (§8). Konumu geçersiz belgeler atlanır.
class FirestoreAssemblyPointsRepository implements AssemblyPointsRepository {
  FirestoreAssemblyPointsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('assembly_points');

  static List<AssemblyPoint> _parse(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs
          .map((doc) => AssemblyPoint.tryFromJson(doc.id, doc.data()))
          .whereType<AssemblyPoint>()
          .toList();

  @override
  Stream<List<AssemblyPoint>> watchAssemblyPoints() =>
      _collection.snapshots().map(_parse);

  @override
  Future<List<AssemblyPoint>> getAssemblyPoints() async =>
      _parse(await _collection.get());
}
