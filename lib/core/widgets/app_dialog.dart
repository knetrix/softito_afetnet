// Uygulamanın ortak diyalog (açılır pencere) bileşeni.
// "Emin misiniz?" gibi onay soruları ve bilgi mesajları için kullanılır.

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_status_colors.dart';

/// AfetNet Standart Onay ve Bilgi Diyaloğu
abstract final class AppDialog {
  /// Onay diyaloğu (Çağrı İptal, Çıkış Yap, Hesabı Sil vb.)
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colors = theme.colorScheme;
        final l10n = AppLocalizations.of(dialogContext);
        final danger = theme.extension<AppStatusColors>()!.critical;
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colors.outline,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel ?? l10n?.cancel ?? 'İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    destructive ? danger : colors.primary,
                foregroundColor:
                    destructive ? colors.onError : colors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(confirmLabel ?? l10n?.confirm ?? 'Onayla'),
            ),
          ],
        );
      },
    );
  }

  /// Bilgilendirme diyaloğu
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonLabel,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colors = theme.colorScheme;
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colors.outline,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonLabel ?? l10n?.ok ?? 'Tamam'),
            ),
          ],
        );
      },
    );
  }
}

