import 'package:afetnet/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email', () {
    test('boş → required', () {
      expect(Validators.email(''), ValidationError.required);
      expect(Validators.email(null), ValidationError.required);
    });
    test('geçersiz biçim', () {
      expect(Validators.email('ali'), ValidationError.invalidEmail);
      expect(Validators.email('ali@x'), ValidationError.invalidEmail);
      expect(Validators.email('ali @x.com'), ValidationError.invalidEmail);
    });
    test('geçerli (boşluklar kırpılır)', () {
      expect(Validators.email(' afetzede1@afetnet.demo '), isNull);
    });
  });

  group('phone', () {
    test('maskeli geçerli numara', () {
      expect(Validators.phone('+90 532 123 45 67'), isNull);
      expect(Validators.normalizePhone('+90 532 123 45 67'), '+905321234567');
    });
    test('eksik veya 5 ile başlamayan numara', () {
      expect(Validators.phone('+90 532 123 45'), ValidationError.invalidPhone);
      expect(Validators.phone('+90 212 123 45 67'), ValidationError.invalidPhone);
      expect(Validators.phone(''), ValidationError.required);
    });
    test('normalizePhone farklı yazımları kabul eder', () {
      expect(Validators.normalizePhone('05321234567'), '+905321234567');
      expect(Validators.normalizePhone('5321234567'), '+905321234567');
    });
    test('formatPhone kayıtlı numarayı maskeli gösterir', () {
      expect(Validators.formatPhone('+905339876543'), '+90 533 987 65 43');
      expect(Validators.formatPhone('+90 533 987 65 43'), '+90 533 987 65 43');
      expect(Validators.formatPhone('abc'), 'abc');
    });
    test('formatter kayıtlı numarayla başlayabilir', () {
      final f = Validators.phoneFormatter(initialText: '+90 533 987 65 43');
      expect(f.getMaskedText(), '+90 533 987 65 43');
      expect(f.isFill(), isTrue);
    });
    test('formatter maskeyi uygular', () {
      final masked = Validators.phoneFormatter().maskText('5321234567');
      expect(masked, '+90 532 123 45 67');
      expect(Validators.phone(masked), isNull);
    });
  });

  group('password', () {
    test('kurallar sırayla kontrol edilir', () {
      expect(Validators.password(''), ValidationError.required);
      expect(Validators.password('Abc1'), ValidationError.passwordTooShort);
      expect(Validators.password('abcdefg1'), ValidationError.passwordNoUppercase);
      expect(Validators.password('Abcdefgh'), ValidationError.passwordNoDigit);
      expect(Validators.password('Abcdefg1'), isNull);
    });
    test('Türkçe büyük harf kabul edilir', () {
      expect(Validators.password('şifreĞ123'), isNull);
    });
    test('tekrar alanı eşleşmeli', () {
      expect(Validators.confirmPassword('Abcdefg1', 'Abcdefg2'), ValidationError.passwordMismatch);
      expect(Validators.confirmPassword('Abcdefg1', 'Abcdefg1'), isNull);
    });
    test('güç puanı 0–4', () {
      expect(Validators.passwordStrength(''), 0);
      expect(Validators.passwordStrength('abc'), 0);
      expect(Validators.passwordStrength('Abcdefg1'), 3);
      expect(Validators.passwordStrength('Abcdefg1!'), 4);
    });
  });
}
