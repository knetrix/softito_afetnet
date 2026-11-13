// "domain" katmanı: gizli profil modeli (users/{uid}/private/contact).
// Telefon, adres, acil durum yakını ve tıbbi bilgi; yalnızca sahibi ve onaylı yetkili okuyabilir.

import 'package:flutter/foundation.dart';

/// Afetzede ve Yetkili Gizli İletişim & Sağlık Profili
/// `users/{uid}/private/contact` belgesinden okunur.
@immutable
class UserContactProfile {
  const UserContactProfile({
    required this.uid,
    this.email,
    this.phone,
    this.bloodType,
    this.medications,
    this.conditions,
    this.birthYear,
    this.weightKg,
    this.emergencyContactName,
    this.emergencyContactRelation,
    this.emergencyContactPhone,
    this.addressText,
    this.medicalConsentAt,
  });

  final String uid;
  final String? email;
  final String? phone;

  // Tıbbi & Fiziksel Bilgiler
  final String? bloodType;
  final String? medications;
  final String? conditions;
  final int? birthYear;
  final int? weightKg;
  final DateTime? medicalConsentAt;

  // Acil Durum Yakını
  final String? emergencyContactName;
  final String? emergencyContactRelation;
  final String? emergencyContactPhone;

  // İkamet Adresi
  final String? addressText;

  // Tıbbi bilgi için açık rıza verilmiş mi.
  bool get hasMedicalConsent => medicalConsentAt != null;

  // Doğum yılından hesaplanan yaş.
  int? get age => birthYear == null ? null : DateTime.now().year - birthYear!;

  // Nesnenin bir kopyasını oluşturur; yalnızca verilen alanlar değişir, orijinal nesne olduğu gibi kalır.
  UserContactProfile copyWith({
    String? email,
    String? phone,
    String? bloodType,
    String? medications,
    String? conditions,
    int? birthYear,
    int? weightKg,
    DateTime? medicalConsentAt,
    String? emergencyContactName,
    String? emergencyContactRelation,
    String? emergencyContactPhone,
    String? addressText,
  }) {
    return UserContactProfile(
      uid: uid,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodType: bloodType ?? this.bloodType,
      medications: medications ?? this.medications,
      conditions: conditions ?? this.conditions,
      birthYear: birthYear ?? this.birthYear,
      weightKg: weightKg ?? this.weightKg,
      medicalConsentAt: medicalConsentAt ?? this.medicalConsentAt,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelation:
          emergencyContactRelation ?? this.emergencyContactRelation,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      addressText: addressText ?? this.addressText,
    );
  }
}

