// Hesabı Sil akışı (mağaza zorunluluğu): 1) "Emin misiniz?" 2) şifre sorulur 3) veriler ve hesap silinir.
// Afetzede ve yetkili profili aynı akışı kullanır.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_status_colors.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/domain/auth_failure.dart';
import 'profile_controller.dart';

/// Hesabı Sil: onay → şifre → silme. A4 ve Y4 aynı akışı kullanır.
/// Başarılı olunca Auth hesabı silinir ve router kullanıcıyı Giriş'e götürür.
Future<void> runDeleteAccountFlow(
  BuildContext context, {
  required bool isOfficial,
}) async {
  final l10n = AppLocalizations.of(context);
  final controller = context.read<ProfileController>();
  final messenger = ScaffoldMessenger.of(context);
  final danger = Theme.of(context).extension<AppStatusColors>()!.critical;

  final confirmed = await AppDialog.confirm(
    context,
    title: l10n?.deleteAccountConfirmTitle ?? 'Hesabınızı Silmek İstiyor Musunuz?',
    message: isOfficial
        ? (l10n?.deleteAccountConfirmMessageOfficial ??
            'Bu işlem geri alınamaz. Koordinatör hesabı kalıcı olarak silinecektir.')
        : (l10n?.deleteAccountConfirmMessage ??
            'Bu işlem geri alınamaz. Kişisel verileriniz ve sağlık bilgileriniz kalıcı olarak silinecektir.'),
    confirmLabel: l10n?.deleteAccount ?? 'Hesabı Sil',
    destructive: true,
  );
  if (confirmed != true || !context.mounted) return;

  final password = await showDialog<String>(
    context: context,
    builder: (_) => const _PasswordDialog(),
  );
  if (password == null || password.isEmpty) return;

  final ok = await controller.deleteAccount(password: password);
  if (ok) return;
  final message = switch (controller.deleteFailure) {
    AuthFailure.invalidCredentials =>
      l10n?.authFailureInvalidCredentials ?? 'E-posta veya şifre hatalı',
    AuthFailure.network =>
      l10n?.authFailureNetwork ?? 'İnternet bağlantısı yok, tekrar deneyin',
    AuthFailure.tooManyRequests => l10n?.authFailureTooManyRequests ??
        'Çok fazla deneme yapıldı, biraz sonra tekrar deneyin',
    _ => l10n?.deleteAccountFailed ?? 'Hesap silinemedi, tekrar deneyin.',
  };
  messenger.showSnackBar(
    SnackBar(content: Text(message), backgroundColor: danger),
  );
}

// Hesap silmeden önce şifre soran diyalog.
class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  // Bu StatefulWidget'ın değişen verilerini tutacak State nesnesini oluşturur.
  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

// Şifre alanını ve doğrulamayı yönetir.
class _PasswordDialogState extends State<_PasswordDialog> {
  final _password = TextEditingController();
  final _obscure = ValueNotifier(true);

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    _password.dispose();
    _obscure.dispose();
    super.dispose();
  }

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final danger = theme.extension<AppStatusColors>()!.critical;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outline),
      ),
      title: Text(
        l10n?.deleteAccountPasswordTitle ?? 'Şifrenizi Doğrulayın',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n?.deleteAccountPasswordMessage ??
                'Güvenliğiniz için hesabı silmeden önce şifrenizi girin.',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: _obscure,
            builder: (context, obscure, _) => TextField(
              controller: _password,
              obscureText: obscure,
              autofocus: true,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (v) => Navigator.of(context).pop(v),
              decoration: InputDecoration(
                labelText: l10n?.loginPassword ?? 'Şifre',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                  onPressed: () => _obscure.value = !obscure,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'İptal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_password.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: danger,
            foregroundColor: colors.onError,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(l10n?.deleteAccount ?? 'Hesabı Sil'),
        ),
      ],
    );
  }
}
