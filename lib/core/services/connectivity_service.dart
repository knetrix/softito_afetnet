// Cihazın bir ağa (Wi-Fi / mobil veri) bağlı olup olmadığını izleyen servis.
// Not: ağa bağlı olmak internetin çalıştığı anlamına gelmez; asıl kontrol sunucu onayıyla yapılır.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Ağ arayüzü durumunu izleyen servis arayüzü.
///
/// Not: Bu servis yalnızca cihazdaki ağ arayüzü
/// değişimini bildirir. "Çevrimiçi" kesin kararı Firestore
/// sunucu onayıyla (`hasPendingWrites == false`) verilir.
abstract class ConnectivityService extends ChangeNotifier {
  bool get hasNetworkInterface;
  Stream<bool> get onNetworkChanged;

  // Bağlantıyı dinlemeye başlar (uygulama açılışında bir kez çağrılır).
  Future<void> initialize();
  // Cihaz şu an bir ağa bağlı mı? Sonucu Future ile (biraz sonra) döndürür.
  Future<bool> checkNetworkInterface();
}

/// `connectivity_plus` tabanlı cihaz ağ durumu servisi.
class DeviceConnectivityService extends ConnectivityService {
  DeviceConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  bool _hasNetworkInterface = true;
  bool _initialized = false;
  bool _disposed = false;

  // En son öğrenilen bağlantı durumu (true = bir ağa bağlı).
  @override
  bool get hasNetworkInterface => _hasNetworkInterface;

  // Bağlantı her değiştiğinde yeni değeri yayınlayan akış (Stream).
  // Ekranlar bu akışı dinleyerek internet gelince/gidince tepki verir.
  @override
  Stream<bool> get onNetworkChanged => _changes.stream;

  // Önce mevcut durumu okur, sonra connectivity_plus paketinden gelen değişiklikleri dinlemeye başlar.
  @override
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await checkNetworkInterface();
      _sub = _connectivity.onConnectivityChanged.listen(_handleResults);
    } catch (_) {
      // Platform eklentisi desteklenmiyorsa varsayılan değer korunur.
    }
  }

  // Bağlantı durumunu o anda bir kez sorar (dinleme yapmaz).
  @override
  Future<bool> checkNetworkInterface() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _handleResults(results);
    } catch (_) {
      // Hata durumunda mevcut durum korunur.
    }
    return _hasNetworkInterface;
  }

  // Paketten gelen sonucu "bağlı / bağlı değil" bilgisine çevirir ve değiştiyse dinleyicilere haber verir.
  void _handleResults(List<ConnectivityResult> results) {
    final next = results.any((r) => r != ConnectivityResult.none);
    if (next == _hasNetworkInterface) return;
    _hasNetworkInterface = next;
    if (!_changes.isClosed) _changes.add(next);
    if (!_disposed) notifyListeners();
  }

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _changes.close();
    super.dispose();
  }
}

