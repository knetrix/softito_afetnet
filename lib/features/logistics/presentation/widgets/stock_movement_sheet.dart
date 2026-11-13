// Stok giriş / çıkış formu.

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/inventory_item.dart';
import '../../domain/logistics_repository.dart';

// Stok giriş/çıkış formu.
class StockMovementSheet extends StatefulWidget {
  const StockMovementSheet({
    super.key,
    required this.item,
    required this.onSave,
  });

  final InventoryItem item;

  final Future<void> Function(int quantity, bool incoming) onSave;

  // Formu alttan açar.
  static Future<void> open(
    BuildContext context, {
    required InventoryItem item,
    required Future<void> Function(int quantity, bool incoming) onSave,
  }) {
    return AppBottomSheet.show<void>(
      context,
      title: item.name,
      child: StockMovementSheet(item: item, onSave: onSave),
    );
  }

  // Widget'ın durum (State) nesnesini oluşturur.
  @override
  State<StockMovementSheet> createState() => _StockMovementSheetState();
}

// Hareket türünü, miktarı ve kaydetmeyi yönetir.
class _StockMovementSheetState extends State<StockMovementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  bool _isIncoming = true;
  bool _isSaving = false;
  String? _error;

  // Kapanırken dinleyicileri ve kaynakları serbest bırakır.
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  // Hareketi kaydeder; stok yetersizse uyarır.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final quantity = int.parse(_quantityController.text.trim());

      await widget.onSave(quantity, _isIncoming);

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      // Transaction eksi stoğu reddeder (Kural 3): bu arada başka biri stok
      // düşmüş olabilir.
      setState(() {
        _error = error is InsufficientStockException
            ? l10n.stockInsufficient
            : l10n.stockSaveFailed;
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Arayüzü çizer.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.stockMovementTitle, style: theme.textTheme.titleSmall),

          const SizedBox(height: 16),

          SegmentedButton<bool>(
            segments: [
              ButtonSegment<bool>(
                value: true,
                icon: const Icon(Icons.add),
                label: Text(l10n.stockIn),
              ),
              ButtonSegment<bool>(
                value: false,
                icon: const Icon(Icons.remove),
                label: Text(l10n.stockOut),
              ),
            ],
            selected: {_isIncoming},
            onSelectionChanged: _isSaving
                ? null
                : (selection) {
                    setState(() {
                      _isIncoming = selection.first;
                    });
                  },
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.stockCurrent),
                Text(
                  '${widget.item.quantity} '
                  '${widget.item.unit}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          TextFormField(
            controller: _quantityController,
            enabled: !_isSaving,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.stockQuantity,
              hintText: l10n.stockQuantityHint,
              suffixText: widget.item.unit,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              final quantity = int.tryParse(value?.trim() ?? '');

              if (quantity == null || quantity <= 0) {
                return l10n.stockInvalidQuantity;
              }

              if (!_isIncoming && quantity > widget.item.quantity) {
                return l10n.stockInsufficient;
              }

              return null;
            },
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],

          const SizedBox(height: 24),

          AppButton.primary(
            label: _isIncoming ? l10n.stockSaveIn : l10n.stockSaveOut,
            isLoading: _isSaving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
