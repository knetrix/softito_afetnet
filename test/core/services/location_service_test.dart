import 'dart:async';

import 'package:afetnet/core/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLocationGateway implements LocationGateway {
  bool serviceEnabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  LocationPermission requestedPermission = LocationPermission.whileInUse;
  Future<LatLng> Function()? onGetCurrent;
  LatLng? lastKnown;
  String? Function(double lat, double lng)? onResolveLabel;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async => requestedPermission;

  @override
  Future<LatLng> getCurrentPosition() =>
      onGetCurrent != null ? onGetCurrent!() : Future.value(const LatLng(36.2, 36.16));

  @override
  Future<LatLng?> getLastKnownPosition() async => lastKnown;

  @override
  Future<String?> resolveAddressLabel(double latitude, double longitude) async =>
      onResolveLabel?.call(latitude, longitude);
}

void main() {
  group('LocationService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('formatPlacemarkLabel İlçe, İl biçimini üretir ve tekrarı önler', () {
      expect(
        DeviceLocationService.formatPlacemarkLabel(
          subAdministrativeArea: 'Antakya',
          administrativeArea: 'Hatay',
        ),
        'Antakya, Hatay',
      );
      expect(
        DeviceLocationService.formatPlacemarkLabel(
          subAdministrativeArea: 'Hatay',
          administrativeArea: 'Hatay',
        ),
        'Hatay',
      );
      expect(
        DeviceLocationService.formatPlacemarkLabel(
          locality: 'Defne',
          administrativeArea: 'Hatay',
        ),
        'Defne, Hatay',
      );
      expect(
        DeviceLocationService.formatPlacemarkLabel(),
        isNull,
      );
    });

    test('refresh konumu alır, etiketi üretir ve önbelleğe kaydeder', () async {
      final gateway = _FakeLocationGateway()
        ..onResolveLabel = (_, _) => 'Antakya, Hatay';
      final service = DeviceLocationService(gateway: gateway);
      addTearDown(service.dispose);

      final snap = await service.refresh();
      expect(snap, isNotNull);
      expect(snap!.label, 'Antakya, Hatay');
      expect(service.currentLabel, 'Antakya, Hatay');
      expect(service.status, LocationStatus.ready);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(DeviceLocationService.cacheLabelKey),
        'Antakya, Hatay',
      );
    });

    test('geocoding başarısız olursa önbellekteki son etiketi korur', () async {
      SharedPreferences.setMockInitialValues({
        DeviceLocationService.cacheLabelKey: 'Defne, Hatay',
        DeviceLocationService.cacheLatKey: 36.21,
        DeviceLocationService.cacheLngKey: 36.15,
      });

      final gateway = _FakeLocationGateway()
        ..onResolveLabel = (_, _) => throw Exception('offline');
      final service = DeviceLocationService(gateway: gateway);
      addTearDown(service.dispose);

      final snap = await service.refresh();
      expect(snap, isNotNull);
      expect(service.currentLabel, 'Defne, Hatay');
    });

    test('getCurrentPosition zaman aşımında getLastKnownPosition kullanır', () async {
      final gateway = _FakeLocationGateway();
      gateway.onGetCurrent = () => Completer<LatLng>().future;
      gateway.lastKnown = const LatLng(36.202, 36.161);
      gateway.onResolveLabel = (_, _) => 'Antakya, Hatay';
      final service = DeviceLocationService(
        gateway: gateway,
        positionTimeout: const Duration(milliseconds: 20),
      );
      addTearDown(service.dispose);

      final snap = await service.refresh();
      expect(snap?.coordinates, const LatLng(36.202, 36.161));
      expect(service.currentLabel, 'Antakya, Hatay');
    });

    test('izin reddedilirse sahte etiket üretmeden null döner', () async {
      final gateway = _FakeLocationGateway()
        ..permission = LocationPermission.denied
        ..requestedPermission = LocationPermission.denied;
      final service = DeviceLocationService(gateway: gateway);
      addTearDown(service.dispose);

      final snap = await service.refresh();
      expect(snap, isNull);
      expect(service.currentLabel, isNull);
      expect(service.status, LocationStatus.permissionDenied);
    });
  });
}

