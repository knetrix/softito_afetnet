import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/user_role.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/not_official_notice.dart';
import 'auth_controller.dart';
import 'auth_texts.dart';

/// O3 — Giriş. Başarılı girişte router kullanıcıyı rolüne göre yönlendirir.
// TODO(G2): Tasarımı (design/ 09.32.09) uygula, metinleri ARB'ye taşı.
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
    final messenger = ScaffoldMessenger.of(context);
    if (Validators.email(_email.text) != null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Şifre sıfırlama için e-posta adresinizi girin')),
      );
      return;
    }
    final sent = await context.read<AuthController>().sendPasswordReset(_email.text);
    if (!mounted || !sent) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Şifre sıfırlama bağlantısı e-postanıza gönderildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('AfetNet', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  DropdownButtonFormField<UserRole>(
                    initialValue: _role,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Giriş Türü'),
                    items: [
                      for (final r in UserRole.values)
                        DropdownMenuItem(value: r, child: Text(roleLabel(r))),
                    ],
                    onChanged: auth.isBusy ? null : (r) => setState(() => _role = r!),
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
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscure,
                    builder: (context, obscure, _) => TextFormField(
                      controller: _password,
                      obscureText: obscure,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        suffixIcon: IconButton(
                          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => _obscure.value = !obscure,
                        ),
                      ),
                      validator: (v) => validationMessage(Validators.required(v)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: auth.isBusy ? null : _forgotPassword,
                      child: const Text('Şifremi Unuttum'),
                    ),
                  ),
                  if (auth.failure != null) ...[
                    Text(
                      failureMessage(auth.failure!),
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    onPressed: auth.isBusy ? null : _submit,
                    child: auth.isBusy
                        ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Giriş Yap'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: auth.isBusy
                        ? null
                        : () {
                            auth.clearFailure();
                            context.push(AppRoutes.register);
                          },
                    child: const Text('Hesabınız yok mu? Üye Olun'),
                  ),
                  const SizedBox(height: 24),
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
