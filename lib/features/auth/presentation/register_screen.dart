import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/user_role.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_status_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import 'auth_controller.dart';
import 'auth_texts.dart';

/// O4 — Kayıt Ekranı (§3.1, §3.3).
/// Afetzede kaydı tamamlanınca Ana Sayfa'ya geçer.
/// Yetkili hesabı onaysız açılır, kullanıcı bilgilendirilir (§2).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _passwordAgain = TextEditingController();
  final _phoneFormatter = Validators.phoneFormatter();
  final _obscure = ValueNotifier(true);
  UserRole _role = UserRole.citizen;
  bool _notificationsOptIn = true;
  bool _legalAccepted = false;
  bool _showLegalError = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _passwordAgain.dispose();
    _obscure.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    setState(() => _showLegalError = !_legalAccepted);
    if (!valid || !_legalAccepted) return;
    FocusScope.of(context).unfocus();

    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthController>();
    final ok = await auth.register(RegisterInput(
      role: _role,
      fullName: _fullName.text,
      email: _email.text,
      phone: Validators.normalizePhone(_phone.text)!,
      password: _password.text,
      notificationsOptIn: _notificationsOptIn,
    ));

    if (ok || !mounted || auth.failure != AuthFailure.pendingApproval) return;

    await AppDialog.info(
      context,
      title: l10n?.registerOfficialPendingTitle ?? 'Kayıt Alındı',
      message: l10n?.registerOfficialPendingMessage ??
          'Hesabınız yönetici onayı bekliyor. Onaylandıktan sonra giriş yapabilirsiniz.',
    );
    if (!mounted) return;
    context.canPop() ? context.pop() : context.go(AppRoutes.login);
  }

  void _openLegal(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final l10n = AppLocalizations.of(context);
    final busy = auth.isBusy;
    final theme = Theme.of(context);
    final danger = theme.extension<AppStatusColors>()!.critical;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.registerTitle ?? 'Kayıt Ol'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hesap Türü
                DropdownButtonFormField<UserRole>(
                  initialValue: _role,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n?.registerAccountType ?? 'Hesap Türü',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  ),
                  items: [
                    for (final r in UserRole.values)
                      DropdownMenuItem(
                        value: r,
                        child: Text(roleLabel(r, l10n)),
                      ),
                  ],
                  onChanged: busy ? null : (r) => setState(() => _role = r!),
                ),
                const SizedBox(height: 16),

                // Ad Soyad
                TextFormField(
                  controller: _fullName,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n?.registerFullName ?? 'Ad Soyad',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (v) => validationMessage(Validators.required(v), l10n),
                ),
                const SizedBox(height: 16),

                // E-posta
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n?.registerEmail ?? 'E-posta',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  ),
                  validator: (v) => validationMessage(Validators.email(v), l10n),
                ),
                const SizedBox(height: 16),

                // Telefon
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [_phoneFormatter],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n?.registerPhone ?? 'Telefon',
                    hintText: '+90 5XX XXX XX XX',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  ),
                  validator: (v) => validationMessage(Validators.phone(v), l10n),
                ),
                const SizedBox(height: 16),

                // Şifre ve Güç Göstergesi
                ValueListenableBuilder<bool>(
                  valueListenable: _obscure,
                  builder: (context, obscure, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _password,
                        obscureText: obscure,
                        autofillHints: const [AutofillHints.newPassword],
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: l10n?.registerPassword ?? 'Şifre',
                          helperText: l10n?.registerPasswordHelper ??
                              'En az 8 karakter, 1 büyük harf, 1 rakam',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () => _obscure.value = !obscure,
                          ),
                        ),
                        validator: (v) =>
                            validationMessage(Validators.password(v), l10n),
                      ),
                      const SizedBox(height: 8),
                      _PasswordStrengthBar(
                        strength: Validators.passwordStrength(_password.text),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordAgain,
                        obscureText: obscure,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText:
                              l10n?.registerPasswordAgain ?? 'Şifre Tekrar',
                          prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                        ),
                        validator: (v) => validationMessage(
                          Validators.confirmPassword(v, _password.text),
                          l10n,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bildirim Onayı
                CheckboxListTile(
                  value: _notificationsOptIn,
                  onChanged: busy
                      ? null
                      : (v) => setState(() => _notificationsOptIn = v!),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    l10n?.registerNotificationsOptIn ??
                        'Kritik Afet Uyarı Bildirimlerini Al',
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    l10n?.registerNotificationsSubtitle ??
                        'Tahliye ve artçı sarsıntı uyarılarını almak istiyorum',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),

                // KVKK & Gizlilik Onayı (T4, §7)
                CheckboxListTile(
                  value: _legalAccepted,
                  onChanged: busy
                      ? null
                      : (v) => setState(() {
                            _legalAccepted = v!;
                            if (_legalAccepted) _showLegalError = false;
                          }),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    l10n?.registerLegalCheckbox ??
                        'Gizlilik Politikası ve KVKK Aydınlatma Metnini okudum, onaylıyorum.',
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: _showLegalError
                      ? Text(
                          l10n?.registerLegalError ??
                              'Devam etmek için onay gereklidir',
                          style: TextStyle(
                            color: danger,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => _openLegal(AppConfig.kvkkNoticeUrl),
                      child: Text(
                        l10n?.kvkkConsent ?? 'KVKK Aydınlatma Metni',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openLegal(AppConfig.privacyPolicyUrl),
                      child: Text(
                        l10n?.privacyPolicy ?? 'Gizlilik Politikası',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (auth.failure != null &&
                    auth.failure != AuthFailure.pendingApproval) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: danger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            failureMessage(auth.failure!, l10n),
                            style: TextStyle(
                              color: danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Kayıt Ol Butonu
                AppButton.primary(
                  label: l10n?.registerSubmit ?? 'Kayıt Ol',
                  isLoading: busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.strength});

  final int strength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<AppStatusColors>()!;
    final criticalColor = statusColors.critical;
    final warningColor = statusColors.urgent;
    final successColor = statusColors.normal;

    final color = switch (strength) {
      <= 1 => criticalColor,
      2 || 3 => warningColor,
      _ => successColor,
    };

    return LinearProgressIndicator(
      value: strength / 4,
      color: color,
      backgroundColor: theme.colorScheme.outline,
      minHeight: 4,
      borderRadius: BorderRadius.circular(2),
    );
  }
}
