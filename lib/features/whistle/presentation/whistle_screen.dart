import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_view.dart';
import '../../../l10n/app_localizations.dart';

/// A3 — Düdük. Şimdilik boş sekme; ekranı G3 yazar.
class WhistleScreen extends StatelessWidget {
  const WhistleScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: AppLocalizations.of(context)?.navWhistle ?? 'Düdük');
}
