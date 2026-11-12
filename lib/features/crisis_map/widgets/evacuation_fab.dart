
import 'package:flutter/material.dart';

import '../../../features/broadcast/domain/evacuation_broadcast_sheet.dart';
import '../../../l10n/app_localizations.dart';

class EvacuationFab extends StatelessWidget {
  const EvacuationFab({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return FloatingActionButton.extended(
      heroTag: 'evacuation_broadcast_fab',
      icon: const Icon(Icons.campaign_outlined),
      label: Text(strings.broadcastButton),
      onPressed: () async {
        final created =
            await EvacuationBroadcastSheet.open(context);

        if (!context.mounted || created != true) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.broadcastSaved),
          ),
        );
      },
    );
  }
}
