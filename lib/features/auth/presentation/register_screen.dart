import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/user_role.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import 'auth_controller.dart';
import 'auth_texts.dart';

/// O4 — Kayıt. Afetzede kaydı biter bitmez Ana Sayfa'ya düşer; yetkili hesabı
/// onaysız açılır, kullanıcı Giriş'e döner (§2).
// TODO(G2): Tasarımı (design/ 09.32.23) uygula, metinleri ARB'ye taşı.
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

    final auth = context.read<AuthController>();
    final ok = await auth.register(RegisterInput(
      role: _role,
      fullName: _fullName.text,
      email: _email.text,
      phone: Validators.normalizePhone(_phone.text)!,
      password: _password.text,
      notificationsOptIn: _notificationsOptIn,
    ));
    // Başarılı afetzede kaydında router Ana Sayfa'ya geçer.
    if (ok || !mounted || auth.failure != AuthFailure.pendingApproval) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kayıt alındı'),
        content: const Text(
          'Hesabınız yönetici onayı bekliyor. Onaylandıktan sonra giriş yapabilirsiniz.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Tamam')),
        ],
      ),
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
    final theme = Theme.of(context);
    final busy = auth.isBusy;

    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<UserRole>(
                  initialValue: _role,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Hesap Türü'),
                  items: [
                    for (final r in UserRole.values)
                      DropdownMenuItem(value: r, child: Text(roleLabel(r))),
                  ],
                  onChanged: busy ? null : (r) => setState(() => _role = r!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullName,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Ad Soyad'),
                  validator: (v) => validationMessage(Validators.required(v)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'E-posta'),
                  validator: (v) => validationMessage(Validators.email(v)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [_phoneFormatter],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    hintText: '+90 5XX XXX XX XX',
                  ),
                  validator: (v) => validationMessage(Validators.phone(v)),
                ),
                const SizedBox(height: 16),
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
                          labelText: 'Şifre',
                          helperText: 'En az 8 karakter, 1 büyük harf, 1 rakam',
                          suffixIcon: IconButton(
                            icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => _obscure.value = !obscure,
                          ),
                        ),
                        validator: (v) => validationMessage(Validators.password(v)),
                      ),
                      const SizedBox(height: 8),
                      _PasswordStrengthBar(strength: Validators.passwordStrength(_password.text)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordAgain,
                        obscureText: obscure,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(labelText: 'Şifre Tekrar'),
                        validator: (v) =>
                            validationMessage(Validators.confirmPassword(v, _password.text)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _notificationsOptIn,
                  onChanged: busy ? null : (v) => setState(() => _notificationsOptIn = v!),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Kritik Afet Uyarı Bildirimleri'),
                  subtitle: const Text('Tahliye ve artçı sarsıntı uyarılarını almak istiyorum'),
                ),
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
                  title: const Text(
                    'KVKK Aydınlatma Metni\'ni ve Gizlilik Politikası\'nı okudum, kabul ediyorum',
                  ),
                  subtitle: _showLegalError
                      ? Text('Devam etmek için onay gereklidir',
                          style: TextStyle(color: theme.colorScheme.error))
                      : null,
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => _openLegal(AppConfig.kvkkNoticeUrl),
                      child: const Text('KVKK Aydınlatma Metni'),
                    ),
                    TextButton(
                      onPressed: () => _openLegal(AppConfig.privacyPolicyUrl),
                      child: const Text('Gizlilik Politikası'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (auth.failure != null && auth.failure != AuthFailure.pendingApproval) ...[
                  Text(
                    failureMessage(auth.failure!),
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: busy ? null : _submit,
                  child: busy
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Kayıt Ol'),
                ),
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

  /// 0–4 (Validators.passwordStrength).
  final int strength;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // TODO(G2): Renkleri AppStatusColors'tan al (danger / warning / success).
    final color = switch (strength) {
      <= 1 => scheme.error,
      2 || 3 => scheme.tertiary,
      _ => scheme.primary,
    };
    return LinearProgressIndicator(
      value: strength / 4,
      color: color,
      backgroundColor: scheme.surfaceContainerHighest,
      minHeight: 4,
      borderRadius: BorderRadius.circular(2),
    );
  }
}
