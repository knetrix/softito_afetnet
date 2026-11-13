// Mor panik pini paneli: konum, zaman, Ulaşıldı.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../safety_signal/domain/safety_signal.dart';
import '../feed_labels.dart';

/// Y1 mor panik pini (§3.2): konum, zaman, Ulaşıldı (Kural 8).
abstract final class PanicSignalSheet {
  static Future<void> show(
    BuildContext context, {
    required SafetySignal signal,
    required Future<bool> Function() onMarkReached,
    LatLng? userLocation,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    return AppBottomSheet.show<void>(
      context,
      title: l10n.panicPinTitle,
      child: _PanicBody(
        signal: signal,
        userLocation: userLocation,
        onMarkReached: () async {
          final delivered = await onMarkReached();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                delivered
                    ? l10n.panicPinReachedSuccess
                    : l10n.panicPinReachedQueued,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PanicBody extends StatefulWidget {
  const _PanicBody({
    required this.signal,
    required this.onMarkReached,
    this.userLocation,
  });

  final SafetySignal signal;
  final LatLng? userLocation;
  final Future<void> Function() onMarkReached;

  @override
  State<_PanicBody> createState() => _PanicBodyState();
}

class _PanicBodyState extends State<_PanicBody> {
  bool _busy = false;
  bool _failed = false;

  Future<void> _mark() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await widget.onMarkReached();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = theme.extension<AppStatusColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final s = widget.signal;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final coords =
        '${s.location.latitude.toStringAsFixed(5)}, ${s.location.longitude.toStringAsFixed(5)}';
    final distance = FeedLabels.distance(l10n, widget.userLocation, s.location);
    final time =
        '${DateFormat.yMMMd(locale).add_Hm().format(s.updatedAt)} · ${FeedLabels.timeAgo(l10n, s.updatedAt, DateTime.now())}';

    Widget row(IconData icon, String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: status.panic),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row(
          Icons.location_on_rounded,
          l10n.panicPinLocation,
          [coords, ?distance].join('\n'),
        ),
        row(Icons.schedule_rounded, l10n.panicPinTime, time),
        const SizedBox(height: 16),
        if (s.isHandled)
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: status.normal),
              const SizedBox(width: 8),
              Text(
                l10n.panicPinHandled,
                style: TextStyle(
                  color: status.normal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        else ...[
          if (_failed) ...[
            Text(l10n.genericError, style: TextStyle(color: status.critical)),
            const SizedBox(height: 8),
          ],
          AppButton.primary(
            label: l10n.panicPinReached,
            icon: Icons.check_circle_outline_rounded,
            isLoading: _busy,
            onPressed: _mark,
          ),
        ],
      ],
    );
  }
}
