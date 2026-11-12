import 'dart:async';
import 'dart:io';

import 'package:afetnet/core/constants/case_status.dart';
import 'package:afetnet/core/constants/help_type.dart';
import 'package:afetnet/core/services/connectivity_service.dart';
import 'package:afetnet/core/services/offline_queue_service.dart';
import 'package:afetnet/features/help_request/domain/assigned_team_info.dart';
import 'package:afetnet/features/help_request/domain/help_request.dart';
import 'package:afetnet/features/help_request/domain/help_request_draft.dart';
import 'package:afetnet/features/help_request/domain/help_request_repository.dart';
import 'package:afetnet/features/help_request/presentation/active_help_request_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:latlong2/latlong.dart';

class _MockRepo implements HelpRequestRepository {
  final _activeController = StreamController<HelpRequest?>.broadcast();
  final List<String> cancelledIds = [];
  AssignedTeamInfo? teamToReturn;

  @override
  Stream<HelpRequest?> watchActiveHelpRequest(String uid) =>
      _activeController.stream;

  @override
  Future<AssignedTeamInfo?> fetchTeamInfo(String teamId) async => teamToReturn;

  @override
  Future<void> cancelHelpRequest(String requestId) async {
    cancelledIds.add(requestId);
  }

  @override
  Future<String> submitHelpRequest(HelpRequestDraft draft) async => draft.id;

  void emit(HelpRequest? req) => _activeController.add(req);

  void close() => _activeController.close();
}

class _FakeConnectivity extends ConnectivityService {
  _FakeConnectivity({bool initial = true})
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
  late Box<Map> hiveBox;
  late _MockRepo repo;
  late _FakeConnectivity conn;
  late OfflineQueueService queue;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('active_ctrl_test_');
    Hive.init(tempDir.path);
    hiveBox = await Hive.openBox<Map>('test_active_ctrl_box');
    repo = _MockRepo();
    conn = _FakeConnectivity();
    queue = OfflineQueueService(
      repository: repo,
      connectivityService: conn,
      box: hiveBox,
    );
  });

  tearDown(() async {
    await hiveBox.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    repo.close();
  });

  test('ActiveHelpRequestController repo akışını dinler ve takım bilgisini çeker', () async {
    repo.teamToReturn = const AssignedTeamInfo(
      id: 'team_1',
      name: 'AKUT',
      leaderName: 'Ali Kaptan',
    );

    final controller = ActiveHelpRequestController(
      repository: repo,
      queueService: queue,
      citizenUid: 'user_1',
    );
    addTearDown(controller.dispose);

    expect(controller.activeRequest, isNull);
    expect(controller.hasActiveOrQueuedCall, isFalse);

    final req = HelpRequest(
      id: 'hr_1',
      createdBy: 'user_1',
      type: HelpType.debris,
      priority: 1,
      status: CaseStatus.assigned,
      peopleCount: 2,
      location: const LatLng(36.2, 36.16),
      geohash: 'sy72wxyz',
      createdAt: DateTime.now(),
      assignedTeamId: 'team_1',
    );

    repo.emit(req);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(controller.activeRequest?.id, 'hr_1');
    expect(controller.assignedTeam?.name, 'AKUT');
    expect(controller.hasActiveOrQueuedCall, isTrue);
  });

  test('ActiveHelpRequestController çevrimdışı kuyruktaki taslağı algılar', () async {
    final draft = HelpRequestDraft(
      id: 'draft_offline_1',
      createdBy: 'user_1',
      fullName: 'Ahmet',
      phone: '0555',
      location: const LatLng(36.2, 36.16),
      type: HelpType.water,
      peopleCount: 1,
      createdOffline: true,
    );
    await hiveBox.put(draft.id, draft.toJson());

    final controller = ActiveHelpRequestController(
      repository: repo,
      queueService: queue,
      citizenUid: 'user_1',
    );
    addTearDown(controller.dispose);

    expect(controller.hasPendingOffline, isTrue);
    expect(controller.topOfflineDraft?.id, 'draft_offline_1');
    expect(controller.hasActiveOrQueuedCall, isTrue);
  });

  test('ActiveHelpRequestController çevrimdışı taslağı iptal ettiğinde kuyruktan siler', () async {
    final draft = HelpRequestDraft(
      id: 'draft_offline_2',
      createdBy: 'user_1',
      fullName: 'Ahmet',
      phone: '0555',
      location: const LatLng(36.2, 36.16),
      type: HelpType.water,
      peopleCount: 1,
      createdOffline: true,
    );
    await hiveBox.put(draft.id, draft.toJson());

    final controller = ActiveHelpRequestController(
      repository: repo,
      queueService: queue,
      citizenUid: 'user_1',
    );
    addTearDown(controller.dispose);

    expect(controller.hasPendingOffline, isTrue);

    final result = await controller.cancel('draft_offline_2');
    expect(result, isTrue);
    expect(hiveBox.containsKey('draft_offline_2'), isFalse);
    expect(controller.hasPendingOffline, isFalse);
    expect(controller.hasActiveOrQueuedCall, isFalse);
  });

  test('ActiveHelpRequestController Firestore çağrısını iptal ettiğinde repo.cancelHelpRequest çağırır', () async {
    final controller = ActiveHelpRequestController(
      repository: repo,
      queueService: queue,
      citizenUid: 'user_1',
    );
    addTearDown(controller.dispose);

    final req = HelpRequest(
      id: 'hr_active_1',
      createdBy: 'user_1',
      type: HelpType.medical,
      priority: 1,
      status: CaseStatus.pending,
      peopleCount: 1,
      location: const LatLng(36.2, 36.16),
      geohash: 'sy72wxyz',
      createdAt: DateTime.now(),
    );
    repo.emit(req);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final result = await controller.cancel('hr_active_1');
    expect(result, isTrue);
    expect(repo.cancelledIds, contains('hr_active_1'));
    expect(controller.activeRequest?.status, CaseStatus.cancelled);
    expect(controller.hasActiveOrQueuedCall, isFalse);
  });
}
