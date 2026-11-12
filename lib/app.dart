import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/location_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/offline_queue_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/help_request/data/firestore_help_request_repository.dart';
import 'features/help_request/domain/help_request_repository.dart';
import 'features/profile/data/firestore_profile_repository.dart';
import 'features/profile/domain/profile_repository.dart';
import 'features/safety_signal/data/firestore_safety_signal_repository.dart';
import 'features/safety_signal/domain/safety_signal_repository.dart';
import 'l10n/app_localizations.dart';

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
  final HelpRequestRepository _helpRequestRepository =
      FirestoreHelpRequestRepository();
  late final OfflineQueueService _offlineQueueService = OfflineQueueService(
    repository: _helpRequestRepository,
    connectivityService: _connectivityService,
  );

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
    unawaited(_locationService.loadCached());
    unawaited(_connectivityService.initialize());
    unawaited(_notificationService.initialize());
    unawaited(_offlineQueueService.initialize());
  }

  void _onAuthChanged() {
    if (_auth.isInitializing) return;
    final user = _auth.currentUser;
    final optIn =
        user != null && !user.isPendingApproval && user.notificationsOptIn;
    unawaited(_notificationService.syncTopicSubscription(optIn: optIn));
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _locationService.dispose();
    _connectivityService.dispose();
    _notificationService.dispose();
    _offlineQueueService.dispose();
    _router.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: _authRepository),
        ChangeNotifierProvider<AuthController>.value(value: _auth),
        Provider<ProfileRepository>(create: (_) => FirestoreProfileRepository()),
        ChangeNotifierProvider<LocationService>.value(value: _locationService),
        ChangeNotifierProvider<ConnectivityService>.value(
          value: _connectivityService,
        ),
        Provider<NotificationService>.value(value: _notificationService),
        Provider<SafetySignalRepository>.value(value: _safetySignalRepository),
        Provider<HelpRequestRepository>.value(value: _helpRequestRepository),
        ChangeNotifierProvider<OfflineQueueService>.value(
          value: _offlineQueueService,
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'AfetNet',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system, // T14: Sistem temasını izler
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, _) =>
            locale?.languageCode == 'tr' ? const Locale('tr') : const Locale('en'),
        routerConfig: _router,
      ),
    );
  }
}
