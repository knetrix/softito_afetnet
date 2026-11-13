import 'package:afetnet/core/constants/case_status.dart';
import 'package:afetnet/core/constants/help_type.dart';
import 'package:afetnet/core/theme/app_theme.dart';
import 'package:afetnet/features/live_feed/domain/incident_summary.dart';
import 'package:afetnet/features/live_feed/presentation/live_feed_controller.dart';
import 'package:afetnet/features/live_feed/presentation/live_feed_screen.dart';
import 'package:afetnet/features/live_feed/presentation/sheets/panic_signal_sheet.dart';
import 'package:afetnet/features/teams/domain/team.dart';
import 'package:afetnet/features/teams/presentation/teams_controller.dart';
import 'package:afetnet/features/teams/presentation/teams_screen.dart';
import 'package:afetnet/features/teams/domain/assignment.dart';
import 'package:afetnet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'live_feed_fakes.dart';

Widget _wrap(Widget home, {Locale locale = const Locale('tr')}) => MaterialApp(
  theme: AppTheme.dark(),
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  late FakeLiveFeedRepository repo;
  late FakeTeamsRepository teamsRepo;

  setUp(() {
    repo = FakeLiveFeedRepository();
    teamsRepo = FakeTeamsRepository();
  });

  tearDown(() {
    repo.dispose();
    teamsRepo.dispose();
  });

  group('Y1 Canlı Akış', () {
    testWidgets(
      'kartta ad, öncelik, yalnızca Detay ve Ekip Yönlendir görünür',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final ctrl = LiveFeedController(
          repository: repo,
          teamsRepository: teamsRepo,
        );
        addTearDown(ctrl.dispose);
        repo.summaries['inc1'] = const IncidentSummary(
          fullName: 'Mehmet Y.',
          peopleCount: 3,
          addressText: 'Bina A-4 önü',
          description: 'Tavan çöktü',
        );

        await tester.pumpWidget(
          _wrap(
            LiveFeedScreen(
              controller: ctrl,
              tileLayer: const SizedBox.shrink(),
              officialUid: 'off1',
            ),
          ),
        );
        repo.incidents.add([testIncident()]);
        await tester.pumpAndSettle();

        expect(find.text('CANLI ÇAĞRI AKIŞI'), findsOneWidget);
        expect(find.text('Mehmet Y.'), findsOneWidget);
        expect(find.text('KRİTİK'), findsOneWidget);
        expect(find.text('"Tavan çöktü"'), findsOneWidget);
        expect(find.text('Detay'), findsOneWidget);
        expect(find.text('Ekip Yönlendir'), findsOneWidget);
        // T2/T9: telsiz, rota, müdahale ifadeleri yok
        expect(find.textContaining('Telsiz'), findsNothing);
        expect(find.text('Rota Çiz'), findsNothing);
      },
    );

    testWidgets(
      'ekip atanmış olayda Ekip Yönlendir yerine ekip ve durum görünür',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final ctrl = LiveFeedController(
          repository: repo,
          teamsRepository: teamsRepo,
        );
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(
          _wrap(
            LiveFeedScreen(
              controller: ctrl,
              tileLayer: const SizedBox.shrink(),
              officialUid: 'off1',
            ),
          ),
        );
        teamsRepo.teams.add([testTeam(status: TeamStatus.onDuty)]);
        repo.incidents.add([
          testIncident(assignedTeamId: 't1', status: CaseStatus.enRoute),
        ]);
        await tester.pumpAndSettle();

        expect(find.text('Ekip Yönlendir'), findsNothing);
        expect(find.text('Ekip: Arama Kurtarma Tim 4'), findsOneWidget);
        expect(find.text('Yola Çıktı'), findsOneWidget);
      },
    );

    testWidgets('Ekip Yönlendir boştaki ekibi listeler ve olaya atar', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final ctrl = LiveFeedController(
        repository: repo,
        teamsRepository: teamsRepo,
      );
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(
          LiveFeedScreen(
            controller: ctrl,
            tileLayer: const SizedBox.shrink(),
            officialUid: 'off1',
          ),
        ),
      );
      teamsRepo.teams.add([
        testTeam(id: 't1', name: 'Arama Kurtarma Tim 4'),
        testTeam(id: 't2', name: 'Aşevi Ekibi', status: TeamStatus.onDuty),
      ]);
      repo.incidents.add([testIncident()]);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ekip Yönlendir'));
      await tester.pumpAndSettle();
      expect(
        find.text('Aşevi Ekibi'),
        findsNothing,
      ); // görevde olan listelenmez
      await tester.tap(find.text('Arama Kurtarma Tim 4'));
      await tester.pumpAndSettle();
      expect(teamsRepo.assigned, [('inc1', 't1')]);
    });

    testWidgets('açık olay yokken boş durum gösterilir (İngilizce)', (
      tester,
    ) async {
      final ctrl = LiveFeedController(
        repository: repo,
        teamsRepository: teamsRepo,
      );
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(
          LiveFeedScreen(
            controller: ctrl,
            tileLayer: const SizedBox.shrink(),
            officialUid: 'off1',
          ),
          locale: const Locale('en'),
        ),
      );
      repo.incidents.add([]);
      await tester.pumpAndSettle();

      expect(find.text('No open calls right now.'), findsOneWidget);
    });

    testWidgets(
      'Detay sheet\'i telefon ve Olayı Kapat gösterir, kapatma çalışır',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final ctrl = LiveFeedController(
          repository: repo,
          teamsRepository: teamsRepo,
        );
        addTearDown(ctrl.dispose);

        await tester.pumpWidget(
          _wrap(
            LiveFeedScreen(
              controller: ctrl,
              tileLayer: const SizedBox.shrink(),
              officialUid: 'off1',
            ),
          ),
        );
        repo.incidents.add([testIncident()]);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Detay'));
        await tester.pumpAndSettle();
        expect(find.text('Çağrı Detayı'), findsOneWidget);
        expect(find.text('+90 532 123 45 67'), findsOneWidget);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Olayı Kapat'));
        await tester.pumpAndSettle();
        // Onay diyaloğu
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Olayı Kapat').last,
        );
        await tester.pumpAndSettle();
        expect(repo.closed, ['inc1']);
      },
    );
  });

  group('G1 incelemesi', () {
    Future<LiveFeedController> pumpFeed(
      WidgetTester tester, {
      required Size size,
      Locale locale = const Locale('tr'),
    }) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final ctrl = LiveFeedController(
        repository: repo,
        teamsRepository: teamsRepo,
      );
      addTearDown(ctrl.dispose);
      await tester.pumpWidget(
        _wrap(
          LiveFeedScreen(
            controller: ctrl,
            tileLayer: const SizedBox.shrink(),
            officialUid: 'off1',
          ),
          locale: locale,
        ),
      );
      return ctrl;
    }

    testWidgets(
      'kart butonları sığmazsa metin kesilmez, alt alta dizilir (EN, 411 dp)',
      (tester) async {
        await pumpFeed(
          tester,
          size: const Size(411, 1400),
          locale: const Locale('en'),
        );
        repo.incidents.add([testIncident()]);
        await tester.pumpAndSettle();

        final dispatch = find.text('Dispatch Team');
        final detail = find.text('Detail');
        expect(
          tester.getTopLeft(dispatch).dy,
          isNot(tester.getTopLeft(detail).dy),
        );
        final text = tester.widget<Text>(dispatch);
        final painter = TextPainter(
          text: TextSpan(text: 'Dispatch Team', style: text.style),
          textDirection: TextDirection.ltr,
        )..layout();
        expect(
          tester.getSize(dispatch).width,
          greaterThanOrEqualTo(painter.width),
        );
        painter.dispose();
      },
    );

    testWidgets('geniş ekranda kart butonları yan yana kalır', (tester) async {
      await pumpFeed(tester, size: const Size(800, 1400));
      repo.incidents.add([testIncident()]);
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('Ekip Yönlendir')).dy,
        tester.getTopLeft(find.text('Detay')).dy,
      );
    });

    testWidgets('Detay bağlı çağrılardaki iptalleri ayrıca yazar', (
      tester,
    ) async {
      repo.detail = const IncidentDetail(
        fullName: 'Test Kişi',
        phone: '+905321234567',
        cancelledCalls: 1,
      );
      await pumpFeed(tester, size: const Size(400, 1400));
      repo.incidents.add([testIncident(requestCount: 3)]);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Detay'));
      await tester.pumpAndSettle();
      expect(find.text('3 (1 iptal edildi)'), findsOneWidget);
    });

    testWidgets(
      'internet yokken Ulaşıldı takılı kalmaz, bağlantı gelince gönderileceğini söyler',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => PanicSignalSheet.show(
                      context,
                      signal: testSignal(),
                      onMarkReached: () async => false,
                    ),
                    child: const Text('aç'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('aç'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ulaşıldı'));
        await tester.pumpAndSettle();

        expect(find.text('Panik Sinyali'), findsNothing);
        expect(
          find.text('İnternet yok; işaret bağlantı gelince iletilecek.'),
          findsOneWidget,
        );
      },
    );
  });

  group('Y2 Ekipler', () {
    testWidgets('boştaki ekipte Görev Ata, görevdeki ekipte Görev Güncelle', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final ctrl = TeamsController(
        repository: teamsRepo,
        liveFeedRepository: repo,
      );
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(
          TeamsScreen(
            controller: ctrl,
            tileLayer: const SizedBox.shrink(),
            officialUid: 'off1',
          ),
        ),
      );
      teamsRepo.teams.add([
        testTeam(id: 't1', name: 'Arama Kurtarma Tim 4', memberCount: 6),
        testTeam(
          id: 't2',
          name: 'Sağlık Ekibi 1',
          type: TeamType.medical,
          status: TeamStatus.onDuty,
          currentTask: 'inc1',
          memberCount: 4,
        ),
      ]);
      teamsRepo.assignments.add([
        const Assignment(
          id: 'a1',
          incidentId: 'inc1',
          teamId: 't2',
          status: CaseStatus.onSite,
          assignedBy: 'off1',
        ),
      ]);
      repo.incidents.add([
        testIncident(assignedTeamId: 't2', status: CaseStatus.onSite),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('2 Tim · 10 Personel'), findsOneWidget);
      expect(find.text('BOŞTA'), findsOneWidget);
      expect(find.text('GÖREVDE'), findsOneWidget);
      expect(find.text('Görev Ata'), findsOneWidget);
      expect(find.text('Görev Güncelle'), findsOneWidget);
      expect(find.text('Enkaz Altında · Olay Yerinde'), findsOneWidget);

      // Görev Güncelle: yalnızca bir sonraki adım (Kurtarıldı)
      await tester.tap(find.text('Görev Güncelle'));
      await tester.pumpAndSettle();
      expect(find.text('Kurtarıldı olarak işaretle'), findsOneWidget);
      await tester.tap(find.text('Kurtarıldı olarak işaretle'));
      await tester.pumpAndSettle();
      expect(teamsRepo.advanced, ['a1']);
    });

    testWidgets('Görev Ata yalnızca ekip bekleyen olayları listeler ve atar', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final ctrl = TeamsController(
        repository: teamsRepo,
        liveFeedRepository: repo,
      );
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _wrap(
          TeamsScreen(
            controller: ctrl,
            tileLayer: const SizedBox.shrink(),
            officialUid: 'off1',
          ),
        ),
      );
      teamsRepo.teams.add([testTeam()]);
      teamsRepo.assignments.add([]);
      repo.incidents.add([
        testIncident(
          id: 'busy',
          type: HelpType.medical,
          assignedTeamId: 'tX',
          status: CaseStatus.assigned,
        ),
        testIncident(id: 'waiting', type: HelpType.debris),
      ]);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Görev Ata'));
      await tester.pumpAndSettle();
      // Ekibi olan olay listede yok (tek aktif görev)
      expect(find.text('Tıbbi Müdahale'), findsNothing);
      await tester.tap(find.text('Enkaz Altında'));
      await tester.pumpAndSettle();
      expect(teamsRepo.assigned, [('waiting', 't1')]);
    });
  });
}
