import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/offline_queue_service.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/utils/sms_uri.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../help_request/presentation/sheets/help_request_sheet.dart';
import '../../profile/domain/profile_repository.dart';
import '../../profile/domain/user_contact_profile.dart';
import '../../safety_signal/domain/safety_signal.dart';
import '../../safety_signal/domain/safety_signal_repository.dart';
import '../../safety_signal/presentation/safety_signal_controller.dart';
import '../../safety_signal/presentation/widgets/panic_hold_button.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri);

/// A1 — Afetzede Ana Sayfası (PROJECT_NEW.md §3.1, 19.20.02, T1, T8).
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.safetySignalRepository,
    this.onAddHelpRequest,
    this.onOpenWhistle,
    this.onOpenProfile,
    this.urlLauncher,
    this.panicHoldDuration = const Duration(seconds: 2),
  });

  final SafetySignalRepository? safetySignalRepository;
  final VoidCallback? onAddHelpRequest;
  final VoidCallback? onOpenWhistle;
  final VoidCallback? onOpenProfile;
  final ExternalUrlLauncher? urlLauncher;
  final Duration panicHoldDuration;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    if (user == null) {
      return const Scaffold(
        body: StateView(
          status: ViewStatus.loading,
          child: SizedBox.shrink(),
        ),
      );
    }

    return ChangeNotifierProvider<SafetySignalController>(
      create: (ctx) => SafetySignalController(
        repository:
            safetySignalRepository ?? ctx.read<SafetySignalRepository>(),
        locationService: ctx.read<LocationService>(),
        profileRepository: ctx.read<ProfileRepository>(),
        uid: user.uid,
      ),
      child: _HomeView(
        fullName: user.fullName,
        onAddHelpRequest: onAddHelpRequest,
        onOpenWhistle: onOpenWhistle,
        onOpenProfile: onOpenProfile,
        urlLauncher: urlLauncher ?? launchUrl,
        panicHoldDuration: panicHoldDuration,
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView({
    required this.fullName,
    required this.urlLauncher,
    required this.panicHoldDuration,
    this.onAddHelpRequest,
    this.onOpenWhistle,
    this.onOpenProfile,
  });

  final String fullName;
  final VoidCallback? onAddHelpRequest;
  final VoidCallback? onOpenWhistle;
  final VoidCallback? onOpenProfile;
  final ExternalUrlLauncher urlLauncher;
  final Duration panicHoldDuration;

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocationService>().refresh();
    });
  }

  void _goToBranch(int index, String fallbackRoute) {
    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      shell.goBranch(index);
    } else {
      context.go(fallbackRoute);
    }
  }

  void _openProfile() {
    if (widget.onOpenProfile != null) {
      widget.onOpenProfile!();
      return;
    }
    _goToBranch(3, AppRoutes.citizenProfile);
  }

  void _openWhistle() {
    if (widget.onOpenWhistle != null) {
      widget.onOpenWhistle!();
      return;
    }
    _goToBranch(2, AppRoutes.whistle);
  }

  Future<void> _handleTriggerDanger() async {
    final controller = context.read<SafetySignalController>();
    final outcome = await controller.triggerDanger();
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    switch (outcome) {
      case PanicTriggerOutcome.confirmed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.panicStatusDelivered)),
        );
      case PanicTriggerOutcome.pendingOffline:
        await _promptOfflineSms();
      case PanicTriggerOutcome.locationUnavailable:
        await _showLocationUnavailableDialog();
      case PanicTriggerOutcome.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError)),
        );
    }
  }

  Future<void> _handleMarkSafe() async {
    final ok = await context.read<SafetySignalController>().markSafe();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.panicSafeSuccess : l10n.genericError),
      ),
    );
  }

  Future<void> _promptOfflineSms() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.panicOfflineSmsTitle,
      message: l10n.panicOfflineSmsMessage,
      confirmLabel: l10n.panicOfflineSmsAction,
      cancelLabel: l10n.cancel,
    );
    if (confirmed != true || !mounted) return;
    await _launchEmergencySms();
  }

  Future<void> _launchEmergencySms() async {
    final controller = context.read<SafetySignalController>();
    final target = await controller.loadEmergencySmsTarget();
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    if (target == null) {
      await AppDialog.info(
        context,
        title: l10n.panicNoEmergencyContactTitle,
        message: l10n.panicNoEmergencyContactMessage,
      );
      return;
    }

    final body = target.coordinates != null
        ? l10n.panicSmsBodyWithLocation(
            buildLocationMapLink(
              target.coordinates!.latitude,
              target.coordinates!.longitude,
            ),
          )
        : l10n.panicSmsBodyNoLocation;

    final uri = buildEmergencySmsUri(phone: target.phone, body: body);
    final launched = await widget.urlLauncher(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.panicSmsOpenFailed)),
      );
    }
  }

  Future<void> _showLocationUnavailableDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = theme.extension<AppStatusColors>()!;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colors.outline),
          ),
          title: Row(
            children: [
              Icon(Icons.location_off_rounded, color: status.critical),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.panicLocationFailedTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            l10n.panicLocationFailedMessage,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actionsOverflowDirection: VerticalDirection.down,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.close),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _openWhistle();
              },
              icon: Icon(Icons.campaign_rounded, color: status.whistle),
              label: Text(l10n.panicOpenWhistle),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _launchEmergencySms();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                elevation: 0,
              ),
              icon: const Icon(Icons.sms_outlined, size: 18),
              label: Text(l10n.panicOfflineSmsAction),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openHelpRequestSheet() async {
    OfflineQueueService? offlineQueue;
    try {
      offlineQueue = context.read<OfflineQueueService>();
    } catch (_) {}

    await showHelpRequestSheet(
      context,
      onSubmit: offlineQueue == null
          ? null
          : (draft) async {
              final authController = context.read<AuthController>();
              final user = authController.currentUser;
              if (user == null) return false;

              final locationService = context.read<LocationService>();
              final profileRepo = context.read<ProfileRepository>();

              var coords = locationService.currentPosition;
              if (coords == null) {
                final snap = await locationService.refresh();
                coords = snap?.coordinates;
              }
              if (coords == null) {
                if (!mounted) return false;
                final l10n = AppLocalizations.of(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n?.panicLocationFailedTitle ?? 'Konum Alınamadı',
                    ),
                  ),
                );
                return false;
              }

              UserContactProfile? profile;
              try {
                profile = await profileRepo.getProfile(user.uid);
              } catch (_) {}

              final fullDraft = draft.copyWith(
                createdBy: user.uid,
                fullName: user.fullName,
                phone: profile?.phone ?? '',
                location: coords,
              );

              return offlineQueue!.submitOrQueue(fullDraft);
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = theme.extension<AppStatusColors>()!;
    final location = context.watch<LocationService>();
    final signalCtrl = context.watch<SafetySignalController>();

    final locationText = location.currentLabel ??
        (location.isFetching
            ? l10n.locationFetching
            : l10n.locationUnavailable);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HomeHeader(
                fullName: widget.fullName,
                locationText: locationText,
                isRefreshingLocation: location.isFetching,
                onRefreshLocation: location.refresh,
                onOpenProfile: _openProfile,
              ),
              const SizedBox(height: 28),
              Center(
                child: PanicHoldButton(
                  isDangerActive: signalCtrl.isDangerActive,
                  isBusy: signalCtrl.isBusy,
                  holdDuration: widget.panicHoldDuration,
                  onTriggerDanger: _handleTriggerDanger,
                  onMarkSafe: _handleMarkSafe,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    signalCtrl.isDangerActive
                        ? Icons.shield_outlined
                        : Icons.touch_app_outlined,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      signalCtrl.isDangerActive
                          ? l10n.homePanicActiveHint
                          : l10n.homePanicHoldHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (signalCtrl.isDangerActive) ...[
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusBadge(
                      label: signalCtrl.delivery == SignalDelivery.confirmed
                          ? l10n.panicStatusDelivered
                          : l10n.panicStatusPending,
                      color: signalCtrl.delivery == SignalDelivery.confirmed
                          ? status.normal
                          : status.urgent,
                    ),
                    if (signalCtrl.delivery == SignalDelivery.pending)
                      TextButton.icon(
                        onPressed: _launchEmergencySms,
                        icon: const Icon(Icons.sms_outlined, size: 16),
                        label: Text(l10n.panicOfflineSmsAction),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              // TODO(G4): Aktif yardım çağrısı kartı G4'te buraya yerleştirilecek.
              const _ActiveRequestEmptySlot(),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed:
                      widget.onAddHelpRequest ?? _openHelpRequestSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    elevation: 0,
                    minimumSize: const Size(48, 50),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notification_add_outlined, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          l10n.homeAddHelpRequest,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.fullName,
    required this.locationText,
    required this.isRefreshingLocation,
    required this.onRefreshLocation,
    required this.onOpenProfile,
  });

  final String fullName;
  final String locationText;
  final bool isRefreshingLocation;
  final VoidCallback onRefreshLocation;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: onRefreshLocation,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          locationText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isRefreshingLocation)
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: colors.primary,
                          ),
                        )
                      else
                        Icon(
                          Icons.refresh_rounded,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onOpenProfile,
          style: IconButton.styleFrom(
            backgroundColor: colors.primary.withValues(alpha: 0.14),
            foregroundColor: colors.primary,
            minimumSize: const Size(44, 44),
          ),
          icon: const Icon(Icons.person_outline_rounded),
        ),
      ],
    );
  }
}

class _ActiveRequestEmptySlot extends StatelessWidget {
  const _ActiveRequestEmptySlot();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 22,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeActiveRequestEmptyTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.homeActiveRequestEmptySubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
