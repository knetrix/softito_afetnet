// Dönen radar animasyonu (splash).

import 'dart:math' as math; // Pi sayısı ve açısal radyan dönüşümleri kütüphanesidir
import 'package:flutter/material.dart'; // Flutter temel çizim ve arayüz kütüphanesidir
import '../../../core/theme/app_colors.dart'; // Uygulamanın renk paleti sınıfıdır

// StatefulWidget: Animasyonla nabız gibi atıp dönen radar görseli widget'ıdır
class RadarTargetWidget extends StatefulWidget {
  final double size; // Radarın piksel cinsinden kare boyutudur
  const RadarTargetWidget({super.key, this.size = 220}); // Kurucu metottur (varsayılan 220px)

  // Widget'ın durum (State) nesnesini oluşturur.
  @override
  State<RadarTargetWidget> createState() => _RadarTargetWidgetState(); // Durum yöneticisini başlatır
}

// SingleTickerProviderStateMixin: Ekran yenileme hızına duyarlı animasyon ticker'ı sağlar
class _RadarTargetWidgetState extends State<RadarTargetWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller; // Animasyonun süresini ve döngüsünü kontrol eden nesnedir
  late final Animation<double> _pulse; // Radarın büyüyüp küçülmesini sağlayan nabız animasyonudur
  late final Animation<double> _rotation; // Radarın kesikli halkasını döndüren açı animasyonudur

  // Widget ilk açıldığında bir kez çalışır; başlangıç işlerini yapar.
  @override
  void initState() {
    super.initState(); // Üst sınıfın başlangıç mantığını çalıştırır
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(); // 3.2 sn'lik sonsuz döngü başlatır
    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate( // %96 ile %104 arasında boyut esnemesi yapar
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine), // Yumuşak sinüs eğrisi uygular
    );
    _rotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate( // 0 ile 360 derece arası dönme açısı üretir
      CurvedAnimation(parent: _controller, curve: Curves.linear), // Sabit hızda doğrusal dönüş verir
    );
  }

  // Kapanırken dinleyicileri ve kaynakları serbest bırakır.
  @override
  void dispose() {
    _controller.dispose(); // Bellek sızıntısını önlemek için animasyon kontrolcüsünü siler
    super.dispose(); // Üst sınıfın dispose işlemini tamamlar
  }

  // Arayüzü çizer.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder( // Animasyon her kare ilerlediğinde altındaki ağacı yeniden çizer
      animation: _controller, // Takip edilecek animasyon kontrolcüsüdür
      builder: (context, child) => Transform.scale( // Widget'ı nabız gibi büyütüp küçülten dönüştürücüdür
        scale: _pulse.value, // Anlık büyüme katsayısıdır
        child: SizedBox( // Radarın genişlik ve yüksekliğini sınırlayan kutudur
          width: widget.size, // Genişlik
          height: widget.size, // Yükseklik
          child: Stack( // Radarın katmanlarını üst üste bindiren yapıdır
            alignment: Alignment.center, // Katmanları tam ortaya kilitler
            children: [
              Container( // Arka plandaki yumuşak parlama dairesidir
                width: widget.size * 0.75, // Daire genişliği %75
                height: widget.size * 0.75, // Daire yüksekliği %75
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Daire şekli
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryCyan.withValues(alpha: 0.18), blurRadius: 40, spreadRadius: 10), // Dağılan mavi ışıma gölgesidir
                  ],
                ),
              ),
              CustomPaint(size: Size(widget.size, widget.size), painter: _RadarPainter(rotation: _rotation.value)), // Radar çizgilerini çizen ressamdır
              Container( // Merkezdeki koyu verici istasyonu dairesidir
                width: widget.size * 0.38, // Çekirdek genişliği %38
                height: widget.size * 0.38, // Çekirdek yüksekliği %38
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Tam daire formu
                  color: const Color(0xFF0C1624), // Koyu lacivert zemin rengi
                  border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.7), width: 2.5), // Cyan renkli parlak kenarlık
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryCyan.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2), // Neon parlama efekti
                  ],
                ),
                child: Center( // İkonu dairenin ortasına kilitler
                  child: Icon(Icons.cell_tower_rounded, size: widget.size * 0.18, color: AppColors.primaryCyan), // Verici kulesi simgesidir
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CustomPainter: Tuvale dış halkayı, dönen kesikli çemberi ve çentikleri çizen özel ressamdır
class _RadarPainter extends CustomPainter {
  final double rotation; // Anlık dönme açısıdır
  _RadarPainter({required this.rotation}); // Kurucu metottur

  // Şekli tuvale çizer.
  @override
  void paint(Canvas canvas, Size size) { // Tuval çizim fonksiyonudur
    final center = Offset(size.width / 2, size.height / 2); // Tuval orta noktasıdır
    final maxRadius = size.width / 2; // Çizilebilecek maksimum yarıçaptır

    final ring = Paint()..color = AppColors.primaryCyan.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = 1.2; // Dış halka fırçası
    canvas.drawCircle(center, maxRadius * 0.88, ring); // Dış ince çemberi çizer

    final dash = Paint()..color = AppColors.primaryCyan.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 1.4; // Kesikli çember fırçası
    const count = 36; // 36 parçalı kesik sayısıdır
    final angle = (2 * math.pi) / count; // Her parçanın açı dilimidir

    for (int i = 0; i < count; i += 2) { // Bir dolu bir boş yay çizen döngüdür
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: maxRadius * 0.65), // Kesikli dairenin yeridir
        i * angle + (rotation * 0.2), // Dönme açısını ekleyerek yayı kaydırır
        angle * 0.6, // Yayın uzunluk payıdır
        false, // Merkeze birleştirmeden sadece yay çizer
        dash, // Çizim fırçasıdır
      );
    }

    final tick = Paint()..color = AppColors.primaryCyan..strokeWidth = 2.0..strokeCap = StrokeCap.round; // Dört yön çentiği fırçasıdır
    final dist = maxRadius * 0.88; // Çentiğin merkezden uzaklığıdır
    canvas.drawLine(Offset(center.dx, center.dy - dist - 8), Offset(center.dx, center.dy - dist + 8), tick); // Üst çentik (Kuzey)
    canvas.drawLine(Offset(center.dx, center.dy + dist - 8), Offset(center.dx, center.dy + dist + 8), tick); // Alt çentik (Güney)
    canvas.drawLine(Offset(center.dx - dist - 8, center.dy), Offset(center.dx - dist + 8, center.dy), tick); // Sol çentik (Batı)
    canvas.drawLine(Offset(center.dx + dist - 8, center.dy), Offset(center.dx + dist + 8, center.dy), tick); // Sağ çentik (Doğu)
  }

  // Değişiklik yoksa yeniden çizmez.
  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => oldDelegate.rotation != rotation; // Açı değiştikçe tuvali yeniden çizer
}
