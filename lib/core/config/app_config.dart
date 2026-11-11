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

  // Yasal metinler (Firebase Hosting, `hosting/legal/`; içeriği G6 yazar).
  static const _legalBaseUrl = 'https://afetnet-softito.web.app/legal';
  static const privacyPolicyUrl = '$_legalBaseUrl/privacy.html';
  static const kvkkNoticeUrl = '$_legalBaseUrl/kvkk.html';
  static const termsUrl = '$_legalBaseUrl/terms.html';
  static const accountDeletionUrl = '$_legalBaseUrl/delete-account.html';

  /// Kayıtta `users.consents` içine yazılan metin sürümleri.
  /// Yasal metin değişirse sürüm artırılır.
  static const privacyVersion = '1.0';
  static const kvkkVersion = '1.0';

  /// Bu sürede tamamlanmayan yazma çevrimdışı kabul edilir (Kural 4, 8).
  static const offlineTimeout = Duration(seconds: 10);
}
