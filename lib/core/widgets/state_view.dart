// Yükleniyor / Hata / Boş durumlarını gösteren ortak görünüm.

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_status_colors.dart';

/// Ekran veya liste durumları (§6.1, screens-with-provider-integration)
enum ViewStatus { loading, ready, empty, failure }

/// Ekranların ortak yüklenme, hata, boş ve hazır durum görünümü.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.status,
    required this.child,
    this.emptyMessage,
    this.errorMessage,
    this.onRetry,
    this.loadingWidget,
    this.emptyIcon = Icons.inbox_outlined,
  });

  final ViewStatus status;
  final Widget child;
  final String? emptyMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget? loadingWidget;
  final IconData emptyIcon;

  // Arayüzü çizer.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case ViewStatus.loading:
        return loadingWidget ??
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            );

      case ViewStatus.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  emptyIcon,
                  size: 56,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage ?? l10n?.emptyList ?? 'Kayıt bulunamadı.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        );

      case ViewStatus.failure:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: theme.extension<AppStatusColors>()!.critical,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage ?? l10n?.genericError ?? 'Bir hata oluştu.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n?.retry ?? 'Tekrar Dene'),
                  ),
                ],
              ],
            ),
          ),
        );

      case ViewStatus.ready:
        return child;
    }
  }
}

