// Ekranların adreslerini (rota yollarını) tek yerde tutan sabitler.
// Böylece "/feed" gibi metinleri kodun her yerine tek tek yazmayız.

/// 12 ekranın rotaları (PROJECT_NEW.md §3.1). Ek işlemler için rota eklenmez;
/// bottom sheet / diyalog açılır (§3.2).
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';

  // citizen
  static const home = '/home';
  static const assembly = '/assembly';
  static const whistle = '/whistle';
  static const citizenProfile = '/profile';

  // official
  static const liveFeed = '/feed';
  static const teams = '/teams';
  static const logistics = '/logistics';
  static const officialProfile = '/official-profile';

  static const publicPaths = {onboarding, login, register};
  static const citizenPaths = {home, assembly, whistle, citizenProfile};
  static const officialPaths = {liveFeed, teams, logistics, officialProfile};
}
