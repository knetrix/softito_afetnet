import 'package:go_router/go_router.dart';

import '../../features/assembly_points/presentation/assembly_points_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/live_feed/presentation/live_feed_screen.dart';
import '../../features/logistics/presentation/logistics_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/citizen_profile_screen.dart';
import '../../features/profile/presentation/official_profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/teams/presentation/teams_screen.dart';
import '../../features/whistle/presentation/whistle_screen.dart';
import 'app_routes.dart';
import 'citizen_shell.dart';
import 'official_shell.dart';

/// `app.dart`'ta bir kez oluşturulur (build içinde değil).
GoRouter createAppRouter(AuthController auth) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: auth, // oturum/rol değişince redirect yeniden çalışır
    redirect: (context, state) => appRedirect(auth, state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => CitizenShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.assembly, builder: (_, _) => const AssemblyPointsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.whistle, builder: (_, _) => const WhistleScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.citizenProfile, builder: (_, _) => const CitizenProfileScreen()),
          ]),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => OfficialShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.liveFeed, builder: (_, _) => const LiveFeedScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.teams, builder: (_, _) => const TeamsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.logistics, builder: (_, _) => const LogisticsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.officialProfile, builder: (_, _) => const OfficialProfileScreen()),
          ]),
        ],
      ),
    ],
  );
}

/// Rol bazlı yönlendirme (§2). Test edilebilmesi için ayrı fonksiyondur.
String? appRedirect(AuthController auth, String location) {
  if (auth.isInitializing) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final user = auth.currentUser;
  if (user == null) {
    if (AppRoutes.publicPaths.contains(location)) return null;
    return auth.onboardingDone ? AppRoutes.login : AppRoutes.onboarding;
  }

  // Onaysız yetkili hiçbir ekrana giremez; signOut tamamlanana kadar da (R4).
  if (user.isPendingApproval) {
    return location == AppRoutes.login ? null : AppRoutes.login;
  }

  // Yetkiyi her zaman veritabanındaki rol belirler.
  final home = user.isOfficial ? AppRoutes.liveFeed : AppRoutes.home;
  final allowed = user.isOfficial ? AppRoutes.officialPaths : AppRoutes.citizenPaths;
  return allowed.contains(location) ? null : home;
}
