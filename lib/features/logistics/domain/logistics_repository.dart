// Lojistik repository arayüzü ve yetersiz stok hatası.

import 'inventory_item.dart';

// Lojistik repository arayüzü.
abstract class LogisticsRepository {
  // Depoları canlı izler.
  Stream<List<Warehouse>> watchWarehouses();

  // Deponun stok kalemlerini canlı izler.
  Stream<List<InventoryItem>> watchInventory(String warehouseId);

  // Stok giriş veya çıkışı yapar.
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
