import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/case_status.dart';
import '../../../core/constants/help_type.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../teams/domain/team.dart';

/// Canlı Akış (Y1) ve Ekipler (Y2) ekranlarının ortak metin ve simge eşlemeleri.
/// Ekranlarda sabit metin yazılmaz (§3.4); tümü ARB'den gelir.
abstract final class FeedLabels {
  static String helpType(AppLocalizations l10n, HelpType t) => switch (t) {
    HelpType.debris => l10n.helpTypeDebris,
    HelpType.medical => l10n.helpTypeMedical,
    HelpType.shelter => l10n.helpTypeShelter,
    HelpType.heating => l10n.helpTypeHeating,
    HelpType.babyFood => l10n.helpTypeBabyFood,
    HelpType.water => l10n.helpTypeWater,
    HelpType.other => l10n.helpTypeOther,
  };

  static IconData helpTypeIcon(HelpType t) => switch (t) {
    HelpType.debris => Icons.domain_disabled_rounded,
    HelpType.medical => Icons.medical_services_outlined,
    HelpType.shelter => Icons.night_shelter_outlined,
    HelpType.heating => Icons.local_fire_department_outlined,
    HelpType.babyFood => Icons.child_care_rounded,
    HelpType.water => Icons.water_drop_outlined,
    HelpType.other => Icons.more_horiz_rounded,
  };

  static String caseStatus(AppLocalizations l10n, CaseStatus s) => switch (s) {
    CaseStatus.pending => l10n.caseStatusPending,
    CaseStatus.assigned => l10n.caseStatusAssigned,
    CaseStatus.enRoute => l10n.caseStatusEnRoute,
    CaseStatus.onSite => l10n.caseStatusOnSite,
    CaseStatus.resolved => l10n.caseStatusResolved,
    CaseStatus.cancelled => l10n.caseStatusCancelled,
  };

  /// Afetzede kartıyla aynı renkler (G4 `ActiveRequestCard`).
  static Color caseStatusColor(BuildContext context, CaseStatus s) {
    final colors = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    return switch (s) {
      CaseStatus.pending => status.urgent,
      CaseStatus.assigned => colors.primary,
      CaseStatus.enRoute => status.urgent,
      CaseStatus.onSite => status.critical,
      CaseStatus.resolved => status.normal,
      CaseStatus.cancelled => colors.outline,
    };
  }

  static String teamType(AppLocalizations l10n, TeamType t) => switch (t) {
    TeamType.searchRescue => l10n.teamTypeSearchRescue,
    TeamType.medical => l10n.teamTypeMedical,
    TeamType.fire => l10n.teamTypeFire,
    TeamType.logistics => l10n.teamTypeLogistics,
  };

  static IconData teamTypeIcon(TeamType t) => switch (t) {
    TeamType.searchRescue => Icons.manage_search_rounded,
    TeamType.medical => Icons.medical_services_rounded,
    TeamType.fire => Icons.local_fire_department_rounded,
    TeamType.logistics => Icons.local_shipping_rounded,
  };

  /// İki nokta arası metre (saf Dart; testlerde platform gerekmez).
  static double distanceMeters(LatLng a, LatLng b) =>
      const Distance().as(LengthUnit.Meter, a, b);

  /// "350 m mesafe" / "1.2 km mesafe". Konumlardan biri yoksa `null`.
  static String? distance(AppLocalizations l10n, LatLng? from, LatLng? to) {
    if (from == null || to == null) return null;
    final m = distanceMeters(from, to);
    if (m < 1000) return l10n.distanceMeters(m.round());
    return l10n.distanceKm((m / 1000).toStringAsFixed(1));
  }

  /// "az önce" / "7 dk önce" / "2 sa önce" / "1 gün önce".
  static String timeAgo(AppLocalizations l10n, DateTime time, DateTime now) {
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inHours < 1) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.timeHoursAgo(diff.inHours);
    return l10n.timeDaysAgo(diff.inDays);
  }
}
