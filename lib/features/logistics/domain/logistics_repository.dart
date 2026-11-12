
import 'inventory_item.dart';

abstract class LogisticsRepository {
  Stream<List<Warehouse>> watchWarehouses();

  Stream<List<InventoryItem>> watchInventory(
    String warehouseId,
  );

  Future<void> moveStock({
    required String warehouseId,
    required String itemId,
    required String userId,
    required int quantity,
    required bool isIncoming,
  });
}
