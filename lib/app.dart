import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/user_role.dart';
import 'core/router/app_router.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/location_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';

import 'features/broadcast/data/broadcast_notification_listener.dart';

import 'features/profile/data/firestore_profile_repository.dart';
import 'features/profile/domain/profile_repository.dart';

import 'features/safety_signal/data/firestore_safety_signal_repository.dart';
import 'features/safety_signal/domain/safety_signal_repository.dart';

import 'l10n/app_localizations.dart';
import 'features/live_feed/data/firestore_live_feed_repository.dart';
import 'features/live_feed/domain/live_feed_repository.dart';

import 'features/teams/data/firestore_teams_repository.dart';
import 'features/teams/domain/teams_repository.dart';

class AfetNetApp extends StatefulWidget {
  const AfetNetApp({super.key});

  @override
  State<AfetNetApp> createState() => _AfetNetAppState();
}

class _AfetNetAppState extends State<AfetNetApp> {
  final AuthRepository _authRepository = FirebaseAuthRepository();

  late final AuthController _auth = AuthController(_authRepository);

  late final GoRouter _router = createAppRouter(_auth);

  final LocationService _locationService = DeviceLocationService();

  final ConnectivityService _connectivityService = DeviceConnectivityService();

  final NotificationService _notificationService = DeviceNotificationService();

  final SafetySignalRepository _safetySignalRepository =
      FirestoreSafetySignalRepository();

  // G6 - Tahliye anonsu dinleyicisi.
  // Mevcut G3 konum ve bildirim servislerini kullanır.
  late final BroadcastNotificationListener _broadcastListener =
      BroadcastNotificationListener(
        locationService: _locationService,
        notificationService: _notificationService,
      );

  String? _listeningCitizenUid;

  @override
  void initState() {
    super.initState();

    _auth.addListener(_onAuthChanged);

    unawaited(_locationService.loadCached());

    unawaited(_connectivityService.initialize());

    unawaited(_notificationService.initialize());
  }

  void _onAuthChanged() {
    if (_auth.isInitializing) {
      return;
    }

    final user = _auth.currentUser;

    // G3 - all_users FCM aboneliği.
    final optIn =
        user != null && !user.isPendingApproval && user.notificationsOptIn;

    unawaited(_notificationService.syncTopicSubscription(optIn: optIn));

    // G6 - Bölgesel tahliye dinleyicisi.
    // Sadece afetzede + bildirim onayı açıkken çalışır.
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

    // AuthController'ın her bildiriminde aynı
    // Firestore listener'ını yeniden açma.
    if (_listeningCitizenUid == uid) {
      return;
    }

    _listeningCitizenUid = uid;

    unawaited(_broadcastListener.start(uid));
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);

    _broadcastListener.dispose();

    _locationService.dispose();
    _connectivityService.dispose();
    _notificationService.dispose();

    _router.dispose();
    _auth.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        Provider<LiveFeedRepository>(
  create: (_) => FirestoreLiveFeedRepository(),
),

Provider<TeamsRepository>(
  create: (_) => FirestoreTeamsRepository(),
),
        Provider<AuthRepository>.value(value: _authRepository),

        ChangeNotifierProvider<AuthController>.value(value: _auth),

        Provider<ProfileRepository>(
          create: (_) => FirestoreProfileRepository(),
        ),

        ChangeNotifierProvider<LocationService>.value(value: _locationService),

        ChangeNotifierProvider<ConnectivityService>.value(
          value: _connectivityService,
        ),

        Provider<NotificationService>.value(value: _notificationService),

        Provider<SafetySignalRepository>.value(value: _safetySignalRepository),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,

        onGenerateTitle: (context) =>
            AppLocalizations.of(context)?.appTitle ?? 'AfetNet',

        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),

        themeMode: ThemeMode.system,

        localizationsDelegates: AppLocalizations.localizationsDelegates,

        supportedLocales: AppLocalizations.supportedLocales,

        localeResolutionCallback: (locale, _) {
          return locale?.languageCode == 'tr'
              ? const Locale('tr')
              : const Locale('en');
        },

        routerConfig: _router,
      ),
    );
  }
}
