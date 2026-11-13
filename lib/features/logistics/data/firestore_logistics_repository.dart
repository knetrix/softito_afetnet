// Depo ve stok verileri; giriş/çıkış tek Transaction (eksi stok yok).


import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/inventory_item.dart';
import '../domain/logistics_repository.dart';

class FirestoreLogisticsRepository
    implements LogisticsRepository {
  FirestoreLogisticsRepository({
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

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

  @override
  Future<void> moveStock({
    required String warehouseId,
    required String itemId,
    required String userId,
    required int quantity,
    required bool isIncoming,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Miktar sıfırdan büyük olmalı.');
    }

    if (userId.trim().isEmpty) {
      throw ArgumentError('Kullanıcı bulunamadı.');
    }

    final warehouseRef =
        _db.collection('warehouses').doc(warehouseId);

    final itemRef =
        warehouseRef.collection('inventory').doc(itemId);

    final movementRef =
        warehouseRef.collection('movements').doc();

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(itemRef);

      if (!snapshot.exists) {
        throw StateError('Ürün bulunamadı.');
      }

      final data = snapshot.data()!;
      final currentQuantity =
          (data['quantity'] as num?)?.toInt() ?? 0;

      final newQuantity = isIncoming
          ? currentQuantity + quantity
          : currentQuantity - quantity;

      if (newQuantity < 0) {
        throw const InsufficientStockException();
      }

      transaction.update(itemRef, {
        'quantity': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
