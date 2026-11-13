// "domain" katmanı: Canlı Akış verilerinin sözleşmesi (arayüz).

import '../../safety_signal/domain/safety_signal.dart';
import 'incident.dart';
import 'incident_summary.dart';

/// Canlı Akış (Y1) repository arayüzü.
abstract interface class LiveFeedRepository {
  /// Açık olaylar, `priority` ve `createdAt` sırasıyla, canlı.
  Stream<List<Incident>> watchOpenIncidents();

  /// `state == danger` olan panik sinyalleri, en yeni önce, canlı.
  Stream<List<SafetySignal>> watchDangerSignals();

  /// Kart bilgisi: olayın ilk çağrısı ve sahibinin adı.
  Future<IncidentSummary> fetchSummary(Incident incident);

  /// Detay sheet'i: telefon (`help_requests/{id}/private/contact`) ve tıbbi
  /// özet (`users/{createdBy}/private/contact`).
  Future<IncidentDetail> fetchDetail(Incident incident);

  /// Görev atanmamış olayı doğrudan kapatır (`resolved`,
  /// `isOpen: false`). Bağlı, iptal edilmemiş çağrılar da `resolved` olur.
  /// Olayda görev varsa veya olay kapanmışsa `false` döner.
  Future<bool> closeIncident(Incident incident);

  /// Panik pininde "Ulaşıldı": `handledBy` ve `handledAt` yazılır.
  /// Sunucu onayı 10 sn içinde gelmezse `false` döner; yazım Firestore'un
  /// kuyruğunda kalır ve internet gelince gider (pin yerel önbellekten hemen
  /// "ulaşıldı" görünür).
  Future<bool> markSignalHandled({
    required String signalUid,
    required String officialUid,
  });
}
