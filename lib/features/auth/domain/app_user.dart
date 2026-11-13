// "domain" katmanı: kullanıcı modeli (users/{uid}). Ad, rol (afetzede/yetkili), onay durumu,
// birim, bölge ve ekip bilgisi. Telefon gibi gizli bilgiler burada değil, private/contact'tadır.

import 'package:flutter/foundation.dart';

import '../../../core/constants/user_role.dart';

/// `users/{uid}` herkese açık profil.
/// Gizli bilgiler (e-posta, telefon …) `private/contact`'tadır, burada tutulmaz.
@immutable
class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.role,
    required this.isVerified,
    this.notificationsOptIn = false,
    this.unitName,
    this.region,
    this.teamId,
  });

  final String uid;
  final String fullName;
  final UserRole role;
  final bool isVerified;
  final bool notificationsOptIn;

  // Yalnızca yetkili; Console'dan yazılır.
  final String? unitName;
  final String? region;
  final String? teamId;

  // Kullanıcı yetkili mi.
  bool get isOfficial => role == UserRole.official;

  /// Onaysız yetkili hiçbir yetkili verisine erişemez.
  bool get isPendingApproval => isOfficial && !isVerified;
}
