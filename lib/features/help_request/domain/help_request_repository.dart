// "domain" katmanı: yardım çağrısı işlemlerinin sözleşmesi (arayüz): gönder, canlı izle, iptal et.

import 'assigned_team_info.dart';
import 'help_request.dart';
import 'help_request_draft.dart';
import 'incident_progress.dart';

/// AfetNet Yardım Çağrısı Repository Arayüzü (PROJECT_NEW.md §4 Kural 2, Kural 6, Kural 7, §5.2).
abstract interface class HelpRequestRepository {
  /// Kural 2: 50 m mükerrer kontrolü ve Transaction ile yardım çağrısı açar/bağlar.
  ///
  /// Başarılı olduğunda oluşturulan/bağlanan çağrının `requestId`'sini döndürür.
  Future<String> submitHelpRequest(HelpRequestDraft draft);

  /// Kullanıcının en son aktif (çözümlenmemiş ve iptal edilmemiş) çağrısını izler.
  Stream<HelpRequest?> watchActiveHelpRequest(String uid);

  /// Çağrının bağlı olduğu olayın görev durumu ve ekibi, canlı (Kural 6).
  /// Olay yoksa `null`.
  Stream<IncidentProgress?> watchIncidentProgress(String incidentId);

  /// Kural 6: Atanan ekibin adı ve sorumlu lider bilgisini okur.
  Future<AssignedTeamInfo?> fetchTeamInfo(String teamId);

  /// Kural 7: Afetzede kendi çağrısını iptal edebilir (`status → cancelled`).
  Future<void> cancelHelpRequest(String requestId);
}
