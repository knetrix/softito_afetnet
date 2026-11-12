import 'package:latlong2/latlong.dart';

import '../domain/assembly_point.dart';
import '../domain/assembly_point_type.dart';
import '../domain/assembly_service.dart';

/// Çevrimdışı ve Demo Verisi için Varsayılan Toplanma Alanları (PROJECT_NEW.md §3.1 A2, §8).
/// Antakya / Hatay merkezli gerçekçi acil durum toplanma noktaları.
abstract final class DefaultAssemblyPoints {
  static List<AssemblyPoint> get list => [
        AssemblyPoint(
          id: 'ap_antakya_ataturk_parki',
          name: 'Antakya Atatürk Parkı Toplanma Alanı',
          type: AssemblyPointType.assembly,
          description:
              'Geniş toplanma meydanı, temiz su tankeri ve sahra mutfağı dağıtım noktası.',
          location: const LatLng(36.2025, 36.1610),
          geohash: 'sy72wxy1',
          capacity: 2500,
          currentCount: 850,
          services: const [
            AssemblyService.water,
            AssemblyService.food,
            AssemblyService.tent,
          ],
          isOpen: true,
          updatedAt: DateTime.now(),
        ),
        AssemblyPoint(
          id: 'ap_defne_sahra_hastanesi',
          name: 'Defne Sahra Hastanesi',
          type: AssemblyPointType.fieldHospital,
          description:
              'Acil travma müdahale, triyaj çadırı, ilaç temini ve genel sağlık hizmeti.',
          location: const LatLng(36.1910, 36.1420),
          geohash: 'sy72wxy2',
          capacity: 500,
          currentCount: 380,
          services: const [
            AssemblyService.health,
            AssemblyService.water,
          ],
          isOpen: true,
          updatedAt: DateTime.now(),
        ),
        AssemblyPoint(
          id: 'ap_sumerler_cadir_kent',
          name: 'Sümerler Çadır Kent ve Barınma',
          type: AssemblyPointType.shelter,
          description:
              'Isıtmalı aile çadırları, sıcak çorba dağıtımı, battaniye ve hijyen kitleri.',
          location: const LatLng(36.1850, 36.1550),
          geohash: 'sy72wxy3',
          capacity: 1200,
          currentCount: 1120,
          services: const [
            AssemblyService.tent,
            AssemblyService.food,
            AssemblyService.water,
            AssemblyService.health,
          ],
          isOpen: true,
          updatedAt: DateTime.now(),
        ),
        AssemblyPoint(
          id: 'ap_antakya_sehir_stadi',
          name: 'Antakya Şehir Stadyumu Toplanma Alanı',
          type: AssemblyPointType.assembly,
          description:
              'Açık tribün ve saha içi toplanma alanı, koordinasyon merkezi ve insani yardım deposu.',
          location: const LatLng(36.2150, 36.1680),
          geohash: 'sy72wxy4',
          capacity: 3500,
          currentCount: 1400,
          services: const [
            AssemblyService.water,
            AssemblyService.food,
          ],
          isOpen: true,
          updatedAt: DateTime.now(),
        ),
        AssemblyPoint(
          id: 'ap_koprubasi_ilkyardim',
          name: 'Köprübaşı Sahra Tıbbi Müdahale Noktası',
          type: AssemblyPointType.fieldHospital,
          description:
              'Hafif yaralanmalar, pansuman, seyyar ambulans bekleme ve ilk yardım çadırı.',
          location: const LatLng(36.2040, 36.1590),
          geohash: 'sy72wxy5',
          capacity: 250,
          currentCount: 110,
          services: const [
            AssemblyService.health,
            AssemblyService.water,
          ],
          isOpen: true,
          updatedAt: DateTime.now(),
        ),
        AssemblyPoint(
          id: 'ap_valigobegi_cadir_alani',
          name: 'Vali Göbeği Geçici Barınma Alanı',
          type: AssemblyPointType.shelter,
          description:
              'Acil barınma çadırları, bebek bakım ve beslenme kabini, temiz su noktası.',
          location: const LatLng(36.2080, 36.1630),
          geohash: 'sy72wxy6',
          capacity: 800,
          currentCount: 540,
          services: const [
            AssemblyService.tent,
            AssemblyService.water,
            AssemblyService.food,
          ],
          isOpen: true,
          updatedAt: DateTime.now(),
        ),
      ];
}
