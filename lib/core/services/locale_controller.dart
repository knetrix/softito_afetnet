// Uygulama dili (varsayılan Türkçe, Profil'den İngilizce) ve kaydı.

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama dili: cihaz dilinden bağımsız olarak varsayılan Türkçe,
/// Profil'den İngilizce seçilebilir. Seçim cihazda saklanır.
class LocaleController extends ChangeNotifier {
  LocaleController({Future<SharedPreferences> Function()? prefsLoader})
    : _prefsLoader = prefsLoader ?? SharedPreferences.getInstance;

  static const prefsKey = 'app_language';
  static const turkish = Locale('tr');
  static const english = Locale('en');

  /// Widget ağacı dışındaki yerler (yerel bildirim başlıkları, bildirim
  /// kanalı) için güncel dil.
  static Locale current = turkish;

  final Future<SharedPreferences> Function() _prefsLoader;

  // Seçili uygulama dili.
  Locale get locale => current;

  /// Saklanan seçimi yükler; ilk kare doğru dilde çizilsin diye
  /// `runApp`'ten önce çağrılır.
  Future<void> load() async {
    try {
      final prefs = await _prefsLoader();
      current = prefs.getString(prefsKey) == english.languageCode
          ? english
          : turkish;
    } catch (_) {
      current = turkish;
    }
    notifyListeners();
  }

  // Dili değiştirir ve seçimi cihaza kaydeder.
  Future<void> setLocale(Locale locale) async {
    final next = locale.languageCode == english.languageCode
        ? english
        : turkish;
    if (next == current) return;
    current = next;
    notifyListeners();
    try {
      final prefs = await _prefsLoader();
      await prefs.setString(prefsKey, next.languageCode);
    } catch (_) {
      // Saklanamazsa seçim bu oturumda geçerli kalır.
    }
  }
}
