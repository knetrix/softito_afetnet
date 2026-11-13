// Küçük renkli etiket (rozet): Kritik / Acil / Normal gibi öncelikler
// ve "Sivil Kullanıcı", "Saha Koordinatörü" gibi rol etiketleri için.

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_status_colors.dart';

// Rozet türleri: özel metin, öncelik, afetzede rolü, yetkili rolü.
enum _BadgeKind { custom, priority, citizen, official }

/// AfetNet Durum ve Öncelik Rozeti (§3.4, §4 Kural 1, Y1, Y2, Y3)
///
/// Öncelik ve rol rozetlerinin metni ARB'den, rengi temadan (`AppStatusColors`)
/// `build` sırasında okunur; böylece dil ve tema değişince rozet de güncellenir.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required String this.label,
    required Color this.color,
    this.icon,
  })  : _kind = _BadgeKind.custom,
        _priority = 0;

  const StatusBadge._(this._kind, this.icon, this._priority)
      : label = null,
        color = null;

  /// Öncelik rozeti (1: Kritik, 2: Acil, 3: Normal)
  const StatusBadge.priority(int priority)
      : this._(_BadgeKind.priority, null, priority);

  /// Rol rozeti (SİVİL KULLANICI / SAHA KOORDİNATÖRÜ)
  factory StatusBadge.role({required bool isOfficial}) => isOfficial
      ? const StatusBadge._(_BadgeKind.official, Icons.verified_user_rounded, 0)
      : const StatusBadge._(_BadgeKind.citizen, Icons.person_rounded, 0);

  final String? label;
  final Color? color;
  final IconData? icon;
  final _BadgeKind _kind;
  final int _priority;

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = theme.extension<AppStatusColors>()!;
    final l10n = AppLocalizations.of(context);

    final (String text, Color tint) = switch (_kind) {
      _BadgeKind.custom => (label!, color!),
      _BadgeKind.priority => (
          switch (_priority) {
            1 => l10n?.priorityCritical ?? 'KRİTİK',
            2 => l10n?.priorityUrgent ?? 'ACİL',
            _ => l10n?.priorityNormal ?? 'NORMAL',
          },
          status.forPriority(_priority),
        ),
      _BadgeKind.citizen => (
          l10n?.roleBadgeCitizen ?? 'SİVİL KULLANICI',
          theme.colorScheme.primary,
        ),
      _BadgeKind.official => (
          l10n?.roleBadgeOfficial ?? 'SAHA KOORDİNATÖRÜ',
          status.urgent,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tint.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: tint),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tint,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tint,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
