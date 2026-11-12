import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/profile_repository.dart';
import 'delete_account_flow.dart';
import 'profile_controller.dart';

/// Y4 — Profil (Yetkili / Saha Koordinatörü) (§3.1, 20.28.08, T2, T11, T12, T13)
class OfficialProfileScreen extends StatelessWidget {
  const OfficialProfileScreen({super.key, this.repository});

  final ProfileRepository? repository;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChangeNotifierProvider<ProfileController>(
      create: (_) => ProfileController(
        repository: repository ?? context.read<ProfileRepository>(),
        uid: user.uid,
      ),
      child: const _OfficialProfileView(),
    );
  }
}

class _OfficialProfileView extends StatelessWidget {
  const _OfficialProfileView();

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'Y';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _signOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n?.signOutConfirmTitle ?? 'Çıkış Yap',
      message:
          l10n?.signOutConfirmMessage ??
          'Oturumunuzu kapatmak istediğinize emin misiniz?',
      confirmLabel: l10n?.officialSignOut ?? 'Sistemden Çıkış Yap',
      cancelLabel: l10n?.cancel ?? 'İptal',
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthController>().signOut();
    }
  }

  Future<void> _resetDemoData(BuildContext context) async {
    if (!kDebugMode) return;

    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n?.demoResetTitle ?? 'Demo Verilerini Sıfırla',
      message:
          'Demo stokları, ekipleri ve toplanma alanları '
          'başlangıç durumuna getirilecek.\n\n'
          'Gerçek kayıtlar ve stok hareket geçmişi korunacak.\n\n'
          'Devam etmek istiyor musunuz?',
      confirmLabel: l10n?.demoReset ?? 'Demo Verisini Sıfırla',
      cancelLabel: l10n?.cancel ?? 'İptal',
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final db = FirebaseFirestore.instance;
      const warehouseIds = ['demo_merkez_depo', 'demo_bolge_depo'];
      const initialStock = <String, int>{
        'water': 150,
        'blanket': 8,
        'food': 60,
        'medical': 25,
      };

      var restored = 0;
      for (final warehouseId in warehouseIds) {
        final warehouseRef = db.collection('warehouses').doc(warehouseId);
        restored += await db.runTransaction<int>((transaction) async {
          // Yetki ve isDemo kontrolleri ayrıca firestore.rules'ta yapılmalı.
          final warehouse = await transaction.get(warehouseRef);
          if (!warehouse.exists || warehouse.data()?['isDemo'] != true) {
            return 0;
          }

          final itemRefs = initialStock.keys
              .map((id) => warehouseRef.collection('inventory').doc(id))
              .toList();
          final itemSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
          for (final ref in itemRefs) {
            itemSnapshots.add(await transaction.get(ref));
          }

          var count = 0;
          for (var i = 0; i < itemRefs.length; i++) {
            final item = itemSnapshots[i];
            if (!item.exists || item.data()?['isDemo'] != true) continue;
            transaction.update(itemRefs[i], {
              'quantity': initialStock[itemRefs[i].id],
              'updatedAt': FieldValue.serverTimestamp(),
            });
            count++;
          }
          return count;
        });
      }
      final (teams, points) = await _resetDemoTeamsAndPoints(db);

      if (!context.mounted) return;
      await AppDialog.info(
        context,
        title: l10n?.demoResetTitle ?? 'Demo Verisi',
        message:
            'Demo verileri başlangıç durumuna getirildi.\n\n'
            'Stok: $restored kayıt\n'
            'Ekipler: $teams kayıt\n'
            'Toplanma alanları: $points kayıt',
      );
    } catch (error) {
      if (!context.mounted) return;
      await AppDialog.info(
        context,
        title: 'İşlem Başarısız',
        message: 'Demo stokları sıfırlanamadı: $error',
      );
    }
  }

  Future<int> _resetDemoCollection(
    FirebaseFirestore db,
    String collection,
    Map<String, Map<String, dynamic>> records,
  ) async {
    var restored = 0;

    for (final entry in records.entries) {
      final reference = db.collection(collection).doc(entry.key);

      final updated = await db.runTransaction<bool>((transaction) async {
        final snapshot = await transaction.get(reference);

        // Gerçek bir kayıt varsa asla değiştirme.
        if (snapshot.exists && snapshot.data()?['isDemo'] != true) {
          return false;
        }

        transaction.set(reference, {
          ...entry.value,
          'isDemo': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return true;
      });

      if (updated) {
        restored++;
      }
    }

    return restored;
  }

  Future<(int teams, int points)> _resetDemoTeamsAndPoints(
    FirebaseFirestore db,
  ) async {
    // Tamamı örnek veridir; gerçek tesis/ekip bilgisi değildir.
    final demoTeams = <String, Map<String, dynamic>>{
      'team_01': {
        'name': 'DEMO - Arama Kurtarma Ekibi',
        'type': 'searchRescue',
        'leaderName': 'Demo Ekip Lideri 1',
        'memberCount': 6,
        'location': const GeoPoint(36.2021, 36.1606),
        'geohash': 'sy3tyy7k',
        'locationText': 'Antakya - Demo Bölgesi',
        'status': 'available',
        'currentTask': null,
      },
      'team_02': {
        'name': 'DEMO - Sağlık Ekibi',
        'type': 'medical',
        'leaderName': 'Demo Ekip Lideri 2',
        'memberCount': 4,
        'location': const GeoPoint(36.2090, 36.1700),
        'geohash': 'sy3tzpdh',
        'locationText': 'Antakya - Demo Bölgesi',
        'status': 'available',
        'currentTask': null,
      },
      'team_03': {
        'name': 'DEMO - İtfaiye Ekibi',
        'type': 'fire',
        'leaderName': 'Demo Ekip Lideri 3',
        'memberCount': 5,
        'location': const GeoPoint(36.2060, 36.1650),
        'geohash': 'sy3tyzne',
        'locationText': 'Antakya - Demo Bölgesi',
        'status': 'available',
        'currentTask': null,
      },
      'team_04': {
        'name': 'DEMO - Lojistik Ekibi',
        'type': 'logistics',
        'leaderName': 'Demo Ekip Lideri 4',
        'memberCount': 4,
        'location': const GeoPoint(36.1950, 36.1550),
        'geohash': 'sy3tytp7',
        'locationText': 'Antakya - Demo Bölgesi',
        'status': 'available',
        'currentTask': null,
      },
    };

    final demoPoints = <String, Map<String, dynamic>>{
      'demo_toplanma_01': {
        'name': 'DEMO - Merkez Toplanma Alanı',
        'type': 'assembly',
        'description': 'AfetNet senaryosu için örnek toplanma alanı.',
        'location': const GeoPoint(36.2030, 36.1630),
        'geohash': 'sy3tyyt1',
        'capacity': 500,
        'currentCount': 120,
        'services': ['water', 'food'],
        'isOpen': true,
      },
      'demo_sahra_hastanesi': {
        'name': 'DEMO - Sahra Hastanesi',
        'type': 'fieldHospital',
        'description': 'AfetNet senaryosu için örnek sağlık noktası.',
        'location': const GeoPoint(36.1980, 36.1580),
        'geohash': 'sy3tyv9k',
        'capacity': 150,
        'currentCount': 35,
        'services': ['health', 'water'],
        'isOpen': true,
      },
      'demo_barinma_01': {
        'name': 'DEMO - Geçici Barınma Alanı',
        'type': 'shelter',
        'description': 'AfetNet senaryosu için örnek barınma noktası.',
        'location': const GeoPoint(36.2100, 36.1750),
        'geohash': 'sy3tzpvf',
        'capacity': 300,
        'currentCount': 80,
        'services': ['tent', 'food', 'water'],
        'isOpen': true,
      },
    };

    final teams = await _resetDemoCollection(db, 'teams', demoTeams);

    final points = await _resetDemoCollection(
      db,
      'assembly_points',
      demoPoints,
    );

    return (teams, points);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = theme.extension<AppStatusColors>()!.urgent;
    final l10n = AppLocalizations.of(context);
    final notAssigned = l10n?.profileNotAssigned ?? 'Atanmadı';
    final teamId = user?.teamId;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.profileOfficialTitle ?? 'Saha Koordinatörü Profili'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar ve Başlık (T12: Ad baş harfli avatar)
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.15),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(user?.fullName ?? 'Yetkili'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? '',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatusBadge.role(isOfficial: true),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Birim ve Görev Bilgileri Kartı (T11: Sicil no / mesai / vardiya yok)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 20, color: accent),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.profileCoordinationInfo ??
                            'Koordinasyon Bilgileri',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _OfficialInfoTile(
                    label: l10n?.profileUnit ?? 'Birim Adı',
                    value: user?.unitName ?? notAssigned,
                    icon: Icons.business_outlined,
                  ),
                  const Divider(),
                  _OfficialInfoTile(
                    label: l10n?.profileRegion ?? 'Sorumlu Bölge',
                    value: user?.region ?? notAssigned,
                    icon: Icons.map_outlined,
                  ),
                  const Divider(),
                  // Ekip adı teams/{teamId}'den okunur; kayıt yoksa id gösterilir.
                  FutureBuilder<String?>(
                    future: teamId == null
                        ? null
                        : context.read<ProfileController>().teamName(teamId),
                    builder: (context, snap) => _OfficialInfoTile(
                      label: l10n?.profileTeam ?? 'Bağlı Ekip',
                      value: teamId == null
                          ? notAssigned
                          : (snap.data ?? teamId),
                      icon: Icons.groups_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Debug Modu "Demo Verisini Sıfırla" butonu (§8, §3.3)
            if (kDebugMode) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.developer_mode, size: 16, color: accent),
                        const SizedBox(width: 6),
                        Text(
                          l10n?.debugToolsTitle ??
                              'Demo & Test Araçları (Debug)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppButton.secondary(
                      label: l10n?.demoReset ?? 'Demo Verisini Sıfırla',
                      icon: Icons.restart_alt_rounded,
                      isFullWidth: true,
                      onPressed: () => _resetDemoData(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Sistemden Çıkış Yap Butonu
            AppButton.danger(
              label: l10n?.officialSignOut ?? 'Sistemden Çıkış Yap',
              icon: Icons.logout_rounded,
              isFullWidth: true,
              onPressed: () => _signOut(context),
            ),
            const SizedBox(height: 16),

            // T13: Yasal bağlantılar ve Hesabı Sil
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse(AppConfig.privacyPolicyUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(
                    l10n?.privacyPolicy ?? 'Gizlilik Politikası',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Text('·', style: TextStyle(color: colors.onSurfaceVariant)),
                TextButton(
                  onPressed: () =>
                      runDeleteAccountFlow(context, isOfficial: true),
                  child: Text(
                    l10n?.deleteAccount ?? 'Hesabı Sil',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.extension<AppStatusColors>()!.critical,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OfficialInfoTile extends StatelessWidget {
  const _OfficialInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: muted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
