// Form doğrulama: e-posta, telefon maskesi, şifre kuralı.

import 'package:flutter/services.dart';
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

  /// Telefon alanı için `+90 5XX XXX XX XX` biçimlendiricisi.
  static TextInputFormatter phoneFormatter() => const _PhoneInputFormatter();
}

/// Her değişiklikte rakamları baştan yorumlar. `5321234567`, `05321234567`,
/// `+90 532...` ya da `+90 5`'ten sonra `321234567` yazmak aynı sonucu verir.
/// (Durum tutan maske, `+90 5`'ten sonra yazılan `5`'i ikinci kez ekliyordu.)
class _PhoneInputFormatter extends TextInputFormatter {
  const _PhoneInputFormatter();

  static final _mask = MaskTextInputFormatter(
    mask: '+90 ### ### ## ##',
    filter: {'#': RegExp(r'\d')},
  );

  static String _digits(String text) => text.replaceAll(RegExp(r'\D'), '');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Elle `+90` yazılırken ülke kodu henüz tamamlanmamıştır.
    if (RegExp(r'^\+?9?0?$').hasMatch(newValue.text)) return newValue;

    var digits = _digits(newValue.text);
    // Boşluk gibi bir ayırıcı silindiyse önündeki rakam silinir.
    if (newValue.text.length < oldValue.text.length &&
        digits == _digits(oldValue.text) &&
        digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }

    if (digits.startsWith('90')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.isNotEmpty && !digits.startsWith('5')) digits = '5$digits';
    if (digits.length > 10) digits = digits.substring(0, 10);

    final text = digits.isEmpty ? '' : _mask.maskText(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
