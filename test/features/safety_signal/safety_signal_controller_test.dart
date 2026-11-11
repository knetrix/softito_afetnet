import 'dart:async';

import 'package:afetnet/core/services/location_service.dart';
import 'package:afetnet/features/profile/domain/profile_repository.dart';
import 'package:afetnet/features/profile/domain/user_contact_profile.dart';
import 'package:afetnet/features/safety_signal/domain/safety_signal.dart';
import 'package:afetnet/features/safety_signal/domain/safety_signal_repository.dart';
import 'package:afetnet/features/safety_signal/presentation/safety_signal_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class _FakeSafetySignalRepository implements SafetySignalRepository {
  final controller = StreamController<SafetySignal?>.broadcast();
  SignalDelivery nextDelivery = SignalDelivery.confirmed;
  int dangerCalls = 0;
  int safeCalls = 0;

  @override
  Stream<SafetySignal?> watchSignal(String uid) => controller.stream;

  @override
  Future<SignalDelivery> sendDanger(
    String uid,
    double latitude,
    double longitude,
  ) async {
    dangerCalls++;
    controller.add(
      SafetySignal(
        uid: uid,
        state: SafetySignalState.danger,
        location: LatLng(latitude, longitude),
        geohash: 'sy72wxyz',
        updatedAt: DateTime.now(),
        hasPendingWrites: nextDelivery == SignalDelivery.pending,
      ),
    );
    return nextDelivery;
  }

  @override
  Future<void> sendSafe(String uid) async {
    safeCalls++;
    controller.add(
      SafetySignal(
        uid: uid,
        state: SafetySignalState.safe,
        location: const LatLng(36.2, 36.16),
        geohash: 'sy72wxyz',
        updatedAt: DateTime.now(),
      ),
    );
  }
}

class _FakeLocationService extends LocationService {
  LatLng? coords = const LatLng(36.202, 36.161);
  String? label = 'Antakya, Hatay';

  @override
  LatLng? get currentPosition => coords;

  @override
  String? get currentLabel => label;

  @override
  LocationStatus get status =>
      coords == null ? LocationStatus.unavailable : LocationStatus.ready;

  @override
  bool get isFetching => false;

  @override
  Future<void> loadCached() async {}

  @override
  Future<LocationSnapshot?> refresh() async =>
      coords == null ? null : LocationSnapshot(coordinates: coords!, label: label);

  @override
  Future<LatLng?> resolveCoordinates() async => coords;
}

class _FakeProfileRepository implements ProfileRepository {
  UserContactProfile? profile;

  @override
  Future<UserContactProfile?> getProfile(String uid) async => profile;

  @override
  Stream<UserContactProfile?> watchProfile(String uid) =>
      Stream.value(profile);

  @override
  Future<void> deleteAccount(String uid, {required String password}) async {}

  @override
  Future<String?> getTeamName(String teamId) async => null;

  @override
  Future<void> updateAddress(String uid, {required String addressText}) async {}

  @override
  Future<void> updateEmergencyContact(
    String uid, {
    required String name,
    required String relation,
    required String phone,
  }) async {}

  @override
  Future<void> updateMedicalInfo(
    String uid, {
    required String bloodType,
    required String medications,
    required String conditions,
    required DateTime consentAt,
  }) async {}

  @override
  Future<void> updatePhysicalInfo(
    String uid, {
    required int? birthYear,
    required int? weightKg,
  }) async {}
}

void main() {
  group('SafetySignalController', () {
    late _FakeSafetySignalRepository repo;
    late _FakeLocationService location;
    late _FakeProfileRepository profileRepo;
    late SafetySignalController controller;

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    setUp(() {
      repo = _FakeSafetySignalRepository();
      location = _FakeLocationService();
      profileRepo = _FakeProfileRepository()
        ..profile = const UserContactProfile(
          uid: 'u1',
          emergencyContactPhone: '+905551112233',
        );
      controller = SafetySignalController(
        repository: repo,
        locationService: location,
        profileRepository: profileRepo,
        uid: 'u1',
      );
    });

    tearDown(() async {
      controller.dispose();
      await repo.controller.close();
    });

    test('onaylı panik gönderimi confirmed döner ve durumu danger yapar', () async {
      repo.nextDelivery = SignalDelivery.confirmed;
      final outcome = await controller.triggerDanger();
      await settle();

      expect(outcome, PanicTriggerOutcome.confirmed);
      expect(controller.isDangerActive, isTrue);
      expect(controller.delivery, SignalDelivery.confirmed);
      expect(repo.dangerCalls, 1);
    });

    test('10 sn onayı gelmezse pendingOffline döner, bağlantı gelince confirmed olur', () async {
      repo.nextDelivery = SignalDelivery.pending;
      final outcome = await controller.triggerDanger();
      await settle();

      expect(outcome, PanicTriggerOutcome.pendingOffline);
      expect(controller.isDangerActive, isTrue);
      expect(controller.delivery, SignalDelivery.pending);

      // İnternet gelince Firestore hasPendingWrites: false yayar
      repo.controller.add(
        SafetySignal(
          uid: 'u1',
          state: SafetySignalState.danger,
          location: const LatLng(36.202, 36.161),
          geohash: 'sy72wxyz',
          updatedAt: DateTime.now(),
          hasPendingWrites: false,
        ),
      );
      await settle();

      expect(controller.delivery, SignalDelivery.confirmed);
    });

    test('konum alınamazsa asılı kalmaz ve locationUnavailable döner', () async {
      location.coords = null;
      final outcome = await controller.triggerDanger();

      expect(outcome, PanicTriggerOutcome.locationUnavailable);
      expect(controller.error, SafetySignalError.locationUnavailable);
      expect(controller.isBusy, isFalse);
      expect(repo.dangerCalls, 0);
    });

    test('GÜVENDEYİM çağrısı sinyali safe durumuna kapatır', () async {
      await controller.triggerDanger();
      await settle();
      expect(controller.isDangerActive, isTrue);

      final ok = await controller.markSafe();
      await settle();

      expect(ok, isTrue);
      expect(repo.safeCalls, 1);
      expect(controller.isDangerActive, isFalse);
    });

    test('acil durum yakını telefonu ve son konumu döndürür', () async {
      final target = await controller.loadEmergencySmsTarget();
      expect(target, isNotNull);
      expect(target!.phone, '+905551112233');
      expect(target.coordinates, const LatLng(36.202, 36.161));
    });

    test('dispose sonrası stream olayı hata fırlatmaz', () async {
      controller.dispose();
      repo.controller.add(
        SafetySignal(
          uid: 'u1',
          state: SafetySignalState.danger,
          location: const LatLng(36.2, 36.16),
          geohash: 'sy72wxyz',
          updatedAt: DateTime.now(),
        ),
      );
      await settle();
    });
  });
}

