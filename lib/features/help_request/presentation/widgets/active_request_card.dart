// Ana Sayfa'daki aktif çağrı kartı (durum, ekip, iptal).

import 'package:flutter/material.dart';

import '../../../../core/constants/case_status.dart';
import '../../../../core/constants/help_type.dart';
import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/assigned_team_info.dart';
import '../../domain/help_request.dart';
import '../../domain/help_request_draft.dart';

/// Afetzede Aktif Yardım Çağrısı Kartı (PROJECT_NEW.md §3.1 A1, §4 Kural 4, Kural 6, Kural 7).
class ActiveRequestCard extends StatelessWidget {
  const ActiveRequestCard({
    super.key,
    required this.onCancel,
    this.request,
    this.offlineDraft,
    this.assignedTeam,
    this.isCancelling = false,
  }) : assert(
          request != null || offlineDraft != null,
          'request veya offlineDraft parametrelerinden en az biri verilmelidir.',
        );

  final HelpRequest? request;
  final HelpRequestDraft? offlineDraft;
  final AssignedTeamInfo? assignedTeam;
  final Future<bool> Function(String requestId) onCancel;
  final bool isCancelling;

  bool get isOffline => offlineDraft != null && request == null;
  String get requestId => request?.id ?? offlineDraft!.id;
  HelpType get type => request?.type ?? offlineDraft!.type;
  int get priority => request?.priority ?? offlineDraft!.priority;
  int get peopleCount => request?.peopleCount ?? offlineDraft!.peopleCount;
  String? get addressText => request?.addressText ?? offlineDraft?.addressText;
  String? get description => request?.description ?? offlineDraft?.description;
  CaseStatus get status => request?.status ?? CaseStatus.pending;

  String _typeLabel(BuildContext context, HelpType t) {
    final l10n = AppLocalizations.of(context);
    switch (t) {
      case HelpType.debris:
        return l10n?.helpTypeDebris ?? 'Enkaz Altında';
      case HelpType.medical:
        return l10n?.helpTypeMedical ?? 'Tıbbi Müdahale';
      case HelpType.shelter:
        return l10n?.helpTypeShelter ?? 'Barınma';
      case HelpType.heating:
        return l10n?.helpTypeHeating ?? 'Isınma';
      case HelpType.babyFood:
        return l10n?.helpTypeBabyFood ?? 'Bebek Maması';
      case HelpType.water:
        return l10n?.helpTypeWater ?? 'Su';
      case HelpType.other:
        return l10n?.helpTypeOther ?? 'Diğer';
    }
  }

  IconData _typeIcon(HelpType t) {
    switch (t) {
      case HelpType.debris:
        return Icons.domain_disabled_rounded;
      case HelpType.medical:
        return Icons.medical_services_outlined;
      case HelpType.shelter:
        return Icons.night_shelter_outlined;
      case HelpType.heating:
        return Icons.local_fire_department_outlined;
      case HelpType.babyFood:
        return Icons.child_care_rounded;
      case HelpType.water:
        return Icons.water_drop_outlined;
      case HelpType.other:
        return Icons.more_horiz_rounded;
    }
  }

  Future<void> _handleCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final statusColors = Theme.of(context).extension<AppStatusColors>()!;

    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.cancelRequestTitle,
      message: l10n.cancelRequestMessage,
      confirmLabel: l10n.cancelRequestConfirm,
      // "İptal" ile "Evet, İptal Et" yan yana karışıyordu.
      cancelLabel: l10n.cancelRequestKeep,
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      final ok = await onCancel(requestId);
      if (!context.mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cancelRequestSuccess),
            backgroundColor: statusColors.normal,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColors = theme.extension<AppStatusColors>()!;
    final l10n = AppLocalizations.of(context);

    // Durum rozeti metni ve rengi
    final (String statusText, Color statusColor) = isOffline
        ? (
            l10n?.helpRequestStatusPendingOffline ?? 'Gönderilmeyi Bekliyor',
            statusColors.urgent,
          )
        : switch (status) {
            CaseStatus.pending => (
                l10n?.caseStatusPending ?? 'Beklemede',
                statusColors.urgent,
              ),
            CaseStatus.assigned => (
                l10n?.caseStatusAssigned ?? 'Ekip Yönlendirildi',
                colors.primary,
              ),
            CaseStatus.enRoute => (
                l10n?.caseStatusEnRoute ?? 'Yola Çıktı',
                statusColors.urgent,
              ),
            CaseStatus.onSite => (
                l10n?.caseStatusOnSite ?? 'Olay Yerinde',
                statusColors.critical,
              ),
            CaseStatus.resolved => (
                l10n?.caseStatusResolved ?? 'Kurtarıldı',
                statusColors.normal,
              ),
            CaseStatus.cancelled => (
                l10n?.caseStatusCancelled ?? 'İptal Edildi',
                colors.outline,
              ),
          };

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık Satırı: Durum Rozeti ve Öncelik Rozeti
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusBadge(
                label: statusText,
                color: statusColor,
              ),
              StatusBadge.priority(priority),
            ],
          ),
          const SizedBox(height: 12),

          // İhtiyaç Türü ve Kişi Sayısı Satırı
          Row(
            children: [
              Icon(_typeIcon(type), size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _typeLabel(context, type),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n?.peopleCountLabel(peopleCount) ?? '$peopleCount Kişi',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Ekip Bilgisi (Kural 6)
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
            ),
            child: assignedTeam != null
                ? Row(
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        size: 22,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n?.assignedTeamLabel ?? "Yönlendirilen Ekip"}: ${assignedTeam!.name}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (assignedTeam!.leaderName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${l10n?.teamLeaderLabel ?? "Sorumlu"}: ${assignedTeam!.leaderName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n?.teamWaitingLabel ??
                              'Ekip yönlendirmesi bekleniyor...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Adres / Açıklama (varsa)
          if (addressText != null && addressText!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    addressText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notes_rounded,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // İptal Et Butonu (Kural 7: resolved/cancelled değilse)
          if (status != CaseStatus.resolved && status != CaseStatus.cancelled) ...[
            const SizedBox(height: 16),
            AppButton.danger(
              label: l10n?.cancelRequestAction ?? 'Çağrıyı İptal Et',
              isLoading: isCancelling,
              onPressed: () => _handleCancel(context),
            ),
          ],
        ],
      ),
    );
  }
}
