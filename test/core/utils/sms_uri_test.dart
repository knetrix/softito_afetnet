import 'package:afetnet/core/utils/sms_uri.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildEmergencySmsUri', () {
    test('boşlukları + yerine %20 olarak kodlar', () {
      final uri = buildEmergencySmsUri(
        phone: '+905551234567',
        body: 'ACİL DURUM: Yardıma ihtiyacım var.',
      );

      final raw = uri.toString();
      expect(uri.scheme, 'sms');
      expect(uri.path, '+905551234567');
      expect(raw, contains('%20'));
      expect(uri.query, isNot(contains('+')));
    });

    test('harita bağlantısı doğru koordinatları içerir', () {
      final link = buildLocationMapLink(36.2025, 36.1604);
      expect(link, 'https://maps.google.com/?q=36.202500,36.160400');
    });
  });
}

