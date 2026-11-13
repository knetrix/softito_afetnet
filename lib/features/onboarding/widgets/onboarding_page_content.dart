// Tek bir onboarding sayfasının içeriği: grafik, rozet, başlık ve açıklama.

import 'package:flutter/material.dart'; // Flutter temel arayüz kütüphanesidir

import '../../../core/theme/app_colors.dart'; // Uygulamanın özel tema renkleridir
import '../../../core/widgets/not_official_notice.dart'; // T15: 112 resmi kurum uyarısı
import '../../../l10n/app_localizations.dart';
import 'civilian_target_graphic.dart'; // 1. sayfa kalkan hedef görselidir
import 'field_radar_graphic.dart'; // 2. sayfa radar tarama görselidir
import 'onboarding_components.dart'; // Rozet, hap ve entegrasyon kartı bileşenleridir

// StatelessWidget: Durumu (state) sonradan değişmeyen, statik arayüz widget'ıdır
class OnboardingPageContent extends StatelessWidget {
  final int pageIndex; // Hangi sayfanın çizileceğini belirten indeks değeridir (0 veya 1)

  const OnboardingPageContent({super.key, required this.pageIndex});

  @override
  // build: Sayfanın görsel widget ağacını oluşturan metottur
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCivilian = pageIndex == 0; // 1. sayfa (Sivil kullanıcı) kontrolüdür

    final badgeText = isCivilian
        ? (l10n?.onboardingCivilianBadge ?? 'SİVİL KULLANICI')
        : (l10n?.onboardingOfficialBadge ?? 'SAHA YÖNETİMİ');

    final titleText = isCivilian
        ? (l10n?.onboardingCivilianTitle ?? 'Tek Dokunuşla Güvendesiniz')
        : (l10n?.onboardingOfficialTitle ?? 'Krizi Canlı Yönetin');

    final descText = isCivilian
        ? (l10n?.onboardingCivilianDesc ??
            'İnternet erişimi olmasa bile acil yardım çağrısı yapın, çevrimdışı düdüğü kullanın ve en yakın güvenli toplanma alanına ulaşın.')
        : (l10n?.onboardingOfficialDesc ??
            'Harita üzerinden canlı çağrıları takip edin, arama kurtarma ekiplerini yönlendirin ve sahra depolarının anlık stok durumunu yönetin.');

    final stockLabel = l10n?.onboardingStockPill ?? 'Canlı Sahra Stoğu';
    final teamLabel = l10n?.onboardingTeamPill ?? 'Ekip Takibi'; // T2: Ekip Takibi

    // LayoutBuilder: Ekranın anlık piksel sınırlarını (constraints) alıp uyum sağlayan widget'tır
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                isCivilian ? const CivilianTargetGraphic() : const FieldRadarGraphic(),
                const SizedBox(height: 24),
                CategoryBadge(
                  dotColor: isCivilian ? AppColors.primaryCyan : AppColors.danger,
                  text: badgeText,
                ),
                const SizedBox(height: 16),
                Text(
                  titleText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  descText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
                ),
                if (!isCivilian) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FeaturePill(icon: Icons.inventory_2_outlined, label: stockLabel),
                      const SizedBox(width: 10),
                      FeaturePill(icon: Icons.groups_outlined, label: teamLabel), // T2: Ekip Takibi
                    ],
                  ),
                  const SizedBox(height: 16),
                  const IntegrationCard(), // T1: Otomatik Önceliklendirme
                ] else ...[
                  const SizedBox(height: 24),
                  const NotOfficialNotice(), // T15: Resmi kurum değildir + 112
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
