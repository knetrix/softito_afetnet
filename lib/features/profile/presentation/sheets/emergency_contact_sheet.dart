import 'package:flutter/material.dart';

import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/user_contact_profile.dart';

Future<void> showEmergencyContactSheet(
  BuildContext context, {
  required UserContactProfile? currentProfile,
  required Future<bool> Function({
    required String name,
    required String relation,
    required String phone,
  }) onSave,
}) {
  return AppBottomSheet.show<void>(
    context,
    title: AppLocalizations.of(context)?.profileEmergencyContact ??
        '1. Derece Acil Durum Yakını',
    child: _EmergencyContactForm(
      currentProfile: currentProfile,
      onSave: onSave,
    ),
  );
}

class _EmergencyContactForm extends StatefulWidget {
  const _EmergencyContactForm({
    required this.currentProfile,
    required this.onSave,
  });

  final UserContactProfile? currentProfile;
  final Future<bool> Function({
    required String name,
    required String relation,
    required String phone,
  }) onSave;

  @override
  State<_EmergencyContactForm> createState() => _EmergencyContactFormState();
}

class _EmergencyContactFormState extends State<_EmergencyContactForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _relation;
  late final TextEditingController _phone;
  late final _phoneFormatter = Validators.phoneFormatter(initialText: _phone.text);
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: widget.currentProfile?.emergencyContactName ?? '',
    );
    _relation = TextEditingController(
      text: widget.currentProfile?.emergencyContactRelation ?? '',
    );
    final savedPhone = widget.currentProfile?.emergencyContactPhone;
    _phone = TextEditingController(
      text: savedPhone == null ? '' : Validators.formatPhone(savedPhone),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _relation.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final ok = await widget.onSave(
      name: _name.text,
      relation: _relation.text,
      phone: _phone.text,
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
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n?.profileContactName ?? 'Yakının Adı Soyadı',
              prefixIcon: const Icon(Icons.person_outline, size: 20),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? (l10n?.validationRequired ?? 'Bu alan zorunludur')
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _relation,
            decoration: InputDecoration(
              labelText: l10n?.profileRelation ?? 'Yakınlık Derecesi',
              hintText: l10n?.profileRelationHint ?? 'Örn. Anne, Eş, Kardeş',
              prefixIcon: const Icon(Icons.favorite_outline, size: 20),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? (l10n?.validationRequired ?? 'Bu alan zorunludur')
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneFormatter],
            decoration: InputDecoration(
              labelText: l10n?.registerPhone ?? 'Telefon Numarası',
              hintText: '+90 5XX XXX XX XX',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
            ),
            validator: (v) => Validators.phone(v) != null
                ? (l10n?.validationInvalidPhone ??
                    'Telefonu +90 5XX XXX XX XX biçiminde girin')
                : null,
          ),
          const SizedBox(height: 24),
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
