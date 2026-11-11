import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/profile_repository.dart';
import '../domain/user_contact_profile.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _contactDoc(String uid) =>
      _db.collection('users').doc(uid).collection('private').doc('contact');

  UserContactProfile _fromMap(String uid, Map<String, dynamic> data) {
    final medical = data['medical'] as Map<String, dynamic>?;
    final emergency = data['emergencyContact'] as Map<String, dynamic>?;
    final address = data['address'] as Map<String, dynamic>?;

    final consentTimestamp = data['medicalConsentAt'] as Timestamp?;

    return UserContactProfile(
      uid: uid,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      bloodType: medical?['bloodType'] as String?,
      medications: medical?['medications'] as String?,
      conditions: medical?['conditions'] as String?,
      birthYear: (medical?['birthYear'] as num?)?.toInt(),
      weightKg: (medical?['weightKg'] as num?)?.toInt(),
      medicalConsentAt: consentTimestamp?.toDate(),
      emergencyContactName: emergency?['name'] as String?,
      emergencyContactRelation: emergency?['relation'] as String?,
      emergencyContactPhone: emergency?['phone'] as String?,
      addressText: address?['text'] as String?,
    );
  }

  @override
  Stream<UserContactProfile?> watchProfile(String uid) {
    return _contactDoc(uid).snapshots().map((snap) {
      final data = snap.data();
      return data == null ? null : _fromMap(uid, data);
    });
  }

  @override
  Future<UserContactProfile?> getProfile(String uid) async {
    final snap = await _contactDoc(uid).get();
    final data = snap.data();
    return data == null ? null : _fromMap(uid, data);
  }

  @override
  Future<void> updateMedicalInfo(
    String uid, {
    required String bloodType,
    required String medications,
    required String conditions,
    required DateTime consentAt,
  }) async {
    await _contactDoc(uid).set({
      'medical': {
        'bloodType': bloodType.trim(),
        'medications': medications.trim(),
        'conditions': conditions.trim(),
      },
      'medicalConsentAt': Timestamp.fromDate(consentAt),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updatePhysicalInfo(
    String uid, {
    required int? birthYear,
    required int? weightKg,
  }) async {
    await _contactDoc(uid).set({
      'medical': {
        'birthYear': ?birthYear,
        'weightKg': ?weightKg,
      },
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateEmergencyContact(
    String uid, {
    required String name,
    required String relation,
    required String phone,
  }) async {
    await _contactDoc(uid).set({
      'emergencyContact': {
        'name': name.trim(),
        'relation': relation.trim(),
        'phone': phone.trim(),
      },
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateAddress(
    String uid, {
    required String addressText,
  }) async {
    await _contactDoc(uid).set({
      'address': {
        'text': addressText.trim(),
      },
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteAccount(String uid) async {
    // 1. safety_signals/{uid} silinir
    await _db.collection('safety_signals').doc(uid).delete().catchError((Object _) {});

    // 2. users/{uid}/private/contact ve users/{uid} silinir
    await _contactDoc(uid).delete().catchError((Object _) {});
    await _db.collection('users').doc(uid).delete().catchError((Object _) {});

    // 3. Firebase Auth hesabı silinir
    final user = _auth.currentUser;
    if (user != null && user.uid == uid) {
      await user.delete();
    }
  }
}
