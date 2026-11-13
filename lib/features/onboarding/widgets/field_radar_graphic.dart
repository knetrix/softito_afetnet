// Onboarding 2. sayfa radar grafiği (Saha Yönetimi).

import 'dart:math' as math; // Pi sayısı ve trigonometrik açı hesapları kütüphanesidir
import 'package:flutter/material.dart'; // Flutter temel çizim ve arayüz kütüphanesidir
import '../../../core/theme/app_colors.dart'; // Projenin renk paleti sabitleridir
import '../../../l10n/app_localizations.dart';

// StatelessWidget: 2. sayfa saha yönetimi radar taramasını ve tim rozetlerini çizen bileşendir
class FieldRadarGraphic extends StatelessWidget {
  const FieldRadarGraphic({super.key}); // Kurucu metottur

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const size = 250.0; // Radar alanının 250x250 piksel sabit boyutudur
    return SizedBox( // Boyut sınırlayıcı kutudur
      width: size, // Genişliği 250px yapar
      height: size, // Yüksekliği 250px yapar
      child: Stack( // Radar katmanlarını ve rozetleri üst üste dizer
        alignment: Alignment.center, // Katmanları tam ortaya hizalar
        children: [
          CustomPaint(size: const Size(size, size), painter: _RadarSectorPainter()), // Radar tarama yayını ve halkalarını çizer
          Container( // Merkezdeki baz istasyonu/sensör çekirdeğidir
            width: 58, // Çekirdek genişliği 58px'dir
            height: 58, // Çekirdek yüksekliği 58px'dir
            decoration: BoxDecoration( // Şekil ve neon parlama dekorasyonudur
              shape: BoxShape.circle, // Şekli tam daire yapar
              color: const Color(0xFF0F1726), // Koyu lacivert zemin rengidir
              border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.5), width: 1.5), // Cyan renkli çerçevedir
              boxShadow: [
                BoxShadow(color: AppColors.primaryCyan.withValues(alpha: 0.35), blurRadius: 16, spreadRadius: 2), // Neon parlama gölgesidir
              ],
            ),
            child: const Center( // İkonu dairenin ortasına kilitler
              child: Icon(Icons.sensors_rounded, size: 28, color: AppColors.primaryCyan), // Sinyal ve sensör simgesidir
            ),
          ),
          Positioned(top: 24, left: 8, child: _RadarTag(dotColor: AppColors.danger, text: l10n?.onboardingRadarTeam ?? 'TİM #04 1.2km')), // Sol üstteki kırmızı tim rozetidir
          Positioned(bottom: 24, right: 8, child: _RadarTag(dotColor: AppColors.success, text: l10n?.onboardingRadarDepot ?? 'DEPO %94 L-4')), // Sağ alttaki yeşil depo rozetidir
          const Positioned(top: 48, right: 48, child: _RadarDot(color: AppColors.primaryCyan, size: 7)), // Radardaki serbest cyan sinyal noktasıdır
          const Positioned(top: 66, right: 82, child: _RadarDot(color: AppColors.danger, size: 9)), // Radardaki serbest kırmızı sinyal noktasıdır
          const Positioned(bottom: 50, left: 54, child: _RadarDot(color: AppColors.success, size: 7)), // Radardaki serbest yeşil sinyal noktasıdır
        ],
      ),
    );
  }
}

// CustomPainter: Eş merkezli radar halkalarını ve dönen ışık sektörünü tuvale çizer
class _RadarSectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) { // Tuval çizim mantığıdır
    final center = Offset(size.width / 2, size.height / 2); // Radar merkez noktasıdır
    final maxRadius = size.width / 2; // Çizilebilecek maksimum yarıçaptır

    final ring = Paint()..color = AppColors.borderGlow.withValues(alpha: 0.2)..style = PaintingStyle.stroke..strokeWidth = 1.0; // İnce halka fırçasıdır
    canvas.drawCircle(center, maxRadius * 0.9, ring); // En dıştaki halkayı çizer
    canvas.drawCircle(center, maxRadius * 0.65, ring); // Ortadaki halkayı çizer
    canvas.drawCircle(center, maxRadius * 0.4, ring); // İçteki küçük halkayı çizer

    final sweep = Paint() // Radar tarama sektörünün degrade fırçasıdır
      ..shader = RadialGradient( // Merkezden dışarıya doğru şeffaflaşan ışık efekti verir
        colors: [AppColors.primaryCyan.withValues(alpha: 0.35), AppColors.primaryCyan.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill; // Alanı dolu boyar

    canvas.drawArc(Rect.fromCircle(center: center, radius: maxRadius * 0.9), math.pi * 1.05, math.pi * 0.45, true, sweep); // Tarama dilimini çizer
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // Sabit çizim olduğu için tekrar çizimi engeller
}

// Radar üzerindeki tim ve depo konum bilgi kartıdır
class _RadarTag extends StatelessWidget {
  final Color dotColor; // Rozet başındaki sinyal noktasının rengidir
  final String text; // Rozette yazan metindir (örn. TİM #04)
  const _RadarTag({required this.dotColor, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container( // Rozet kutusudur
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // İç boşluk verir
      decoration: BoxDecoration( // Koyu cam efekti arka planıdır
        color: const Color(0xFF131A26).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14), // Köşeleri yuvarlatır
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.8), // İnce beyaz kenarlık verir
      ),
      child: Row( // Sinyal noktası ile metni yan yana dizer
        mainAxisSize: MainAxisSize.min, // Sadece içerik kadar genişlik kaplar
        children: [
          Container( // Küçük sinyal ışığı noktasıdır
            width: 7, // Nokta genişliği 7px'dir
            height: 7, // Nokta yüksekliği 7px'dir
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Noktayı daire yapar
              color: dotColor, // Belirtilen durum rengini boyar
              boxShadow: [BoxShadow(color: dotColor.withValues(alpha: 0.6), blurRadius: 6)], // Işıma gölgesi verir
            ),
          ),
          const SizedBox(width: 6), // Işık ile yazı arasına 6px boşluk koyar
          Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.4)), // Rozet metnidir
        ],
      ),
    );
  }
}

// Radar üzerinde beliren küçük sinyal noktacığı widget'ıdır
class _RadarDot extends StatelessWidget {
  final Color color; // Noktanın rengidir
  final double size; // Noktanın piksel çapıdır
  const _RadarDot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container( // Nokta kutusudur
      width: size, // Genişlik
      height: size, // Yükseklik
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Daire formu
        color: color, // Sinyal rengi
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 8)], // Parlama efekti
      ),
    );
  }
}
