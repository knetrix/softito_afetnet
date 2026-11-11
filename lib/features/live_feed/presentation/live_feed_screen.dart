import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_view.dart';
import '../../../l10n/app_localizations.dart';

/// Y1 — Canlı Akış. Şimdilik boş sekme; ekranı G5 yazar.
class LiveFeedScreen extends StatelessWidget {
  const LiveFeedScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: AppLocalizations.of(context)?.navLiveFeed ?? 'Canlı Akış');
}
