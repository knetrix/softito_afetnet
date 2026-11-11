import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_view.dart';
import '../../../l10n/app_localizations.dart';

/// A2 — Toplanma. Şimdilik boş sekme; ekranı G4 yazar.
class AssemblyPointsScreen extends StatelessWidget {
  const AssemblyPointsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: AppLocalizations.of(context)?.navAssembly ?? 'Toplanma');
}
