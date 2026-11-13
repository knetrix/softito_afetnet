// Panik akışını yöneten controller: konumu alır, sinyali gönderir, sunucu onayını bekler.
// İnternet yoksa SMS köprüsü için acil durum yakınının numarasını ve konumu hazırlar.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/location_service.dart';
import '../../profile/domain/profile_repository.dart';
import '../domain/safety_signal.dart';
import '../domain/safety_signal_repository.dart';

// Panik hata türleri: konum yok, gönderilemedi.
enum SafetySignalError { locationUnavailable, sendFailed }

// PANİĞİM sonucu: iletildi, çevrimdışı bekliyor, konum yok, başarısız.
enum PanicTriggerOutcome { confirmed, pendingOffline, locationUnavailable, failed }

// SMS köprüsü hedefi: acil durum yakınının telefonu ve konum.
@immutable
class EmergencySmsTarget {
  const EmergencySmsTarget({
    required this.phone,
    this.coordinates,
  });

  final String phone;
  final LatLng? coordinates;
}

/// Panik sinyali (`safety_signals/{uid}`) ekran ve işlem yöneticisi.
class SafetySignalController extends ChangeNotifier {
  SafetySignalController({
    required SafetySignalRepository repository,
    required LocationService locationService,
    required ProfileRepository profileRepository,
    required this.uid,
  })  : _repo = repository,
        _location = locationService,
        _profileRepo = profileRepository {
    _sub = _repo.watchSignal(uid).listen(
      (data) {
        _signal = data;
        if (data != null && data.isDanger) {
          _lastDelivery = data.hasPendingWrites
              ? SignalDelivery.pending
              : SignalDelivery.confirmed;
        } else if (data != null && !data.isDanger) {
          _lastDelivery = null;
        }
        _notify();
      },
      onError: (Object _) {
        // Akış geçici hata verirse mevcut yerel durum korunur.
      },
    );
  }

  final SafetySignalRepository _repo;
  final LocationService _location;
  final ProfileRepository _profileRepo;
  final String uid;

  StreamSubscription<SafetySignal?>? _sub;
  bool _disposed = false;

  SafetySignal? _signal;
  // Kullanıcının mevcut sinyali.
  SafetySignal? get signal => _signal;

  // TEHLİKEDEYİM sinyali açık mı.
  bool get isDangerActive => _signal?.isDanger ?? false;

  SignalDelivery? _lastDelivery;
  // Açık sinyalin iletim durumu (iletildi / bekliyor).
  SignalDelivery? get delivery => isDangerActive
      ? (_signal!.hasPendingWrites
          ? SignalDelivery.pending
          : SignalDelivery.confirmed)
      : _lastDelivery;

  bool _busy = false;
  // Bir işlem sürüyor mu.
  bool get isBusy => _busy;

  SafetySignalError? _error;
  // Son hata.
  SafetySignalError? get error => _error;

  LatLng? _lastPanicCoordinates;
  // Son panik sinyalinin koordinatı (SMS linki için).
  LatLng? get lastPanicCoordinates =>
      _lastPanicCoordinates ?? _signal?.location ?? _location.currentPosition;

  // Hatayı temizler.
  void clearError() {
    if (_error == null) return;
    _error = null;
    _notify();
  }

  /// 2 sn basılı tutma tamamlandığında çağrılır.
  /// Konum alınamazsa buton asılı kalmaz, `locationUnavailable` döner.
  Future<PanicTriggerOutcome> triggerDanger() async {
    if (_busy) return PanicTriggerOutcome.failed;
    _busy = true;
    _error = null;
    _notify();

    try {
      final coords = await _location.resolveCoordinates();
      if (coords == null) {
        _error = SafetySignalError.locationUnavailable;
        return PanicTriggerOutcome.locationUnavailable;
      }

      _lastPanicCoordinates = coords;
      final result = await _repo.sendDanger(
        uid,
        coords.latitude,
        coords.longitude,
      );
      _lastDelivery = result;
      return result == SignalDelivery.confirmed
          ? PanicTriggerOutcome.confirmed
          : PanicTriggerOutcome.pendingOffline;
    } catch (_) {
      _error = SafetySignalError.sendFailed;
      return PanicTriggerOutcome.failed;
    } finally {
      _busy = false;
      _notify();
    }
  }

  /// Sinyal açıkken `GÜVENDEYİM` ile kapatır.
  Future<bool> markSafe() async {
    if (_busy) return false;
    _busy = true;
    _error = null;
    _notify();

    try {
      await _repo.sendSafe(uid);
      _lastDelivery = null;
      return true;
    } catch (_) {
      _error = SafetySignalError.sendFailed;
      return false;
    } finally {
      _busy = false;
      _notify();
    }
  }

  /// Acil durum yakınının telefonunu (`+905XXXXXXXXX`) ve son konumu okur.
  Future<EmergencySmsTarget?> loadEmergencySmsTarget() async {
    try {
      final profile = await _profileRepo.getProfile(uid);
      final phone = profile?.emergencyContactPhone?.trim();
      if (phone == null || phone.isEmpty) return null;
      return EmergencySmsTarget(
        phone: phone,
        coordinates: lastPanicCoordinates,
      );
    } catch (_) {
      return null;
    }
  }

  // Kapanmadıysa dinleyicilere haber verir.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}

