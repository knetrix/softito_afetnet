// "data" katmanı: depo ve stok işlemleri. Stok giriş/çıkışı tek bir Transaction'dır:
// miktar okunur, kontrol edilir (eksi stok yok), güncellenir ve hareket kaydı yazılır.


import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/inventory_item.dart';
import '../domain/logistics_repository.dart';

// Lojistik verilerinin Firestore uygulaması.
class FirestoreLogisticsRepository
    implements LogisticsRepository {
  FirestoreLogisticsRepository({
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // Depoları canlı izler.
  @override
  Stream<List<Warehouse>> watchWarehouses() {
    return _db.collection('warehouses').snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();

          return Warehouse(
            id: doc.id,
            name: data['name'] as String? ?? '',
            locationText:
                data['locationText'] as String?,
          );
        }).toList();
      },
    );
  }

  // Deponun stok kalemlerini canlı izler.
  @override
  Stream<List<InventoryItem>> watchInventory(
    String warehouseId,
  ) {
    return _db
        .collection('warehouses')
        .doc(warehouseId)
        .collection('inventory')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            return InventoryItem(
              id: doc.id,
              name: data['name'] as String? ?? '',
              unit: data['unit'] as String? ?? '',
              category:
                  data['category'] as String? ?? 'other',
              quantity:
                  (data['quantity'] as num?)?.toInt() ?? 0,
              targetLevel:
                  (data['targetLevel'] as num?)?.toInt() ?? 0,
              criticalLevel:
                  (data['criticalLevel'] as num?)?.toInt() ?? 0,
            );
          }).toList();
        });
  }

  // Stok giriş/çıkışı yapar. Transaction = ya hepsi olur ya hiçbiri: iki yetkili aynı anda çıkış yapsa bile
  // stok yanlış hesaplanmaz. Çıkış miktarı stoktan fazlaysa işlem reddedilir.
  @override
  Future<void> moveStock({
    required String warehouseId,
    required String itemId,
    required String userId,
    required int quantity,
    required bool isIncoming,
  }) async {
    // Önce basit kontroller: miktar pozitif olmalı ve işlemi yapan kullanıcı belli olmalı.
    if (quantity <= 0) {
      throw ArgumentError('Miktar sıfırdan büyük olmalı.');
    }

    if (userId.trim().isEmpty) {
      throw ArgumentError('Kullanıcı bulunamadı.');
    }

    // Kullanılacak belgelerin adresleri (referansları): depo, stok kalemi ve yeni hareket kaydı.
    // movements.doc() parametresiz çağrılınca Firestore yeni, benzersiz bir ID üretir.
    final warehouseRef =
        _db.collection('warehouses').doc(warehouseId);

    final itemRef =
        warehouseRef.collection('inventory').doc(itemId);

    final movementRef =
        warehouseRef.collection('movements').doc();

    await _db.runTransaction((transaction) async {
      // 1) Kalemin güncel miktarını Transaction içinde oku (o anki gerçek değer).
      final snapshot = await transaction.get(itemRef);

      if (!snapshot.exists) {
        throw StateError('Ürün bulunamadı.');
      }

      final data = snapshot.data()!;
      final currentQuantity =
          (data['quantity'] as num?)?.toInt() ?? 0;

      // 2) Girişse ekle, çıkışsa çıkar.
      final newQuantity = isIncoming
          ? currentQuantity + quantity
          : currentQuantity - quantity;

      // 3) Sonuç eksiye düşüyorsa işlemi durdur: hata fırlatılınca Transaction hiçbir şey yazmaz.
      if (newQuantity < 0) {
        throw const InsufficientStockException();
      }

      // 4) Yeni miktarı yaz.
      transaction.update(itemRef, {
        'quantity': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 5) Aynı işlemde hareket kaydını (kim, ne kadar, giriş/çıkış) yaz.
      transaction.set(movementRef, {
        'itemId': itemId,
        'type': isIncoming ? 'in' : 'out',
        'quantity': quantity,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
