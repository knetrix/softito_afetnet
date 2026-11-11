import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/user_contact_profile.dart';

Future<void> showPhysicalEditSheet(
  BuildContext context, {
  required UserContactProfile? currentProfile,
  required Future<bool> Function({
    required int? birthYear,
    required int? weightKg,
  }) onSave,
}) {
  return AppBottomSheet.show<void>(
    context,
    title: AppLocalizations.of(context)?.profilePhysicalInfo ?? 'Fiziksel Bilgiler',
    child: _PhysicalEditForm(
      currentProfile: currentProfile,
      onSave: onSave,
    ),
  );
}

class _PhysicalEditForm extends StatefulWidget {
  const _PhysicalEditForm({
    required this.currentProfile,
    required this.onSave,
  });

  final UserContactProfile? currentProfile;
  final Future<bool> Function({
    required int? birthYear,
    required int? weightKg,
  }) onSave;

  @override
  State<_PhysicalEditForm> createState() => _PhysicalEditFormState();
}

class _PhysicalEditFormState extends State<_PhysicalEditForm> {
  late final TextEditingController _birthYear;
  late final TextEditingController _weight;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _birthYear = TextEditingController(
      text: widget.currentProfile?.birthYear?.toString() ?? '',
    );
    _weight = TextEditingController(
      text: widget.currentProfile?.weightKg?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _birthYear.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    final ok = await widget.onSave(
      birthYear: int.tryParse(_birthYear.text),
      weightKg: int.tryParse(_weight.text),
    );
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
          controller: _birthYear,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Doğum Yılı',
            hintText: 'Örn. 1995',
            prefixIcon: Icon(Icons.cake_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _weight,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n?.profileWeight ?? 'Kilo (kg)',
            hintText: 'Örn. 72',
            prefixIcon: const Icon(Icons.monitor_weight_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 24),
        AppButton.primary(
          label: l10n?.save ?? 'Kaydet',
          isLoading: _isSaving,
          onPressed: _submit,
        ),
      ],
    );
  }
}
