// Oturum ve rol durumu; router yönlendirmesi bunu dinler.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/user_role.dart';
import '../domain/app_user.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';

/// Oturum, rol ve onboarding durumu. Router `refreshListenable` olarak dinler.
///
/// Rol kontrolü iki yerde yapılır (§2): [signIn] içinde ve uygulama açılırken
/// geri yüklenen oturumda ([_onUidChanged]). Onaysız yetkili ve profili
/// olmayan hesap her iki durumda da oturumdan çıkarılır.
class AuthController extends ChangeNotifier {
  AuthController(this._repo) {
    _init();
  }

  static const onboardingDoneKey = 'onboardingDone';

  final AuthRepository _repo;
  StreamSubscription<String?>? _sub;
  bool _disposed = false;

  // signIn/register sırasında Firebase'in yaydığı oturum olayları yok sayılır;
  // sonucu işlemi yapan metot belirler. Her işlem sayacı artırır, böylece
  // işlemden önce başlamış bir geri yükleme sonucu da üzerine yazmaz.
  int _generation = 0;
  bool _actionInProgress = false;
  // Yalnızca en son oturum olayının sonucu uygulanır (geç gelen fetch eskiyi yazmaz).
  int _eventSeq = 0;

  bool _authResolved = false;
  bool _prefsLoaded = false;
  bool get isInitializing => !_authResolved || !_prefsLoaded;

  bool _onboardingDone = false;
  bool get onboardingDone => _onboardingDone;

  AppUser? _user;
  AppUser? get currentUser => _user;

  bool _busy = false;
  bool get isBusy => _busy;

  AuthFailure? _failure;
  AuthFailure? get failure => _failure;

  void _init() {
    SharedPreferences.getInstance().then((prefs) {
      _onboardingDone = prefs.getBool(onboardingDoneKey) ?? false;
    }).whenComplete(() {
      _prefsLoaded = true;
      _notify();
    });
    _sub = _repo.uidChanges().listen(
      _onUidChanged,
      onError: (Object _) {
        _authResolved = true;
        _notify();
      },
    );
  }

  Future<void> _onUidChanged(String? uid) async {
    final seq = ++_eventSeq;
    if (_actionInProgress) return;
    final gen = _generation;

    AppUser? user;
    AuthFailure? failure;
    var mustSignOut = false;
    if (uid != null) {
      try {
        user = await _repo.fetchUser(uid);
        failure = _check(user);
        mustSignOut = failure != null;
      } on AuthException catch (e) {
        // Profil okunamadı (ör. bağlantı yok): oturum kapatılmaz.
        failure = e.failure;
      }
      if (failure != null) user = null;
    }

    if (_disposed || seq != _eventSeq || gen != _generation || _actionInProgress) return;
    _user = user;
    // Profili olmayan geri yüklenmiş oturum (ör. silinmiş hesap; iOS oturumu
    // uygulama silinse de saklar) sessizce kapatılır, yeni kullanıcıya hata
    // gösterilmez.
    if (failure != null && failure != AuthFailure.profileMissing) {
      _failure = failure;
    }
    _authResolved = true;
    _notify();
    if (mustSignOut) await _repo.signOut();
  }

  /// [selectedRole]: Giriş ekranındaki "Giriş Türü". Yetkiyi her zaman
  /// veritabanındaki rol belirler; uyuşmazsa oturum kapatılır.
  Future<bool> signIn({
    required String email,
    required String password,
    required UserRole selectedRole,
  }) {
    return _run(() async {
      final uid = await _repo.signIn(email: email, password: password);
      final AppUser? user;
      try {
        user = await _repo.fetchUser(uid);
      } catch (_) {
        await _repo.signOut();
        rethrow;
      }
      final failure = _check(user, selectedRole: selectedRole);
      if (failure != null) {
        await _repo.signOut();
        throw AuthException(failure);
      }
      return user;
    });
  }

  /// Yetkili hesabı onaysız açılır: kayıt başarılı olsa da oturum kapatılır ve
  /// [failure] `pendingApproval` olur.
  Future<bool> register(RegisterInput input) {
    return _run(() async {
      final user = await _repo.register(input);
      if (user.isPendingApproval) {
        await _repo.signOut();
        throw const AuthException(AuthFailure.pendingApproval);
      }
      return user;
    });
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _repo.sendPasswordReset(email);
      return true;
    } on AuthException catch (e) {
      _failure = e.failure;
      _notify();
      return false;
    }
  }

  Future<void> signOut() {
    return _run(() async {
      await _repo.signOut();
      return null;
    });
  }

  Future<void> completeOnboarding() async {
    _onboardingDone = true;
    _notify();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingDoneKey, true);
  }

  void clearFailure() {
    if (_failure == null) return;
    _failure = null;
    _notify();
  }

  AuthFailure? _check(AppUser? user, {UserRole? selectedRole}) {
    if (user == null) return AuthFailure.profileMissing;
    if (selectedRole != null && user.role != selectedRole) {
      return AuthFailure.roleMismatch;
    }
    if (user.isPendingApproval) return AuthFailure.pendingApproval;
    return null;
  }

  /// Başarılıysa `true`; hata [failure]'a yazılır.
  Future<bool> _run(Future<AppUser?> Function() action) async {
    _generation++;
    _actionInProgress = true;
    _busy = true;
    _failure = null;
    _notify();
    try {
      _user = await action();
      return true;
    } on AuthException catch (e) {
      _user = null;
      _failure = e.failure;
      return false;
    } catch (_) {
      _user = null;
      _failure = AuthFailure.unknown;
      return false;
    } finally {
      _actionInProgress = false;
      _busy = false;
      _authResolved = true;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}
