// "data" katmanı: toplanma alanlarını Firestore'daki assembly_points koleksiyonundan okur.
// Domain'deki AssemblyPointsRepository arayüzünü uygular (Clean Architecture).

import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/assembly_point.dart';
import '../domain/assembly_points_repository.dart';

/// Firestore Toplanma Alanları Deposu (`assembly_points/{pointId}`).
///
/// Koleksiyon boşsa boş liste döner; uygulama içinde uydurma nokta gösterilmez
/// (var olmayan bir alan insanları yanlış yere gönderebilir). Demo verisini
/// G6 Firestore'a yazar. Konumu geçersiz belgeler atlanır.
class FirestoreAssemblyPointsRepository implements AssemblyPointsRepository {
  FirestoreAssemblyPointsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // assembly_points koleksiyonu.
  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('assembly_points');

  // Firestore'dan gelen belgeleri (Map) tek tek AssemblyPoint nesnesine çevirip liste yapar.
  static List<AssemblyPoint> _parse(QuerySnapshot<Map<String, dynamic>> snap) =>
      snap.docs
          .map((doc) => AssemblyPoint.tryFromJson(doc.id, doc.data()))
          .whereType<AssemblyPoint>()
          .toList();

  // Toplanma noktalarını canlı dinler (Stream): Firestore'da bir nokta değişince ekran kendiliğinden güncellenir.
  @override
  Stream<List<AssemblyPoint>> watchAssemblyPoints() =>
      _collection.snapshots().map(_parse);

  // Toplanma noktalarını bir kez okur.
  @override
  Future<List<AssemblyPoint>> getAssemblyPoints() async =>
      _parse(await _collection.get());
}
