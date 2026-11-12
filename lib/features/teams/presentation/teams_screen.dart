import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../live_feed/domain/live_feed_repository.dart';
import '../../live_feed/presentation/feed_labels.dart';
import '../../live_feed/presentation/live_feed_screen.dart' show FeedChoiceChip;
import '../../live_feed/presentation/widgets/live_feed_map.dart';
import '../domain/team.dart';
import '../domain/teams_repository.dart';
import 'sheets/assignment_sheets.dart';
import 'teams_controller.dart';

/// Y2 — Ekipler (PROJECT_NEW.md §3.1 Y2, §3.2, §4 Kural 6; T1, T2).
class TeamsScreen extends StatelessWidget {
  const TeamsScreen({
    super.key,
    this.controller,
    this.tileLayer,
    this.officialUid,
  });

  /// Testlerde sahte veriyle açmak için.
  final TeamsController? controller;
  final Widget? tileLayer;

  /// Testlerde giriş yapmış yetkili; verilmezse `AuthController`'dan okunur.
  final String? officialUid;

  @override
  Widget build(BuildContext context) {
    final view = _TeamsView(tileLayer: tileLayer, officialUid: officialUid);
    if (controller != null) {
      return ChangeNotifierProvider<TeamsController>.value(
        value: controller!,
        child: view,
      );
    }
    return ChangeNotifierProvider<TeamsController>(
      create: (ctx) => TeamsController(
        repository: ctx.read<TeamsRepository>(),
        liveFeedRepository: ctx.read<LiveFeedRepository>(),
        locationService: ctx.read<LocationService>(),
      ),
      child: view,
    );
  }
}

class _TeamsView extends StatelessWidget {
  const _TeamsView({this.tileLayer, this.officialUid});

  final Widget? tileLayer;
  final String? officialUid;

  String? _officialUid(BuildContext context) {
    if (officialUid != null) return officialUid;
    try {
      return context.read<AuthController>().currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  void _assign(BuildContext context, Team team) {
    final uid = _officialUid(context);
    if (uid == null) return;
    AssignTaskSheet.show(
      context,
      team: team,
      openIncidents: context.read<TeamsController>().openIncidents,
      repository: context.read<TeamsController>().repository,
      officialUid: uid,
    );
  }

  void _update(BuildContext context, Team team) {
    final uid = _officialUid(context);
    if (uid == null) return;
    final ctrl = context.read<TeamsController>();
    final assignment = ctrl.activeAssignmentOf(team.id);
    if (assignment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.updateNoActiveTask),
        ),
      );
      return;
    }
    UpdateTaskSheet.show(
      context,
      team: team,
      assignment: assignment,
      incident: ctrl.incidentById(assignment.incidentId),
      repository: ctrl.repository,
      officialUid: uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<TeamsController>();
    final l10n = AppLocalizations.of(context)!;
    final teams = ctrl.filteredTeams;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(controller: ctrl)),
            SliverToBoxAdapter(child: _TypeFilterBar(controller: ctrl)),
            SliverToBoxAdapter(
              child: _MiniMap(
                teams: teams,
                controller: ctrl,
                tileLayer: tileLayer,
              ),
            ),
            if (ctrl.listStatus != ViewStatus.ready)
              SliverToBoxAdapter(
                child: StateView(
                  status: ctrl.listStatus,
                  emptyMessage: l10n.teamsEmpty,
                  emptyIcon: Icons.groups_outlined,
                  onRetry: ctrl.retry,
                  child: const SizedBox.shrink(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                sliver: SliverList.separated(
                  itemCount: teams.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final team = teams[i];
                    return TeamCard(
                      key: ValueKey(team.id),
                      team: team,
                      taskText: _taskText(l10n, ctrl, team),
                      distance: FeedLabels.distance(
                        l10n,
                        ctrl.userLocation,
                        team.location,
                      ),
                      onAssign: () => _assign(context, team),
                      onUpdate: () => _update(context, team),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// "Enkaz Altında · Yola Çıktı". Metin Firestore'a yazılmaz; olay ve görev
  /// durumundan cihaz dilinde üretilir.
  static String _taskText(AppLocalizations l10n, TeamsController c, Team t) {
    if (t.isAvailable) return l10n.teamIdleDescription;
    final assignment = c.activeAssignmentOf(t.id);
    final incident = c.incidentById(assignment?.incidentId ?? t.currentTask);
    if (incident == null) return l10n.teamTaskNotFound;
    return [
      FeedLabels.helpType(l10n, incident.type),
      if (incident.requestCount > 1)
        l10n.liveFeedMergedCalls(incident.requestCount),
      if (assignment != null) FeedLabels.caseStatus(l10n, assignment.status),
    ].join(' · ');
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final TeamsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outline.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.teamsSummaryTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.teamsSummarySubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.teamsSummaryCount(
                  controller.teams.length,
                  controller.totalMembers,
                ),
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeFilterBar extends StatelessWidget {
  const _TypeFilterBar({required this.controller});

  final TeamsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = <(TeamType?, String, IconData?)>[
      (
        null,
        l10n.liveFeedFilterAll(controller.teams.length),
        Icons.groups_rounded,
      ),
      for (final t in TeamType.values)
        (
          t,
          '${FeedLabels.teamType(l10n, t)} (${controller.countOf(t)})',
          FeedLabels.teamTypeIcon(t),
        ),
    ];
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (type, label, icon) = items[i];
          return FeedChoiceChip(
            label: label,
            icon: icon,
            selected: controller.filter == type,
            onSelected: () => controller.setFilter(type),
          );
        },
      ),
    );
  }
}

class _MiniMap extends StatelessWidget {
  const _MiniMap({
    required this.teams,
    required this.controller,
    this.tileLayer,
  });

  final List<Team> teams;
  final TeamsController controller;
  final Widget? tileLayer;

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final colors = Theme.of(context).colorScheme;
    final located = teams.where((t) => t.location != null).toList();
    final user = controller.userLocation;
    final center =
        user ??
        (located.isNotEmpty
            ? located.first.location!
            : LiveFeedMap.defaultCenter);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 170,
          child: FlutterMap(
            // Veri değişince kamera yeniden ortalansın.
            key: ValueKey('${center.latitude},${center.longitude}'),
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
            ),
            children: [
              tileLayer ??
                  TileLayer(
                    urlTemplate: AppConfig.osmTileUrl,
                    userAgentPackageName: AppConfig.osmUserAgentPackageName,
                  ),
              const RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [TextSourceAttribution(AppConfig.osmAttribution)],
              ),
              MarkerLayer(
                markers: [
                  if (user != null)
                    Marker(
                      point: user,
                      width: 18,
                      height: 18,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  for (final t in located)
                    Marker(
                      point: t.location!,
                      width: 30,
                      height: 30,
                      child: Tooltip(
                        message: t.name,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: t.isAvailable
                                ? status.normal
                                : status.critical,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            FeedLabels.teamTypeIcon(t.type),
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Y2 ekip kartı: ad, lider, mesafe, konum, mevcut görev, durum,
/// Görev Ata / Görev Güncelle. "Telsiz #" butonu yoktur (T2).
class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    required this.taskText,
    required this.onAssign,
    required this.onUpdate,
    this.distance,
  });

  final Team team;
  final String taskText;
  final String? distance;
  final VoidCallback onAssign;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = theme.extension<AppStatusColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final accent = team.isAvailable ? status.normal : status.critical;
    final locationLine = [?distance, ?team.locationText].join(' • ');

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: accent.withValues(alpha: 0.15),
                  child: Icon(
                    FeedLabels.teamTypeIcon(team.type),
                    color: accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (team.leaderName.isNotEmpty)
                        Text(
                          l10n.teamLeaderWithName(team.leaderName),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label: team.isAvailable
                      ? l10n.teamStatusAvailable
                      : l10n.teamStatusOnDuty,
                  color: accent,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: colors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [
                      if (locationLine.isNotEmpty) locationLine,
                      l10n.teamMembers(team.memberCount),
                    ].join(' • '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              team.isAvailable
                  ? l10n.teamOperationStatus
                  : l10n.teamCurrentTask,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(taskText, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            if (team.isAvailable)
              AppButton.primary(
                label: l10n.assignTaskAction,
                icon: Icons.assignment_turned_in_outlined,
                onPressed: onAssign,
              )
            else
              AppButton.secondary(
                label: l10n.updateTaskAction,
                icon: Icons.update_rounded,
                isFullWidth: true,
                onPressed: onUpdate,
              ),
          ],
        ),
      ),
    );
  }
}
