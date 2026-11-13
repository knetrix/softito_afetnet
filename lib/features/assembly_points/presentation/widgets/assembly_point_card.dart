// Haritada seçilen toplanma noktasının bilgi kartı: tür, mesafe, doluluk yüzdesi, hizmetler, açıklama.

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/assembly_point.dart';
import '../../domain/assembly_point_type.dart';
import '../../domain/assembly_service.dart';

/// Toplanma Alanı Detay Kartı.
class AssemblyPointCard extends StatelessWidget {
  const AssemblyPointCard({
    super.key,
    required this.point,
    required this.onGetDirections,
    this.userLocation,
    this.onClose,
    this.isNearest = false,
  });

  final AssemblyPoint point;
  final LatLng? userLocation;
  final VoidCallback? onClose;
  final void Function(AssemblyPoint point) onGetDirections;
  final bool isNearest;

  // Nokta türünün metni.
  String _typeLabel(BuildContext context, AssemblyPointType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case AssemblyPointType.assembly:
        return l10n?.assemblyFilterAssembly ?? 'Toplanma Alanı';
      case AssemblyPointType.fieldHospital:
        return l10n?.assemblyFilterFieldHospital ?? 'Sahra Hastanesi';
      case AssemblyPointType.shelter:
        return l10n?.assemblyFilterShelter ?? 'Barınma / Çadır';
    }
  }

  // Nokta türünün simgesi.
  IconData _iconForType(AssemblyPointType type) {
    switch (type) {
      case AssemblyPointType.assembly:
        return Icons.groups_rounded;
      case AssemblyPointType.fieldHospital:
        return Icons.medical_services_rounded;
      case AssemblyPointType.shelter:
        return Icons.night_shelter_rounded;
    }
  }

  // Hizmetin metni.
  String _serviceLabel(BuildContext context, AssemblyService service) {
    final l10n = AppLocalizations.of(context);
    switch (service) {
      case AssemblyService.water:
        return l10n?.assemblyServiceWater ?? 'Temiz Su';
      case AssemblyService.health:
        return l10n?.assemblyServiceHealth ?? 'İlk Yardım';
      case AssemblyService.food:
        return l10n?.assemblyServiceFood ?? 'Sıcak Yemek';
      case AssemblyService.tent:
        return l10n?.assemblyServiceTent ?? 'Barınma';
    }
  }

  // Hizmetin simgesi.
  IconData _serviceIcon(AssemblyService service) {
    switch (service) {
      case AssemblyService.water:
        return Icons.water_drop_outlined;
      case AssemblyService.health:
        return Icons.medical_services_outlined;
      case AssemblyService.food:
        return Icons.restaurant_outlined;
      case AssemblyService.tent:
        return Icons.night_shelter_outlined;
    }
  }

  // Doluluk oranına göre renk seçer: az doluysa yeşil, orta ise turuncu, çok doluysa kırmızı.
  Color _occupancyColor(BuildContext context, double rate) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    if (rate >= 0.90) return status.critical;
    if (rate >= 0.70) return status.urgent;
    return status.normal;
  }

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColors = theme.extension<AppStatusColors>()!;
    final l10n = AppLocalizations.of(context);

    final distanceText =
        userLocation != null ? point.formatDistance(userLocation!) : null;
    final occupancyColor = _occupancyColor(context, point.occupancyRate);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNearest
              ? colors.primary.withValues(alpha: 0.8)
              : colors.outline.withValues(alpha: 0.35),
          width: isNearest ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Üst Satır: İkon, Başlık ve Kapat Butonu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForType(point.type),
                  color: colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _typeLabel(context, point.type),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClose != null)
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Rozetler: Açık/Kapalı, Mesafe, En Yakın
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusBadge(
                label: point.isOpen
                    ? (l10n?.assemblyOpenLabel ?? 'Açık')
                    : (l10n?.assemblyClosedLabel ?? 'Kapalı'),
                color: point.isOpen ? statusColors.normal : statusColors.critical,
              ),
              if (distanceText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.near_me_outlined, size: 12, color: colors.primary),
                      const SizedBox(width: 4),
                      Text(
                        distanceText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isNearest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.primary),
                  ),
                  child: Text(
                    l10n?.assemblyNearestBadge ?? 'En Yakın',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Doluluk Barı ve Kapasite Bilgisi
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      l10n?.assemblyOccupancyLabel(point.occupancyPercentage) ??
                          'Doluluk: %${point.occupancyPercentage}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: occupancyColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.assemblyCapacityLabel(
                          point.currentCount.toString(),
                          point.capacity.toString(),
                        ) ??
                        '${point.currentCount} / ${point.capacity} Kişi',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: point.occupancyRate,
                  backgroundColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),

          // Hizmetler
          if (point.services.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: point.services.map((svc) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _serviceIcon(svc),
                        size: 14,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _serviceLabel(context, svc),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // Açıklama (varsa)
          if (point.description != null && point.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              point.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),

          // Yol Tarifi Al / Rota Butonu
          AppButton.primary(
            label: l10n?.assemblyGetDirections ?? 'Yol Tarifi Al',
            icon: Icons.directions_rounded,
            onPressed: () => onGetDirections(point),
          ),
        ],
      ),
    );
  }
}
