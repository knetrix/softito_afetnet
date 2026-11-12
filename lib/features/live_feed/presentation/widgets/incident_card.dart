import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../teams/domain/team.dart';
import '../../domain/incident.dart';
import '../../domain/incident_summary.dart';
import '../feed_labels.dart';

/// Y1 olay kartı (§3.1 Y1, T9): ad, kişi sayısı, mesafe, adres tarifi,
/// açıklama, süre, öncelik rozeti. Butonlar yalnızca Detay ve Ekip Yönlendir.
class IncidentCard extends StatelessWidget {
  const IncidentCard({
    super.key,
    required this.incident,
    required this.onDetail,
    required this.onDispatch,
    this.summary,
    this.assignedTeam,
    this.userLocation,
    this.now,
  });

  final Incident incident;
  final IncidentSummary? summary;
  final Team? assignedTeam;
  final LatLng? userLocation;
  final VoidCallback onDetail;
  final VoidCallback onDispatch;

  /// Testlerde sabit zaman için.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = theme.extension<AppStatusColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final accent = status.forPriority(incident.priority);

    final name = summary?.fullName ?? l10n.liveFeedUnknownName;
    final distance = FeedLabels.distance(l10n, userLocation, incident.location);
    final address = summary?.addressText;
    final locationLine = [?distance, ?address].join(' • ');
    final description = summary?.description;
    final people = summary?.peopleCount;
    final hasTeam = incident.assignedTeamId != null;

    final meta = [
      FeedLabels.helpType(l10n, incident.type),
      if (incident.requestCount > 1)
        l10n.liveFeedMergedCalls(incident.requestCount),
      FeedLabels.timeAgo(l10n, incident.createdAt, now ?? DateTime.now()),
    ].join(' • ');

    // Yuvarlak köşe farklı renkli kenarlıkla çizilemediği için köşeler
    // ClipRRect ile kırpılır; soldaki öncelik çizgisi tasarımdaki gibidir.
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (people != null)
                        _Chip(
                          text: l10n.peopleCountLabel(people),
                          color: accent,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge.priority(incident.priority),
              ],
            ),
            if (locationLine.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.near_me_rounded, size: 14, color: colors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      locationLine,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description != null) ...[
                    Text(
                      '"$description"',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Icon(
                        FeedLabels.helpTypeIcon(incident.type),
                        size: 14,
                        color: accent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          meta,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (hasTeam) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.groups_rounded, size: 16, color: colors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.liveFeedAssignedTeam(
                        assignedTeam?.name ?? incident.assignedTeamId!,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  StatusBadge(
                    label: FeedLabels.caseStatus(l10n, incident.status),
                    color: FeedLabels.caseStatusColor(context, incident.status),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: l10n.detail,
                    icon: Icons.info_outline_rounded,
                    isFullWidth: true,
                    onPressed: onDetail,
                  ),
                ),
                if (!hasTeam) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton.danger(
                      label: l10n.liveFeedDispatch,
                      icon: Icons.send_rounded,
                      onPressed: onDispatch,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
