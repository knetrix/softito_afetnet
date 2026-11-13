// Panik sinyali repository arayüzü.

import 'safety_signal.dart';

/// Panik sinyali (`safety_signals/{uid}`) repository arayüzü.
abstract interface class SafetySignalRepository {
  /// Kullanıcının son sinyal durumunu canlı (`includeMetadataChanges: true`) izler.
  Stream<SafetySignal?> watchSignal(String uid);

  /// `TEHLİKEDEYİM` sinyali yazar ve 10 sn içinde sunucu onayını bekler (Kural 8).
  Future<SignalDelivery> sendDanger(
    String uid,
    double latitude,
    double longitude,
  );

  /// `GÜVENDEYİM` ile sinyali kapatır (T8).
  Future<void> sendSafe(String uid);
}

