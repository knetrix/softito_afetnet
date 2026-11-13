// Profil ekranının durumu ve kaydetme işlemleri.

import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../auth/domain/auth_failure.dart';
import '../domain/profile_repository.dart';
import '../domain/user_contact_profile.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    required this.repository,
    required this.uid,
  }) {
    _subscription = repository.watchProfile(uid).listen(
      (data) {
        _profile = data;
        _isLoading = false;
        _safeNotify();
      },
      onError: (Object err) {
        _error = err.toString();
        _isLoading = false;
        _safeNotify();
      },
    );
  }

  final ProfileRepository repository;
  final String uid;
  StreamSubscription<UserContactProfile?>? _subscription;

  UserContactProfile? _profile;
  UserContactProfile? get profile => _profile;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _disposed = false;

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> updateMedicalInfo({
    required String bloodType,
    required String medications,
    required String conditions,
    required DateTime consentAt,
  }) async {
    try {
      _isLoading = true;
      _safeNotify();
      await repository.updateMedicalInfo(
        uid,
        bloodType: bloodType,
        medications: medications,
        conditions: conditions,
        consentAt: consentAt,
      );
      _isLoading = false;
      _safeNotify();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotify();
      return false;
    }
  }

  Future<bool> updatePhysicalInfo({
    required int? birthYear,
    required int? weightKg,
  }) async {
    try {
      _isLoading = true;
      _safeNotify();
      await repository.updatePhysicalInfo(
        uid,
        birthYear: birthYear,
        weightKg: weightKg,
      );
      _isLoading = false;
      _safeNotify();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotify();
      return false;
    }
  }

  Future<bool> updateEmergencyContact({
    required String name,
    required String relation,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      _safeNotify();
      await repository.updateEmergencyContact(
        uid,
        name: name,
        relation: relation,
        phone: phone,
      );
      _isLoading = false;
      _safeNotify();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotify();
      return false;
    }
  }

  Future<bool> updateAddress({
    required String addressText,
  }) async {
    try {
      _isLoading = true;
      _safeNotify();
      await repository.updateAddress(uid, addressText: addressText);
      _isLoading = false;
      _safeNotify();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotify();
      return false;
    }
  }

  AuthFailure? _deleteFailure;

  /// Son Hesabı Sil denemesinin hatası (yanlış şifre, bağlantı …).
  AuthFailure? get deleteFailure => _deleteFailure;

  /// Başarılıysa `true`; Auth hesabı silinince router kullanıcıyı Giriş'e götürür.
  Future<bool> deleteAccount({required String password}) async {
    _deleteFailure = null;
    try {
      _isLoading = true;
      _safeNotify();
      await repository.deleteAccount(uid, password: password);
      return true;
    } on AuthException catch (e) {
      _deleteFailure = e.failure;
      return false;
    } catch (e) {
      _deleteFailure = AuthFailure.unknown;
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  final _teamNames = <String, Future<String?>>{};

  /// Y4 "Bağlı Ekip": `teams/{teamId}.name`; build her çalıştığında yeniden okunmaz.
  Future<String?> teamName(String teamId) => _teamNames.putIfAbsent(
        teamId,
        () => repository.getTeamName(teamId).catchError((Object _) => null),
      );

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
