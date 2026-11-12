import 'package:afetnet/core/constants/case_status.dart';
import 'package:afetnet/core/constants/help_type.dart';
import 'package:afetnet/core/theme/app_theme.dart';
import 'package:afetnet/features/help_request/domain/assigned_team_info.dart';
import 'package:afetnet/features/help_request/domain/help_request.dart';
import 'package:afetnet/features/help_request/domain/help_request_draft.dart';
import 'package:afetnet/features/help_request/presentation/widgets/active_request_card.dart';
import 'package:afetnet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

Widget _buildCard({
  HelpRequest? request,
  HelpRequestDraft? offlineDraft,
  AssignedTeamInfo? assignedTeam,
  Future<bool> Function(String)? onCancel,
  double textScale = 1.0,
}) {
  return MaterialApp(
    theme: AppTheme.dark(),
    locale: const Locale('tr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
      ),
      child: child!,
    ),
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ActiveRequestCard(
            request: request,
            offlineDraft: offlineDraft,
            assignedTeam: assignedTeam,
            onCancel: onCancel ?? (_) async => true,
          ),
        ),
      ),
    ),
  );
}

void main() {
  final sampleRequest = HelpRequest(
    id: 'req_123',
    createdBy: 'user_1',
    type: HelpType.debris,
    priority: 1,
    status: CaseStatus.assigned,
    peopleCount: 3,
    location: const LatLng(36.202, 36.160),
    geohash: 'sy72wxyz',
    createdAt: DateTime.now(),
    addressText: 'Atatürk Cad. No: 42, Antakya',
    description: '2. kat çöktü, ses geliyor',
    assignedTeamId: 'team_akut_1',
  );

  testWidgets('ActiveRequestCard aktif çağrı bilgilerini ve ekip detayını gösterir', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildCard(
        request: sampleRequest,
        assignedTeam: const AssignedTeamInfo(
          id: 'team_akut_1',
          name: 'AKUT Hatay-1',
          leaderName: 'Mehmet Kaptan',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ekip Yönlendirildi'), findsOneWidget);
    expect(find.text('KRİTİK'), findsOneWidget);
    expect(find.text('Enkaz Altında'), findsOneWidget);
    expect(find.text('3 Kişi'), findsOneWidget);
    expect(find.textContaining('AKUT Hatay-1'), findsOneWidget);
    expect(find.textContaining('Mehmet Kaptan'), findsOneWidget);
    expect(find.text('Atatürk Cad. No: 42, Antakya'), findsOneWidget);
    expect(find.text('2. kat çöktü, ses geliyor'), findsOneWidget);
    expect(find.text('Çağrıyı İptal Et'), findsOneWidget);
  });

  testWidgets('ActiveRequestCard henüz ekip atanmadıysa bekleme mesajı gösterir', (tester) async {
    await tester.pumpWidget(
      _buildCard(
        request: sampleRequest.copyWith(
          status: CaseStatus.pending,
          assignedTeamId: null,
        ),
        assignedTeam: null,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Beklemede'), findsOneWidget);
    expect(find.text('Ekip yönlendirmesi bekleniyor...'), findsOneWidget);
  });

  testWidgets('ActiveRequestCard çevrimdışı taslak için "Gönderilmeyi Bekliyor" gösterir', (tester) async {
    final draft = HelpRequestDraft(
      id: 'draft_99',
      createdBy: 'user_1',
      fullName: 'Ahmet Yılmaz',
      phone: '05551234567',
      location: const LatLng(36.20, 36.16),
      type: HelpType.medical,
      peopleCount: 2,
      addressText: 'Köprübaşı, Defne',
      description: 'Acil ilaç ve pansuman lazım',
      createdOffline: true,
    );

    await tester.pumpWidget(_buildCard(offlineDraft: draft));
    await tester.pumpAndSettle();

    expect(find.text('Gönderilmeyi Bekliyor'), findsOneWidget);
    expect(find.text('Tıbbi Müdahale'), findsOneWidget);
    expect(find.text('2 Kişi'), findsOneWidget);
    expect(find.text('Köprübaşı, Defne'), findsOneWidget);
    expect(find.text('Ekip yönlendirmesi bekleniyor...'), findsOneWidget);
  });

  testWidgets('ActiveRequestCard iptal butonuna basıldığında onay diyalogu açar ve onaylanırsa onCancel çağırır', (tester) async {
    String? cancelledId;

    await tester.pumpWidget(
      _buildCard(
        request: sampleRequest,
        onCancel: (id) async {
          cancelledId = id;
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    final cancelButton = find.text('Çağrıyı İptal Et');
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    // Dialog açıldı mı?
    expect(find.text('Çağrıyı İptal Et'), findsNWidgets(2));
    expect(
      find.text(
        'Yardım çağrınızı iptal etmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
      ),
      findsOneWidget,
    );

    // Onayla
    final confirmButton = find.text('Evet, İptal Et');
    expect(confirmButton, findsOneWidget);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    expect(cancelledId, 'req_123');
    expect(find.text('Yardım çağrınız iptal edildi.'), findsOneWidget);
  });

  testWidgets('ActiveRequestCard çözülmüş (resolved) çağrıda iptal butonu göstermez', (tester) async {
    await tester.pumpWidget(
      _buildCard(
        request: sampleRequest.copyWith(status: CaseStatus.resolved),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kurtarıldı'), findsOneWidget);
    expect(find.text('Çağrıyı İptal Et'), findsNothing);
  });

  testWidgets('ActiveRequestCard 360x640 ve 1.3x metin ölçeğinde taşma olmadan çizilir', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _buildCard(
        request: sampleRequest,
        assignedTeam: const AssignedTeamInfo(
          id: 'team_1',
          name: 'AKUT Hatay Kurtarma Ekibi 1',
          leaderName: 'Ali Veli Çokuzunsoyadlıoğlu',
        ),
        textScale: 1.3,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
