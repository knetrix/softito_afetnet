import 'package:afetnet/core/constants/help_type.dart';
import 'package:afetnet/core/widgets/state_view.dart';
import 'package:afetnet/features/live_feed/domain/incident_summary.dart';
import 'package:afetnet/features/live_feed/presentation/live_feed_controller.dart';
import 'package:afetnet/features/safety_signal/domain/safety_signal.dart';
import 'package:afetnet/features/teams/domain/team.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'live_feed_fakes.dart';

void main() {
  late FakeLiveFeedRepository repo;
  late FakeTeamsRepository teamsRepo;
  late List<SafetySignal> notified;
  late LiveFeedController ctrl;

  setUp(() {
    repo = FakeLiveFeedRepository();
    teamsRepo = FakeTeamsRepository();
    notified = [];
    ctrl = LiveFeedController(
      repository: repo,
      teamsRepository: teamsRepo,
      onNewPanicSignal: notified.add,
    );
  });

  tearDown(() {
    ctrl.dispose();
    repo.dispose();
    teamsRepo.dispose();
  });

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('olaylar gelince hazır olur ve kart özetleri yüklenir', () async {
    expect(ctrl.status, ViewStatus.loading);
    repo.summaries['inc1'] = const IncidentSummary(
      fullName: 'Ali V.',
      peopleCount: 2,
    );
    repo.incidents.add([testIncident()]);
    await flush();
    await flush();
    expect(ctrl.status, ViewStatus.ready);
    expect(ctrl.summaryOf('inc1')?.fullName, 'Ali V.');
  });

  test('filtre öncelik ve tür üzerinde istemcide uygulanır', () async {
    repo.incidents.add([
      testIncident(id: 'a', priority: 1, type: HelpType.medical),
      testIncident(id: 'b', priority: 2, type: HelpType.shelter),
      testIncident(id: 'c', priority: 3, type: HelpType.water),
    ]);
    await flush();

    ctrl.setFilter(const LiveFeedFilter.priority(2));
    expect(ctrl.filteredIncidents.map((i) => i.id), ['b']);

    ctrl.setFilter(const LiveFeedFilter.type(HelpType.medical));
    expect(ctrl.filteredIncidents.map((i) => i.id), ['a']);

    ctrl.setFilter(const LiveFeedFilter.type(HelpType.debris));
    expect(ctrl.listStatus, ViewStatus.empty);

    ctrl.setFilter(LiveFeedFilter.all);
    expect(ctrl.filteredIncidents.length, 3);
  });

  test(
    'ilk yüklemede bildirim yok; yeni ve yenilenen panik bildirilir',
    () async {
      final t0 = DateTime(2026, 11, 12, 10);
      repo.signals.add([testSignal(uid: 'u1', updatedAt: t0)]);
      await flush();
      expect(notified, isEmpty);

      // Yeni kullanıcı paniği
      repo.signals.add([
        testSignal(uid: 'u1', updatedAt: t0),
        testSignal(uid: 'u2', updatedAt: t0),
      ]);
      await flush();
      expect(notified.map((s) => s.uid), ['u2']);

      // u1 yeniden panik bastı (daha yeni zaman)
      notified.clear();
      repo.signals.add([
        testSignal(uid: 'u1', updatedAt: t0.add(const Duration(minutes: 5))),
        testSignal(uid: 'u2', updatedAt: t0),
      ]);
      await flush();
      expect(notified.map((s) => s.uid), ['u1']);
    },
  );

  test('ulaşılmış sinyal için bildirim üretilmez', () {
    final fresh = LiveFeedController.newPanicSignals(const {}, [
      testSignal(uid: 'u3', handledBy: 'off1'),
    ]);
    expect(fresh, isEmpty);
  });

  test(
    'Ekip Yönlendir: yalnızca boştaki ekipler, olaya yakından uzağa',
    () async {
      teamsRepo.teams.add([
        testTeam(id: 'far', location: const LatLng(36.30, 36.16)),
        testTeam(
          id: 'busy',
          status: TeamStatus.onDuty,
          location: const LatLng(36.2026, 36.1610),
        ),
        testTeam(id: 'near', location: const LatLng(36.203, 36.161)),
        testTeam(id: 'nolocation', location: null),
      ]);
      await flush();
      final sorted = ctrl.availableTeamsFor(testIncident());
      expect(sorted.map((t) => t.id), ['near', 'far', 'nolocation']);
    },
  );

  test('akış hatasında hata durumu, retry ile yeniden yüklenir', () async {
    repo.incidents.addError(Exception('permission-denied'));
    await flush();
    expect(ctrl.status, ViewStatus.failure);

    ctrl.retry();
    expect(ctrl.status, ViewStatus.loading);
    repo.incidents.add([]);
    await flush();
    expect(ctrl.listStatus, ViewStatus.empty);
  });
}
