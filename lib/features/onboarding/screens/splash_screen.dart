// Splash ekranının görsel kısmı (logo ve radar animasyonu).

import 'dart:async'; // Zamanlayıcı (Timer) işlemleri için kütüphanedir
import 'package:flutter/material.dart'; // Flutter temel UI ve widget kütüphanesidir
import '../../../core/theme/app_colors.dart'; // Uygulamanın renk paleti sınıfıdır
import '../../../core/theme/text_styles.dart'; // Başlık ve yazı tipi stilleridir
import '../../../l10n/app_localizations.dart';
import '../widgets/radar_target_widget.dart'; // Dönen radar animasyonu bileşenidir

// StatefulWidget: Zamanla verisi ve ekran görünümü güncellenebilen widget tipidir
class SplashScreen extends StatefulWidget {
  final VoidCallback? onInitializationComplete; // Yükleme bitince dışarıya haber veren fonksiyondur

  const SplashScreen({super.key, this.onInitializationComplete}); // Kurucu metottur

  @override
  State<SplashScreen> createState() => _SplashScreenState(); // Ekran durum yöneticisini oluşturur
}

// SingleTickerProviderStateMixin: Animasyon kontrolcüsünü ekran yenileme hızına (vsync) bağlar
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _progressController; // İlerleme çubuğunun süresini yöneten kontrolcüdür
  late final Animation<double> _progressAnimation; // 0.15 ile 1.0 arasında değer üreten animasyondur
  String _statusText = 'AfetNet protokolü hazır.'; // Ekranda görünen dinamik durum metnidir

  @override
  void initState() {
    super.initState(); // Üst sınıfın başlangıç metodunu çalıştırır
    _progressController = AnimationController( // Animasyon kontrolcüsünü başlatır
      vsync: this, // Ekran tazeleme hızına eşitler (performans ve pil tasarrufu sağlar)
      duration: const Duration(seconds: 3), // Splash ekranının 3 saniye sürmesini sağlar
    );

    _progressAnimation = Tween<double>(begin: 0.15, end: 1.0).animate( // Değer aralığını belirler
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic), // Yumuşak hızlanma eğrisidir
    );

    _progressController.forward().then((_) { // Animasyonu ileriye doğru oynatır ve bitişini bekler
      if (mounted && widget.onInitializationComplete != null) { // Widget ekranda ise ve callback varsa
        widget.onInitializationComplete!(); // Onboarding ekranına geçiş fonksiyonunu tetikler
      }
    });

    Timer(const Duration(milliseconds: 900), () { // 0.9 saniye sonra çalışan zamanlayıcıdır
      if (mounted) { // Widget hâlâ ekrandaysa
        setState(() => _statusText = 'AfetNet protokolü hazır.'); // Durum metnini yeniler
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose(); // RAM sızıntısını önlemek için animasyon kontrolcüsünü kapatır
    super.dispose(); // Üst sınıfın dispose işlemini tamamlar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Ekranın temel arka plan ve gövde iskeletini oluşturur
      body: Container( // Tüm ekranı kaplayan kutu widget'ıdır
        width: double.infinity, // Yatayda maksimum genişlik kaplar
        height: double.infinity, // Dikeyde maksimum yükseklik kaplar
        decoration: const BoxDecoration( // Arka plana dairesel degrade renk verir
          gradient: RadialGradient(
            center: Alignment(0.0, -0.2), // Degrade merkezini hafif yukarı alır
            radius: 1.1, // Işığın yayılma yarıçapıdır
            colors: [Color(0xFF101926), Color(0xFF090D14), Color(0xFF05070B)], // Merkezden dışa renk tonlarıdır
            stops: [0.0, 0.55, 1.0], // Renklerin geçiş noktalarıdır
          ),
        ),
        child: SafeArea( // Çentik ve sistem çubuklarına taşmayı engelleyen alandır
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0), // Yanlardan 32 piksel boşluk bırakır
            child: Column( // Elemanları yukarıdan aşağıya dizen dikey yerleşimdir
              mainAxisAlignment: MainAxisAlignment.center, // İçeriği dikeyde ortalar
              children: [
                const Spacer(flex: 3), // Üst kısımda orantılı boşluk bırakır
                const RadarTargetWidget(size: 200), // Dönen radar ve verici kulesi görselini çizer
                const SizedBox(height: 36), // Radar ile başlık arasına 36px boşluk koyar
                const Text('AfetNet', style: AppTextStyles.displayTitle), // Ana uygulama başlığını basar
                const SizedBox(height: 8), // Başlık ile alt başlık arasına 8px boşluk koyar
                Text(
                  AppLocalizations.of(context)?.splashSubtitle ?? 'Canlı Kriz Yönetimi Ağı',
                  style: AppTextStyles.subtitle,
                ), // Alt başlığı basar
                const Spacer(flex: 2), // Başlık ile progress bar arasına orantılı boşluk koyar
                AnimatedSwitcher( // Durum metni değiştikçe yumuşak geçiş efekti verir
                  duration: const Duration(milliseconds: 300), // Geçiş süresi 300ms'dir
                  child: Text( // Anlık durum mesajını ekrana basar
                    AppLocalizations.of(context)?.splashReady ?? _statusText,
                    key: ValueKey<String>(_statusText), // Değer değiştiğinde animasyonu tetikler
                    style: AppTextStyles.statusText, // Metin stilidir
                    textAlign: TextAlign.center, // Metni ortalar
                  ),
                ),
                const SizedBox(height: 16), // Metin ile bar arasına 16px boşluk koyar
                AnimatedBuilder( // Animasyon ilerledikçe sadece ilerleme çubuğunu yeniden çizer
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container( // İlerleme çubuğunun koyu arka plan yoludur
                      width: 140, // Toplam bar genişliği 140px'dir
                      height: 4, // Bar yüksekliği 4px'dir
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight, // Çubuğun arka plan rengidir
                        borderRadius: BorderRadius.circular(10), // Yuvarlatılmış köşeler verir
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft, // Doldurulan çubuğu soldan başlatır
                        child: Container( // Animasyonla dolan cyan renkli aktif bardır
                          width: 140 * _progressAnimation.value, // Anlık yüzdeye göre genişliği hesaplar
                          height: 4, // Yükseklik 4px'dir
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan, // Neon camgöbeği rengidir
                            borderRadius: BorderRadius.circular(10), // Köşeleri yuvarlatır
                            boxShadow: [
                              BoxShadow(color: AppColors.primaryCyan.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1), // Neon parlama gölgesidir
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 2), // Alt kısımda orantılı boşluk bırakır
              ],
            ),
          ),
        ),
      ),
    );
  }
}
