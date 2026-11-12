import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/broadcast_repository.dart';

/// Gönderim sonucu: sunucuya ulaştı ya da bağlantı gelince gidecek.
enum BroadcastSendResult { sent, queued }

/// Y1, Y2 "Tahliye Anonsu" (§3.2): tür, yarıçap, mesaj, Gönder.
/// Merkez yetkilinin konumudur (Kural 10).
abstract final class EvacuationBroadcastSheet {
  static Future<BroadcastSendResult?> show(
    BuildContext context, {
    required BroadcastRepository repository,
    required LocationService locationService,
    required String officialUid,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return AppBottomSheet.show<BroadcastSendResult>(
      context,
      title: l10n.broadcastTitle,
      child: _BroadcastForm(
        repository: repository,
        locationService: locationService,
        officialUid: officialUid,
      ),
    );
  }

  /// Bildirimde ve Firestore'da başlık olarak kullanılan tür adı.
  static String typeLabel(AppLocalizations l10n, BroadcastType type) =>
      switch (type) {
        BroadcastType.evacuation => l10n.broadcastTypeEvacuation,
        BroadcastType.aftershock => l10n.broadcastTypeAftershock,
      };
}

class _BroadcastForm extends StatefulWidget {
  const _BroadcastForm({
    required this.repository,
    required this.locationService,
    required this.officialUid,
  });

  final BroadcastRepository repository;
  final LocationService locationService;
  final String officialUid;

  @override
  State<_BroadcastForm> createState() => _BroadcastFormState();
}

class _BroadcastFormState extends State<_BroadcastForm> {
  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();

  BroadcastType _type = BroadcastType.evacuation;
  double _radiusKm = 3;
  LatLng? _center;
  bool _locating = true;
  bool _sending = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    LatLng? center;
    try {
      center = await widget.locationService.resolveCoordinates();
    } catch (_) {
      center = null;
    }
    if (!mounted) return;
    setState(() {
      _center = center;
      _locating = false;
    });
  }

  Future<void> _send() async {
    final center = _center;
    if (_sending || center == null || !_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _sending = true;
      _failed = false;
    });

    final write = widget.repository.send(
      type: _type,
      title: EvacuationBroadcastSheet.typeLabel(l10n, _type),
      body: _message.text,
      center: center,
      radiusMeters: (_radiusKm * 1000).round(),
      createdBy: widget.officialUid,
    );
    try {
      // İnternet yokken yazım sunucu onayına kadar tamamlanmaz; Kural 8'deki
      // gibi 10 sn beklenir, anons Firestore kuyruğunda kalır.
      await write.timeout(AppConfig.offlineTimeout);
      if (mounted) Navigator.of(context).pop(BroadcastSendResult.sent);
    } on TimeoutException {
      unawaited(
        write.catchError(
          (Object e) => debugPrint('Tahliye anonsu gönderilemedi: $e'),
        ),
      );
      if (mounted) Navigator.of(context).pop(BroadcastSendResult.queued);
    } catch (e) {
      debugPrint('Tahliye anonsu gönderilemedi: $e');
      if (!mounted) return;
      setState(() {
        _sending = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final critical = theme.extension<AppStatusColors>()!.critical;
    final center = _center;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<BroadcastType>(
            segments: [
              for (final t in BroadcastType.values)
                ButtonSegment<BroadcastType>(
                  value: t,
                  icon: Icon(
                    t == BroadcastType.evacuation
                        ? Icons.directions_run_rounded
                        : Icons.vibration_rounded,
                  ),
                  label: Text(EvacuationBroadcastSheet.typeLabel(l10n, t)),
                ),
            ],
            selected: {_type},
            onSelectionChanged: _sending
                ? null
                : (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.my_location_rounded, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.broadcastCenter,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _locating
                            ? l10n.broadcastLocating
                            : center == null
                            ? l10n.broadcastLocationUnavailable
                            : '${center.latitude.toStringAsFixed(5)}, '
                                  '${center.longitude.toStringAsFixed(5)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: !_locating && center == null ? critical : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_locating && center == null)
                  IconButton(
                    tooltip: l10n.broadcastRetryLocation,
                    onPressed: _locate,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.broadcastRadius(_radiusKm.toStringAsFixed(1))),
          Slider(
            min: 0.1,
            max: 20,
            divisions: 199,
            value: _radiusKm,
            label: l10n.broadcastRadiusShort(_radiusKm.toStringAsFixed(1)),
            onChanged: _sending ? null : (v) => setState(() => _radiusKm = v),
          ),
          TextFormField(
            controller: _message,
            enabled: !_sending,
            maxLength: 500,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.broadcastMessageLabel,
              border: const OutlineInputBorder(),
            ),
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l10n.broadcastRequired : null,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.broadcastInfo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (_failed) ...[
            const SizedBox(height: 8),
            Text(l10n.broadcastSaveFailed, style: TextStyle(color: critical)),
          ],
          const SizedBox(height: 16),
          AppButton.danger(
            label: l10n.broadcastSave,
            icon: Icons.campaign_rounded,
            isLoading: _sending,
            onPressed: center == null ? null : _send,
          ),
        ],
      ),
    );
  }
}
