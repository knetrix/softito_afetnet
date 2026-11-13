// A2 Toplanma ekranı: harita ve seçili nokta kartı.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/assembly_point.dart';
import '../domain/assembly_point_type.dart';
import '../domain/assembly_points_repository.dart';
import 'assembly_points_controller.dart';
import 'widgets/assembly_point_card.dart';
import 'widgets/assembly_point_marker.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri);

/// A2 — Toplanma Alanları Ekranı (PROJECT_NEW.md §3.1 A2, §3.4).
class AssemblyPointsScreen extends StatelessWidget {
  const AssemblyPointsScreen({
    super.key,
    this.repository,
    this.controller,
    this.urlLauncher,
    this.tileLayer,
  });

  final AssemblyPointsRepository? repository;
  final AssemblyPointsController? controller;
  final ExternalUrlLauncher? urlLauncher;
  final Widget? tileLayer;

  // Provider'dan güvenli okur; yoksa null döner.
  T? _safeRead<T>(BuildContext context) {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  // Arayüzü çizer.
  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return ChangeNotifierProvider<AssemblyPointsController>.value(
        value: controller!,
        child: _AssemblyPointsView(
          urlLauncher: urlLauncher ?? (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
          tileLayer: tileLayer,
        ),
      );
    }

    final repo = repository ?? _safeRead<AssemblyPointsRepository>(context);
    final locationService = _safeRead<LocationService>(context);

    if (repo == null) {
      return const Scaffold(
        body: StateView(
          status: ViewStatus.loading,
          child: SizedBox.shrink(),
        ),
      );
    }

    return ChangeNotifierProvider<AssemblyPointsController>(
      create: (_) => AssemblyPointsController(
        repository: repo,
        locationService: locationService,
      ),
      child: _AssemblyPointsView(
        urlLauncher: urlLauncher ?? (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
        tileLayer: tileLayer,
      ),
    );
  }
}

// Harita ve kartı içeren asıl ekran gövdesi.
class _AssemblyPointsView extends StatefulWidget {
  const _AssemblyPointsView({
    required this.urlLauncher,
    this.tileLayer,
  });

  final ExternalUrlLauncher urlLauncher;
  final Widget? tileLayer;

  // Widget'ın durum (State) nesnesini oluşturur.
  @override
  State<_AssemblyPointsView> createState() => _AssemblyPointsViewState();
}

// Harita denetleyicisini ve yakınlaştırmayı yönetir.
class _AssemblyPointsViewState extends State<_AssemblyPointsView> {
  final MapController _mapController = MapController();
  static const LatLng _defaultCenter = LatLng(36.2025, 36.1610);

  // Haritayı yakınlaştırır.
  void _zoomIn() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom + 1);
  }

  // Haritayı uzaklaştırır.
  void _zoomOut() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom - 1);
  }

  // Haritayı kullanıcının konumuna götürür.
  void _goToMyLocation(LatLng? userLocation) {
    if (userLocation != null) {
      _mapController.move(userLocation, 15.0);
    } else {
      final loc = context.read<LocationService?>()?.currentPosition;
      if (loc != null) {
        _mapController.move(loc, 15.0);
      }
    }
  }

  // Seçili noktaya yol tarifi için harita uygulamasını açar.
  Future<void> _handleDirections(AssemblyPoint point) async {
    final urlStr = AssemblyPointsController.buildNavigationUrl(point);
    final uri = Uri.parse(urlStr);
    await widget.urlLauncher(uri);
  }

  // Arayüzü çizer.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final ctrl = context.watch<AssemblyPointsController>();

    final userLoc = ctrl.userLocation;
    final initialCenter = userLoc ?? _defaultCenter;
    final filtered = ctrl.filteredPoints;
    final nearestTop3 = ctrl.nearestThreePoints;
    final selected = ctrl.selectedPoint;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Harita Katmanı (FlutterMap)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 13.5,
              onTap: (tapPosition, point) {
                if (selected != null) {
                  ctrl.selectPoint(null);
                }
              },
            ),
            children: [
              // Tile Katmanı (testlerde override edilebilir)
              widget.tileLayer ??
                  TileLayer(
                    urlTemplate: AppConfig.osmTileUrl,
                    userAgentPackageName: AppConfig.osmUserAgentPackageName,
                  ),
              // OSM kullanım koşulu: harita üzerinde atıf zorunlu. Rich sürümü
              // küçük bir düğme olarak durur; Simple dar ekranda taşıyordu.
              const RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [TextSourceAttribution(AppConfig.osmAttribution)],
              ),

              // Kullanıcı Konum Rozeti (Varsa)
              if (userLoc != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLoc,
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

              // Toplanma Alanları Pinleri
              MarkerLayer(
                markers: filtered.map((point) {
                  final isSelected = selected?.id == point.id;
                  final isNearest =
                      nearestTop3.isNotEmpty && nearestTop3.first.id == point.id;

                  return Marker(
                    point: point.location,
                    width: 80,
                    height: 75,
                    alignment: Alignment.topCenter,
                    child: AssemblyPointMarkerWidget(
                      point: point,
                      isSelected: isSelected,
                      isNearest: isNearest,
                      userLocation: userLoc,
                      onTap: () {
                        ctrl.selectPoint(point);
                        _mapController.move(point.location, 15.0);
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. Üst Overlay: Filtre Chip'leri
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      label: l10n?.assemblyFilterAll ?? 'Tümü',
                      isSelected: ctrl.filter == null,
                      onTap: () => ctrl.setFilter(null),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: l10n?.assemblyFilterAssembly ?? 'Toplanma',
                      icon: Icons.groups_rounded,
                      isSelected: ctrl.filter == AssemblyPointType.assembly,
                      onTap: () => ctrl.setFilter(AssemblyPointType.assembly),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: l10n?.assemblyFilterFieldHospital ?? 'Sahra Hastanesi',
                      icon: Icons.medical_services_rounded,
                      isSelected: ctrl.filter == AssemblyPointType.fieldHospital,
                      onTap: () => ctrl.setFilter(AssemblyPointType.fieldHospital),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      label: l10n?.assemblyFilterShelter ?? 'Barınma / Çadır',
                      icon: Icons.night_shelter_rounded,
                      isSelected: ctrl.filter == AssemblyPointType.shelter,
                      onTap: () => ctrl.setFilter(AssemblyPointType.shelter),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Sağ Taraf Harita Kontrolleri (Zoom In / Out / My Location)
          SafeArea(
            child: Align(
              // Üstte durur; ortada olunca seçili nokta kartının altında kalıyordu.
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 14, top: 72),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMapIconButton(
                      icon: Icons.add_rounded,
                      tooltip: l10n?.assemblyZoomInTooltip ?? 'Yakınlaştır',
                      onPressed: _zoomIn,
                    ),
                    const SizedBox(height: 8),
                    _buildMapIconButton(
                      icon: Icons.remove_rounded,
                      tooltip: l10n?.assemblyZoomOutTooltip ?? 'Uzaklaştır',
                      onPressed: _zoomOut,
                    ),
                    const SizedBox(height: 12),
                    _buildMapIconButton(
                      icon: Icons.my_location_rounded,
                      tooltip: l10n?.assemblyMyLocationTooltip ?? 'Konumuma Git',
                      isAccent: true,
                      onPressed: () => _goToMyLocation(userLoc),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Alt Panel: Seçili Kart VEYA En Yakın 3 Alan Önizleme Kartları
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: selected != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: AssemblyPointCard(
                        point: selected,
                        userLocation: userLoc,
                        isNearest: nearestTop3.isNotEmpty &&
                            nearestTop3.first.id == selected.id,
                        onClose: () => ctrl.selectPoint(null),
                        onGetDirections: _handleDirections,
                      ),
                    )
                  : nearestTop3.isNotEmpty
                      ? _NearestPointsPeekBar(
                          points: nearestTop3,
                          userLocation: userLoc,
                          onSelect: (pt) {
                            ctrl.selectPoint(pt);
                            _mapController.move(pt.location, 15.0);
                          },
                        )
                      : (!ctrl.isLoading && ctrl.points.isEmpty)
                          ? const _EmptyPointsBanner()
                          : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  // Tür filtresi chip'ini çizer.
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary
                : colors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colors.primary
                  : colors.outline.withValues(alpha: 0.35),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? colors.onPrimary : colors.primary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? colors.onPrimary : colors.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Harita üzerindeki yuvarlak buton (yakınlaştır, konum).
  Widget _buildMapIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isAccent = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: isAccent ? colors.primary : colors.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black38,
      child: IconButton(
        icon: Icon(
          icon,
          color: isAccent ? colors.onPrimary : colors.onSurface,
          size: 20,
        ),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      ),
    );
  }
}

/// Alt Kısımda En Yakın 3 Alanı Gösteren Yatay Önizleme Çubuğu
class _NearestPointsPeekBar extends StatelessWidget {
  const _NearestPointsPeekBar({
    required this.points,
    required this.onSelect,
    this.userLocation,
  });

  final List<AssemblyPoint> points;
  final LatLng? userLocation;
  final ValueChanged<AssemblyPoint> onSelect;

  // Arayüzü çizer.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.near_me_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                l10n?.assemblyNearestTop3 ?? 'En Yakın 3 Alan',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: points.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final pt = points[index];
                final dist = userLocation != null
                    ? pt.formatDistance(userLocation!)
                    : null;

                return InkWell(
                  onTap: () => onSelect(pt),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 170,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.outline.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pt.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (dist != null)
                              Text(
                                dist,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            Text(
                              l10n?.assemblyOccupancyShort(pt.occupancyPercentage) ??
                                  '%${pt.occupancyPercentage}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Firestore'da toplanma noktası yoksa gösterilir (uydurma nokta gösterilmez).
class _EmptyPointsBanner extends StatelessWidget {
  const _EmptyPointsBanner();

  // Arayüzü çizer.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n?.assemblyEmptyList ?? 'Toplanma alanı bulunamadı',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
