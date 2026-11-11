import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_view.dart';
import '../../../l10n/app_localizations.dart';

/// Y2 — Ekipler. Şimdilik boş sekme; ekranı G5 yazar.
class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: AppLocalizations.of(context)?.navTeams ?? 'Ekipler');
}
