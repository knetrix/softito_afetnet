import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/services/offline_queue_service.dart';
import '../domain/assigned_team_info.dart';
import '../domain/help_request.dart';
import '../domain/help_request_draft.dart';
import '../domain/help_request_repository.dart';

/// Afetzede Aktif Yardım Çağrısı Kontrolcüsü (PROJECT_NEW.md §4 Kural 4, Kural 6, Kural 7, A1).
class ActiveHelpRequestController extends ChangeNotifier {
  ActiveHelpRequestController({
    required HelpRequestRepository repository,
    required OfflineQueueService queueService,
    required String citizenUid,
  })  : _repo = repository,
        _offlineQueue = queueService,
        _uid = citizenUid {
    _init();
  }

  final HelpRequestRepository _repo;
  final OfflineQueueService _offlineQueue;
  final String _uid;

  StreamSubscription<HelpRequest?>? _requestSub;
  HelpRequest? _activeRequest;
  AssignedTeamInfo? _assignedTeam;
  bool _isLoading = true;
  bool _isCancelling = false;
  bool _disposed = false;

  HelpRequest? get activeRequest => _activeRequest;
  AssignedTeamInfo? get assignedTeam => _assignedTeam;
  bool get isLoading => _isLoading;
  bool get isCancelling => _isCancelling;

  /// Kural 4: Henüz Firestore'a iletilmemiş, yerel Hive kuyruğunda bekleyen çağrı var mı?
  /// Başka aktif çağrı olsa da bekleyen çağrı kartta öncelikli gösterilir;
  /// yoksa afetzede yeni çağrısının gönderilmediğini göremez.
  bool get hasPendingOffline => _offlineQueue.hasPendingItems;

  /// Hive kuyruğundaki ilk bekleyen çağrı
  HelpRequestDraft? get topOfflineDraft {
    if (!hasPendingOffline) return null;
    final list = _offlineQueue.pendingRequests;
    return list.isNotEmpty ? list.first : null;
  }

  /// Aktif bir çağrı veya kuyrukta bekleyen çağrı var mı?
  bool get hasActiveOrQueuedCall =>
      (_activeRequest != null &&
          !_activeRequest!.isCancelled &&
          !_activeRequest!.isResolved) ||
      hasPendingOffline;

  void _init() {
    _offlineQueue.addListener(_onOfflineQueueChanged);
    _requestSub = _repo.watchActiveHelpRequest(_uid).listen(
      (req) async {
        if (_disposed) return;
        _activeRequest = req;
        _isLoading = false;

        final teamId = req?.assignedTeamId;
        if (teamId != null && teamId.isNotEmpty) {
          if (_assignedTeam?.id != teamId) {
            _assignedTeam = await _repo.fetchTeamInfo(teamId);
          }
        } else {
          _assignedTeam = null;
        }

        if (!_disposed) notifyListeners();
      },
      onError: (_) {
        if (_disposed) return;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _onOfflineQueueChanged() {
    if (!_disposed) notifyListeners();
  }

  /// Kural 7: Afetzede çağrısını iptal edebilir (`status: cancelled`).
  Future<bool> cancel(String requestId) async {
    if (_isCancelling) return false;
    _isCancelling = true;
    notifyListeners();

    try {
      // Eğer çağrı henüz Hive kuyruğundaysa kuyruktan sil
      if (hasPendingOffline && topOfflineDraft?.id == requestId) {
        await _offlineQueue.removeRequest(requestId);
        _isCancelling = false;
        if (!_disposed) notifyListeners();
        return true;
      }

      // Kart Firestore akışından güncellenir (yerel önbellek anında yayınlar).
      // Burada elle `cancelled` yazmak, akışın o arada gösterdiği başka bir
      // aktif çağrıyı da gizliyordu.
      await _repo.cancelHelpRequest(requestId);
      _isCancelling = false;
      if (!_disposed) notifyListeners();
      return true;
    } catch (_) {
      _isCancelling = false;
      if (!_disposed) notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _offlineQueue.removeListener(_onOfflineQueueChanged);
    _requestSub?.cancel();
    super.dispose();
  }
}
