// "domain" katmanı: profil işlemlerinin sözleşmesi (arayüz).

import 'user_contact_profile.dart';

/// Profil verileri yönetim arayüzü (Clean Architecture - Domain katmanı)
abstract class ProfileRepository {
  // Gizli profili canlı izler.
  Stream<UserContactProfile?> watchProfile(String uid);

  // Gizli profili bir kez okur.
  Future<UserContactProfile?> getProfile(String uid);

  // Tıbbi bilgiyi kaydeder.
  Future<void> updateMedicalInfo(
    String uid, {
    required String bloodType,
    required String medications,
    required String conditions,
    required DateTime consentAt,
  });

  // Doğum yılı ve kiloyu kaydeder.
  Future<void> updatePhysicalInfo(
    String uid, {
    required int? birthYear,
    required int? weightKg,
  });

  // Acil durum yakınını kaydeder.
  Future<void> updateEmergencyContact(
    String uid, {
    required String name,
    required String relation,
    required String phone,
  });

  // Adresi kaydeder.
  Future<void> updateAddress(
    String uid, {
    required String addressText,
  });

  /// Bağlı ekibin adı (`teams/{teamId}.name`); ekip kaydı yoksa `null`.
  Future<String?> getTeamName(String teamId);

  /// Hesabı Sil (PROJECT_NEW.md §7 mağaza zorunluluğu).
  /// Önce [password] ile kimlik yeniden doğrulanır; hatalar `AuthException`
  /// olarak fırlatılır (yanlış şifrede `AuthFailure.invalidCredentials`).
  Future<void> deleteAccount(String uid, {required String password});
}

