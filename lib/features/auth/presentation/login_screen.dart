import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/user_role.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/not_official_notice.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';
import 'auth_texts.dart';

/// O3 — Giriş Ekranı (§3.1, 09.32.09).
/// Başarılı girişte router kullanıcıyı rolüne göre ilgili ekrana yönlendirir.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _obscure = ValueNotifier(true);
  UserRole _role = UserRole.citizen;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _obscure.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await context.read<AuthController>().signIn(
          email: _email.text,
          password: _password.text,
          selectedRole: _role,
        );
  }

  Future<void> _forgotPassword() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (Validators.email(_email.text) != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.loginForgotPasswordPrompt ??
                'Şifre sıfırlama için e-posta adresinizi girin',
          ),
          backgroundColor: AppColors.surfaceHigh,
        ),
      );
      return;
    }
    final sent =
        await context.read<AuthController>().sendPasswordReset(_email.text);
    if (!mounted || !sent) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n?.loginForgotPasswordSent ??
              'Şifre sıfırlama bağlantısı e-postanıza gönderildi',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  // Logo / Başlık Rozeti
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.radar_rounded,
                          size: 34,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.appTitle ?? 'AfetNet',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n?.splashSubtitle ?? 'Canlı Kriz Yönetimi Ağı',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Giriş Türü (Rol)
                  DropdownButtonFormField<UserRole>(
                    initialValue: _role,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n?.loginType ?? 'Giriş Türü',
                      prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                    ),
                    items: [
                      for (final r in UserRole.values)
                        DropdownMenuItem(
                          value: r,
                          child: Text(roleLabel(r, l10n)),
                        ),
                    ],
                    onChanged: auth.isBusy
                        ? null
                        : (r) => setState(() => _role = r!),
                  ),
                  const SizedBox(height: 16),

                  // E-posta alanı (T3: yalnızca e-posta)
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n?.loginEmail ?? 'E-posta',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    ),
                    validator: (v) => validationMessage(Validators.email(v), l10n),
                  ),
                  const SizedBox(height: 16),

                  // Şifre alanı
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscure,
                    builder: (context, obscure, _) => TextFormField(
                      controller: _password,
                      obscureText: obscure,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n?.loginPassword ?? 'Şifre',
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
                          validationMessage(Validators.required(v), l10n),
                    ),
                  ),

                  // Şifremi Unuttum
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: auth.isBusy ? null : _forgotPassword,
                      child: Text(
                        l10n?.loginForgotPassword ?? 'Şifremi Unuttum',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // Hata Mesajı
                  if (auth.failure != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              failureMessage(auth.failure!, l10n),
                              style: const TextStyle(
                                color: AppColors.danger,
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

                  // Giriş Yap Butonu (T5)
                  AppButton.primary(
                    label: l10n?.loginSubmit ?? 'Giriş Yap',
                    isLoading: auth.isBusy,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),

                  // Üye Olun Yönlendirmesi
                  TextButton(
                    onPressed: auth.isBusy
                        ? null
                        : () {
                            auth.clearFailure();
                            context.push(AppRoutes.register);
                          },
                    child: Text(
                      l10n?.loginSignUpPrompt ?? 'Hesabınız yok mu? Üye Olun',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // T15: Resmi kurum değildir uyarısı
                  const NotOfficialNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
