// Kayıtlı ikamet adresini düzenleme formu (alttan açılan panel).

import 'package:flutter/material.dart';

import '../../../../core/theme/app_status_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/user_contact_profile.dart';

// Adres düzenleme formunu alttan açar.
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

// Adres formu widget'ı.
class _AddressEditForm extends StatefulWidget {
  const _AddressEditForm({
    required this.currentProfile,
    required this.onSave,
  });

  final UserContactProfile? currentProfile;
  final Future<bool> Function({required String addressText}) onSave;

  // Bu StatefulWidget'ın değişen verilerini tutacak State nesnesini oluşturur.
  @override
  State<_AddressEditForm> createState() => _AddressEditFormState();
}

// Adres alanlarını ve kaydetmeyi yönetir.
class _AddressEditFormState extends State<_AddressEditForm> {
  late final TextEditingController _address;
  bool _isSaving = false;

  // Widget ekrana ilk geldiğinde yalnızca bir kez çalışır; dinleyiciler ve başlangıç verileri burada hazırlanır.
  @override
  void initState() {
    super.initState();
    _address = TextEditingController(
      text: widget.currentProfile?.addressText ?? '',
    );
  }

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  // Formu doğrular ve adresi kaydeder.
  Future<void> _submit() async {
    setState(() => _isSaving = true);
    final ok = await widget.onSave(addressText: _address.text);
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

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
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
            hintText: l10n?.profileAddressHint ??
                'İl, ilçe, mahalle, sokak, bina ve kat bilgisi...',
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
