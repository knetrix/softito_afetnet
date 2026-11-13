// Uygulama geneli sabitler: harita tile adresi ve yasal sayfa bağlantıları.

import 'dart:ui' show Locale;

/// Uygulama genelindeki sabit ayarlar (PROJECT_NEW.md §6.1, §7).
abstract final class AppConfig {
  static const appName = 'AfetNet';
  static const packageName = 'com.softito.afetnet';

  /// Hayati tehlikede aranacak numara (T15).
  static const emergencyNumber = '112';

  // Harita (OpenStreetMap, API anahtarı gerekmez).
  static const osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const osmUserAgentPackageName = packageName;
  static const osmAttribution = '© OpenStreetMap contributors';

  // Yasal metinler (Firebase Hosting, `hosting/legal/<sayfa>-<tr|en>.html`, §7).
  static const _legalBaseUrl = 'https://afetnet-softito.web.app/legal';
  static const privacyPage = 'privacy';
  static const kvkkPage = 'kvkk';
  static const termsPage = 'terms';
  static const accountDeletionPage = 'delete-account';

  /// Yasal sayfanın uygulama dilindeki adresi (Türkçe değilse İngilizce).
  static String legalUrl(String page, Locale locale) =>
      '$_legalBaseUrl/$page-${locale.languageCode == 'tr' ? 'tr' : 'en'}.html';

  /// Kayıtta `users.consents` içine yazılan metin sürümleri.
  /// Yasal metin değişirse sürüm artırılır.
  static const privacyVersion = '1.0';
  static const kvkkVersion = '1.0';

  /// Bu sürede tamamlanmayan yazma çevrimdışı kabul edilir (Kural 4, 8).
  static const offlineTimeout = Duration(seconds: 10);

  /// Kuyrukta çağrı varken gönderimin yeniden denenme aralığı (Kural 4, R8).
  static const offlineQueueRetryInterval = Duration(seconds: 30);
}
