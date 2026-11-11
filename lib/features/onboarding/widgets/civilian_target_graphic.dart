import 'dart:math' as math; // Pi sayısı ve açısal hesaplamalar için matematik kütüphanesidir
import 'package:flutter/material.dart'; // Flutter temel görsel ve çizim bileşenleridir
import '../../../core/theme/app_colors.dart'; // Projenin renk paletidir

// StatelessWidget: Sayfa 1 için statik kalkan ve koordinat göstergesi widget'ıdır
class CivilianTargetGraphic extends StatelessWidget {
  const CivilianTargetGraphic({super.key}); // Kurucu metottur

  @override
  Widget build(BuildContext context) {
    const double size = 260.0; // Hedef alanının sabit kare boyutudur (260x260 px)
    return SizedBox( // Boyut sınırlandırma kutusudur
      width: size, // Genişliği 260px yapar
      height: size, // Yüksekliği 260px yapar
      child: Stack( // Çemberleri ve yazıları katman katman üst üste bindirir
        alignment: Alignment.center, // Tüm iç katmanları tam ortaya hizalar
        children: [
          Container( // En dıştaki ince sınır çemberini çizen kutudur
            width: 200, // Dış çember genişliği 200px'dir
            height: 200, // Dış çember yüksekliği 200px'dir
            decoration: BoxDecoration( // Çemberin kenarlık ve şekil ayarıdır
              shape: BoxShape.circle, // Şekli tam daire yapar
              border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.3), width: 1.0), // 1px ince kenarlık çizer
            ),
          ),
          const Positioned.fill( // Kuzey koordinatını dış halkanın en üstüne hizalar
            child: Align(alignment: Alignment.topCenter, child: _CoordText('39°55\'N')),
          ),
          const Positioned.fill( // Güney koordinatını dış halkanın en altına hizalar
            child: Align(alignment: Alignment.bottomCenter, child: _CoordText('32°51\'E')),
          ),
          const Positioned.fill( // Batı kodunu (M-02) dış halkanın soluna hizalar
            child: Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 6.0), child: _CoordText('M-02'))),
          ),
          const Positioned.fill( // Doğu kodunu (SYNC) dış halkanın sağına hizalar
            child: Align(alignment: Alignment.centerRight, child: Padding(padding: EdgeInsets.only(right: 6.0), child: _CoordText('SYNC'))),
          ),
          CustomPaint( // Ortadaki kalın yay ve halkayı tuvale (Canvas) doğrudan çizen widget'tır
            size: const Size(130, 130), // Çizim tuvali 130x130 pikseldir
            painter: _TargetArcPainter(), // Yay ve daire çizimini yapan ressam sınıftır
          ),
          Container( // Merkezdeki kalkan ikonunu barındıran koyu dairedir
            width: 74, // Merkez çekirdek genişliği 74px'dir
            height: 74, // Merkez çekirdek yüksekliği 74px'dir
            decoration: BoxDecoration( // Çekirdeğin şekil, arka plan ve ışıma dekorasyonudur
              shape: BoxShape.circle, // Çekirdeği daire yapar
              color: const Color(0xFF0F1726), // Koyu lacivert zemin rengidir
              border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.4), width: 1.5), // Cyan renkli ince kenarlıktır
              boxShadow: [
                BoxShadow(color: AppColors.primaryCyan.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: 2), // Neon parlama efekti verir
              ],
            ),
            child: const Center( // Kalkan simgesini çekirdeğin ortasına kilitler
              child: Icon(Icons.shield_rounded, size: 36, color: AppColors.primaryCyan), // Güvenliği simgeleyen kalkan ikonudur
            ),
          ),
        ],
      ),
    );
  }
}

// Koordinat yazılarını standart yazı tipiyle çizen yardımcı widget'tır
class _CoordText extends StatelessWidget {
  final String text; // Ekrana yazılacak koordinat metnidir
  const _CoordText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text( // Metni ekrana basar
      text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.8),
    );
  }
}

// CustomPainter: Tuvale kalın çember ve yay çizen özel grafik ressamıdır
class _TargetArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) { // Çizim işlemlerini yürüten ana metottur
    final center = Offset(size.width / 2, size.height / 2); // Tuvalin tam orta koordinatıdır
    final radius = size.width / 2; // Çizilecek dairenin yarıçapıdır

    final bgPaint = Paint() // Koyu alt taban çemberinin fırçasıdır
      ..color = const Color(0xFF131D2E) // Koyu zemin rengidir
      ..style = PaintingStyle.stroke // İçi boş, sadece çizgi çizer
      ..strokeWidth = 14; // Çizgi kalınlığı 14px'dir
    canvas.drawCircle(center, radius, bgPaint); // Taban çemberini tuvale çizer

    final arcPaint = Paint() // Üstteki parlak cyan renkli yayın fırçasıdır
      ..color = AppColors.primaryCyan // Neon cyan rengidir
      ..style = PaintingStyle.stroke // Sadece yay çizgisi çizer
      ..strokeCap = StrokeCap.round // Çizgi uçlarını yuvarlak yapar
      ..strokeWidth = 14; // Yay kalınlığı 14px'dir

    canvas.drawArc( // Belirtilen açıda dairesel yay parçasını çizer
      Rect.fromCircle(center: center, radius: radius), // Yayın oturacağı daire sınırıdır
      -math.pi * 0.45, // Yayın başladığı radyan açısıdır
      math.pi * 0.8, // Yayın uzunluk açısıdır
      false, // Merkeze kapatılmadan sadece açık yay kalır
      arcPaint, // Çizim fırçasıdır
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // Çizim sabit olduğu için tekrar çizimi engeller
}
