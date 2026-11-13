// Y3 Lojistik ekranı (yetkili): depo seçimi, kritik stok uyarı kartı, filtreler (Tümü / Kritik / Orta / Yeterli)
// ve stok kartları. Karta dokununca giriş/çıkış formu açılır.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/widgets/state_view.dart';
import '../../../l10n/app_localizations.dart';

import '../data/firestore_logistics_repository.dart';
import '../domain/inventory_item.dart';
import '../domain/logistics_repository.dart';
import 'widgets/stock_movement_sheet.dart';

// Stok filtresi: tümü, kritik, orta, yeterli.
enum InventoryFilter { all, critical, medium, sufficient }

// Y3 Lojistik ekranı.
class LogisticsScreen extends StatefulWidget {
  const LogisticsScreen({super.key, this.repository});

  final LogisticsRepository? repository;

  // Bu StatefulWidget'ın değişen verilerini tutacak State nesnesini oluşturur.
  @override
  State<LogisticsScreen> createState() => _LogisticsScreenState();
}

// Depoları dinler ve seçili depoyu tutar.
class _LogisticsScreenState extends State<LogisticsScreen> {
  late final LogisticsRepository _repository;
  late Stream<List<Warehouse>> _warehouseStream;

  String? _selectedWarehouseId;
  InventoryFilter _selectedFilter = InventoryFilter.all;

  // Widget ekrana ilk geldiğinde yalnızca bir kez çalışır; dinleyiciler ve başlangıç verileri burada hazırlanır.
  @override
  void initState() {
    super.initState();

    _repository = widget.repository ?? FirestoreLogisticsRepository();

    _warehouseStream = _repository.watchWarehouses();
  }

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return StreamBuilder<List<Warehouse>>(
      stream: _warehouseStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StateView(
            status: ViewStatus.failure,
            errorMessage: strings.logisticsWarehouseLoadFailed,
            onRetry: () {
              setState(() {
                _warehouseStream = _repository.watchWarehouses();
              });
            },
            child: const SizedBox.shrink(),
          );
        }

        if (!snapshot.hasData) {
          return const StateView(
            status: ViewStatus.loading,
            child: SizedBox.shrink(),
          );
        }

        final warehouses = snapshot.data!;

        // Depo ve stok seed verisidir; debug derlemede Profil'deki
        // "Demo Verisini Sıfırla" ile yüklenir.
        if (warehouses.isEmpty) {
          return StateView(
            status: ViewStatus.empty,
            emptyMessage: strings.logisticsNoWarehouses,
            emptyIcon: Icons.warehouse_outlined,
            child: const SizedBox.shrink(),
          );
        }

        final selected = warehouses.where(
          (warehouse) => warehouse.id == _selectedWarehouseId,
        );

        final warehouse = selected.isEmpty ? warehouses.first : selected.first;

        return _InventoryContent(
          key: ValueKey(warehouse.id),
          warehouse: warehouse,
          warehouses: warehouses,
          repository: _repository,
          selectedFilter: _selectedFilter,
          onFilterChanged: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
          onWarehouseChanged: (id) {
            setState(() {
              _selectedWarehouseId = id;
              _selectedFilter = InventoryFilter.all;
            });
          },
        );
      },
    );
  }
}

// --------------------------------------------------
// ENVANTER EKRANI
// --------------------------------------------------

// Seçili deponun stok listesi.
class _InventoryContent extends StatefulWidget {
  const _InventoryContent({
    super.key,
    required this.warehouse,
    required this.warehouses,
    required this.repository,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onWarehouseChanged,
  });

  final Warehouse warehouse;
  final List<Warehouse> warehouses;
  final LogisticsRepository repository;
  final InventoryFilter selectedFilter;
  final ValueChanged<InventoryFilter> onFilterChanged;
  final ValueChanged<String?> onWarehouseChanged;

  // Bu StatefulWidget'ın değişen verilerini tutacak State nesnesini oluşturur.
  @override
  State<_InventoryContent> createState() => _InventoryContentState();
}

// Seçili deponun stoklarını canlı dinler; bir kalem kritik seviyeye inerse yetkiliye bildirim gösterir.
class _InventoryContentState extends State<_InventoryContent> {
  late Stream<List<InventoryItem>> _inventoryStream;

  /// Önceki snapshot'taki kritik kalemler; ilk yüklemede `null` (bildirim
  /// yalnızca bir kalem bu ekranda kritik düzeye inince gösterilir).
  Set<String>? _previousCriticalIds;

  // Widget ekrana ilk geldiğinde yalnızca bir kez çalışır; dinleyiciler ve başlangıç verileri burada hazırlanır.
  @override
  void initState() {
    super.initState();

    _inventoryStream = widget.repository.watchInventory(widget.warehouse.id);
  }

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return StreamBuilder<List<InventoryItem>>(
      stream: _inventoryStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return StateView(
            status: ViewStatus.failure,
            errorMessage: strings.logisticsInventoryLoadFailed,
            onRetry: () {
              setState(() {
                _inventoryStream = widget.repository.watchInventory(
                  widget.warehouse.id,
                );
              });
            },
            child: const SizedBox.shrink(),
          );
        }

        if (!snapshot.hasData) {
          return const StateView(
            status: ViewStatus.loading,
            child: SizedBox.shrink(),
          );
        }

        final items = snapshot.data!;

        final criticalItems = items
            .where((item) => item.level == StockLevel.critical)
            .toList();

        _checkCriticalStock(criticalItems);

        final filteredItems = items.where((item) {
          return switch (widget.selectedFilter) {
            InventoryFilter.all => true,
            InventoryFilter.critical => item.level == StockLevel.critical,
            InventoryFilter.medium => item.level == StockLevel.medium,
            InventoryFilter.sufficient => item.level == StockLevel.sufficient,
          };
        }).toList();

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildWarehouseCard(context),

              if (criticalItems.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildCriticalWarning(context, criticalItems),
              ],

              const SizedBox(height: 24),

              _buildInventoryHeader(context, items.length),

              const SizedBox(height: 14),
              _buildFilters(),
              const SizedBox(height: 16),

              if (filteredItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    strings.logisticsNoFilteredItems,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth >= 650 ? 3 : 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 190,
                      ),
                      itemBuilder: (context, index) {
                        return _buildStockCard(context, filteredItems[index]);
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Kalem kritik düzeye inince yetkiliye yerel bildirim. İlk
  /// yüklemede zaten kritik olan kalemler yalnızca uyarı kartında görünür.
  void _checkCriticalStock(List<InventoryItem> criticalItems) {
    final currentIds = criticalItems.map((item) => item.id).toSet();
    final previous = _previousCriticalIds;
    _previousCriticalIds = currentIds;
    if (previous == null) return;

    final newlyCritical = criticalItems
        .where((item) => !previous.contains(item.id))
        .toList();
    if (newlyCritical.isEmpty) return;

    final strings = AppLocalizations.of(context)!;
    final notifications = context.read<NotificationService>();
    for (final item in newlyCritical) {
      notifications.showLocalNotification(
        id: Object.hash(widget.warehouse.id, item.id) & 0x7fffffff,
        title: strings.logisticsCriticalTitle,
        body: strings.logisticsCriticalNotification(item.name),
        payload: 'stock:${widget.warehouse.id}/${item.id}',
      );
    }
  }

  // Ekran başlığı.
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(Icons.circle, size: 9, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            strings.logisticsTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  // Depo bilgi kartı.
  Widget _buildWarehouseCard(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context)!;

    return _LogisticsPanel(
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.warehouse_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.warehouses.length > 1)
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: widget.warehouse.id,
                      items: widget.warehouses.map((warehouse) {
                        return DropdownMenuItem<String>(
                          value: warehouse.id,
                          child: Text(warehouse.name),
                        );
                      }).toList(),
                      onChanged: widget.onWarehouseChanged,
                    ),
                  )
                else
                  Text(
                    widget.warehouse.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  widget.warehouse.locationText ??
                      strings.logisticsMissingLocation,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Kritik stok uyarı kartı.
  Widget _buildCriticalWarning(
    BuildContext context,
    List<InventoryItem> criticalItems,
  ) {
    final strings = AppLocalizations.of(context)!;
    final critical = Theme.of(context).extension<AppStatusColors>()!.critical;

    return _LogisticsPanel(
      backgroundColor: critical.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: critical),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.logisticsCriticalTitle,
                  style: TextStyle(
                    color: critical,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 15,
                backgroundColor: critical,
                child: Text(
                  '${criticalItems.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(criticalItems.map((item) => item.name).join(', ')),
        ],
      ),
    );
  }

  // Envanter başlığı ve kalem sayısı.
  Widget _buildInventoryHeader(BuildContext context, int count) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context)!;

    return Row(
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            strings.logisticsInventoryTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          strings.logisticsItemCount(count),
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }

  // Stok düzeyi filtre chip'leri.
  Widget _buildFilters() {
    final strings = AppLocalizations.of(context)!;

    final filters = {
      InventoryFilter.all: strings.logisticsAll,
      InventoryFilter.critical: strings.logisticsCritical,
      InventoryFilter.medium: strings.logisticsMedium,
      InventoryFilter.sufficient: strings.logisticsSufficient,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: widget.selectedFilter == entry.key,
              onSelected: (_) {
                widget.onFilterChanged(entry.key);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // Stok kartı: miktar, düzey çubuğu, etiket.
  Widget _buildStockCard(BuildContext context, InventoryItem item) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context)!;

    final statusColors = theme.extension<AppStatusColors>()!;

    final color = switch (item.level) {
      StockLevel.critical => statusColors.critical,
      StockLevel.medium => statusColors.urgent,
      StockLevel.sufficient => statusColors.normal,
    };

    final statusText = switch (item.level) {
      StockLevel.critical => strings.logisticsCritical.toUpperCase(),
      StockLevel.medium => strings.logisticsMedium.toUpperCase(),
      StockLevel.sufficient => strings.logisticsSufficient.toUpperCase(),
    };

    final categoryIcon = switch (item.category) {
      'water' => Icons.water_drop_outlined,
      'food' => Icons.restaurant_outlined,
      'medical' => Icons.medical_services_outlined,
      'shelter' => Icons.home_outlined,
      'energy' => Icons.bolt_outlined,
      _ => Icons.inventory_2_outlined,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openStockMovement(item),
      child: _LogisticsPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(categoryIcon, size: 18, color: color),
                ),
                const Spacer(),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${item.quantity} ${item.unit}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.logisticsStockLevel,
                  style: theme.textTheme.labelSmall,
                ),
                Text(
                  '${(item.ratio * 100).round()}%',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 7),
            LinearProgressIndicator(
              value: item.ratio,
              minHeight: 5,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      ),
    );
  }

  // Stok giriş/çıkış formunu açar.
  Future<void> _openStockMovement(InventoryItem item) async {
    final strings = AppLocalizations.of(context)!;

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.logisticsLoginRequired)));
      return;
    }

    await StockMovementSheet.open(
      context,
      item: item,
      onSave: (quantity, incoming) {
        return widget.repository.moveStock(
          warehouseId: widget.warehouse.id,
          itemId: item.id,
          userId: userId,
          quantity: quantity,
          isIncoming: incoming,
        );
      },
    );
  }
}

// --------------------------------------------------
// ORTAK PANEL
// --------------------------------------------------

// Ortak kart çerçevesi.
class _LogisticsPanel extends StatelessWidget {
  const _LogisticsPanel({required this.child, this.backgroundColor});

  final Widget child;
  final Color? backgroundColor;

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }
}
