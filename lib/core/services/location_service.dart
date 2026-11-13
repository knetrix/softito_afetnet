// Konum alma, "Antakya, Hatay" gibi konum etiketi ve son konum önbelleği.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/permission_queue.dart';

/// Konum servisinin mevcut durumu (PROJECT_NEW.md §4 Kural 9).
enum LocationStatus {
  initial,
  fetching,
  ready,
  permissionDenied,
  serviceDisabled,
  unavailable,
}

/// Konum ve okunabilir etiket sonucu.
@immutable
class LocationSnapshot {
  const LocationSnapshot({
    required this.coordinates,
    this.label,
  });

  final LatLng coordinates;
  final String? label;
}

/// Konum ve konum etiketi servisi arayüzü.
/// Testlerde sahte sınıfla değiştirilebilmesi için soyuttur.
abstract class LocationService extends ChangeNotifier {
  LatLng? get currentPosition;
  String? get currentLabel;
  LocationStatus get status;
  bool get isFetching;

  /// Önbelleğe alınmış son konum etiketini yükler (varsa).
  Future<void> loadCached();

  /// Güncel konumu ve "İlçe, İl" etiketini yeniler.
  /// Konum alınamazsa [currentLabel] için uydurma değer üretmez (`null` veya
  /// son bilinen önbellek etiketi korunur).
  Future<LocationSnapshot?> refresh();

  /// Panik sinyali / yardım çağrısı için koordinat döndürür. Yakın zamanda
  /// alınmış konum varsa beklemeden onu verir; adres (geocoding) çözmez.
  Future<LatLng?> resolveCoordinates();
}

/// Cihaz GPS + `geocoding` + `SharedPreferences` önbelleğini kullanan uygulama.
class DeviceLocationService extends LocationService {
  DeviceLocationService({
    this._prefs,
    Future<SharedPreferences> Function()? prefsLoader,
    LocationGateway? gateway,
    this._positionTimeout = const Duration(seconds: 6),
    this._freshFor = const Duration(minutes: 2),
    DateTime Function()? clock,
  })  : _prefsLoader = prefsLoader ?? SharedPreferences.getInstance,
        _gateway = gateway ?? const GeolocatorLocationGateway(),
        _clock = clock ?? DateTime.now;

  static const cacheLabelKey = 'lastKnownLocationLabel';
  static const cacheLatKey = 'lastKnownLat';
  static const cacheLngKey = 'lastKnownLng';

  SharedPreferences? _prefs;
  final Future<SharedPreferences> Function() _prefsLoader;
  final LocationGateway _gateway;
  final Duration _positionTimeout;
  final Duration _freshFor;
  final DateTime Function() _clock;

  LatLng? _currentPosition;
  // Bu oturumda GPS'ten alınan son konumun zamanı (önbellekten gelen konumda `null`).
  DateTime? _positionAt;
  String? _currentLabel;
  LocationStatus _status = LocationStatus.initial;
  bool _isFetching = false;
  bool _disposed = false;
  Future<LocationSnapshot?>? _inFlightRefresh;

  // Son alınan konum (koordinat).
  @override
  LatLng? get currentPosition => _currentPosition;

  // Son konum etiketi (ör. "Antakya, Hatay").
  @override
  String? get currentLabel => _currentLabel;

  // Konum servisinin şu anki durumu.
  @override
  LocationStatus get status => _status;

  // Konum şu an alınıyor mu.
  @override
  bool get isFetching => _isFetching;

  /// `Placemark` alanlarından "İlçe, İl" biçiminde etiket üretir.
  static String? formatPlacemarkLabel({
    String? subAdministrativeArea,
    String? locality,
    String? administrativeArea,
  }) {
    final district = _cleanPart(subAdministrativeArea) ?? _cleanPart(locality);
    final city = _cleanPart(administrativeArea);

    if (district != null && city != null) {
      if (district.toLowerCase() == city.toLowerCase()) return city;
      return '$district, $city';
    }
    return district ?? city;
  }

  // Adres parçasını temizler; boşsa null döner.
  static String? _cleanPart(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  // SharedPreferences örneğini (bir kez) getirir.
  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await _prefsLoader();

  // Önbellekteki son konumu ve etiketi yükler.
  @override
  Future<void> loadCached() async {
    try {
      final prefs = await _getPrefs();
      final cachedLabel = prefs.getString(cacheLabelKey);
      final cachedLat = prefs.getDouble(cacheLatKey);
      final cachedLng = prefs.getDouble(cacheLngKey);

      var changed = false;
      if (_currentLabel == null &&
          cachedLabel != null &&
          cachedLabel.trim().isNotEmpty) {
        _currentLabel = cachedLabel;
        changed = true;
      }
      if (_currentPosition == null && cachedLat != null && cachedLng != null) {
        _currentPosition = LatLng(cachedLat, cachedLng);
        changed = true;
      }
      if (changed) _notify();
    } catch (_) {
      // Önbellek okunamasa da akışı bozmaz.
    }
  }

  // Konumu yeniler; süren bir istek varsa onu bekler.
  @override
  Future<LocationSnapshot?> refresh() {
    return _inFlightRefresh ??= _performRefresh().whenComplete(() {
      _inFlightRefresh = null;
    });
  }

  // Asıl konum yenileme: izin, koordinat, etiket ve önbellek.
  Future<LocationSnapshot?> _performRefresh() async {
    _isFetching = true;
    _status = LocationStatus.fetching;
    _notify();

    try {
      await loadCached();

      final coords = await _fetchCoordinates();
      if (coords == null) {
        _isFetching = false;
        _notify();
        if (_status == LocationStatus.permissionDenied ||
            _currentPosition == null) {
          return null;
        }
        return LocationSnapshot(
          coordinates: _currentPosition!,
          label: _currentLabel,
        );
      }

      String? label;
      try {
        label = await _gateway
            .resolveAddressLabel(coords.latitude, coords.longitude)
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        // İnternet yoksa veya geocoding başarısızsa son bilinen etiket korunur (Kural 9).
      }

      if (label != null && label.isNotEmpty) {
        _currentLabel = label;
      }

      await _saveCache(coords, _currentLabel);

      _status = LocationStatus.ready;
      _isFetching = false;
      _notify();
      return LocationSnapshot(coordinates: coords, label: _currentLabel);
    } catch (_) {
      _status = LocationStatus.unavailable;
      _isFetching = false;
      _notify();
      return null;
    }
  }

  // Yalnızca koordinatı döndürür (etiket gerekmeyen yerler için).
  @override
  Future<LatLng?> resolveCoordinates() async {
    final at = _positionAt;
    if (_currentPosition != null &&
        at != null &&
        _clock().difference(at) < _freshFor) {
      return _currentPosition;
    }
    // Panikte adres beklenmez; Kural 8'in 10 sn'si konum alındıktan sonra başlar.
    try {
      final coords = await _fetchCoordinates();
      if (coords != null) {
        _status = LocationStatus.ready;
        unawaited(_saveCache(coords, _currentLabel));
      }
    } catch (_) {
      _status = LocationStatus.unavailable;
    }
    _notify();
    return _currentPosition;
  }

  /// Servis, izin ve GPS kontrolü yapar; adres çözmez. Konum alınamazsa
  /// [_status]'u günceller ve `null` döner.
  Future<LatLng?> _fetchCoordinates() async {
    if (!await _gateway.isLocationServiceEnabled()) {
      _status = LocationStatus.serviceDisabled;
      return null;
    }

    var permission = await _gateway.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _gateway.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _status = LocationStatus.permissionDenied;
      return null;
    }

    LatLng? coords;
    try {
      coords = await _gateway.getCurrentPosition().timeout(_positionTimeout);
    } catch (_) {
      coords = await _gateway.getLastKnownPosition();
    }

    if (coords == null) {
      _status = LocationStatus.unavailable;
      return null;
    }
    _currentPosition = coords;
    _positionAt = _clock();
    return coords;
  }

  // Konumu ve etiketi cihaza kaydeder (internetsiz gösterim için).
  Future<void> _saveCache(LatLng coords, String? label) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setDouble(cacheLatKey, coords.latitude);
      await prefs.setDouble(cacheLngKey, coords.longitude);
      if (label != null && label.isNotEmpty) {
        await prefs.setString(cacheLabelKey, label);
      }
    } catch (_) {
      // Önbellek yazma hatası konumu engellemez.
    }
  }

  // Dinleyicilere değişikliği haber verir (kapanmadıysa).
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // Kapanırken dinleyicileri ve kaynakları serbest bırakır.
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Platform konum ve ters coğrafi kodlama geçidi (test edilebilirlik için).
abstract interface class LocationGateway {
  // Cihazda konum servisi açık mı.
  Future<bool> isLocationServiceEnabled();
  // Konum izninin mevcut durumu.
  Future<LocationPermission> checkPermission();
  // Kullanıcıdan konum izni ister.
  Future<LocationPermission> requestPermission();
  // Anlık konumu alır.
  Future<LatLng> getCurrentPosition();
  // Cihazın bildiği son konumu alır.
  Future<LatLng?> getLastKnownPosition();
  // Koordinattan okunur konum etiketi üretir.
  Future<String?> resolveAddressLabel(double latitude, double longitude);
}

// Gerçek cihaz konumunu geolocator ve geocoding paketleriyle sağlar.
class GeolocatorLocationGateway implements LocationGateway {
  const GeolocatorLocationGateway();

  // Cihazda konum servisi açık mı.
  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  // Konum izninin mevcut durumu.
  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  // Konum iznini, izin kuyruğu üzerinden ister.
  @override
  Future<LocationPermission> requestPermission() =>
      PermissionQueue.run(Geolocator.requestPermission);

  // Yüksek doğrulukla anlık konumu alır.
  @override
  Future<LatLng> getCurrentPosition() async {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  // Cihazın bildiği son konumu alır.
  @override
  Future<LatLng?> getLastKnownPosition() async {
    final pos = await Geolocator.getLastKnownPosition();
    if (pos == null) return null;
    return LatLng(pos.latitude, pos.longitude);
  }

  // Koordinattan "İlçe, İl" etiketini bulur.
  @override
  Future<String?> resolveAddressLabel(double latitude, double longitude) async {
    final placemarks =
        await Geocoding().placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) return null;
    final p = placemarks.first;
    return DeviceLocationService.formatPlacemarkLabel(
      subAdministrativeArea: p.subAdministrativeArea,
      locality: p.locality,
      administrativeArea: p.administrativeArea,
    );
  }
}

