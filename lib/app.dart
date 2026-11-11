import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/profile/data/firestore_profile_repository.dart';
import 'features/profile/domain/profile_repository.dart';
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

  @override
  void dispose() {
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
        // Diğer repository ve servisler sonraki adımlarda eklenir.
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
