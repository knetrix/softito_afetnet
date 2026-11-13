// "Demo Verisini Sıfırla" servisi (yalnızca debug derlemede, yetkili profilinde görünür).
// 4 ekip, 2 depo, 8 stok kalemi ve 3 toplanma noktasını yükler veya başlangıç hâline döndürür.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

/// "Demo Verisini Sıfırla" sonucu: yazılan kayıt sayıları.
typedef DemoSeedResult = ({int teams, int warehouses, int items, int points});

/// Demo verisi: yalnızca ekip, depo, stok ve toplanma
/// noktası. Yalnızca debug derlemede, onaylı yetkili profilinden çalıştırılır.
///
/// Kayıtlar sabit id'lerle yazılır ve `isDemo: true` taşır. Aynı id'de
/// `isDemo` olmayan (gerçek) bir kayıt varsa ona dokunulmaz. Çağrı, olay,
/// görev ve panik kayıtları kurallar gereği silinemez; demo öncesi Console'dan
/// temizlenir.
class DemoSeedService {
  DemoSeedService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // Koordinatın 8 haneli geohash'ini hesaplar (geohash = konumu kısa bir metinle ifade etme yöntemi).
  static String _geohash(GeoPoint p) => GeoFirePoint(p).geohash.substring(0, 8);

  /// Ekipler (T1 örnek adları). `team_04` demo yetkilisinin ekibidir.
  static final teams = <String, Map<String, dynamic>>{
    'team_04': _team(
      'Arama Kurtarma Tim 4',
      'searchRescue',
      'Ali Kaptan',
      8,
      const GeoPoint(36.2100, 36.1650),
      'Kurtuluş Caddesi',
    ),
    'team_01': _team(
      'Sağlık Ekibi 1',
      'medical',
      'Zeynep Demir',
      4,
      const GeoPoint(36.1950, 36.1550),
      'Devlet Hastanesi önü',
    ),
    'team_02': _team(
      'Aşevi Ekibi',
      'logistics',
      'Mehmet Yılmaz',
      6,
      const GeoPoint(36.2060, 36.1720),
      'Merkez Park',
    ),
    'team_03': _team(
      'İtfaiye Ekibi 2',
      'fire',
      'Ayşe Kara',
      5,
      const GeoPoint(36.1990, 36.1680),
      'İtfaiye Merkezi',
    ),
  };

  // Demo ekip belgesinin verisi.
  static Map<String, dynamic> _team(
    String name,
    String type,
    String leader,
    int members,
    GeoPoint location,
    String locationText,
  ) => {
    'name': name,
    'type': type,
    'leaderName': leader,
    'memberCount': members,
    'location': location,
    'geohash': _geohash(location),
    'locationText': locationText,
    'status': 'available',
  };

  static const warehouses = <String, Map<String, dynamic>>{
    'demo_merkez_depo': {
      'name': 'Merkez Yardım Deposu',
      'locationText': 'Antakya',
      'location': GeoPoint(36.2021, 36.1606),
    },
    'demo_bolge_depo': {
      'name': 'Bölge Yardım Deposu',
      'locationText': 'Defne',
      'location': GeoPoint(36.1880, 36.1500),
    },
  };

  /// Stok kalemleri; başlangıçta hiçbiri kritik değildir. Demo adım 6:
  /// 50 koli su çıkışı → 70 − 50 = 20 ≤ 25 → kritik uyarı ve bildirim.
  static const inventory = <String, Map<String, dynamic>>{
    'water': {
      'name': 'İçme Suyu',
      'unit': 'koli',
      'category': 'water',
      'quantity': 70,
      'targetLevel': 200,
      'criticalLevel': 25,
    },
    'food': {
      'name': 'Gıda Paketi',
      'unit': 'adet',
      'category': 'food',
      'quantity': 60,
      'targetLevel': 100,
      'criticalLevel': 25,
    },
    'blanket': {
      'name': 'Battaniye',
      'unit': 'adet',
      'category': 'shelter',
      'quantity': 80,
      'targetLevel': 100,
      'criticalLevel': 20,
    },
    'medical': {
      'name': 'İlk Yardım Seti',
      'unit': 'adet',
      'category': 'medical',
      'quantity': 25,
      'targetLevel': 40,
      'criticalLevel': 10,
    },
  };

  static final assemblyPoints = <String, Map<String, dynamic>>{
    'demo_toplanma_01': _point(
      'Merkez Toplanma Alanı',
      'assembly',
      'Belediye önü açık alan.',
      const GeoPoint(36.2030, 36.1630),
      500,
      120,
      ['water', 'food'],
    ),
    'demo_sahra_hastanesi': _point(
      'Sahra Hastanesi',
      'fieldHospital',
      'İlk yardım ve triyaj.',
      const GeoPoint(36.1980, 36.1580),
      150,
      35,
      ['health', 'water'],
    ),
    'demo_barinma_01': _point(
      'Geçici Barınma Alanı',
      'shelter',
      'Çadır kent.',
      const GeoPoint(36.2100, 36.1750),
      300,
      80,
      ['tent', 'food', 'water'],
    ),
  };

  // Demo toplanma noktası belgesinin verisi.
  static Map<String, dynamic> _point(
    String name,
    String type,
    String description,
    GeoPoint location,
    int capacity,
    int currentCount,
    List<String> services,
  ) => {
    'name': name,
    'type': type,
    'description': description,
    'location': location,
    'geohash': _geohash(location),
    'capacity': capacity,
    'currentCount': currentCount,
    'services': services,
    'isOpen': true,
  };

  /// Demo kayıtlarını başlangıç hâline getirir; eksikse oluşturur.
  /// Ekiplerin `currentTask` alanı silinir, stok miktarları geri yüklenir.
  Future<DemoSeedResult> reset() async {
    var teamCount = 0;
    var warehouseCount = 0;
    var itemCount = 0;
    var pointCount = 0;

    for (final e in teams.entries) {
      if (await _restore(_db.collection('teams').doc(e.key), e.value)) {
        teamCount++;
      }
    }
    for (final w in warehouses.entries) {
      final ref = _db.collection('warehouses').doc(w.key);
      if (!await _restore(ref, w.value)) continue;
      warehouseCount++;
      for (final i in inventory.entries) {
        if (await _restore(ref.collection('inventory').doc(i.key), i.value)) {
          itemCount++;
        }
      }
    }
    for (final p in assemblyPoints.entries) {
      if (await _restore(
        _db.collection('assembly_points').doc(p.key),
        p.value,
      )) {
        pointCount++;
      }
    }
    return (
      teams: teamCount,
      warehouses: warehouseCount,
      items: itemCount,
      points: pointCount,
    );
  }

  /// Kayıt yoksa ya da demo kaydıysa üzerine yazar; gerçek kayda dokunmaz.
  Future<bool> _restore(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
  ) {
    return _db.runTransaction<bool>((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists && snap.data()?['isDemo'] != true) return false;
      tx.set(ref, {
        ...data,
        'isDemo': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }
}
