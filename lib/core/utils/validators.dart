import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Form doğrulama hataları. Metne çeviri ekranda yapılır (ARB, G2).
enum ValidationError {
  required,
  invalidEmail,
  invalidPhone,
  passwordTooShort,
  passwordNoUppercase,
  passwordNoDigit,
  passwordMismatch,
}

/// Giriş ve Kayıt formu kuralları (PROJECT_NEW.md §7, T3, T4).
abstract final class Validators {
  static const passwordMinLength = 8;
  static const phoneMask = '+90 5## ### ## ##';

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final _uppercasePattern = RegExp(r'[A-ZÇĞİÖŞÜ]');
  static final _digitPattern = RegExp(r'\d');

  static ValidationError? required(String? value) =>
      (value == null || value.trim().isEmpty) ? ValidationError.required : null;

  static ValidationError? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ValidationError.required;
    return _emailPattern.hasMatch(v) ? null : ValidationError.invalidEmail;
  }

  /// `+90 5XX XXX XX XX` biçimindeki maskeli değeri doğrular.
  static ValidationError? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ValidationError.required;
    return normalizePhone(v) == null ? ValidationError.invalidPhone : null;
  }

  /// En az 8 karakter, 1 büyük harf, 1 rakam.
  static ValidationError? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return ValidationError.required;
    if (v.length < passwordMinLength) return ValidationError.passwordTooShort;
    if (!_uppercasePattern.hasMatch(v)) return ValidationError.passwordNoUppercase;
    if (!_digitPattern.hasMatch(v)) return ValidationError.passwordNoDigit;
    return null;
  }

  static ValidationError? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return ValidationError.required;
    return value == password ? null : ValidationError.passwordMismatch;
  }

  /// Şifre güç göstergesi için 0–4 arası puan (O4).
  static int passwordStrength(String value) {
    if (value.isEmpty) return 0;
    var score = 0;
    if (value.length >= passwordMinLength) score++;
    if (_uppercasePattern.hasMatch(value)) score++;
    if (_digitPattern.hasMatch(value)) score++;
    if (value.length >= 12 || RegExp(r'[^A-Za-z0-9ÇĞİÖŞÜçğıöşü]').hasMatch(value)) {
      score++;
    }
    return score;
  }

  /// Maskeli telefonu `+905XXXXXXXXX` biçimine çevirir; geçersizse `null`.
  static String? normalizePhone(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = '90${digits.substring(1)}';
    if (!digits.startsWith('90')) digits = '90$digits';
    return RegExp(r'^905\d{9}$').hasMatch(digits) ? '+$digits' : null;
  }

  /// `+905XXXXXXXXX` biçimini ekranda `+90 5XX XXX XX XX` olarak gösterir.
  /// Çözülemeyen değer olduğu gibi döner.
  static String formatPhone(String value) {
    final e164 = normalizePhone(value);
    if (e164 == null) return value;
    final d = e164.substring(3); // 5XXXXXXXXX
    return '+90 ${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6, 8)} ${d.substring(8)}';
  }

  /// Her telefon alanı kendi formatter örneğini kullanır (durum tutar).
  /// Düzenlenen alanda kayıtlı numara varsa [initialText] olarak verilir.
  static MaskTextInputFormatter phoneFormatter({String? initialText}) =>
      MaskTextInputFormatter(
        mask: phoneMask,
        filter: {'#': RegExp(r'\d')},
        initialText: initialText,
      );
}
