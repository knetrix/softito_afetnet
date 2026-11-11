import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';

/// "Resmi kurum uygulaması değildir · Acil durumda 112" (T15).
/// O2'nin 1. sayfasında ve O3'ün altında gösterilir; 112'ye dokununca arama açılır.
// TODO(G2): Metni ARB'ye taşı, tasarımın stilini uygula.
class NotOfficialNotice extends StatefulWidget {
  const NotOfficialNotice({super.key});

  @override
  State<NotOfficialNotice> createState() => _NotOfficialNoticeState();
}

class _NotOfficialNoticeState extends State<NotOfficialNotice> {
  late final TapGestureRecognizer _callTap = TapGestureRecognizer()
    ..onTap = () => launchUrl(Uri(scheme: 'tel', path: AppConfig.emergencyNumber));

  @override
  void dispose() {
    _callTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Text.rich(
      TextSpan(
        text: 'Resmi kurum uygulaması değildir · Acil durumda ',
        children: [
          TextSpan(
            text: AppConfig.emergencyNumber,
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
