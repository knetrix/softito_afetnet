// Lojistik repository arayüzü ve yetersiz stok hatası.

import 'inventory_item.dart';

abstract class LogisticsRepository {
  Stream<List<Warehouse>> watchWarehouses();

  Stream<List<InventoryItem>> watchInventory(String warehouseId);

  Future<void> moveStock({
    required String warehouseId,
    required String itemId,
    required String userId,
    required int quantity,
    required bool isIncoming,
  });
}

/// Çıkış miktarı güncel stoktan fazla (Kural 3: eksi stok yok).
class InsufficientStockException implements Exception {
  const InsufficientStockException();
}
