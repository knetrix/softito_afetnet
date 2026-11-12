import 'dart:async';

import 'package:afetnet/core/constants/case_status.dart';
import 'package:afetnet/core/constants/help_type.dart';
import 'package:afetnet/core/constants/user_role.dart';
import 'package:afetnet/core/services/connectivity_service.dart';
import 'package:afetnet/core/services/location_service.dart';
import 'package:afetnet/core/services/offline_queue_service.dart';
import 'package:afetnet/core/theme/app_theme.dart';
import 'package:afetnet/features/auth/domain/app_user.dart';
import 'package:afetnet/features/auth/domain/auth_repository.dart';
import 'package:afetnet/features/auth/presentation/auth_controller.dart';
import 'package:afetnet/features/help_request/domain/assigned_team_info.dart';
import 'package:afetnet/features/help_request/domain/help_request.dart';
import 'package:afetnet/features/help_request/domain/help_request_draft.dart';
import 'package:afetnet/features/help_request/domain/help_request_repository.dart';
import 'package:afetnet/features/help_request/presentation/active_help_request_controller.dart';
import 'package:afetnet/features/help_request/presentation/widgets/active_request_card.dart';
import 'package:afetnet/features/home/presentation/home_screen.dart';
import 'package:afetnet/features/profile/domain/profile_repository.dart';
import 'package:afetnet/features/profile/domain/user_contact_profile.dart';
import 'package:afetnet/features/safety_signal/domain/safety_signal.dart';
import 'package:afetnet/features/safety_signal/domain/safety_signal_repository.dart';
import 'package:afetnet/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAuthRepository implements AuthRepository {
  @override
  Stream<String?> uidChanges() => Stream.value('c1');

  @override
  Future<AppUser?> fetchUser(String uid) async => const AppUser(
        uid: 'c1',
        fullName: 'Ahmet Yılmaz',
        role: UserRole.citizen,
        isVerified: false,
      );

  @override
  Future<AppUser> register(RegisterInput input) => throw UnimplementedError();

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<String> signIn({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}

class _TestLocationService extends LocationService {
  _TestLocationService({this.label});

  final String? label;
  final LatLng? coords = const LatLng(36.2, 36.16);

  @override
  LatLng? get currentPosition => coords;

  @override
  String? get currentLabel => label;

  @override
  LocationStatus get status => LocationStatus.ready;

  @override
  bool get isFetching => false;

  @override
  Future<void> loadCached() async {}

  @override
  Future<LocationSnapshot?> refresh() async =>
      coords == null ? null : LocationSnapshot(coordinates: coords!, label: label);

  @override
  Future<LatLng?> resolveCoordinates() async => coords;
}

class _TestSafetySignalRepository implements SafetySignalRepository {
  final _stream = StreamController<SafetySignal?>.broadcast();
  SignalDelivery nextDelivery = SignalDelivery.confirmed;

  @override
  Stream<SafetySignal?> watchSignal(String uid) => _stream.stream;

  @override
  Future<SignalDelivery> sendDanger(
    String uid,
    double latitude,
    double longitude,
  ) async {
    _stream.add(
      SafetySignal(
        uid: uid,
        state: SafetySignalState.danger,
        location: LatLng(latitude, longitude),
        geohash: 'sy72wxyz',
        updatedAt: DateTime.now(),
        hasPendingWrites: nextDelivery == SignalDelivery.pending,
      ),
    );
    return nextDelivery;
  }

  @override
  Future<void> sendSafe(String uid) async {
    _stream.add(
      SafetySignal(
        uid: uid,
        state: SafetySignalState.safe,
        location: const LatLng(36.2, 36.16),
        geohash: 'sy72wxyz',
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> close() => _stream.close();
}

class _TestProfileRepository implements ProfileRepository {
  @override
  Future<UserContactProfile?> getProfile(String uid) async =>
      const UserContactProfile(
        uid: 'c1',
        emergencyContactPhone: '+905551234567',
      );

  @override
  Stream<UserContactProfile?> watchProfile(String uid) => const Stream.empty();

  @override
  Future<void> deleteAccount(String uid, {required String password}) async {}

  @override
  Future<String?> getTeamName(String teamId) async => null;

  @override
  Future<void> updateAddress(String uid, {required String addressText}) async {}

  @override
  Future<void> updateEmergencyContact(
    String uid, {
    required String name,
    required String relation,
    required String phone,
  }) async {}

  @override
  Future<void> updateMedicalInfo(
    String uid, {
    required String bloodType,
    required String medications,
    required String conditions,
    required DateTime consentAt,
  }) async {}

  @override
  Future<void> updatePhysicalInfo(
    String uid, {
    required int? birthYear,
    required int? weightKg,
  }) async {}
}

class _TestHelpRequestRepository implements HelpRequestRepository {
  _TestHelpRequestRepository({this.activeRequest});

  final HelpRequest? activeRequest;

  @override
  Stream<HelpRequest?> watchActiveHelpRequest(String uid) =>
      Stream.value(activeRequest);

  @override
  Future<AssignedTeamInfo?> fetchTeamInfo(String teamId) async =>
      const AssignedTeamInfo(id: 't1', name: 'AKUT Hatay', leaderName: 'Lider');

  @override
  Future<void> cancelHelpRequest(String requestId) async {}

  @override
  Future<String> submitHelpRequest(HelpRequestDraft draft) async => draft.id;
}

Widget _wrapHome({
  required AuthController auth,
  required LocationService location,
  required SafetySignalRepository signalRepo,
  required ProfileRepository profileRepo,
  ActiveHelpRequestController? activeHelpRequestController,
  Future<bool> Function(Uri uri)? urlLauncher,
  double textScale = 1.0,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: auth),
      ChangeNotifierProvider<LocationService>.value(value: location),
      Provider<SafetySignalRepository>.value(value: signalRepo),
      Provider<ProfileRepository>.value(value: profileRepo),
    ],
    child: MaterialApp(
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
      home: HomeScreen(
        panicHoldDuration: const Duration(milliseconds: 50),
        urlLauncher: urlLauncher,
        activeHelpRequestController: activeHelpRequestController,
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HomeScreen 360x640 ve büyük yazıda taşma olmadan açılır', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final auth = AuthController(_TestAuthRepository());
    final location = _TestLocationService(label: 'Antakya, Hatay');
    final signalRepo = _TestSafetySignalRepository();
    final profileRepo = _TestProfileRepository();
    addTearDown(() async {
      auth.dispose();
      location.dispose();
      await signalRepo.close();
    });

    await tester.pumpWidget(
      _wrapHome(
        auth: auth,
        location: location,
        signalRepo: signalRepo,
        profileRepo: profileRepo,
        textScale: 1.6,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Ahmet Yılmaz'), findsOneWidget);
    expect(find.text('Antakya, Hatay'), findsOneWidget);
    expect(find.textContaining('PANİĞİM'), findsOneWidget);
    expect(find.text('YARDIM ÇAĞRISI EKLE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeScreen çevrimdışı panikte SMS diyaloğu ve GÜVENDEYİM açar', (tester) async {
    final auth = AuthController(_TestAuthRepository());
    final location = _TestLocationService(label: null);
    final signalRepo = _TestSafetySignalRepository()
      ..nextDelivery = SignalDelivery.pending;
    final profileRepo = _TestProfileRepository();
    Uri? launchedUri;

    addTearDown(() async {
      auth.dispose();
      location.dispose();
      await signalRepo.close();
    });

    await tester.pumpWidget(
      _wrapHome(
        auth: auth,
        location: location,
        signalRepo: signalRepo,
        profileRepo: profileRepo,
        urlLauncher: (uri) async {
          launchedUri = uri;
          return true;
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Konum etiketi yoksa uydurma etiket gösterilmez
    expect(find.text('Konum alınamadı — Yenilemek için dokunun'), findsOneWidget);

    // 2 sn (testte 50 ms) basılı tutma
    final gesture = await tester.startGesture(
      tester.getCenter(find.textContaining('PANİĞİM')),
    );
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // Çevrimdışı SMS diyaloğu açılır
    expect(find.text('Çevrimdışı Sinyal'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('SMS ile Haber Ver'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(launchedUri, isNotNull);
    expect(launchedUri!.scheme, 'sms');
    expect(launchedUri!.path, '+905551234567');
    expect(launchedUri!.query, isNot(contains('+')));

    // Buton GÜVENDEYİM görünümüne geçer
    expect(find.textContaining('GÜVENDEYİM'), findsOneWidget);
  });

  testWidgets('HomeScreen aktif yardım çağrısı varsa ActiveRequestCard gösterir', (tester) async {
    final auth = AuthController(_TestAuthRepository());
    final location = _TestLocationService(label: 'Antakya, Hatay');
    final signalRepo = _TestSafetySignalRepository();
    final profileRepo = _TestProfileRepository();
    final helpRepo = _TestHelpRequestRepository(
      activeRequest: HelpRequest(
        id: 'req_1',
        createdBy: 'c1',
        type: HelpType.debris,
        priority: 1,
        status: CaseStatus.assigned,
        peopleCount: 4,
        location: const LatLng(36.2, 36.16),
        geohash: 'sy72wxyz',
        createdAt: DateTime.now(),
        assignedTeamId: 't1',
      ),
    );
    final offlineQueue = OfflineQueueService(
      repository: helpRepo,
      connectivityService: DeviceConnectivityService(),
    );
    final activeCtrl = ActiveHelpRequestController(
      repository: helpRepo,
      queueService: offlineQueue,
      citizenUid: 'c1',
    );

    addTearDown(() async {
      auth.dispose();
      location.dispose();
      await signalRepo.close();
      activeCtrl.dispose();
      offlineQueue.dispose();
    });

    await tester.pumpWidget(
      _wrapHome(
        auth: auth,
        location: location,
        signalRepo: signalRepo,
        profileRepo: profileRepo,
        activeHelpRequestController: activeCtrl,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ActiveRequestCard), findsOneWidget);
    expect(find.text('Ekip Yönlendirildi'), findsOneWidget);
    expect(find.text('Enkaz Altında'), findsOneWidget);
    expect(find.text('4 Kişi'), findsOneWidget);
    expect(find.textContaining('AKUT Hatay'), findsOneWidget);
  });
}

