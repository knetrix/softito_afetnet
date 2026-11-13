import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/help_type.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/utils/priority_policy.dart';
import '../../../core/widgets/state_view.dart';
import '../../broadcast/presentation/evacuation_fab.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../safety_signal/domain/safety_signal.dart';
import '../../teams/domain/teams_repository.dart';
import '../../teams/presentation/sheets/assignment_sheets.dart';
import '../domain/incident.dart';
import '../domain/live_feed_repository.dart';
import 'feed_labels.dart';
import 'live_feed_controller.dart';
import 'sheets/incident_detail_sheet.dart';
import 'sheets/panic_signal_sheet.dart';
import 'widgets/incident_card.dart';
import 'widgets/live_feed_map.dart';

/// Y1 — Canlı Akış (PROJECT_NEW.md §3.1 Y1, §3.2, §4 Kural 1, 5, 6, 7, 8).
class LiveFeedScreen extends StatelessWidget {
  const LiveFeedScreen({
    super.key,
    this.controller,
    this.tileLayer,
    this.officialUid,
  });

  /// Testlerde sahte veriyle açmak için.
  final LiveFeedController? controller;
  final Widget? tileLayer;

  /// Testlerde giriş yapmış yetkili; verilmezse `AuthController`'dan okunur.
  final String? officialUid;

  @override
  Widget build(BuildContext context) {
    final view = _LiveFeedView(tileLayer: tileLayer, officialUid: officialUid);
    if (controller != null) {
      return ChangeNotifierProvider<LiveFeedController>.value(
        value: controller!,
        child: view,
      );
    }
    return ChangeNotifierProvider<LiveFeedController>(
      create: (ctx) {
        final notifications = ctx.read<NotificationService>();
        return LiveFeedController(
          repository: ctx.read<LiveFeedRepository>(),
          teamsRepository: ctx.read<TeamsRepository>(),
          locationService: ctx.read<LocationService>(),
          // Kural 8: yeni panik sinyalinde yetkiliye yerel bildirim.
          onNewPanicSignal: (signal) {
            final l10n = lookupAppLocalizations(
              Localizations.maybeLocaleOf(ctx) ?? const Locale('tr'),
            );
            notifications.showLocalNotification(
              id: signal.uid.hashCode,
              title: l10n.panicNotificationTitle,
              body: l10n.panicNotificationBody,
              payload: 'panic',
            );
          },
        );
      },
      child: view,
    );
  }
}

class _LiveFeedView extends StatelessWidget {
  const _LiveFeedView({this.tileLayer, this.officialUid});

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

  void _openDetail(BuildContext context, Incident incident) {
    IncidentDetailSheet.show(
      context,
      controller: context.read<LiveFeedController>(),
      incident: incident,
    );
  }

  void _openDispatch(BuildContext context, Incident incident) {
    final uid = _officialUid(context);
    if (uid == null) return;
    final ctrl = context.read<LiveFeedController>();
    DispatchTeamSheet.show(
      context,
      incident: incident,
      availableTeams: ctrl.availableTeamsFor(incident),
      repository: ctrl.teamsRepository,
      officialUid: uid,
    );
  }

  void _openSignal(BuildContext context, SafetySignal signal) {
    final uid = _officialUid(context);
    if (uid == null) return;
    final ctrl = context.read<LiveFeedController>();
    PanicSignalSheet.show(
      context,
      signal: signal,
      userLocation: ctrl.userLocation,
      onMarkReached: () => ctrl.markSignalHandled(signal, uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<LiveFeedController>();
    final l10n = AppLocalizations.of(context)!;
    final incidents = ctrl.filteredIncidents;
    final now = DateTime.now();

    return Scaffold(
      // Ekranın kendi Scaffold'unda: açılan sheet'ler butonu örter (§3.1).
      floatingActionButton: const EvacuationFab(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 260,
                    child: LiveFeedMap(
                      incidents: ctrl.incidents,
                      signals: ctrl.signals,
                      userLocation: ctrl.userLocation,
                      tileLayer: tileLayer,
                      onIncidentTap: (i) => _openDetail(context, i),
                      onSignalTap: (s) => _openSignal(context, s),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _FilterBar(controller: ctrl)),
            SliverToBoxAdapter(child: _FeedHeader(controller: ctrl)),
            if (ctrl.listStatus != ViewStatus.ready)
              SliverToBoxAdapter(
                child: StateView(
                  status: ctrl.listStatus,
                  emptyMessage: ctrl.incidents.isEmpty
                      ? l10n.liveFeedEmpty
                      : l10n.liveFeedEmptyFiltered,
                  onRetry: ctrl.retry,
                  child: const SizedBox.shrink(),
                ),
              )
            else
              SliverPadding(
                // Alt boşluk Tahliye Anonsu butonu son kartı örtmesin diye.
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                sliver: SliverList.separated(
                  itemCount: incidents.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final incident = incidents[index];
                    return IncidentCard(
                      key: ValueKey(incident.id),
                      incident: incident,
                      summary: ctrl.summaryOf(incident.id),
                      assignedTeam: ctrl.teamById(incident.assignedTeamId),
                      userLocation: ctrl.userLocation,
                      now: now,
                      onDetail: () => _openDetail(context, incident),
                      onDispatch: () => _openDispatch(context, incident),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final LiveFeedController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final filters = <(LiveFeedFilter, String, Color?)>[
      (
        LiveFeedFilter.all,
        l10n.liveFeedFilterAll(controller.incidents.length),
        null,
      ),
      (
        const LiveFeedFilter.priority(PriorityPolicy.critical),
        l10n.liveFeedFilterCritical,
        status.critical,
      ),
      (
        const LiveFeedFilter.priority(PriorityPolicy.urgent),
        l10n.liveFeedFilterUrgent,
        status.urgent,
      ),
      (
        const LiveFeedFilter.priority(PriorityPolicy.normal),
        l10n.liveFeedFilterNormal,
        status.normal,
      ),
      for (final t in HelpType.values)
        (LiveFeedFilter.type(t), FeedLabels.helpType(l10n, t), null),
    ];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (filter, label, dot) = filters[i];
          return FeedChoiceChip(
            label: label,
            dotColor: dot,
            selected: controller.filter == filter,
            onSelected: () => controller.setFilter(filter),
          );
        },
      ),
    );
  }
}

/// Canlı Akış ve Ekipler ekranlarının filtre chip'i.
class FeedChoiceChip extends StatelessWidget {
  const FeedChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.dotColor,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? dotColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fg = selected ? colors.onPrimary : colors.onSurface;
    return Material(
      color: selected ? colors.primary : colors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? colors.primary
              : colors.outline.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
                const SizedBox(width: 6),
              ] else if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? fg : colors.primary),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({required this.controller});

  final LiveFeedController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = theme.extension<AppStatusColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final openSignals = controller.signals.where((s) => !s.isHandled).length;

    Widget pill(String text, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          letterSpacing: 0.5,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status.normal,
            ),
          ),
          Text(
            l10n.liveFeedTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          pill(
            l10n.liveFeedWaitingCount(controller.incidents.length),
            colors.onSurfaceVariant,
          ),
          if (openSignals > 0)
            pill(l10n.liveFeedPanicCount(openSignals), status.panic),
        ],
      ),
    );
  }
}
