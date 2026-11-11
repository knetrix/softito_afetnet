import '../../../core/constants/user_role.dart';
import '../../../core/utils/validators.dart';
import '../domain/auth_failure.dart';

// TODO(G2): Bu dosyadaki metinler ARB'ye (app_tr.arb + app_en.arb) taşınır,
// fonksiyonlar `AppLocalizations` alacak şekilde değişir ve dosya silinir.
// Giriş/Kayıt ekranlarındaki diğer sabit metinler de G2'de taşınır.

String roleLabel(UserRole role) => switch (role) {
      UserRole.citizen => 'Sivil Kullanıcı (Afetzede)',
      UserRole.official => 'Saha Koordinatörü (Yetkili)',
    };

String? validationMessage(ValidationError? error) => switch (error) {
      null => null,
      ValidationError.required => 'Bu alan zorunludur',
      ValidationError.invalidEmail => 'Geçerli bir e-posta adresi girin',
      ValidationError.invalidPhone => 'Telefonu +90 5XX XXX XX XX biçiminde girin',
      ValidationError.passwordTooShort =>
        'Şifre en az ${Validators.passwordMinLength} karakter olmalı',
      ValidationError.passwordNoUppercase => 'Şifre en az 1 büyük harf içermeli',
      ValidationError.passwordNoDigit => 'Şifre en az 1 rakam içermeli',
      ValidationError.passwordMismatch => 'Şifreler eşleşmiyor',
    };

String failureMessage(AuthFailure failure) => switch (failure) {
      AuthFailure.invalidCredentials => 'E-posta veya şifre hatalı',
      AuthFailure.emailAlreadyInUse => 'Bu e-posta ile kayıtlı bir hesap var',
      AuthFailure.weakPassword => 'Şifre çok zayıf',
      AuthFailure.roleMismatch => 'Seçtiğiniz giriş türü bu hesapla uyuşmuyor',
      AuthFailure.pendingApproval => 'Hesabınız yönetici onayı bekliyor',
      AuthFailure.profileMissing => 'Hesap profili bulunamadı',
      AuthFailure.network => 'İnternet bağlantısı yok, tekrar deneyin',
      AuthFailure.tooManyRequests => 'Çok fazla deneme yapıldı, biraz sonra tekrar deneyin',
      AuthFailure.providerDisabled => 'E-posta ile giriş şu an kullanılamıyor',
      AuthFailure.unknown => 'Bir hata oluştu, tekrar deneyin',
    };
