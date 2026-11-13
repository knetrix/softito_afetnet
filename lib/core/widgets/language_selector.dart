// Profil ekranındaki dil seçimi (Türkçe / English).
// Seçim LocaleController'a iletilir, uygulama anında o dile geçer.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../services/locale_controller.dart';

/// Profil'deki dil seçimi. Dil adları her dilde kendi adıyla yazılır.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final controller = context.watch<LocaleController>();

    return Row(
      children: [
        Icon(Icons.language_rounded, color: colors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: Text(l10n.languageLabel)),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 'tr', label: Text('Türkçe')),
            ButtonSegment(value: 'en', label: Text('English')),
          ],
          selected: {controller.locale.languageCode},
          onSelectionChanged: (s) => controller.setLocale(Locale(s.first)),
        ),
      ],
    );
  }
}
