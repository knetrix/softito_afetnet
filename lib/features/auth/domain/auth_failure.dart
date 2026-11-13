// Giriş ve kayıt hata türleri.

/// Giriş/Kayıt hata türleri. Metne çeviri ekranda yapılır.
enum AuthFailure {
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  roleMismatch,
  pendingApproval,
  profileMissing,
  network,
  tooManyRequests,
  /// Firebase Console'da E-posta/Şifre girişi etkin değil.
  providerDisabled,
  unknown,
}

/// Repository'nin fırlattığı tek hata tipi; Firebase hatası presentation'a sızmaz.
class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;

  // Hata ayıklama için okunur metin döndürür.
  @override
  String toString() => 'AuthException(${failure.name})';
}
