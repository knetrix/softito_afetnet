// Uygulamanın kök (en üst) widget'ı.
// Servisler burada bir kez oluşturulur ve MultiProvider ile tüm ekranlara dağıtılır;
// tema, dil ve GoRouter (sayfa geçişleri) de burada MaterialApp'e bağlanır.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/user_role.dart';
import 'core/router/app_router.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/locale_controller.dart';
import 'core/services/location_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/offline_queue_service.dart';
import 'core/theme/app_theme.dart';

import 'features/assembly_points/data/firestore_assembly_points_repository.dart';
import 'features/assembly_points/domain/assembly_points_repository.dart';

import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';

import 'features/broadcast/data/broadcast_notification_listener.dart';
import 'features/broadcast/data/firestore_broadcast_repository.dart';
import 'features/broadcast/domain/broadcast_repository.dart';

import 'features/help_request/data/firestore_help_request_repository.dart';
import 'features/help_request/domain/help_request_repository.dart';

import 'features/live_feed/data/firestore_live_feed_repository.dart';
import 'features/live_feed/domain/live_feed_repository.dart';

import 'features/profile/data/firestore_profile_repository.dart';
import 'features/profile/domain/profile_repository.dart';

import 'features/safety_signal/data/firestore_safety_signal_repository.dart';
import 'features/safety_signal/domain/safety_signal_repository.dart';

import 'features/teams/data/firestore_teams_repository.dart';
import 'features/teams/domain/teams_repository.dart';

import 'l10n/app_localizations.dart';

// Uygulamanın en dıştaki widget'ı. StatefulWidget'tır çünkü servisleri bir kez oluşturup saklaması gerekir.
// Dil denetleyicisi main.dart'ta oluşturulup buraya parametre olarak verilir.
class AfetNetApp extends StatefulWidget {
  const AfetNetApp({super.key, required this.localeController});

  final LocaleController localeController;

  // Bu StatefulWidget'ın değişen verilerini tutacak State nesnesini oluşturur.
  @override
  State<AfetNetApp> createState() => _AfetNetAppState();
}

// AfetNetApp'in durumunu (State) tutan sınıf.
// Servisler (konum, bildirim, kuyruk…) burada alan olarak bir kez oluşturulur; ekran yeniden çizilse de kaybolmaz.
class _AfetNetAppState extends State<AfetNetApp> {
  final AuthRepository _authRepository = FirebaseAuthRepository();

  late final AuthController _auth = AuthController(_authRepository);

  late final GoRouter _router = createAppRouter(_auth);

  final LocationService _locationService = DeviceLocationService();

  final ConnectivityService _connectivityService = DeviceConnectivityService();

  final NotificationService _notificationService = DeviceNotificationService();

  final SafetySignalRepository _safetySignalRepository =
      FirestoreSafetySignalRepository();

  // G4 - Yardım çağrıları ve çevrimdışı kuyruk
  final HelpRequestRepository _helpRequestRepository =
      FirestoreHelpRequestRepository();

  final AssemblyPointsRepository _assemblyPointsRepository =
      FirestoreAssemblyPointsRepository();

  late final OfflineQueueService _offlineQueueService = OfflineQueueService(
    repository: _helpRequestRepository,
    connectivityService: _connectivityService,
  );

  // G6 - Bölgesel tahliye bildirimleri
  late final BroadcastNotificationListener _broadcastListener =
      BroadcastNotificationListener(
        locationService: _locationService,
        notificationService: _notificationService,
      );

  String? _listeningCitizenUid;

  // Widget ekrana ilk geldiğinde yalnızca bir kez çalışır; dinleyiciler ve başlangıç verileri burada hazırlanır.
  @override
  void initState() {
    super.initState();

    _auth.addListener(_onAuthChanged);

    unawaited(_locationService.loadCached());
    unawaited(_connectivityService.initialize());
    unawaited(_notificationService.initialize());

    // G4 - Çevrimdışı işlemleri başlat.
    unawaited(_offlineQueueService.initialize());
  }

  // Oturum açan kullanıcı veya rolü değişince çalışır.
  // Örneğin bildirim onayına göre FCM topic aboneliğini açar/kapatır, yetkiliden bildirim izni ister.
  void _onAuthChanged() {
    if (_auth.isInitializing) {
      return;
    }

    final user = _auth.currentUser;

    // G3 - FCM topic aboneliği
    final optIn =
        user != null && !user.isPendingApproval && user.notificationsOptIn;

    unawaited(_notificationService.syncTopicSubscription(optIn: optIn));

    // G3 - Onaylı yetkililerin panik bildirimleri için izin
    if (user != null && user.isOfficial && !user.isPendingApproval) {
      unawaited(_notificationService.requestPermission());
    }

    // G6 - Tahliye anonslarını yalnızca uygun afetzedeler dinler
    final shouldListen =
        user != null &&
        user.role == UserRole.citizen &&
        !user.isPendingApproval &&
        user.notificationsOptIn;

    if (!shouldListen) {
      _listeningCitizenUid = null;
      _broadcastListener.stop();
      return;
    }

    final uid = user.uid;

    // Aynı kullanıcı için dinleyiciyi tekrar başlatma.
    if (_listeningCitizenUid == uid) {
      return;
    }

    _listeningCitizenUid = uid;

    unawaited(_broadcastListener.start(uid));
  }

  // Kapanırken çalışır: dinleyicileri, akışları ve denetleyicileri kapatır (bellek sızıntısı olmasın diye).
  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);

    _broadcastListener.dispose();
    _offlineQueueService.dispose();

    _locationService.dispose();
    _connectivityService.dispose();
    _notificationService.dispose();

    _router.dispose();
    _auth.dispose();

    super.dispose();
  }

  // Ekranda görünecek arayüzü (widget ağacını) oluşturur. Veri değişince Flutter bu metodu yeniden çağırır.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: _authRepository),

        ChangeNotifierProvider<AuthController>.value(value: _auth),

        ChangeNotifierProvider<LocaleController>.value(
          value: widget.localeController,
        ),

        Provider<ProfileRepository>(
          create: (_) => FirestoreProfileRepository(),
        ),

        ChangeNotifierProvider<LocationService>.value(value: _locationService),

        ChangeNotifierProvider<ConnectivityService>.value(
          value: _connectivityService,
        ),

        Provider<NotificationService>.value(value: _notificationService),

        Provider<SafetySignalRepository>.value(value: _safetySignalRepository),

        Provider<HelpRequestRepository>.value(value: _helpRequestRepository),

        Provider<AssemblyPointsRepository>.value(
          value: _assemblyPointsRepository,
        ),

        Provider<LiveFeedRepository>(
          create: (_) => FirestoreLiveFeedRepository(),
        ),

        Provider<TeamsRepository>(create: (_) => FirestoreTeamsRepository()),

        Provider<BroadcastRepository>(
          create: (_) => FirestoreBroadcastRepository(),
        ),

        ChangeNotifierProvider<OfflineQueueService>.value(
          value: _offlineQueueService,
        ),
      ],
      child: ListenableBuilder(
        listenable: widget.localeController,
        builder: (context, _) => MaterialApp.router(
          debugShowCheckedModeBanner: false,

          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.appTitle ?? 'AfetNet',

          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,

          localizationsDelegates: AppLocalizations.localizationsDelegates,

          supportedLocales: AppLocalizations.supportedLocales,

          // Cihaz dilinden bağımsız: varsayılan Türkçe, Profil'den İngilizce.
          locale: widget.localeController.locale,

          routerConfig: _router,
        ),
      ),
    );
  }
}
