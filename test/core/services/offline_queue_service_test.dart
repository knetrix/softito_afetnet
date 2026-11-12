import 'dart:async';
import 'dart:io';

import 'package:afetnet/core/constants/help_type.dart';
import 'package:afetnet/core/services/connectivity_service.dart';
import 'package:afetnet/core/services/offline_queue_service.dart';
import 'package:afetnet/features/help_request/domain/help_request.dart';
import 'package:afetnet/features/help_request/domain/help_request_draft.dart';
import 'package:afetnet/features/help_request/domain/help_request_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:latlong2/latlong.dart';

class _FakeHelpRequestRepository implements HelpRequestRepository {
  final List<HelpRequestDraft> submitted = [];
  bool shouldTimeout = false;
  bool shouldBeUnavailable = false;

  @override
  Future<String> submitHelpRequest(HelpRequestDraft draft) async {
    if (shouldTimeout) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      throw TimeoutException('10s timeout exceeded');
    }
    if (shouldBeUnavailable) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'The service is currently unavailable.',
      );
    }
    submitted.add(draft);
    return draft.id;
  }

  @override
  Stream<HelpRequest?> watchActiveHelpRequest(String uid) =>
      const Stream.empty();

  @override
  Future<void> cancelHelpRequest(String requestId) async {}
}

class _FakeConnectivityService extends ConnectivityService {
  _FakeConnectivityService({bool initial = true})
      : _hasNetworkInterface = initial;

  final StreamController<bool> _changes = StreamController<bool>.broadcast();
  bool _hasNetworkInterface;

  @override
  bool get hasNetworkInterface => _hasNetworkInterface;

  @override
  Stream<bool> get onNetworkChanged => _changes.stream;

  void setNetwork(bool value) {
    _hasNetworkInterface = value;
    _changes.add(value);
    notifyListeners();
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> checkNetworkInterface() async => _hasNetworkInterface;

  @override
  void dispose() {
    _changes.close();
    super.dispose();
  }
}

void main() {
  late Directory tempDir;
  late Box<Map> box;
  late _FakeHelpRequestRepository repo;
  late _FakeConnectivityService connectivity;
  late OfflineQueueService queueService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<Map>('test_help_request_queue');

    repo = _FakeHelpRequestRepository();
    connectivity = _FakeConnectivityService(initial: true);
    queueService = OfflineQueueService(
      repository: repo,
      connectivityService: connectivity,
      box: box,
      timeout: const Duration(milliseconds: 50),
    );
    await queueService.initialize();
  });

  tearDown(() async {
    queueService.dispose();
    connectivity.dispose();
    await box.close();
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  HelpRequestDraft makeDraft({String? id}) => HelpRequestDraft(
        id: id ?? 'req_1',
        type: HelpType.debris,
        peopleCount: 2,
        addressText: 'Atatürk Cad. No:10',
        description: 'Enkaz altındayız',
        location: const LatLng(36.2023, 36.1604),
        createdBy: 'user_1',
        fullName: 'Ali Demir',
        phone: '+905551234567',
      );

  group('OfflineQueueService — Kural 4 (Çevrimdışı Çağrı Kuyruğu)', () {
    test('çevrimiçiyken çağrı doğrudan gönderilir ve Hive kutusu boş kalır',
        () async {
      final draft = makeDraft();
      final result = await queueService.submitOrQueue(draft);

      expect(result, SubmitResult.sent);
      expect(repo.submitted.length, 1);
      expect(repo.submitted.first.id, 'req_1');
      expect(queueService.hasPendingItems, isFalse);
      expect(box.isEmpty, isTrue);
    });

    test(
        'ağ arayüzü yokken çağrı Hive kuyruğuna yazılır ve createdOffline: true olur',
        () async {
      connectivity.setNetwork(false);

      final draft = makeDraft(id: 'offline_req');
      final result = await queueService.submitOrQueue(draft);

      expect(result, SubmitResult.queued);
      expect(repo.submitted, isEmpty);
      expect(queueService.hasPendingItems, isTrue);
      expect(queueService.queueLength, 1);
      expect(box.containsKey('offline_req'), isTrue);

      final stored = box.get('offline_req');
      expect(stored, isNotNull);
      expect(stored!['createdOffline'], isTrue);
      expect(stored['id'], 'offline_req');
      expect(stored['type'], 'debris');
    });

    test(
        'zaman aşımında (timeout) çağrı Hive kuyruğuna alınır',
        () async {
      repo.shouldTimeout = true;

      final draft = makeDraft(id: 'timeout_req');
      final result = await queueService.submitOrQueue(draft);

      expect(result, SubmitResult.queued);
      expect(queueService.hasPendingItems, isTrue);
      expect(box.containsKey('timeout_req'), isTrue);
    });

    test(
        'Firestore unavailable hatasında çağrı Hive kuyruğuna alınır',
        () async {
      repo.shouldBeUnavailable = true;

      final draft = makeDraft(id: 'unavail_req');
      final result = await queueService.submitOrQueue(draft);

      expect(result, SubmitResult.queued);
      expect(queueService.hasPendingItems, isTrue);
      expect(box.containsKey('unavail_req'), isTrue);
    });

    test('flushQueue bekleyen kuyruktaki çağrıları gönderip kutuyu temizler',
        () async {
      // 1. Önce internetsiz 2 çağrı kaydet
      connectivity.setNetwork(false);
      await queueService.submitOrQueue(makeDraft(id: 'q1'));
      await queueService.submitOrQueue(makeDraft(id: 'q2'));

      expect(queueService.queueLength, 2);
      expect(repo.submitted, isEmpty);

      // 2. İnternet geldi
      connectivity.setNetwork(true);
      await queueService.flushQueue();

      expect(queueService.queueLength, 0);
      expect(box.isEmpty, isTrue);
      expect(repo.submitted.length, 2);
      expect(repo.submitted.map((d) => d.id), containsAll(['q1', 'q2']));
    });

    test('onNetworkChanged tetiklendiğinde flushQueue otomatik çalışır',
        () async {
      connectivity.setNetwork(false);
      await queueService.submitOrQueue(makeDraft(id: 'auto_flush'));

      expect(queueService.queueLength, 1);
      expect(repo.submitted, isEmpty);

      // Ağ geri geldiğinde stream üzerinden tetiklenir
      connectivity.setNetwork(true);

      // async flush işleminin tamamlanmasını bekle
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(queueService.queueLength, 0);
      expect(repo.submitted.length, 1);
      expect(repo.submitted.first.id, 'auto_flush');
    });
  });
}
