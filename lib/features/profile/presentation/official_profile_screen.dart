// Y4 Yetkili Profil ekranı: ad, "Saha Koordinatörü" rozeti, birim, bölge, bağlı ekip, dil seçimi,
// Çıkış Yap ve (yalnızca debug derlemede) "Demo Verisini Sıfırla".

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/language_selector.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../demo_seed/data/demo_seed_service.dart';
import '../domain/profile_repository.dart';
import 'delete_account_flow.dart';
import 'profile_controller.dart';

/// Y4 — Profil (Yetkili / Saha Koordinatörü) (§3.1, 20.28.08, T2, T11, T12, T13)
class OfficialProfileScreen extends StatelessWidget {
  const OfficialProfileScreen({super.key, this.repository});

  final ProfileRepository? repository;

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
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

// Yetkili profilinin asıl gövdesi.
class _OfficialProfileView extends StatelessWidget {
  const _OfficialProfileView();

  // Addan baş harfleri çıkarır (avatar için).
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'Y';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // Onay sorup oturumu kapatır.
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

  /// §8: Demo verisini (ekip, depo, stok, toplanma noktası) başlangıç
  /// hâline getirir. Yalnızca debug derlemede görünür.
  Future<void> _resetDemoData(BuildContext context) async {
    if (!kDebugMode) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.demoResetTitle,
      message: l10n.demoResetConfirmMessage,
      confirmLabel: l10n.demoReset,
      cancelLabel: l10n.cancel,
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final r = await DemoSeedService().reset();
      if (!context.mounted) return;
      await AppDialog.info(
        context,
        title: l10n.demoResetTitle,
        message: l10n.demoResetDone(r.teams, r.warehouses, r.items, r.points),
      );
    } catch (error) {
      debugPrint('Demo verisi sıfırlanamadı: $error');
      if (!context.mounted) return;
      await AppDialog.info(
        context,
        title: l10n.demoResetTitle,
        message: l10n.demoResetFailed,
      );
    }
  }

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
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

            const LanguageSelector(),
            const SizedBox(height: 24),

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
                    Uri.parse(
                      AppConfig.legalUrl(
                        AppConfig.privacyPage,
                        Localizations.localeOf(context),
                      ),
                    ),
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

// Birim / bölge / ekip bilgi satırı.
class _OfficialInfoTile extends StatelessWidget {
  const _OfficialInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
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
