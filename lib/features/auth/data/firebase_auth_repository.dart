import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/user_role.dart';
import '../domain/app_user.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Stream<String?> uidChanges() => _auth.authStateChanges().map((u) => u?.uid);

  @override
  Future<AppUser?> fetchUser(String uid) async {
    try {
      final snap = await _userDoc(uid).get();
      final data = snap.data();
      return data == null ? null : _fromMap(uid, data);
    } on FirebaseException catch (e) {
      throw AuthException(_mapFirestore(e));
    }
  }

  @override
  Future<String> signIn({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuth(e));
    }
  }

  @override
  Future<AppUser> register(RegisterInput input) async {
    final UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: input.email.trim(),
        password: input.password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuth(e));
    }

    final uid = cred.user!.uid;
    final fullName = input.fullName.trim();
    final now = FieldValue.serverTimestamp();
    final batch = _db.batch()
      // unitName, region, teamId yazılmaz; isVerified yalnızca Console'dan true olur (§2).
      ..set(_userDoc(uid), {
        'fullName': fullName,
        'role': input.role.name,
        'isVerified': false,
        'notificationsOptIn': input.notificationsOptIn,
        'consents': {
          'privacyVersion': AppConfig.privacyVersion,
          'kvkkVersion': AppConfig.kvkkVersion,
          'acceptedAt': now,
        },
        'createdAt': now,
      })
      ..set(_userDoc(uid).collection('private').doc('contact'), {
        'email': input.email.trim(),
        'phone': input.phone,
      });

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      // Profil yazılamadıysa yarım hesap bırakılmaz.
      await cred.user?.delete().catchError((Object _) {});
      throw AuthException(_mapFirestore(e));
    }

    return AppUser(
      uid: uid,
      fullName: fullName,
      role: input.role,
      isVerified: false,
      notificationsOptIn: input.notificationsOptIn,
    );
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuth(e));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  AppUser _fromMap(String uid, Map<String, dynamic> d) {
    return AppUser(
      uid: uid,
      fullName: d['fullName'] as String? ?? '',
      role: UserRole.values.asNameMap()[d['role']] ?? UserRole.citizen,
      isVerified: d['isVerified'] as bool? ?? false,
      notificationsOptIn: d['notificationsOptIn'] as bool? ?? false,
      unitName: d['unitName'] as String?,
      region: d['region'] as String?,
      teamId: d['teamId'] as String?,
    );
  }

  AuthFailure _mapAuth(FirebaseAuthException e) => switch (e.code) {
        'invalid-credential' ||
        'invalid-email' ||
        'wrong-password' ||
        'user-not-found' ||
        'user-disabled' =>
          AuthFailure.invalidCredentials,
        'email-already-in-use' => AuthFailure.emailAlreadyInUse,
        'weak-password' => AuthFailure.weakPassword,
        'network-request-failed' => AuthFailure.network,
        'too-many-requests' => AuthFailure.tooManyRequests,
        _ => AuthFailure.unknown,
      };

  AuthFailure _mapFirestore(FirebaseException e) =>
      e.code == 'unavailable' ? AuthFailure.network : AuthFailure.unknown;
}
