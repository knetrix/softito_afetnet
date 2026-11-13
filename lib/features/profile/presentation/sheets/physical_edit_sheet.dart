// Yaş ve kilo düzenleme formu.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/user_contact_profile.dart';

// Yaş/kilo formunu alttan açar.
Future<void> showPhysicalEditSheet(
  BuildContext context, {
  required UserContactProfile? currentProfile,
  required Future<bool> Function({
    required int? birthYear,
    required int? weightKg,
  })
  onSave,
}) {
  return AppBottomSheet.show<void>(
    context,
    title:
        AppLocalizations.of(context)?.profilePhysicalInfo ??
        'Fiziksel Bilgiler',
    child: _PhysicalEditForm(currentProfile: currentProfile, onSave: onSave),
  );
}

// Yaş/kilo formu widget'ı.
class _PhysicalEditForm extends StatefulWidget {
  const _PhysicalEditForm({required this.currentProfile, required this.onSave});

  final UserContactProfile? currentProfile;
  final Future<bool> Function({required int? birthYear, required int? weightKg})
  onSave;

  // Widget'ın durum (State) nesnesini oluşturur.
  @override
  State<_PhysicalEditForm> createState() => _PhysicalEditFormState();
}

// Doğum yılı ve kilo alanlarını yönetir.
class _PhysicalEditFormState extends State<_PhysicalEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _birthYear;
  late final TextEditingController _weight;
  bool _isSaving = false;

  // Widget ilk açıldığında bir kez çalışır; başlangıç işlerini yapar.
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

  // Kapanırken dinleyicileri ve kaynakları serbest bırakır.
  @override
  void dispose() {
    _birthYear.dispose();
    _weight.dispose();
    super.dispose();
  }

  /// Boş bırakılabilir; doluysa [min]–[max] aralığında tam sayı olmalı.
  String? _validateRange(String? value, int min, int max) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final n = int.tryParse(text);
    if (n != null && n >= min && n <= max) return null;
    return AppLocalizations.of(context)?.validationInvalidValue ??
        'Geçerli bir değer girin';
  }

  // Formu doğrular ve kaydeder.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final ok = await widget.onSave(
      birthYear: int.tryParse(_birthYear.text),
      weightKg: int.tryParse(_weight.text),
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
              : (l10n?.genericError ??
                    'Bir hata oluştu, lütfen tekrar deneyin.'),
        ),
        backgroundColor: ok ? status.normal : status.critical,
      ),
    );
  }

  // Arayüzü çizer.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _birthYear,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n?.profileBirthYear ?? 'Doğum Yılı',
              hintText: l10n?.profileBirthYearHint ?? 'Örn. 1995',
              prefixIcon: const Icon(Icons.cake_outlined, size: 20),
            ),
            validator: (v) => _validateRange(v, 1900, DateTime.now().year),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _weight,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n?.profileWeight ?? 'Kilo (kg)',
              hintText: l10n?.profileWeightHint ?? 'Örn. 72',
              prefixIcon: const Icon(Icons.monitor_weight_outlined, size: 20),
            ),
            validator: (v) => _validateRange(v, 1, 400),
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
