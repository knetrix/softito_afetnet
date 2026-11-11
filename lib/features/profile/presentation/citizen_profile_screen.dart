import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/firestore_profile_repository.dart';
import '../domain/profile_repository.dart';
import 'profile_controller.dart';
import 'sheets/address_edit_sheet.dart';
import 'sheets/emergency_contact_sheet.dart';
import 'sheets/medical_edit_sheet.dart';
import 'sheets/physical_edit_sheet.dart';

/// A4 — Profil (Afetzede) (§3.1, 19.52.36)
class CitizenProfileScreen extends StatelessWidget {
  const CitizenProfileScreen({super.key, this.repository});

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
      child: const _CitizenProfileView(),
    );
  }
}

class _CitizenProfileView extends StatelessWidget {
  const _CitizenProfileView();

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'A';
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
      confirmLabel: l10n?.signOut ?? 'Çıkış Yap',
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
          'Bu işlem geri alınamaz. Kişisel verileriniz ve sağlık bilgileriniz kalıcı olarak silinecektir.',
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
    final controller = context.watch<ProfileController>();
    final profile = controller.profile;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.profileCivilianTitle ?? 'Afetzede Profili'),
      ),
      body: StateView(
        status: controller.isLoading ? ViewStatus.loading : ViewStatus.ready,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst Profil Başlığı ve Avatar (T12: Ad baş harfli avatar)
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(user?.fullName ?? 'Afetzede'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
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
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        StatusBadge.role(isOfficial: false),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceHigh
                                : AppColors.lightSurfaceHigh,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.border
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 12, color: AppColors.textSecondary),
                              SizedBox(width: 4),
                              Text(
                                'Antakya, Hatay',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 1. Tıbbi & Sağlık Kimliği Kartı
              _ProfileSectionCard(
                title: l10n?.profileMedicalCardTitle ??
                    'Tıbbi & Sağlık Kimliği',
                icon: Icons.favorite_border_rounded,
                iconColor: AppColors.danger,
                onEdit: () => showMedicalEditSheet(
                  context,
                  currentProfile: profile,
                  onSave: controller.updateMedicalInfo,
                ),
                content: Column(
                  children: [
                    _InfoRow(
                      label: l10n?.profileBloodType ?? 'Kan Grubu',
                      value: profile?.bloodType ?? 'Belirtilmedi',
                      valueColor: AppColors.danger,
                      isBold: true,
                    ),
                    const Divider(),
                    _InfoRow(
                      label: l10n?.profileMedications ?? 'Kullandığı İlaçlar',
                      value: (profile?.medications?.isEmpty ?? true)
                          ? 'Belirtilmedi'
                          : profile!.medications!,
                    ),
                    const Divider(),
                    _InfoRow(
                      label: l10n?.profileConditions ??
                          'Kronik Hastalık / Alerji',
                      value: (profile?.conditions?.isEmpty ?? true)
                          ? 'Belirtilmedi'
                          : profile!.conditions!,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Fiziksel Bilgiler Kartı
              _ProfileSectionCard(
                title: l10n?.profilePhysicalInfo ?? 'Fiziksel Bilgiler',
                icon: Icons.accessibility_new_rounded,
                iconColor: AppColors.primary,
                onEdit: () => showPhysicalEditSheet(
                  context,
                  currentProfile: profile,
                  onSave: controller.updatePhysicalInfo,
                ),
                content: Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        title: l10n?.profileAge ?? 'Yaş',
                        value: profile?.age != null
                            ? '${profile!.age}'
                            : (profile?.birthYear != null
                                ? '${profile!.birthYear}'
                                : '-'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        title: l10n?.profileWeight ?? 'Kilo',
                        value: profile?.weightKg != null
                            ? '${profile!.weightKg} kg'
                            : '-',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. 1. Derece Acil Durum Yakını Kartı
              _ProfileSectionCard(
                title: l10n?.profileEmergencyContact ??
                    '1. Derece Acil Durum Yakını',
                icon: Icons.contact_phone_outlined,
                iconColor: AppColors.warning,
                onEdit: () => showEmergencyContactSheet(
                  context,
                  currentProfile: profile,
                  onSave: controller.updateEmergencyContact,
                ),
                content: (profile?.emergencyContactPhone?.isNotEmpty ?? false)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile?.emergencyContactName ??
                                          'Acil Yakını',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      profile?.emergencyContactRelation ?? '',
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      profile?.emergencyContactPhone ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filled(
                                onPressed: () {
                                  final tel = profile?.emergencyContactPhone;
                                  if (tel != null) {
                                    launchUrl(Uri(scheme: 'tel', path: tel));
                                  }
                                },
                                icon: const Icon(Icons.phone_in_talk_rounded),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const Text(
                        'Acil durum yakını henüz eklenmedi.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
              ),
              const SizedBox(height: 16),

              // 4. Kayıtlı İkamet Adresi Kartı
              _ProfileSectionCard(
                title: l10n?.profileAddress ?? 'Kayıtlı İkamet Adresi',
                icon: Icons.home_work_outlined,
                iconColor: AppColors.success,
                onEdit: () => showAddressEditSheet(
                  context,
                  currentProfile: profile,
                  onSave: controller.updateAddress,
                ),
                content: Text(
                  (profile?.addressText?.isNotEmpty ?? false)
                      ? profile!.addressText!
                      : 'Kayıtlı ikamet adresi bulunmuyor.',
                  style: TextStyle(
                    color: (profile?.addressText?.isNotEmpty ?? false)
                        ? theme.colorScheme.onSurface
                        : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Çıkış Yap Butonu
              AppButton.secondary(
                label: l10n?.signOut ?? 'Çıkış Yap',
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
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
    required this.onEdit,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget content;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceHigh : AppColors.lightSurfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
