// Canlı Akış ve Ekipler ekranlarının sağ altındaki kırmızı "Tahliye Anonsu" butonu (FloatingActionButton).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/location_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/broadcast_repository.dart';
import 'evacuation_broadcast_sheet.dart';

/// Y1 ve Y2'deki "Tahliye Anonsu" butonu.
class EvacuationFab extends StatelessWidget {
  const EvacuationFab({super.key});

  // Anons formunu açar ve sonucu mesajla gösterir.
  Future<void> _open(BuildContext context) async {
    final uid = context.read<AuthController>().currentUser?.uid;
    if (uid == null) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final result = await EvacuationBroadcastSheet.show(
      context,
      repository: context.read<BroadcastRepository>(),
      locationService: context.read<LocationService>(),
      officialUid: uid,
    );
    if (result == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result == BroadcastSendResult.sent
              ? l10n.broadcastSaved
              : l10n.broadcastQueued,
        ),
      ),
    );
  }

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton.extended(
      heroTag: 'evacuation_broadcast_fab',
      backgroundColor: Theme.of(context).colorScheme.error,
      foregroundColor: Theme.of(context).colorScheme.onError,
      icon: const Icon(Icons.campaign_rounded),
      label: Text(l10n.broadcastButton),
      onPressed: () => _open(context),
    );
  }
}
