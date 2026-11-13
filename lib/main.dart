import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app.dart';
import 'core/services/locale_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Geliştirme sırasında çökme raporu gönderilmez. Crashlytics web'de yok.
  if (!kIsWeb) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Gömülü yazı tiplerinin OFL lisansları (Lisanslar sayfasında görünür).
  LicenseRegistry.addLicense(() async* {
    for (final family in const ['SpaceGrotesk', 'Inter', 'JetBrainsMono']) {
      final text = await rootBundle.loadString('assets/fonts/OFL-$family.txt');
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });

  // Çevrimdışı çağrı kuyruğu kutusu G4'te burada açılır (Kural 4).
  await Hive.initFlutter();

  // İlk kare seçilen dilde çizilir (varsayılan Türkçe).
  final localeController = LocaleController();
  await localeController.load();

  runApp(AfetNetApp(localeController: localeController));
}
