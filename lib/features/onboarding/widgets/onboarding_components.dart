// Onboarding'in küçük ortak parçaları (rozet, özellik etiketi).

import 'package:flutter/material.dart'; // Flutter temel arayüz bileşenleri kütüphanesidir

import '../../../core/theme/app_colors.dart'; // Uygulamanın renk paleti sınıfıdır
import '../../../l10n/app_localizations.dart';

// StatelessWidget: Başlık üstündeki renkli kategori rozetini (SİVİL KULLANICI / SAHA YÖNETİMİ) çizen bileşendir
class CategoryBadge extends StatelessWidget {
  final Color dotColor; // Rozet başındaki sinyal noktasının ve çerçevesinin rengidir
  final String text; // Rozet içerisinde yazılacak metindir
  const CategoryBadge({super.key, required this.dotColor, required this.text}); // Kurucu metottur

  @override
  Widget build(BuildContext context) {
    return Container( // Rozet kutusudur
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // Yatayda 14, dikeyde 6px iç boşluk verir
      decoration: BoxDecoration( // Rozetin arka plan, kenarlık ve yuvarlaklık ayarıdır
        color: const Color(0xFF131B29), // Koyu zemin rengidir
        borderRadius: BorderRadius.circular(20), // Köşeleri tam yuvarlak hap yapar
        border: Border.all(color: dotColor.withValues(alpha: 0.35)), // Renkli ince kenarlık çizer
      ),
      child: Row( // Sinyal noktası ve yazıyı yan yana koyar
        mainAxisSize: MainAxisSize.min, // Sadece içerik boyutu kadar yer kaplar
        children: [
          Container( // Sinyal ışığı noktasıdır
            width: 7, // Nokta genişliği 7px'dir
            height: 7, // Nokta yüksekliği 7px'dir
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Noktayı daire yapar
              color: dotColor, // Belirtilen durum rengini verir
              boxShadow: [BoxShadow(color: dotColor.withValues(alpha: 0.8), blurRadius: 6)], // Parlama ışıması verir
            ),
          ),
          const SizedBox(width: 8), // Nokta ile yazı arasına 8px boşluk koyar
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: dotColor, letterSpacing: 1.1)), // Rozet başlığıdır
        ],
      ),
    );
  }
}

// StatelessWidget: Saha yönetimindeki küçük özellik haplarıdır (Canlı Sahra Stoğu / Ekip Takibi)
class FeaturePill extends StatelessWidget {
  final IconData icon; // Hapın solunda gösterilecek ikondur
  final String label; // Hap üzerinde gösterilecek metindir
  const FeaturePill({super.key, required this.icon, required this.label}); // Kurucu metottur

  @override
  Widget build(BuildContext context) {
    return Container( // Hap kutusudur
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // İç boşluk bırakır
      decoration: BoxDecoration(
        color: const Color(0xFF111927), // Koyu arka plan rengidir
        borderRadius: BorderRadius.circular(20), // Kenarları yuvarlatır
        border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.25)), // Hafif cyan kenarlık verir
      ),
      child: Row( // İkon ile metni yan yana dizer
        mainAxisSize: MainAxisSize.min, // Sadece içerik boyutu kadar genişlik kaplar
        children: [
          Icon(icon, size: 16, color: AppColors.primaryCyan), // Özellik ikonudur
          const SizedBox(width: 8), // İkon ile metin arasına 8px boşluk koyar
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)), // Özellik yazısıdır
        ],
      ),
    );
  }
}

// StatelessWidget: Otomatik Önceliklendirme durum kartıdır (T1: Kurum taklidi yerine Otomatik Önceliklendirme)
class IntegrationCard extends StatelessWidget {
  const IntegrationCard({super.key}); // Kurucu metottur

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n?.onboardingAutoPriority ?? 'Otomatik Önceliklendirme';
    final desc = l10n?.onboardingAutoPriorityDesc ?? 'Kural tabanlı anlık triage ve acil görev atama';

    return Container( // Kartın ana kapsayıcı kutusudur
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // Kart içi boşluktur
      decoration: BoxDecoration(
        color: const Color(0xFF111724), // Koyu kart zemin rengidir
        borderRadius: BorderRadius.circular(16), // Kart köşelerini 16px yuvarlatır
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)), // Hafif transparan kenarlık çizer
      ),
      child: Row( // Kart içindeki elemanları yatayda yan yana dizer
        children: [
          Container( // Sol taraftaki ikon dairesidir
            width: 40, // Daire genişliği 40px'dir
            height: 40, // Daire yüksekliği 40px'dir
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF182335)), // Koyu mavi daire arka planıdır
            child: const Icon(Icons.bolt_rounded, color: AppColors.primaryCyan, size: 22), // Öncelik simgesidir
          ),
          const SizedBox(width: 12), // Daire ile metinler arasına 12px boşluk koyar
          Expanded( // Kalan yatay alanı kaplayıp metinlerin düzgün sığmasını sağlar
            child: Column( // Başlık ve alt açıklamayı dikeyde alt alta dizer
              crossAxisAlignment: CrossAxisAlignment.start, // Metinleri sola yaslar
              children: [
                Row( // Başlık ve AKTİF etiketini yan yana dizer
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6), // Başlık ile rozet arasına 6px boşluk koyar
                    Container( // Küçük yeşil AKTİF rozet kutusudur
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5), // Rozet iç boşluğu
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(4)), // Açık yeşil zemin
                      child: Text(l10n?.onboardingActive ?? 'AKTİF', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.success, letterSpacing: 0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 3), // Başlık ile açıklama arasına 3px boşluk koyar
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
