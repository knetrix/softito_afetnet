import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_view.dart';
import '../../../l10n/app_localizations.dart';

/// A1 — Ana Sayfa. Şimdilik boş sekme; ekranı G3 yazar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: AppLocalizations.of(context)?.navHome ?? 'Ana Sayfa');
}
