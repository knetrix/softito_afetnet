// İnternet yokken panik butonuna basılınca açılacak SMS bağlantısını hazırlar.
// İçinde acil durum yakınının numarası ve Google Haritalar konum linki olur; SMS'i kullanıcı kendisi gönderir.

/// Acil durum SMS köprüsü için RFC uyumlu URI üretir.
///
/// `Uri(..., queryParameters: ...)` boşlukları `+` olarak kodladığından
/// bazı Android SMS uygulamalarında literal `+` görünür; bu nedenle `query`
/// alanında `Uri.encodeComponent` kullanılarak `%20` üretilir.
Uri buildEmergencySmsUri({
  required String phone,
  required String body,
}) {
  return Uri(
    scheme: 'sms',
    path: phone.trim(),
    query: 'body=${Uri.encodeComponent(body)}',
  );
}

/// Konum koordinatlarından paylaşılabilir harita bağlantısı üretir.
String buildLocationMapLink(double latitude, double longitude) {
  final lat = latitude.toStringAsFixed(6);
  final lng = longitude.toStringAsFixed(6);
  return 'https://maps.google.com/?q=$lat,$lng';
}

