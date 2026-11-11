import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/user_contact_profile.dart';

Future<void> showAddressEditSheet(
  BuildContext context, {
  required UserContactProfile? currentProfile,
  required Future<bool> Function({required String addressText}) onSave,
}) {
  return AppBottomSheet.show<void>(
    context,
    title: AppLocalizations.of(context)?.profileAddress ?? 'Kayıtlı İkamet Adresi',
    child: _AddressEditForm(
      currentProfile: currentProfile,
      onSave: onSave,
    ),
  );
}

class _AddressEditForm extends StatefulWidget {
  const _AddressEditForm({
    required this.currentProfile,
    required this.onSave,
  });

  final UserContactProfile? currentProfile;
  final Future<bool> Function({required String addressText}) onSave;

  @override
  State<_AddressEditForm> createState() => _AddressEditFormState();
}

class _AddressEditFormState extends State<_AddressEditForm> {
  late final TextEditingController _address;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _address = TextEditingController(
      text: widget.currentProfile?.addressText ?? '',
    );
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    final ok = await widget.onSave(addressText: _address.text);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.profileUpdated ??
                'Profil başarıyla güncellendi.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _address,
          maxLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            labelText: l10n?.profileAddress ?? 'Adres Tarifi',
            hintText: 'İl, ilçe, mahalle, sokak, bina ve kat bilgisi...',
            prefixIcon: const Icon(Icons.home_work_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        AppButton.primary(
          label: l10n?.save ?? 'Kaydet',
          isLoading: _isSaving,
          onPressed: _submit,
        ),
      ],
    );
  }
}
