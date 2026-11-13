// "data" katmanı: profilin gizli bilgilerini (telefon, adres, acil durum yakını, tıbbi bilgi)
// users/{uid}/private/contact belgesinde okur ve yazar; hesap silme de burada.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/validators.dart';
import '../../auth/domain/auth_failure.dart';
import '../domain/profile_repository.dart';
import '../domain/user_contact_profile.dart';

// Profil verilerinin Firestore uygulaması.
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  // users/{uid}/private/contact belgesinin referansı.
  DocumentReference<Map<String, dynamic>> _contactDoc(String uid) =>
      _db.collection('users').doc(uid).collection('private').doc('contact');

  // Firestore verisini UserContactProfile modeline çevirir.
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

  // Gizli profili canlı izler.
  @override
  Stream<UserContactProfile?> watchProfile(String uid) {
    return _contactDoc(uid).snapshots().map((snap) {
      final data = snap.data();
      return data == null ? null : _fromMap(uid, data);
    });
  }

  // Gizli profili bir kez okur.
  @override
  Future<UserContactProfile?> getProfile(String uid) async {
    final snap = await _contactDoc(uid).get();
    final data = snap.data();
    return data == null ? null : _fromMap(uid, data);
  }

  // Tıbbi bilgiyi ve açık rıza zamanını kaydeder.
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

  // Doğum yılı ve kiloyu kaydeder.
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

  // Acil durum yakınını kaydeder.
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
        // Kullanıcının kendi telefonu gibi `+905XXXXXXXXX` biçiminde saklanır (SMS köprüsü, Kural 8).
        'phone': Validators.normalizePhone(phone) ?? phone.trim(),
      },
    }, SetOptions(merge: true));
  }

  // Adresi kaydeder.
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

  // Ekip kimliğinden ekip adını okur (yetkili profili).
  @override
  Future<String?> getTeamName(String teamId) async {
    final snap = await _db.collection('teams').doc(teamId).get();
    return snap.data()?['name'] as String?;
  }

  // Hesabı siler: önce şifre tekrar doğrulanır (Firebase bunu ister),
  // sonra çağrıların gizli belgeleri, panik sinyali, profil belgeleri ve en son Auth hesabı silinir.
  @override
  Future<void> deleteAccount(String uid, {required String password}) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || user.uid != uid || email == null) {
      throw const AuthException(AuthFailure.unknown);
    }
    try {
      // Şifre yanlışsa hiçbir veri silinmez (§7: onay → yeniden şifre).
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );

      final requests = await _db
          .collection('help_requests')
          .where('createdBy', isEqualTo: uid)
          .get();
      final batch = _db.batch();
      // 1. Kullanıcının çağrılarındaki private/contact belgeleri
      //    (çağrı belgeleri operasyonel kayıt olarak kalır).
      for (final request in requests.docs) {
        batch.delete(request.reference.collection('private').doc('contact'));
      }
      // 2. safety_signals/{uid}
      batch.delete(_db.collection('safety_signals').doc(uid));
      // 3. users/{uid}/private/contact ve users/{uid}
      batch.delete(_contactDoc(uid));
      batch.delete(_db.collection('users').doc(uid));
      await batch.commit();

      // 4. Firebase Auth hesabı (oturum kapanır, router Giriş'e döner).
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(switch (e.code) {
        'wrong-password' || 'invalid-credential' => AuthFailure.invalidCredentials,
        'too-many-requests' => AuthFailure.tooManyRequests,
        'network-request-failed' => AuthFailure.network,
        _ => AuthFailure.unknown,
      });
    } on FirebaseException catch (e) {
      throw AuthException(
        e.code == 'unavailable' ? AuthFailure.network : AuthFailure.unknown,
      );
    }
  }
}
