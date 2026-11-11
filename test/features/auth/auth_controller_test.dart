import 'dart:async';

import 'package:afetnet/core/constants/user_role.dart';
import 'package:afetnet/core/router/app_router.dart';
import 'package:afetnet/core/router/app_routes.dart';
import 'package:afetnet/features/auth/domain/app_user.dart';
import 'package:afetnet/features/auth/domain/auth_failure.dart';
import 'package:afetnet/features/auth/domain/auth_repository.dart';
import 'package:afetnet/features/auth/presentation/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepository implements AuthRepository {
  final users = <String, AppUser>{};
  final passwords = <String, String>{}; // email → uid
  final _uid = StreamController<String?>.broadcast();
  int signOutCount = 0;

  void emit(String? uid) => _uid.add(uid);

  @override
  Stream<String?> uidChanges() => _uid.stream;

  @override
  Future<AppUser?> fetchUser(String uid) async => users[uid];

  @override
  Future<String> signIn({required String email, required String password}) async {
    final uid = passwords[email];
    if (uid == null) throw const AuthException(AuthFailure.invalidCredentials);
    _uid.add(uid);
    return uid;
  }

  @override
  Future<AppUser> register(RegisterInput input) async {
    final uid = 'u${users.length + 1}';
    _uid.add(uid); // Firebase, profil yazılmadan önce oturum olayı yayar.
    final user = AppUser(
      uid: uid,
      fullName: input.fullName,
      role: input.role,
      isVerified: false,
    );
    users[uid] = user;
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    signOutCount++;
    _uid.add(null);
  }
}

const _citizen = AppUser(uid: 'c1', fullName: 'Afetzede', role: UserRole.citizen, isVerified: false);
const _official = AppUser(uid: 'o1', fullName: 'Yetkili', role: UserRole.official, isVerified: true);
const _pending = AppUser(uid: 'o2', fullName: 'Onaysız', role: UserRole.official, isVerified: false);

RegisterInput _input(UserRole role) => RegisterInput(
      role: role,
      fullName: 'Yeni Kullanıcı',
      email: 'yeni@afetnet.demo',
      phone: '+905321234567',
      password: 'Abcdefg1',
      notificationsOptIn: true,
    );

void main() {
  late FakeAuthRepository repo;
  late AuthController auth;

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = FakeAuthRepository()
      ..users.addAll({'c1': _citizen, 'o1': _official, 'o2': _pending})
      ..passwords.addAll({'c@x.com': 'c1', 'o@x.com': 'o1', 'p@x.com': 'o2'});
    auth = AuthController(repo);
    repo.emit(null);
    await settle();
  });

  tearDown(() => auth.dispose());

  test('açılışta oturum yok → onboarding', () {
    expect(auth.isInitializing, isFalse);
    expect(appRedirect(auth, AppRoutes.splash), AppRoutes.onboarding);
  });

  test('onboarding tamamlanınca Giriş', () async {
    await auth.completeOnboarding();
    expect(appRedirect(auth, AppRoutes.onboarding), isNull);
    expect(appRedirect(auth, AppRoutes.home), AppRoutes.login);
  });

  test('afetzede girişi → Ana Sayfa, yetkili sekmeleri kapalı', () async {
    final ok = await auth.signIn(email: 'c@x.com', password: 'x', selectedRole: UserRole.citizen);
    expect(ok, isTrue);
    expect(appRedirect(auth, AppRoutes.login), AppRoutes.home);
    expect(appRedirect(auth, AppRoutes.liveFeed), AppRoutes.home);
    expect(appRedirect(auth, AppRoutes.whistle), isNull);
  });

  test('onaylı yetkili girişi → Canlı Akış', () async {
    await auth.signIn(email: 'o@x.com', password: 'x', selectedRole: UserRole.official);
    expect(appRedirect(auth, AppRoutes.home), AppRoutes.liveFeed);
  });

  test('seçilen tür rolle uyuşmazsa oturum kapatılır', () async {
    final ok = await auth.signIn(email: 'c@x.com', password: 'x', selectedRole: UserRole.official);
    expect(ok, isFalse);
    expect(auth.failure, AuthFailure.roleMismatch);
    expect(auth.currentUser, isNull);
    expect(repo.signOutCount, 1);
  });

  test('onaysız yetkili girişte oturum kapatılır', () async {
    final ok = await auth.signIn(email: 'p@x.com', password: 'x', selectedRole: UserRole.official);
    expect(ok, isFalse);
    expect(auth.failure, AuthFailure.pendingApproval);
    expect(auth.currentUser, isNull);
  });

  test('geri yüklenen onaysız yetkili oturumu kapatılır', () async {
    repo.emit('o2');
    await settle();
    await settle();
    expect(auth.currentUser, isNull);
    expect(auth.failure, AuthFailure.pendingApproval);
    expect(repo.signOutCount, 1);
  });

  test('afetzede kaydı → Ana Sayfa (erken oturum olayı yok sayılır)', () async {
    final ok = await auth.register(_input(UserRole.citizen));
    await settle();
    expect(ok, isTrue);
    expect(auth.currentUser?.role, UserRole.citizen);
    expect(appRedirect(auth, AppRoutes.register), AppRoutes.home);
  });

  test('yetkili kaydı onay bekler ve oturum kapatılır', () async {
    final ok = await auth.register(_input(UserRole.official));
    expect(ok, isFalse);
    expect(auth.failure, AuthFailure.pendingApproval);
    expect(auth.currentUser, isNull);
    expect(repo.signOutCount, 1);
  });

  test('hatalı şifre', () async {
    final ok = await auth.signIn(email: 'yok@x.com', password: 'x', selectedRole: UserRole.citizen);
    expect(ok, isFalse);
    expect(auth.failure, AuthFailure.invalidCredentials);
  });
}
