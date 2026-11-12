import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/case_status.dart';
import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../live_feed/domain/incident.dart';
import '../../../live_feed/presentation/feed_labels.dart';
import '../../domain/assignment.dart';
import '../../domain/team.dart';
import '../../domain/teams_repository.dart';

/// Görev reddedildiğinde gösterilecek metin.
String assignmentErrorText(AppLocalizations l10n, Object error) {
  if (error is AssignmentException) {
    return switch (error.reason) {
      AssignmentFailure.incidentClosed => l10n.assignErrorIncidentClosed,
      AssignmentFailure.incidentAlreadyAssigned =>
        l10n.assignErrorAlreadyAssigned,
      AssignmentFailure.teamBusy => l10n.assignErrorTeamBusy,
      AssignmentFailure.invalidTransition => l10n.assignErrorInvalidTransition,
    };
  }
  return l10n.genericError;
}

/// Y1 "Ekip Yönlendir" (§3.2): boştaki ekipler, olaya uzaklığa göre sıralı.
/// Seçilen ekip olaya atanır (Kural 6).
abstract final class DispatchTeamSheet {
  static Future<void> show(
    BuildContext context, {
    required Incident incident,
    required List<Team> availableTeams,
    required TeamsRepository repository,
    required String officialUid,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    return AppBottomSheet.show<void>(
      context,
      title: l10n.liveFeedDispatch,
      child: _PickList<Team>(
        items: availableTeams,
        emptyText: l10n.dispatchNoAvailableTeams,
        emptyIcon: Icons.groups_outlined,
        tileBuilder: (context, team) => _TeamTile(
          team: team,
          distance: FeedLabels.distance(l10n, team.location, incident.location),
        ),
        onPick: (team) async {
          await repository.assignTeam(
            incident: incident,
            team: team,
            officialUid: officialUid,
          );
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.dispatchSuccess(team.name))),
          );
        },
      ),
    );
  }
}

/// Y2 "Görev Ata" (§3.2): ekip bekleyen açık olaylar, önceliğe göre.
abstract final class AssignTaskSheet {
  static Future<void> show(
    BuildContext context, {
    required Team team,
    required List<Incident> openIncidents,
    required TeamsRepository repository,
    required String officialUid,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    // Liste Firestore'dan öncelik + zaman sırasıyla gelir (Kural 1).
    final waiting = openIncidents
        .where((i) => i.assignedTeamId == null)
        .toList();
    return AppBottomSheet.show<void>(
      context,
      title: l10n.assignTaskAction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.assignSheetSubtitle(team.name),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _PickList<Incident>(
            items: waiting,
            emptyText: l10n.assignNoOpenIncidents,
            emptyIcon: Icons.inbox_outlined,
            tileBuilder: (context, incident) =>
                _IncidentTile(incident: incident, teamLocation: team.location),
            onPick: (incident) async {
              await repository.assignTeam(
                incident: incident,
                team: team,
                officialUid: officialUid,
              );
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.dispatchSuccess(team.name))),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Y2 "Görev Güncelle" (§3.2): yalnızca bir sonraki adım butonu (Kural 6).
abstract final class UpdateTaskSheet {
  static Future<void> show(
    BuildContext context, {
    required Team team,
    required Assignment assignment,
    required Incident? incident,
    required TeamsRepository repository,
    required String officialUid,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    return AppBottomSheet.show<void>(
      context,
      title: l10n.updateTaskAction,
      child: _UpdateTaskBody(
        team: team,
        assignment: assignment,
        incident: incident,
        onAdvance: () async {
          final next = await repository.advanceAssignment(
            assignment: assignment,
            officialUid: officialUid,
          );
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                l10n.updateSuccess(FeedLabels.caseStatus(l10n, next)),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Seçim listesi: bir öğeye dokununca işlem yapılır, başarılıysa sheet kapanır,
/// hata olursa sheet açık kalır ve hata gösterilir.
class _PickList<T> extends StatefulWidget {
  const _PickList({
    required this.items,
    required this.emptyText,
    required this.emptyIcon,
    required this.tileBuilder,
    required this.onPick,
  });

  final List<T> items;
  final String emptyText;
  final IconData emptyIcon;
  final Widget Function(BuildContext context, T item) tileBuilder;
  final Future<void> Function(T item) onPick;

  @override
  State<_PickList<T>> createState() => _PickListState<T>();
}

class _PickListState<T> extends State<_PickList<T>> {
  T? _busyItem;
  String? _error;

  Future<void> _pick(T item) async {
    setState(() {
      _busyItem = item;
      _error = null;
    });
    try {
      await widget.onPick(item);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busyItem = null;
        _error = assignmentErrorText(AppLocalizations.of(context)!, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return StateView(
        status: ViewStatus.empty,
        emptyMessage: widget.emptyText,
        emptyIcon: widget.emptyIcon,
        child: const SizedBox.shrink(),
      );
    }
    final colors = Theme.of(context).colorScheme;
    final critical = Theme.of(context).extension<AppStatusColors>()!.critical;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          Text(_error!, style: TextStyle(color: critical)),
          const SizedBox(height: 8),
        ],
        for (final item in widget.items) ...[
          Material(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _busyItem == null ? () => _pick(item) : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(child: widget.tileBuilder(context, item)),
                    const SizedBox(width: 8),
                    if (_busyItem == item)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(Icons.chevron_right_rounded, color: colors.primary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _TeamTile extends StatelessWidget {
  const _TeamTile({required this.team, this.distance});

  final Team team;
  final String? distance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final normal = theme.extension<AppStatusColors>()!.normal;
    final details = [
      FeedLabels.teamType(l10n, team.type),
      if (team.leaderName.isNotEmpty) team.leaderName,
      l10n.teamMembers(team.memberCount),
      ?distance,
    ].join(' • ');
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: normal.withValues(alpha: 0.15),
          child: Icon(
            FeedLabels.teamTypeIcon(team.type),
            color: normal,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                details,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IncidentTile extends StatelessWidget {
  const _IncidentTile({required this.incident, this.teamLocation});

  final Incident incident;
  final LatLng? teamLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = theme.extension<AppStatusColors>()!.forPriority(
      incident.priority,
    );
    final details = [
      if (incident.requestCount > 1)
        l10n.liveFeedMergedCalls(incident.requestCount),
      ?FeedLabels.distance(l10n, teamLocation, incident.location),
      FeedLabels.timeAgo(l10n, incident.createdAt, DateTime.now()),
    ].join(' • ');
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            FeedLabels.helpTypeIcon(incident.type),
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      FeedLabels.helpType(l10n, incident.type),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge.priority(incident.priority),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                details,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UpdateTaskBody extends StatefulWidget {
  const _UpdateTaskBody({
    required this.team,
    required this.assignment,
    required this.incident,
    required this.onAdvance,
  });

  final Team team;
  final Assignment assignment;
  final Incident? incident;
  final Future<void> Function() onAdvance;

  @override
  State<_UpdateTaskBody> createState() => _UpdateTaskBodyState();
}

class _UpdateTaskBodyState extends State<_UpdateTaskBody> {
  bool _busy = false;
  String? _error;

  Future<void> _advance() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onAdvance();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = assignmentErrorText(AppLocalizations.of(context)!, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final current = widget.assignment.status;
    final next = widget.assignment.nextStatus;
    final incident = widget.incident;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.team.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (incident != null) ...[
          const SizedBox(height: 4),
          Text(
            FeedLabels.helpType(l10n, incident.type),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _StepIndicator(current: current),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              l10n.updateSheetCurrent,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            StatusBadge(
              label: FeedLabels.caseStatus(l10n, current),
              color: FeedLabels.caseStatusColor(context, current),
            ),
          ],
        ),
        if (next == CaseStatus.resolved) ...[
          const SizedBox(height: 12),
          Text(
            l10n.updateSheetResolvedNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: TextStyle(
              color: theme.extension<AppStatusColors>()!.critical,
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (next != null)
          AppButton.primary(
            label: l10n.updateSheetNext(FeedLabels.caseStatus(l10n, next)),
            icon: Icons.arrow_forward_rounded,
            isLoading: _busy,
            onPressed: _advance,
          ),
      ],
    );
  }
}

/// Atandı → Yola Çıktı → Olay Yerinde → Kurtarıldı adımları.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final CaseStatus current;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = AssignmentFlow.steps.indexOf(current);
    return Row(
      children: [
        for (var i = 0; i < AssignmentFlow.steps.length; i++)
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i <= currentIndex
                        ? colors.primary
                        : colors.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  FeedLabels.caseStatus(l10n, AssignmentFlow.steps[i]),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: i == currentIndex
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: i <= currentIndex
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
