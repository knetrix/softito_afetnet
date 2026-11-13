// Stok kalemi modeli ve Kritik / Orta / Yeterli hesabı.


import 'package:flutter/foundation.dart';

// Stok düzeyi: Kritik / Orta / Yeterli.
enum StockLevel {
  critical,
  medium,
  sufficient,
}

// Stok kalemi modeli.
@immutable
class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    required this.quantity,
    required this.targetLevel,
    required this.criticalLevel,
  });

  final String id;
  final String name;
  final String unit;
  final String category;
  final int quantity;
  final int targetLevel;
  final int criticalLevel;

  // Miktara göre stok düzeyi (Kural 3).
  StockLevel get level {
    if (quantity <= criticalLevel) {
      return StockLevel.critical;
    }
    if (quantity < targetLevel * 0.5) {
      return StockLevel.medium;
    }
    return StockLevel.sufficient;
  }

  // Hedef seviyeye göre doluluk oranı (en fazla 1).
  double get ratio {
    if (targetLevel <= 0) return 0;

    return (quantity / targetLevel)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}

// Depo modeli.
@immutable
class Warehouse {
  const Warehouse({
    required this.id,
    required this.name,
    this.locationText,
  });

  final String id;
  final String name;
  final String? locationText;
}
