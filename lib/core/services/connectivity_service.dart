import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Ağ arayüzü durumunu izleyen servis arayüzü.
///
/// Not (PROJECT_NEW.md §9 R8): Bu servis yalnızca cihazdaki ağ arayüzü
/// değişimini bildirir. "Çevrimiçi" kesin kararı Kural 8'deki Firestore
/// sunucu onayıyla (`hasPendingWrites == false`) verilir.
abstract class ConnectivityService extends ChangeNotifier {
  bool get hasNetworkInterface;
  Stream<bool> get onNetworkChanged;

  Future<void> initialize();
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

  @override
  bool get hasNetworkInterface => _hasNetworkInterface;

  @override
  Stream<bool> get onNetworkChanged => _changes.stream;

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

  void _handleResults(List<ConnectivityResult> results) {
    final next = results.any((r) => r != ConnectivityResult.none);
    if (next == _hasNetworkInterface) return;
    _hasNetworkInterface = next;
    if (!_changes.isClosed) _changes.add(next);
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _changes.close();
    super.dispose();
  }
}

