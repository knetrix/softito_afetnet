import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/language_selector.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/profile_repository.dart';
import 'delete_account_flow.dart';
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChangeNotifierProvider<ProfileController>(
      create: (_) => ProfileController(
        repository: repository ?? context.read<ProfileRepository>(),
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
      message:
          l10n?.signOutConfirmMessage ??
          'Oturumunuzu kapatmak istediğinize emin misiniz?',
      confirmLabel: l10n?.signOut ?? 'Çıkış Yap',
      cancelLabel: l10n?.cancel ?? 'İptal',
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthController>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final controller = context.watch<ProfileController>();
    final profile = controller.profile;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final status = theme.extension<AppStatusColors>()!;
    final l10n = AppLocalizations.of(context);
    final notSpecified = l10n?.profileNotSpecified ?? 'Belirtilmedi';
    final contactPhone = profile?.emergencyContactPhone;
    final locationLabel = context.watch<LocationService?>()?.currentLabel;

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
                        color: colors.primary.withValues(alpha: 0.15),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(user?.fullName ?? 'Afetzede'),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
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
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusBadge.role(isOfficial: false),
                        if (locationLabel != null)
                          StatusBadge(
                            label: locationLabel,
                            color: colors.primary,
                            icon: Icons.location_on_outlined,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 1. Tıbbi & Sağlık Kimliği Kartı
              _ProfileSectionCard(
                title:
                    l10n?.profileMedicalCardTitle ?? 'Tıbbi & Sağlık Kimliği',
                icon: Icons.favorite_border_rounded,
                iconColor: status.critical,
                onEdit: () => showMedicalEditSheet(
                  context,
                  currentProfile: profile,
                  onSave: controller.updateMedicalInfo,
                ),
                content: Column(
                  children: [
                    _InfoRow(
                      label: l10n?.profileBloodType ?? 'Kan Grubu',
                      value: profile?.bloodType ?? notSpecified,
                      valueColor: status.critical,
                      isBold: true,
                    ),
                    const Divider(),
                    _InfoRow(
                      label: l10n?.profileMedications ?? 'Kullandığı İlaçlar',
                      value: (profile?.medications?.isEmpty ?? true)
                          ? notSpecified
                          : profile!.medications!,
                    ),
                    const Divider(),
                    _InfoRow(
                      label:
                          l10n?.profileConditions ?? 'Kronik Hastalık / Alerji',
                      value: (profile?.conditions?.isEmpty ?? true)
                          ? notSpecified
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
                iconColor: colors.primary,
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
                        value: profile?.age != null ? '${profile!.age}' : '-',
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
                title:
                    l10n?.profileEmergencyContact ??
                    '1. Derece Acil Durum Yakını',
                icon: Icons.contact_phone_outlined,
                iconColor: status.urgent,
                onEdit: () => showEmergencyContactSheet(
                  context,
                  currentProfile: profile,
                  onSave: controller.updateEmergencyContact,
                ),
                content: (contactPhone?.isNotEmpty ?? false)
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
                                      profile?.emergencyContactName ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      profile?.emergencyContactRelation ?? '',
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      Validators.formatPhone(contactPhone!),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filled(
                                onPressed: () => launchUrl(
                                  Uri(
                                    scheme: 'tel',
                                    path:
                                        Validators.normalizePhone(
                                          contactPhone,
                                        ) ??
                                        contactPhone,
                                  ),
                                ),
                                icon: const Icon(Icons.phone_in_talk_rounded),
                                style: IconButton.styleFrom(
                                  backgroundColor: status.normal,
                                  foregroundColor: colors.surface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Text(
                        l10n?.profileEmergencyContactEmpty ??
                            'Acil durum yakını henüz eklenmedi.',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
              ),
              const SizedBox(height: 16),

              // 4. Kayıtlı İkamet Adresi Kartı
              _ProfileSectionCard(
                title: l10n?.profileAddress ?? 'Kayıtlı İkamet Adresi',
                icon: Icons.home_work_outlined,
                iconColor: status.normal,
                onEdit: () => showAddressEditSheet(
                  context,
                  currentProfile: profile,
                  onSave: controller.updateAddress,
                ),
                content: Text(
                  (profile?.addressText?.isNotEmpty ?? false)
                      ? profile!.addressText!
                      : (l10n?.profileAddressEmpty ??
                            'Kayıtlı ikamet adresi bulunmuyor.'),
                  style: TextStyle(
                    color: (profile?.addressText?.isNotEmpty ?? false)
                        ? theme.colorScheme.onSurface
                        : colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const LanguageSelector(),
              const SizedBox(height: 24),

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
                        runDeleteAccountFlow(context, isOfficial: false),
                    child: Text(
                      l10n?.deleteAccount ?? 'Hesabı Sil',
                      style: TextStyle(fontSize: 12, color: status.critical),
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
    final colors = Theme.of(context).colorScheme;

    return Container(
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
                color: colors.primary,
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor,
              ),
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
