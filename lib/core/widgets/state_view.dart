import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage ?? 'Kayıt bulunamadı.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
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
                const Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage ?? 'Bir hata oluştu.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Tekrar Dene'),
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
