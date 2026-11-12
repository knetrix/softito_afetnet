
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/inventory_item.dart';

class StockMovementSheet extends StatefulWidget {
  const StockMovementSheet({
    super.key,
    required this.item,
    required this.onSave,
  });

  final InventoryItem item;

  final Future<void> Function(
    int quantity,
    bool incoming,
  ) onSave;

  static Future<void> open(
    BuildContext context, {
    required InventoryItem item,
    required Future<void> Function(
      int quantity,
      bool incoming,
    ) onSave,
  }) {
    return AppBottomSheet.show<void>(
      context,
      title: item.name,
      child: StockMovementSheet(
        item: item,
        onSave: onSave,
      ),
    );
  }

  @override
  State<StockMovementSheet> createState() =>
      _StockMovementSheetState();
}

class _StockMovementSheetState
    extends State<StockMovementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  bool _isIncoming = true;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final quantity = int.parse(
        _quantityController.text.trim(),
      );

      await widget.onSave(quantity, _isIncoming);

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        if (error is StateError) {
          _error = error.message.toString();
        } else {
          _error = 'Stok işlemi tamamlanamadı.';
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Stok İşlemi',
            style: theme.textTheme.titleSmall,
          ),

          const SizedBox(height: 16),

          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                icon: Icon(Icons.add),
                label: Text('Giriş'),
              ),
              ButtonSegment<bool>(
                value: false,
                icon: Icon(Icons.remove),
                label: Text('Çıkış'),
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
              color: theme
                  .colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mevcut Stok'),
                Text(
                  '${widget.item.quantity} '
                  '${widget.item.unit}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
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
              labelText: 'Miktar',
              hintText: 'İşlem miktarını girin',
              suffixText: widget.item.unit,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              final quantity = int.tryParse(
                value?.trim() ?? '',
              );

              if (quantity == null || quantity <= 0) {
                return 'Geçerli bir miktar girin.';
              }

              if (!_isIncoming &&
                  quantity > widget.item.quantity) {
                return 'Yetersiz stok.';
              }

              return null;
            },
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
            ),
          ],

          const SizedBox(height: 24),

          AppButton.primary(
            label: _isIncoming
                ? 'Stok Girişi Yap'
                : 'Stok Çıkışı Yap',
            isLoading: _isSaving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
