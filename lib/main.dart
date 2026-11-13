// Uygulamanın giriş noktası (ilk çalışan dosya).
// Sırasıyla Firebase, hata kaydı (Crashlytics), yerel veritabanı (Hive) ve dil hazırlanır, sonra uygulama başlar.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app.dart';
import 'core/services/locale_controller.dart';
import 'firebase_options.dart';

// Uygulama buradan başlar. async: bazı hazırlıklar (Firebase gibi) zaman aldığı için await ile beklenir.
Future<void> main() async {
  // 1) Flutter motorunu hazırlar; runApp'ten önce eklenti (plugin) kullanacaksak zorunludur.
  WidgetsFlutterBinding.ensureInitialized();
  // 2) Firebase'i başlatır. Ayarlar firebase_options.dart dosyasından gelir (Android/iOS/Web).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Geliştirme sırasında çökme raporu gönderilmez.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );
  // Flutter içinde oluşan hatalar Crashlytics'e kaydedilir.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Flutter dışında (ör. async kodda) yakalanmayan hatalar da kaydedilir.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Gömülü yazı tiplerinin OFL lisansları (Lisanslar sayfasında görünür).
  LicenseRegistry.addLicense(() async* {
    for (final family in const ['SpaceGrotesk', 'Inter', 'JetBrainsMono']) {
      final text = await rootBundle.loadString('assets/fonts/OFL-$family.txt');
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });

  // Çevrimdışı çağrı kuyruğu kutusu G4'te burada açılır (Kural 4).
  // Hive (cihazdaki yerel veritabanı) hazırlanır; internetsiz çağrı kuyruğu burada saklanır.
  await Hive.initFlutter();

  // İlk kare seçilen dilde çizilir (varsayılan Türkçe).
  final localeController = LocaleController();
  await localeController.load();

  // 3) Hazırlıklar bitti: uygulamanın kök widget'ı ekrana çizilir.
  runApp(AfetNetApp(localeController: localeController));
}
