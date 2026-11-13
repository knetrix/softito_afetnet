// "Resmi kurum uygulaması değildir · Acil durumda 112" uyarısı.
// 112'ye dokununca telefonun arama ekranı açılır. Onboarding'de ve Giriş'te görünür.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../config/app_config.dart';

/// "Resmi kurum uygulaması değildir · Acil durumda 112" (T15).
/// O2'nin 1. sayfasında ve O3'ün altında gösterilir; 112'ye dokununca arama açılır.
class NotOfficialNotice extends StatefulWidget {
  const NotOfficialNotice({super.key});

  // Bu StatefulWidget'ın değişen verilerini tutacak State nesnesini oluşturur.
  @override
  State<NotOfficialNotice> createState() => _NotOfficialNoticeState();
}

// "112" yazısına dokunmayı algılayan nesne (metnin içindeki tıklanabilir kısım için).
class _NotOfficialNoticeState extends State<NotOfficialNotice> {
  late final TapGestureRecognizer _callTap = TapGestureRecognizer()
    ..onTap = () => launchUrl(Uri(scheme: 'tel', path: AppConfig.emergencyNumber));

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    _callTap.dispose();
    super.dispose();
  }

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final disclaimerText = l10n?.notOfficialDisclaimer ??
        'Resmi kurum uygulaması değildir · Acil durumda ';
    final emergencyNum = l10n?.emergencyCall ?? AppConfig.emergencyNumber;

    return Text.rich(
      TextSpan(
        text: disclaimerText,
        children: [
          TextSpan(
            text: emergencyNum,
            recognizer: _callTap,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
      style: style,
      textAlign: TextAlign.center,
    );
  }
}
