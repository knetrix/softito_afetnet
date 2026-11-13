// Olay Detay paneli: telefon, tıbbi özet, Olayı Kapat.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/incident.dart';
import '../../domain/incident_summary.dart';
import '../feed_labels.dart';
import '../live_feed_controller.dart';

/// Y1 "Detay" (§3.2): çağrı sahibinin telefonu (arama butonu) ve tıbbi özeti,
/// bağlı çağrı sayısı, görev durumu, Olayı Kapat (Kural 5, 7).
abstract final class IncidentDetailSheet {
  static Future<void> show(
    BuildContext context, {
    required LiveFeedController controller,
    required Incident incident,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    return AppBottomSheet.show<void>(
      context,
      title: l10n.incidentDetailTitle,
      trailing: StatusBadge.priority(incident.priority),
      child: _DetailBody(
        controller: controller,
        incident: incident,
        messenger: messenger,
      ),
    );
  }
}

class _DetailBody extends StatefulWidget {
  const _DetailBody({
    required this.controller,
    required this.incident,
    required this.messenger,
  });

  final LiveFeedController controller;
  final Incident incident;
  final ScaffoldMessengerState messenger;

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  late final Future<IncidentDetail> _detail = widget.controller.fetchDetail(
    widget.incident,
  );
  bool _closing = false;

  Future<void> _close() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.incidentCloseConfirmTitle,
      message: l10n.incidentCloseConfirmMessage,
      confirmLabel: l10n.incidentCloseAction,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _closing = true);
    var ok = false;
    try {
      ok = await widget.controller.closeIncident(widget.incident);
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    setState(() => _closing = false);
    if (ok) Navigator.of(context).pop();
    widget.messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.incidentClosed : l10n.incidentCloseFailed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // Sheet açıkken olay güncellenirse (ör. ekip atandı) son hâl gösterilir.
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final incident =
            widget.controller.incidentById(widget.incident.id) ??
            widget.incident;
        final summary = widget.controller.summaryOf(incident.id);
        final team = widget.controller.teamById(incident.assignedTeamId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<IncidentDetail>(
              future: _detail,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return Text(
                    l10n.incidentDetailLoadFailed,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  );
                }
                return _CallerSection(detail: snap.data!);
              },
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: l10n.incidentDetailNeedType,
              value: FeedLabels.helpType(l10n, incident.type),
            ),
            if (summary?.peopleCount != null)
              _InfoRow(
                label: l10n.helpRequestPeopleCount,
                value: '${summary!.peopleCount}',
              ),
            if (summary?.addressText != null)
              _InfoRow(
                label: l10n.helpRequestAddress,
                value: summary!.addressText!,
              ),
            if (summary?.description != null)
              _InfoRow(
                label: l10n.helpRequestDescription,
                value: summary!.description!,
              ),
            FutureBuilder<IncidentDetail>(
              future: _detail,
              builder: (context, snap) {
                final cancelled = snap.data?.cancelledCalls ?? 0;
                return _InfoRow(
                  label: l10n.incidentDetailLinkedCalls,
                  value: cancelled > 0
                      ? l10n.incidentDetailLinkedCallsValue(
                          incident.requestCount,
                          cancelled,
                        )
                      : '${incident.requestCount}',
                );
              },
            ),
            _InfoRow(
              label: l10n.incidentDetailTaskStatus,
              value: FeedLabels.caseStatus(l10n, incident.status),
              valueColor: FeedLabels.caseStatusColor(context, incident.status),
            ),
            _InfoRow(
              label: l10n.assignedTeamLabel,
              value:
                  team?.name ??
                  incident.assignedTeamId ??
                  l10n.profileNotAssigned,
            ),
            const SizedBox(height: 20),
            if (!incident.isOpen)
              const SizedBox.shrink()
            else if (incident.canBeClosedDirectly)
              AppButton.danger(
                label: l10n.incidentCloseAction,
                icon: Icons.task_alt_rounded,
                isLoading: _closing,
                onPressed: _close,
              )
            else
              Text(
                l10n.incidentCloseHasTeam,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CallerSection extends StatelessWidget {
  const _CallerSection({required this.detail});

  final IncidentDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final critical = theme.extension<AppStatusColors>()!.critical;
    final phone = detail.phone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.incidentDetailCaller,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail.fullName ?? l10n.liveFeedUnknownName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone == null
                          ? l10n.incidentDetailNoPhone
                          : Validators.formatPhone(phone),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (phone != null)
                AppButton.primary(
                  label: l10n.incidentDetailCall,
                  icon: Icons.call_rounded,
                  isFullWidth: false,
                  onPressed: () => launchUrl(Uri(scheme: 'tel', path: phone)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: critical.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: critical.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.medical_information_rounded,
                    size: 18,
                    color: critical,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.incidentDetailMedical,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!detail.hasMedical)
                Text(
                  l10n.incidentDetailNoMedical,
                  style: TextStyle(color: colors.onSurfaceVariant),
                )
              else ...[
                if (detail.bloodType != null)
                  _InfoRow(
                    label: l10n.profileBloodType,
                    value: detail.bloodType!,
                  ),
                if (detail.medications != null)
                  _InfoRow(
                    label: l10n.profileMedications,
                    value: detail.medications!,
                  ),
                if (detail.conditions != null)
                  _InfoRow(
                    label: l10n.profileConditions,
                    value: detail.conditions!,
                  ),
                if (detail.birthYear != null)
                  _InfoRow(
                    label: l10n.profileAge,
                    value: '${DateTime.now().year - detail.birthYear!}',
                  ),
                if (detail.weightKg != null)
                  _InfoRow(
                    label: l10n.profileWeight,
                    value: '${detail.weightKg}',
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
