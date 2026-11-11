import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/firestore_profile_repository.dart';
import '../domain/profile_repository.dart';
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider<ProfileController>(
      create: (_) => ProfileController(
        repository: repository ?? FirestoreProfileRepository(),
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
      message: l10n?.signOutConfirmMessage ??
          'Oturumunuzu kapatmak istediğinize emin misiniz?',
      confirmLabel: l10n?.officialSignOut ?? 'Sistemden Çıkış Yap',
      cancelLabel: l10n?.cancel ?? 'İptal',
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthController>().signOut();
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n?.deleteAccountConfirmTitle ??
          'Hesabınızı Silmek İstiyor Musunuz?',
      message: l10n?.deleteAccountConfirmMessage ??
          'Bu işlem geri alınamaz. Koordinatör hesabı kalıcı olarak silinecektir.',
      confirmLabel: l10n?.deleteAccount ?? 'Hesabı Sil',
      cancelLabel: l10n?.cancel ?? 'İptal',
      destructive: true,
    );
    if (confirmed == true && context.mounted) {
      final ok = await context.read<ProfileController>().deleteAccount();
      if (ok && context.mounted) {
        context.read<AuthController>().signOut();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

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
                      color: AppColors.warning.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(user?.fullName ?? 'Yetkili'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
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
                color: isDark ? AppColors.surface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 20, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
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
                    value: user?.unitName ?? 'Merkez Koordinasyon',
                    icon: Icons.business_outlined,
                  ),
                  const Divider(),
                  _OfficialInfoTile(
                    label: l10n?.profileRegion ?? 'Sorumlu Bölge',
                    value: user?.region ?? 'Hatay / Antakya',
                    icon: Icons.map_outlined,
                  ),
                  const Divider(),
                  _OfficialInfoTile(
                    label: l10n?.profileTeam ?? 'Bağlı Ekip',
                    value: user?.teamId ?? 'Arama Kurtarma Tim 4',
                    icon: Icons.groups_outlined,
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
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.developer_mode,
                            size: 16, color: AppColors.warning),
                        SizedBox(width: 6),
                        Text(
                          'Demo & Test Araçları (Debug)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppButton.secondary(
                      label: 'Demo Verisini Sıfırla',
                      icon: Icons.restart_alt_rounded,
                      isFullWidth: true,
                      onPressed: () {
                        AppDialog.info(
                          context,
                          title: 'Demo Verisi',
                          message:
                              'Demo tohumlama servisi G6 aşamasında tam veri tablosu ile bağlanacaktır.',
                        );
                      },
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Text('·',
                    style: TextStyle(color: AppColors.textSecondary)),
                TextButton(
                  onPressed: () => _deleteAccount(context),
                  child: Text(
                    l10n?.deleteAccount ?? 'Hesabı Sil',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.danger,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
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
