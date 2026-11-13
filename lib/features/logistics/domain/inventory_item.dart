// Stok kalemi modeli ve Kritik / Orta / Yeterli hesabı.


import 'package:flutter/foundation.dart';

enum StockLevel {
  critical,
  medium,
  sufficient,
}

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

  StockLevel get level {
    if (quantity <= criticalLevel) {
      return StockLevel.critical;
    }
    if (quantity < targetLevel * 0.5) {
      return StockLevel.medium;
    }
    return StockLevel.sufficient;
  }

  double get ratio {
    if (targetLevel <= 0) return 0;

    return (quantity / targetLevel)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}

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
