import 'package:afetnet/features/demo_seed/data/demo_seed_service.dart';
import 'package:afetnet/features/logistics/domain/inventory_item.dart';
import 'package:flutter_test/flutter_test.dart';

InventoryItem _item(String id, Map<String, dynamic> d, {int? quantity}) =>
    InventoryItem(
      id: id,
      name: d['name'] as String,
      unit: d['unit'] as String,
      category: d['category'] as String,
      quantity: quantity ?? d['quantity'] as int,
      targetLevel: d['targetLevel'] as int,
      criticalLevel: d['criticalLevel'] as int,
    );

void main() {
  test(
    'demo başında kritik stok yok; 50 koli su çıkışı kritik yapar',
    () {
      for (final e in DemoSeedService.inventory.entries) {
        expect(
          _item(e.key, e.value).level,
          isNot(StockLevel.critical),
          reason: e.key,
        );
      }
      final water = DemoSeedService.inventory['water']!;
      final after = _item(
        'water',
        water,
        quantity: (water['quantity'] as int) - 50,
      );
      expect(after.level, StockLevel.critical);
    },
  );

  test('demo yetkilisinin ekibi team_04 = Arama Kurtarma Tim 4', () {
    expect(DemoSeedService.teams['team_04']!['name'], 'Arama Kurtarma Tim 4');
    for (final t in DemoSeedService.teams.values) {
      expect(t['status'], 'available');
      expect(t.containsKey('currentTask'), isFalse);
      expect((t['geohash'] as String).length, 8);
    }
  });

  test('toplanma noktaları kurallara uygun (currentCount <= capacity)', () {
    for (final p in DemoSeedService.assemblyPoints.values) {
      expect(p['currentCount'] as int, lessThanOrEqualTo(p['capacity'] as int));
      expect((p['geohash'] as String).length, 8);
    }
  });
}
