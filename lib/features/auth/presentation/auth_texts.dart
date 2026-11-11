import '../../../core/constants/user_role.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/auth_failure.dart';

/// Rol etiketi
String roleLabel(UserRole role, [AppLocalizations? l10n]) => switch (role) {
      UserRole.citizen => l10n?.roleCitizen ?? 'Sivil Kullanıcı (Afetzede)',
      UserRole.official => l10n?.roleOfficial ?? 'Saha Koordinatörü (Yetkili)',
    };

/// Doğrulama hata mesajı
String? validationMessage(ValidationError? error, [AppLocalizations? l10n]) => switch (error) {
      null => null,
      ValidationError.required => l10n?.validationRequired ?? 'Bu alan zorunludur',
      ValidationError.invalidEmail => l10n?.validationInvalidEmail ?? 'Geçerli bir e-posta adresi girin',
      ValidationError.invalidPhone => l10n?.validationInvalidPhone ?? 'Telefonu +90 5XX XXX XX XX biçiminde girin',
      ValidationError.passwordTooShort =>
        l10n?.validationPasswordTooShort ?? 'Şifre en az ${Validators.passwordMinLength} karakter olmalı',
      ValidationError.passwordNoUppercase => l10n?.validationPasswordNoUppercase ?? 'Şifre en az 1 büyük harf içermeli',
      ValidationError.passwordNoDigit => l10n?.validationPasswordNoDigit ?? 'Şifre en az 1 rakam içermeli',
      ValidationError.passwordMismatch => l10n?.validationPasswordMismatch ?? 'Şifreler eşleşmiyor',
    };

/// Kimlik doğrulama hata mesajı
String failureMessage(AuthFailure failure, [AppLocalizations? l10n]) => switch (failure) {
      AuthFailure.invalidCredentials => l10n?.authFailureInvalidCredentials ?? 'E-posta veya şifre hatalı',
      AuthFailure.emailAlreadyInUse => l10n?.authFailureEmailAlreadyInUse ?? 'Bu e-posta ile kayıtlı bir hesap var',
      AuthFailure.weakPassword => l10n?.authFailureWeakPassword ?? 'Şifre çok zayıf',
      AuthFailure.roleMismatch => l10n?.authFailureRoleMismatch ?? 'Seçtiğiniz giriş türü bu hesapla uyuşmuyor',
      AuthFailure.pendingApproval => l10n?.authFailurePendingApproval ?? 'Hesabınız yönetici onayı bekliyor',
      AuthFailure.profileMissing => l10n?.authFailureProfileMissing ?? 'Hesap profili bulunamadı',
      AuthFailure.network => l10n?.authFailureNetwork ?? 'İnternet bağlantısı yok, tekrar deneyin',
      AuthFailure.tooManyRequests => l10n?.authFailureTooManyRequests ?? 'Çok fazla deneme yapıldı, biraz sonra tekrar deneyin',
      AuthFailure.providerDisabled => l10n?.authFailureProviderDisabled ?? 'E-posta ile giriş şu an kullanılamıyor',
      AuthFailure.unknown => l10n?.authFailureUnknown ?? 'Bir hata oluştu, tekrar deneyin',
    };
