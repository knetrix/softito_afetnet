// Onboarding'in alt satırı: hangi sayfada olunduğunu gösteren noktalar ve İleri/Başla butonu.

import 'package:flutter/material.dart'; // Flutter temel görsel bileşenler kütüphanesidir

import '../../../core/theme/app_colors.dart'; // Uygulamanın renk paleti sınıfıdır
import '../../../l10n/app_localizations.dart';

// StatelessWidget: Durumu (state) sonradan değişmeyen, dışarıdan gelen verileri çizen widget'tır
class BottomNavigationRow extends StatelessWidget {
  final int currentPage; // Anlık aktif sayfa numarasını tutar (0 veya 1)
  final int totalPages; // Toplam sayfa sayısını tutar (varsayılan 2)
  final VoidCallback onActionPressed; // Butona basıldığında tetiklenen tıklama olayıdır

  const BottomNavigationRow({ // Kurucu metottur
    super.key,
    required this.currentPage,
    this.totalPages = 2,
    required this.onActionPressed,
  });

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLastPage = currentPage == totalPages - 1; // Son sayfada olup olunmadığını kontrol eder
    final actionLabel = isLastPage
        ? (l10n?.onboardingStart ?? 'BAŞLA')
        : (l10n?.onboardingNext ?? 'İleri');

    return Padding( // Kenarlardan iç boşluk bırakarak ekran sınırına yapışmayı önler
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (index) {
              final isActive = index == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: isActive ? 28 : 8,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryCyan : const Color(0xFF222B38),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isActive
                      ? [BoxShadow(color: AppColors.primaryCyan.withValues(alpha: 0.6), blurRadius: 8)]
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                foregroundColor: const Color(0xFF070B12),
                elevation: 4,
                shadowColor: AppColors.primaryCyan.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    actionLabel,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
