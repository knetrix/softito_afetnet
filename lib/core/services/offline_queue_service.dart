import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';

import '../config/app_config.dart';
import 'connectivity_service.dart';
import '../../features/help_request/domain/help_request_draft.dart';
import '../../features/help_request/domain/help_request_repository.dart';

/// Çağrı gönderim sonucu (PROJECT_NEW.md §4 Kural 4).
enum SubmitResult {
  /// Çağrı doğrudan Firestore'a yazıldı.
  sent,

  /// Ağ yok veya 10 sn zaman aşımı oldu; Hive kuyruğuna alındı ("Gönderilmeyi Bekliyor").
  queued,
}

/// Çevrimdışı Yardım Çağrısı Kuyruk Servisi (PROJECT_NEW.md §4 Kural 4, §6.1).
class OfflineQueueService extends ChangeNotifier {
  OfflineQueueService({
    required HelpRequestRepository repository,
    required ConnectivityService connectivityService,
    Box<Map>? box,
    Duration? timeout,
    Duration? retryInterval,
  })  : _repo = repository,
        _connectivity = connectivityService,
        _timeout = timeout ?? AppConfig.offlineTimeout,
        _retryInterval = retryInterval ?? AppConfig.offlineQueueRetryInterval {
    _box = box;
  }

  static const String boxName = 'help_requests_offline_queue';

  final HelpRequestRepository _repo;
  final ConnectivityService _connectivity;
  Box<Map>? _box;
  final Duration _timeout;
  final Duration _retryInterval;

  StreamSubscription<bool>? _networkSub;
  Timer? _retryTimer;
  bool _isFlushing = false;
  bool _disposed = false;

  Box<Map>? get box => _box;
  int get queueLength => _box?.length ?? 0;
  bool get hasPendingItems => queueLength > 0;

  /// Kutudaki tüm bekleyen çağrıları döndürür.
  List<HelpRequestDraft> get pendingRequests {
    if (_box == null) return const [];
    final list = <HelpRequestDraft>[];
    for (final value in _box!.values) {
      try {
        list.add(HelpRequestDraft.fromJson(Map<String, dynamic>.from(value)));
      } catch (_) {
        // Bozuk kayıtları atla
      }
    }
    return list;
  }

  /// Belirli bir çağrıyı kuyruktan siler (ör. afetzede iptal ettiğinde).
  Future<void> removeRequest(String id) async {
    await _box?.delete(id);
    if (!_disposed) notifyListeners();
  }

  /// Servisi başlatır, Hive kutusunu açar ve ağ dinleyicisini bağlar.
  Future<void> initialize() async {
    _box ??= await Hive.openBox<Map>(boxName);

    _networkSub?.cancel();
    _networkSub = _connectivity.onNetworkChanged.listen((hasNetwork) {
      if (hasNetwork && !_disposed) {
        unawaited(flushQueue());
      }
    });

    // "Wi-Fi bağlı ama internet yok" durumunda internet geri gelince ağ arayüzü
    // değişmez ve yukarıdaki dinleyici tetiklenmez (R8). Kuyrukta çağrı varken
    // belirli aralıklarla yeniden denenir.
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(_retryInterval, (_) {
      if (!_disposed && hasPendingItems && _connectivity.hasNetworkInterface) {
        unawaited(flushQueue());
      }
    });

    if (_connectivity.hasNetworkInterface && hasPendingItems) {
      unawaited(flushQueue());
    }
  }

  /// Hatayı çevrimdışı durumu olarak değerlendirir (Kural 4, §5.3).
  bool isOfflineException(Object e) {
    if (e is TimeoutException) return true;
    if (e is FirebaseException &&
        (e.code == 'unavailable' || e.code == 'deadline-exceeded')) {
      return true;
    }
    return false;
  }

  /// Yardım çağrısını Firestore'a iletir; 10 sn içinde gitmezse Hive'a yazar.
  Future<SubmitResult> submitOrQueue(HelpRequestDraft draft) async {
    final effectiveDraft = draft.copyWith(
      createdOffline: !_connectivity.hasNetworkInterface,
    );

    // Ağ arayüzü yoksa doğrudan Hive kuyruğuna yaz
    if (!_connectivity.hasNetworkInterface) {
      await _enqueue(effectiveDraft.copyWith(createdOffline: true));
      return SubmitResult.queued;
    }

    try {
      await _repo.submitHelpRequest(effectiveDraft).timeout(_timeout);
      return SubmitResult.sent;
    } catch (e) {
      if (isOfflineException(e)) {
        await _enqueue(effectiveDraft.copyWith(createdOffline: true));
        return SubmitResult.queued;
      }
      rethrow;
    }
  }

  /// Hive kutusundaki bekleyen çağrıları sırayla gönderir.
  Future<void> flushQueue() async {
    if (_isFlushing || _box == null || _box!.isEmpty) return;
    _isFlushing = true;

    try {
      final keys = List.of(_box!.keys);
      for (final key in keys) {
        final raw = _box!.get(key);
        if (raw == null) {
          await _box!.delete(key);
          continue;
        }

        final draft =
            HelpRequestDraft.fromJson(Map<String, dynamic>.from(raw));

        try {
          await _repo
              .submitHelpRequest(draft.copyWith(createdOffline: true))
              .timeout(_timeout);
          await _box!.delete(key);
          if (!_disposed) notifyListeners();
        } catch (e) {
          if (isOfflineException(e)) {
            // Bağlantı tekrar koptu, sonraki sefere bırak
            break;
          }
          // Bilinmeyen hata: kaydı kutuda tut; sessizce yutulmasın diye loglanır.
          debugPrint('Kuyruktaki çağrı gönderilemedi (${draft.id}): $e');
        }
      }
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> _enqueue(HelpRequestDraft draft) async {
    _box ??= await Hive.openBox<Map>(boxName);
    await _box!.put(draft.id, draft.toJson());
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _networkSub?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}
