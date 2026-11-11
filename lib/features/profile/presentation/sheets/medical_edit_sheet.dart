import 'package:flutter/material.dart';

import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/user_contact_profile.dart';

Future<void> showMedicalEditSheet(
  BuildContext context, {
  required UserContactProfile? currentProfile,
  required Future<bool> Function({
    required String bloodType,
    required String medications,
    required String conditions,
    required DateTime consentAt,
  }) onSave,
}) {
  return AppBottomSheet.show<void>(
    context,
    title: AppLocalizations.of(context)?.profileMedicalCardTitle ??
        'Tıbbi & Sağlık Kimliği',
    child: _MedicalEditForm(
      currentProfile: currentProfile,
      onSave: onSave,
    ),
  );
}

class _MedicalEditForm extends StatefulWidget {
  const _MedicalEditForm({
    required this.currentProfile,
    required this.onSave,
  });

  final UserContactProfile? currentProfile;
  final Future<bool> Function({
    required String bloodType,
    required String medications,
    required String conditions,
    required DateTime consentAt,
  }) onSave;

  @override
  State<_MedicalEditForm> createState() => _MedicalEditFormState();
}

class _MedicalEditFormState extends State<_MedicalEditForm> {
  final _formKey = GlobalKey<FormState>();
  late String _bloodType;
  late final TextEditingController _medications;
  late final TextEditingController _conditions;
  late bool _consent;
  bool _showConsentError = false;
  bool _isSaving = false;

  static const _bloodTypes = [
    'A Rh+',
    'A Rh-',
    'B Rh+',
    'B Rh-',
    'AB Rh+',
    'AB Rh-',
    '0 Rh+',
    '0 Rh-',
  ];

  @override
  void initState() {
    super.initState();
    _bloodType = widget.currentProfile?.bloodType ?? '0 Rh+';
    if (!_bloodTypes.contains(_bloodType)) {
      _bloodType = _bloodTypes.first;
    }
    _medications = TextEditingController(
      text: widget.currentProfile?.medications ?? '',
    );
    _conditions = TextEditingController(
      text: widget.currentProfile?.conditions ?? '',
    );
    _consent = widget.currentProfile?.hasMedicalConsent ?? false;
  }

  @override
  void dispose() {
    _medications.dispose();
    _conditions.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_consent) {
      setState(() => _showConsentError = true);
      return;
    }
    setState(() => _isSaving = true);
    final ok = await widget.onSave(
      bloodType: _bloodType,
      medications: _medications.text,
      conditions: _conditions.text,
      consentAt: widget.currentProfile?.medicalConsentAt ?? DateTime.now(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (ok) Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (l10n?.profileUpdated ?? 'Profil başarıyla güncellendi.')
              : (l10n?.genericError ?? 'Bir hata oluştu, lütfen tekrar deneyin.'),
        ),
        backgroundColor: ok ? status.normal : status.critical,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _bloodType,
            decoration: InputDecoration(
              labelText: l10n?.profileBloodType ?? 'Kan Grubu',
              prefixIcon: const Icon(Icons.bloodtype_outlined, size: 20),
            ),
            items: _bloodTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _bloodType = val);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _medications,
            decoration: InputDecoration(
              labelText: l10n?.profileMedications ?? 'Kullandığı İlaçlar',
              hintText: l10n?.profileMedicationsHint ?? 'Örn. İnsülin, Tansiyon ilacı',
              prefixIcon: const Icon(Icons.medication_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _conditions,
            decoration: InputDecoration(
              labelText:
                  l10n?.profileConditions ?? 'Kronik Hastalık / Alerji',
              hintText: l10n?.profileConditionsHint ?? 'Örn. Astım, Penisilin alerjisi',
              prefixIcon: const Icon(Icons.healing_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          // KVKK Açık Rıza Onayı (§5 Kural 5, R5)
          CheckboxListTile(
            value: _consent,
            onChanged: (v) => setState(() {
              _consent = v ?? false;
              if (_consent) _showConsentError = false;
            }),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              l10n?.profileMedicalConsent ??
                  'Tıbbi verilerimin acil durumlarda arama kurtarma ekiplerince görüntülenmesine açık rıza veriyorum (KVKK m.6).',
              style: const TextStyle(fontSize: 12),
            ),
            subtitle: _showConsentError
                ? Text(
                    l10n?.profileMedicalConsentRequired ??
                        'Tıbbi bilgi kaydetmek için açık rıza gereklidir.',
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<AppStatusColors>()!
                          .critical,
                      fontSize: 11,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 20),
          AppButton.primary(
            label: l10n?.save ?? 'Kaydet',
            isLoading: _isSaving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
