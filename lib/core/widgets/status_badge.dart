import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_status_colors.dart';

/// AfetNet Durum ve Öncelik Rozeti (§3.4, §4 Kural 1, Y1, Y2, Y3)
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  /// Öncelik rozeti (1: Kritik, 2: Acil, 3: Normal)
  factory StatusBadge.priority(int priority, {BuildContext? context}) {
    String label;
    Color color;

    switch (priority) {
      case 1:
        label = 'KRİTİK';
        color = AppColors.danger;
        break;
      case 2:
        label = 'ACİL';
        color = AppColors.warning;
        break;
      case 3:
      default:
        label = 'NORMAL';
        color = AppColors.success;
        break;
    }

    if (context != null) {
      final statusColors = Theme.of(context).extension<AppStatusColors>();
      if (statusColors != null) {
        color = statusColors.forPriority(priority);
      }
    }

    return StatusBadge(
      label: label,
      color: color,
    );
  }

  /// Rol rozeti (SİVİL KULLANICI / SAHA KOORDİNATÖRÜ)
  factory StatusBadge.role({required bool isOfficial}) {
    return StatusBadge(
      label: isOfficial ? 'SAHA KOORDİNATÖRÜ' : 'SİVİL KULLANICI',
      color: isOfficial ? AppColors.warning : AppColors.primary,
      icon: isOfficial ? Icons.verified_user_rounded : Icons.person_rounded,
    );
  }

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

