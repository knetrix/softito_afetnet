// Canlı Akış haritası: olay pinleri ve mor panik pinleri.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_status_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../safety_signal/domain/safety_signal.dart';
import '../../domain/incident.dart';
import '../feed_labels.dart';

/// Y1 haritası: öncelik renkli olay pinleri ve mor panik pinleri (§3.1 Y1).
class LiveFeedMap extends StatefulWidget {
  const LiveFeedMap({
    super.key,
    required this.incidents,
    required this.signals,
    required this.onIncidentTap,
    required this.onSignalTap,
    this.userLocation,
    this.tileLayer,
  });

  final List<Incident> incidents;
  final List<SafetySignal> signals;
  final LatLng? userLocation;
  final ValueChanged<Incident> onIncidentTap;
  final ValueChanged<SafetySignal> onSignalTap;

  /// Testlerde ağ isteği yapılmaması için değiştirilebilir.
  final Widget? tileLayer;

  /// Konum ve olay yokken açılış merkezi (Hatay; yalnızca harita kamerası).
  static const defaultCenter = LatLng(36.2025, 36.1610);

  // Widget'ın durum (State) nesnesini oluşturur.
  @override
  State<LiveFeedMap> createState() => _LiveFeedMapState();
}

// Harita denetleyicisini ve yakınlaştırmayı yönetir.
class _LiveFeedMapState extends State<LiveFeedMap> {
  final MapController _map = MapController();
  bool _centeredOnData = false;

  // Widget parametreleri değiştiğinde çalışır.
  @override
  void didUpdateWidget(covariant LiveFeedMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Harita ilk açıldığında veri henüz gelmemiş olabilir; ilk veriyle bir kez
    // merkezlenir, sonra yetkilinin kaydırdığı görünüm korunur.
    if (!_centeredOnData) {
      final target = _firstTarget();
      if (target != null) {
        _centeredOnData = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _map.move(target, _map.camera.zoom);
        });
      }
    }
  }

  // Haritanın ilk ortalanacağı nokta.
  LatLng? _firstTarget() =>
      widget.userLocation ??
      (widget.incidents.isNotEmpty ? widget.incidents.first.location : null) ??
      (widget.signals.isNotEmpty ? widget.signals.first.location : null);

  // Haritayı yakınlaştırır / uzaklaştırır.
  void _zoom(double delta) {
    final c = _map.camera;
    _map.move(c.center, c.zoom + delta);
  }

  // Arayüzü çizer.
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final user = widget.userLocation;

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: _firstTarget() ?? LiveFeedMap.defaultCenter,
            initialZoom: 13,
          ),
          children: [
            widget.tileLayer ??
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
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
                for (final i in widget.incidents.reversed)
                  Marker(
                    point: i.location,
                    width: 40,
                    height: 40,
                    child: _Pin(
                      color: status.forPriority(i.priority),
                      icon: FeedLabels.helpTypeIcon(i.type),
                      tooltip: FeedLabels.helpType(l10n, i.type),
                      onTap: () => widget.onIncidentTap(i),
                    ),
                  ),
                for (final s in widget.signals)
                  Marker(
                    point: s.location,
                    width: 40,
                    height: 40,
                    child: _Pin(
                      color: status.panic,
                      icon: s.isHandled
                          ? Icons.check_rounded
                          : Icons.sos_rounded,
                      tooltip: l10n.panicPinTitle,
                      dimmed: s.isHandled,
                      onTap: () => widget.onSignalTap(s),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Column(
            children: [
              _MapButton(
                icon: Icons.add_rounded,
                tooltip: l10n.assemblyZoomInTooltip,
                onPressed: () => _zoom(1),
              ),
              const SizedBox(height: 6),
              _MapButton(
                icon: Icons.remove_rounded,
                tooltip: l10n.assemblyZoomOutTooltip,
                onPressed: () => _zoom(-1),
              ),
              if (user != null) ...[
                const SizedBox(height: 6),
                _MapButton(
                  icon: Icons.my_location_rounded,
                  tooltip: l10n.assemblyMyLocationTooltip,
                  accent: true,
                  onPressed: () => _map.move(user, 15),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// Haritadaki olay veya panik pini.
class _Pin extends StatelessWidget {
  const _Pin({
    required this.color,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.dimmed = false,
  });

  final Color color;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool dimmed;

  // Arayüzü çizer.
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: dimmed ? 0.55 : 1,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.55),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Harita üzerindeki yuvarlak buton.
class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.accent = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool accent;

  // Arayüzü çizer.
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: accent ? colors.primary : colors.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 3,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: tooltip,
        icon: Icon(
          icon,
          size: 18,
          color: accent ? colors.onPrimary : colors.onSurface,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
