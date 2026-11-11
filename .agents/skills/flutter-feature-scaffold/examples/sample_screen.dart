// AfetNet örnek feature: Lojistik (Y3) — stok kartları + Giriş/Çıkış sheet'i.
//
// Okuması kolay olsun diye katmanlar tek dosyada gösterilmiştir. Projede şöyle bölünür:
//   domain/inventory_item.dart               InventoryItem
//   domain/stock_level.dart                  StockLevel, stockLevelOf, stockRatio
//   domain/inventory_repository.dart         InventoryRepository, MovementType, InsufficientStockFailure
//   data/firestore_inventory_repository.dart (Transaction: flutter-development state rehberi §5.6)
//   presentation/logistics_controller.dart
//   presentation/logistics_screen.dart
//   presentation/widgets/stock_card.dart, critical_stock_alert.dart, stock_filter_chips.dart
//   presentation/sheets/stock_move_sheet.dart
//
// Kurallar: PROJECT_NEW.md §4 Kural 3 (stok), §3.3 T7 (3 etiket, "Acil İkmal İste" yok).
// Ekranda sabit metin ve sabit renk yoktur; ARB anahtarları ve AppStatusColors kullanılır.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_status_colors.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/state_view.dart';
import '../../../l10n/app_localizations.dart';

// ============================================================================
// domain/
// ============================================================================

@immutable
class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.targetLevel,
    required this.criticalLevel,
  });

  final String id;
  final String name; // seed verisi ("İçme Suyu 5 L"); veri olduğu için ARB'ye girmez
  final String unit;
  final int quantity; // >= 0 (Security Rules da doğrular)
  final int targetLevel;
  final int criticalLevel;

  InventoryItem copyWith({int? quantity}) => InventoryItem(
        id: id,
        name: name,
        unit: unit,
        quantity: quantity ?? this.quantity,
        targetLevel: targetLevel,
        criticalLevel: criticalLevel,
      );
}

enum StockLevel { critical, medium, sufficient }

/// Eşikler PROJECT_NEW.md §4 Kural 3 tablosundandır.
StockLevel stockLevelOf(InventoryItem i) {
  if (i.quantity <= i.criticalLevel) return StockLevel.critical;
  if (i.quantity < i.targetLevel * 0.5) return StockLevel.medium;
  return StockLevel.sufficient;
}

/// Stok düzeyi oranı, en fazla 1.0 (%100).
double stockRatio(InventoryItem i) =>
    i.targetLevel <= 0 ? 0 : (i.quantity / i.targetLevel).clamp(0.0, 1.0);

enum MovementType { stockIn, stockOut } // Firestore'a 'in' / 'out' olarak yazılır (data/)

class InsufficientStockFailure implements Exception {
  const InsufficientStockFailure();
}

abstract interface class InventoryRepository {
  Stream<List<InventoryItem>> watchInventory(String warehouseId);

  /// Tek Transaction: kalem okunur, eksi stok reddedilir ([InsufficientStockFailure]),
  /// `quantity` güncellenir ve `movements` kaydı yazılır.
  Future<void> move({
    required String warehouseId,
    required String itemId,
    required MovementType type,
    required int amount,
  });
}

// ============================================================================
// presentation/logistics_controller.dart
// ============================================================================

enum StockFilter { all, critical, medium, sufficient }

enum MoveResult { success, insufficient, failure }

class LogisticsController extends ChangeNotifier {
  LogisticsController(this._repo, {required this.warehouseId}) {
    _sub = _repo.watchInventory(warehouseId).listen(
          _onData,
          onError: (Object _) => _setStatus(ViewStatus.failure),
        );
  }

  final InventoryRepository _repo;
  final String warehouseId;
  late final StreamSubscription<List<InventoryItem>> _sub;
  bool _disposed = false;

  ViewStatus _status = ViewStatus.loading;
  ViewStatus get status => _status;

  List<InventoryItem> _items = const [];

  StockFilter _filter = StockFilter.all;
  StockFilter get filter => _filter;

  bool _busy = false;
  bool get busy => _busy;

  /// Üstteki kritik stok uyarı kartı için (filtreden bağımsız).
  List<InventoryItem> get criticalItems => _byLevel(StockLevel.critical);

  /// Filtre istemcide uygulanır.
  List<InventoryItem> get visibleItems => switch (_filter) {
        StockFilter.all => _items,
        StockFilter.critical => _byLevel(StockLevel.critical),
        StockFilter.medium => _byLevel(StockLevel.medium),
        StockFilter.sufficient => _byLevel(StockLevel.sufficient),
      };

  void setFilter(StockFilter f) {
    if (f == _filter) return;
    _filter = f;
    _notify();
  }

  Future<MoveResult> move(InventoryItem item, MovementType type, int amount) async {
    if (_busy || amount <= 0) return MoveResult.failure;
    _busy = true;
    _notify();
    try {
      await _repo.move(warehouseId: warehouseId, itemId: item.id, type: type, amount: amount);
      // Liste elle güncellenmez; stream yeni snapshot'ı getirir.
      return MoveResult.success;
    } on InsufficientStockFailure {
      return MoveResult.insufficient;
    } catch (_) {
      return MoveResult.failure;
    } finally {
      _busy = false;
      _notify();
    }
  }

  List<InventoryItem> _byLevel(StockLevel l) =>
      _items.where((i) => stockLevelOf(i) == l).toList();

  void _onData(List<InventoryItem> data) {
    _items = data;
    _setStatus(data.isEmpty ? ViewStatus.empty : ViewStatus.ready);
  }

  void _setStatus(ViewStatus s) {
    _status = s;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub.cancel();
    super.dispose();
  }
}

// ============================================================================
// presentation/logistics_screen.dart
// ============================================================================

class LogisticsScreen extends StatelessWidget {
  const LogisticsScreen({super.key, required this.warehouseId});

  final String warehouseId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => LogisticsController(ctx.read<InventoryRepository>(), warehouseId: warehouseId),
      child: const _LogisticsView(),
    );
  }
}

class _LogisticsView extends StatelessWidget {
  const _LogisticsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.watch<LogisticsController>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.logisticsTitle)),
      body: SafeArea(
        child: StateView(
          status: c.status,
          emptyMessage: l10n.logisticsEmpty,
          child: CustomScrollView(
            slivers: [
              if (c.criticalItems.isNotEmpty)
                SliverToBoxAdapter(child: CriticalStockAlert(count: c.criticalItems.length)),
              SliverToBoxAdapter(
                child: StockFilterChips(selected: c.filter, onSelected: c.setFilter),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.separated(
                  itemCount: c.visibleItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final item = c.visibleItems[i];
                    return StockCard(item: item, onTap: () => _openMoveSheet(context, item));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ayrı ekran değil, bottom sheet (PROJECT_NEW.md §3.2: Y3 stok kartına dokunma).
  Future<void> _openMoveSheet(BuildContext context, InventoryItem item) async {
    final input = await AppBottomSheet.show<StockMoveInput>(
      context,
      title: item.name,
      child: StockMoveSheet(item: item),
    );
    if (input == null || !context.mounted) return;

    final result = await context.read<LogisticsController>().move(item, input.type, input.amount);
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final message = switch (result) {
      MoveResult.success => l10n.saved,
      MoveResult.insufficient => l10n.stockInsufficient,
      MoveResult.failure => l10n.genericError,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

// ============================================================================
// presentation/widgets/
// ============================================================================

class CriticalStockAlert extends StatelessWidget {
  const CriticalStockAlert({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    return Card(
      margin: const EdgeInsets.all(16),
      color: status.critical.withValues(alpha: 0.12),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: status.critical),
        title: Text(AppLocalizations.of(context)!.logisticsCriticalAlert(count)),
      ),
    );
  }
}

class StockFilterChips extends StatelessWidget {
  const StockFilterChips({super.key, required this.selected, required this.onSelected});

  final StockFilter selected;
  final ValueChanged<StockFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String label(StockFilter f) => switch (f) {
          StockFilter.all => l10n.filterAll,
          StockFilter.critical => l10n.stockLevelCritical,
          StockFilter.medium => l10n.stockLevelMedium,
          StockFilter.sufficient => l10n.stockLevelSufficient,
        };

    // Wrap: dar ekranda taşmaz, alt satıra iner.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final f in StockFilter.values)
            ChoiceChip(
              label: Text(label(f)),
              selected: f == selected,
              onSelected: (_) => onSelected(f),
            ),
        ],
      ),
    );
  }
}

class StockCard extends StatelessWidget {
  const StockCard({super.key, required this.item, this.onTap});

  final InventoryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final status = theme.extension<AppStatusColors>()!;
    final ratio = stockRatio(item);
    final (color, label) = switch (stockLevelOf(item)) {
      StockLevel.critical => (status.critical, l10n.stockLevelCritical),
      StockLevel.medium => (status.urgent, l10n.stockLevelMedium),
      StockLevel.sufficient => (status.normal, l10n.stockLevelSufficient),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color)),
                ],
              ),
              const SizedBox(height: 4),
              Text('${item.quantity} ${item.unit}', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: ratio,
                      color: color,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('%${(ratio * 100).round()}', style: theme.textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// presentation/sheets/stock_move_sheet.dart
// ============================================================================

@immutable
class StockMoveInput {
  const StockMoveInput(this.type, this.amount);

  final MovementType type;
  final int amount;
}

/// Form durumu sheet'e aittir; sheet kapanınca atılır.
class StockMoveSheet extends StatefulWidget {
  const StockMoveSheet({super.key, required this.item});

  final InventoryItem item;

  @override
  State<StockMoveSheet> createState() => _StockMoveSheetState();
}

class _StockMoveSheetState extends State<StockMoveSheet> {
  final _amount = TextEditingController();
  MovementType _type = MovementType.stockOut;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  int? get _parsed {
    final v = int.tryParse(_amount.text);
    return (v == null || v <= 0) ? null : v;
  }

  // Eksi stok burada da engellenir; asıl koruma Transaction'dadır.
  bool get _exceedsStock =>
      _type == MovementType.stockOut && (_parsed ?? 0) > widget.item.quantity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canSave = _parsed != null && !_exceedsStock;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<MovementType>(
          segments: [
            ButtonSegment(value: MovementType.stockIn, label: Text(l10n.stockIn)),
            ButtonSegment(value: MovementType.stockOut, label: Text(l10n.stockOut)),
          ],
          selected: {_type},
          onSelectionChanged: (s) => setState(() => _type = s.first),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l10n.stockAmount,
            suffixText: widget.item.unit,
            errorText: _exceedsStock ? l10n.stockInsufficient : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: canSave
              ? () => Navigator.of(context).pop(StockMoveInput(_type, _parsed!))
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
