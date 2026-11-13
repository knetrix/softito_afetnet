// "domain" katmanı: yardım çağrısı işlemlerinin sözleşmesi (arayüz): gönder, canlı izle, iptal et.

import 'assigned_team_info.dart';
import 'help_request.dart';
import 'help_request_draft.dart';
import 'incident_progress.dart';

/// AfetNet Yardım Çağrısı Repository Arayüzü.
abstract interface class HelpRequestRepository {
  /// 50 m mükerrer kontrolü ve Transaction ile yardım çağrısı açar/bağlar.
  ///
  /// Başarılı olduğunda oluşturulan/bağlanan çağrının `requestId`'sini döndürür.
  Future<String> submitHelpRequest(HelpRequestDraft draft);

  /// Kullanıcının en son aktif (çözümlenmemiş ve iptal edilmemiş) çağrısını izler.
  Stream<HelpRequest?> watchActiveHelpRequest(String uid);

  /// Çağrının bağlı olduğu olayın görev durumu ve ekibi, canlı.
  /// Olay yoksa `null`.
  Stream<IncidentProgress?> watchIncidentProgress(String incidentId);

  /// Atanan ekibin adı ve sorumlu lider bilgisini okur.
  Future<AssignedTeamInfo?> fetchTeamInfo(String teamId);

  /// Afetzede kendi çağrısını iptal edebilir (`status → cancelled`).
  Future<void> cancelHelpRequest(String requestId);
}
