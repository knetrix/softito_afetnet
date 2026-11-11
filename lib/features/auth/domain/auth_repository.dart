import 'package:flutter/foundation.dart';

import '../../../core/constants/user_role.dart';
import 'app_user.dart';

/// Kayıt formundan gelen veriler.
@immutable
class RegisterInput {
  const RegisterInput({
    required this.role,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.notificationsOptIn,
  });

  final UserRole role;
  final String fullName;
  final String email;

  /// `+905XXXXXXXXX` biçiminde.
  final String phone;
  final String password;
  final bool notificationsOptIn;
}

/// Hatalar [AuthException] olarak fırlatılır.
abstract interface class AuthRepository {
  /// Oturum açık kullanıcının uid'si; oturum yoksa `null`.
  Stream<String?> uidChanges();

  /// `users/{uid}` belgesi; yoksa `null`.
  Future<AppUser?> fetchUser(String uid);

  /// Başarılıysa uid döner.
  Future<String> signIn({required String email, required String password});

  /// Auth hesabını açar; `users/{uid}` ve `users/{uid}/private/contact`
  /// belgelerini tek batch'te oluşturur (§7).
  Future<AppUser> register(RegisterInput input);

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
