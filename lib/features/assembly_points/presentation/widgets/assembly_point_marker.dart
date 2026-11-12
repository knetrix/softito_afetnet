import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/theme/app_status_colors.dart';
import '../../domain/assembly_point.dart';
import '../../domain/assembly_point_type.dart';

/// Toplanma Alanı Harita Pini (PROJECT_NEW.md §3.1 A2).
class AssemblyPointMarkerWidget extends StatelessWidget {
  const AssemblyPointMarkerWidget({
    super.key,
    required this.point,
    required this.isSelected,
    required this.onTap,
    this.userLocation,
    this.isNearest = false,
  });

  final AssemblyPoint point;
  final bool isSelected;
  final VoidCallback onTap;
  final LatLng? userLocation;
  final bool isNearest;

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

  Color _pinColor(ThemeData theme) {
    final status = theme.extension<AppStatusColors>()!;
    switch (point.type) {
      case AssemblyPointType.assembly:
        return theme.colorScheme.primary;
      case AssemblyPointType.fieldHospital:
        return status.critical;
      case AssemblyPointType.shelter:
        return status.urgent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pinColor = _pinColor(theme);
    final distanceText =
        userLocation != null ? point.formatDistance(userLocation!) : null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mesafe veya "En Yakın" etiketi
            if (distanceText != null || isNearest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: isNearest
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isNearest
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  distanceText ?? '',
                  maxLines: 1,
                  style: TextStyle(
                    color: isNearest
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Pin gövdesi
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 42 : 34,
              height: isSelected ? 42 : 34,
              decoration: BoxDecoration(
                color: pinColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.8),
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: pinColor.withValues(alpha: isSelected ? 0.6 : 0.35),
                    blurRadius: isSelected ? 10 : 5,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(
                _iconForType(point.type),
                size: isSelected ? 22 : 18,
                color: Colors.white,
              ),
            ),

            // Pin alt üçgen ucu
            CustomPaint(
              size: Size(isSelected ? 10 : 8, isSelected ? 6 : 5),
              painter: _TrianglePainter(color: pinColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => oldDelegate.color != color;
}
