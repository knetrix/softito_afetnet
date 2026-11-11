import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';

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
        // Diğer repository ve servisler buraya eklenir.
      ],
      child: MaterialApp.router(
        title: 'AfetNet',
        debugShowCheckedModeBanner: false,
        // TODO(G2): AppTheme.light() / AppTheme.dark() (§3.4) ve ARB dil
        // kurulumu (localizationsDelegates, supportedLocales, cihaz dili).
        theme: ThemeData(brightness: Brightness.light),
        darkTheme: ThemeData(brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
