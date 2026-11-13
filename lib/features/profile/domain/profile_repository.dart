// Profil repository arayüzü.

import 'user_contact_profile.dart';

/// Profil verileri yönetim arayüzü (Clean Architecture - Domain katmanı)
abstract class ProfileRepository {
  Stream<UserContactProfile?> watchProfile(String uid);

  Future<UserContactProfile?> getProfile(String uid);

  Future<void> updateMedicalInfo(
    String uid, {
    required String bloodType,
    required String medications,
    required String conditions,
    required DateTime consentAt,
  });

  Future<void> updatePhysicalInfo(
    String uid, {
    required int? birthYear,
    required int? weightKg,
  });

  Future<void> updateEmergencyContact(
    String uid, {
    required String name,
    required String relation,
    required String phone,
  });

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

