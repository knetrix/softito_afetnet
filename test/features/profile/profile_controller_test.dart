import 'dart:async';
import 'package:afetnet/features/profile/domain/profile_repository.dart';
import 'package:afetnet/features/profile/domain/user_contact_profile.dart';
import 'package:afetnet/features/profile/presentation/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProfileRepository implements ProfileRepository {
  final _controller = StreamController<UserContactProfile?>.broadcast();
  UserContactProfile? current;

  @override
  Stream<UserContactProfile?> watchProfile(String uid) => _controller.stream;

  @override
  Future<UserContactProfile?> getProfile(String uid) async => current;

  @override
  Future<void> updateMedicalInfo(
    String uid, {
    required String bloodType,
    required String medications,
    required String conditions,
    required DateTime consentAt,
  }) async {
    current = (current ?? UserContactProfile(uid: uid)).copyWith(
      bloodType: bloodType,
      medications: medications,
      conditions: conditions,
      medicalConsentAt: consentAt,
    );
    _controller.add(current);
  }

  @override
  Future<void> updatePhysicalInfo(
    String uid, {
    required int? birthYear,
    required int? weightKg,
  }) async {
    current = (current ?? UserContactProfile(uid: uid)).copyWith(
      birthYear: birthYear,
      weightKg: weightKg,
    );
    _controller.add(current);
  }

  @override
  Future<void> updateEmergencyContact(
    String uid, {
    required String name,
    required String relation,
    required String phone,
  }) async {
    current = (current ?? UserContactProfile(uid: uid)).copyWith(
      emergencyContactName: name,
      emergencyContactRelation: relation,
      emergencyContactPhone: phone,
    );
    _controller.add(current);
  }

  @override
  Future<void> updateAddress(String uid, {required String addressText}) async {
    current = (current ?? UserContactProfile(uid: uid)).copyWith(
      addressText: addressText,
    );
    _controller.add(current);
  }

  @override
  Future<void> deleteAccount(String uid) async {
    current = null;
    _controller.add(null);
  }
}

void main() {
  group('ProfileController tests', () {
    late FakeProfileRepository repo;
    late ProfileController controller;

    setUp(() {
      repo = FakeProfileRepository();
      controller = ProfileController(repository: repo, uid: 'test_user');
    });

    tearDown(() {
      controller.dispose();
    });

    test('updateMedicalInfo successfully updates state', () async {
      final now = DateTime.now();
      final success = await controller.updateMedicalInfo(
        bloodType: 'A Rh+',
        medications: 'Aspirin',
        conditions: 'Astım',
        consentAt: now,
      );

      expect(success, isTrue);
      expect(controller.profile?.bloodType, equals('A Rh+'));
      expect(controller.profile?.medications, equals('Aspirin'));
      expect(controller.profile?.conditions, equals('Astım'));
      expect(controller.profile?.hasMedicalConsent, isTrue);
    });

    test('updatePhysicalInfo successfully updates age and weight', () async {
      final success = await controller.updatePhysicalInfo(
        birthYear: 1990,
        weightKg: 75,
      );

      expect(success, isTrue);
      expect(controller.profile?.birthYear, equals(1990));
      expect(controller.profile?.weightKg, equals(75));
      expect(controller.profile?.age, isNotNull);
    });

    test('updateEmergencyContact successfully updates contact', () async {
      final success = await controller.updateEmergencyContact(
        name: 'Ahmet Yılmaz',
        relation: 'Kardeş',
        phone: '+90 555 123 45 67',
      );

      expect(success, isTrue);
      expect(controller.profile?.emergencyContactName, equals('Ahmet Yılmaz'));
      expect(controller.profile?.emergencyContactPhone, equals('+90 555 123 45 67'));
    });
  });
}

