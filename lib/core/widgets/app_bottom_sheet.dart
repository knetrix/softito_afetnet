// Ortak bottom sheet (alttan açılan panel) bileşeni.

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// AfetNet Standart Bottom Sheet (§3.2, screens-with-provider-integration §3)
abstract final class AppBottomSheet {
  /// Ekran üstü işlem panelini (bottom sheet) açar.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    bool isDismissible = true,
    Widget? trailing,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        // Renkler sheet açıkken tema değişirse de doğru kalsın diye burada okunur.
        final theme = Theme.of(bottomSheetContext);
        final colors = theme.colorScheme;
        // Zemin Material ile çizilir; içindeki ListTile/Checkbox dokunma efektleri
        // görünür kalır (DecoratedBox zemini bunları gizler).
        return Material(
          color: colors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            side: BorderSide(color: colors.outline),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(bottomSheetContext).bottom,
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sürükleme tutamacı (Drag handle)
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.outline,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Başlık satırı
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          ?trailing,
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () =>
                                Navigator.of(bottomSheetContext).pop(),
                            tooltip:
                                AppLocalizations.of(bottomSheetContext)
                                    ?.close ??
                                'Kapat',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
