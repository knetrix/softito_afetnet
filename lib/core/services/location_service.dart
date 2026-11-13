// Konumla ilgili her şey: GPS'ten koordinat alma, izin isteme,
// "Antakya, Hatay" gibi okunur konum etiketi ve internetsizken gösterilecek son konumun önbelleği.

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

  // En son alınan konum (enlem/boylam). Henüz alınmadıysa null.
  @override
  LatLng? get currentPosition => _currentPosition;

  // En son konum etiketi, ör. "Antakya, Hatay". Henüz bulunamadıysa null.
  @override
  String? get currentLabel => _currentLabel;

  // Konum servisinin şu anki durumu (alınıyor, hazır, izin yok…).
  @override
  LocationStatus get status => _status;

  // Konum şu an alınıyor mu? (Ekranda yükleniyor göstermek için.)
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

  // Adresin bir parçasını temizler (baş/son boşlukları siler); boşsa null döndürür.
  static String? _cleanPart(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  // Cihazdaki küçük kayıt deposunu (SharedPreferences) getirir; bir kez açar, sonra aynısını kullanır.
  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await _prefsLoader();

  // Daha önce cihaza kaydedilmiş son konumu ve etiketi yükler.
  // İnternet yokken bile ekranda bir konum gösterebilmek için.
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

  // Konumu yeniler. Zaten süren bir yenileme varsa ikincisini başlatmaz, aynı sonucu bekler.
  @override
  Future<LocationSnapshot?> refresh() {
    return _inFlightRefresh ??= _performRefresh().whenComplete(() {
      _inFlightRefresh = null;
    });
  }

  // Asıl konum yenileme adımları: 1) izin kontrolü 2) koordinatı al
  // 3) koordinattan etiketi bul 4) sonucu cihaza kaydet ve ekranlara haber ver.
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

  // Yalnızca koordinatı döndürür; etikete gerek olmayan yerlerde (ör. çağrı gönderirken) kullanılır.
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

  // Konumu ve etiketi cihaza kaydeder; uygulama tekrar açıldığında hemen gösterilebilsin.
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

  // Dinleyen ekranlara "konum değişti" haberini verir (servis kapanmadıysa).
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Platform konum ve ters coğrafi kodlama geçidi (test edilebilirlik için).
abstract interface class LocationGateway {
  // Cihazın konum servisi (GPS) açık mı?
  Future<bool> isLocationServiceEnabled();
  // Uygulamanın konum izni ne durumda? (verildi / reddedildi / hiç sorulmadı)
  Future<LocationPermission> checkPermission();
  // Kullanıcıya konum izni penceresini gösterir.
  Future<LocationPermission> requestPermission();
  // Cihazın şu anki konumunu alır.
  Future<LatLng> getCurrentPosition();
  // Cihazın en son bildiği konumu alır (yeni ölçüm yapmadan, hızlıdır).
  Future<LatLng?> getLastKnownPosition();
  // Koordinattan "İlçe, İl" gibi okunur bir etiket üretir.
  Future<String?> resolveAddressLabel(double latitude, double longitude);
}

// LocationGateway arayüzünün gerçek cihazda çalışan hâli.
// geolocator paketiyle GPS'ten konum alır, geocoding paketiyle adresi bulur.
class GeolocatorLocationGateway implements LocationGateway {
  const GeolocatorLocationGateway();

  // Cihazın konum servisi (GPS) açık mı?
  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  // Uygulamanın konum izni ne durumda?
  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  // Konum iznini ister. İzin kuyruğu kullanılır çünkü Android aynı anda iki izin penceresi göstermez.
  @override
  Future<LocationPermission> requestPermission() =>
      PermissionQueue.run(Geolocator.requestPermission);

  // Yüksek doğrulukla (GPS) anlık konumu alır ve LatLng (enlem/boylam) olarak döndürür.
  @override
  Future<LatLng> getCurrentPosition() async {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  // Cihazın en son bildiği konumu alır; hiç yoksa null.
  @override
  Future<LatLng?> getLastKnownPosition() async {
    final pos = await Geolocator.getLastKnownPosition();
    if (pos == null) return null;
    return LatLng(pos.latitude, pos.longitude);
  }

  // Koordinattan adres bulur (reverse geocoding) ve "İlçe, İl" etiketine çevirir.
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

