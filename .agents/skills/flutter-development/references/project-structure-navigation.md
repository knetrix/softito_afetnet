# Proje Yapısı ve Navigasyon

Kaynak: `PROJECT_NEW.md` §6.1 (klasörler), §3.1 (ekranlar), §2 (roller), §3.4 (tasarım sistemi).

## 1. Klasör Yapısı

```text
lib/
  main.dart                 # Firebase.initializeApp, Crashlytics, Hive.initFlutter, runApp
  app.dart                  # MultiProvider + MaterialApp.router (tema, dil, router)
  core/
    config/app_config.dart  # OSM tile URL, userAgentPackageName, yasal metin URL'leri
    constants/              # enum'lar: UserRole, HelpType, CaseStatus, TeamStatus …
    theme/                  # token'lar, AppStatusColors, koyu/açık tema
    router/                 # GoRouter, alt menü shell'leri, rol yönlendirmesi
    services/               # location, connectivity, notification, offline_queue
    utils/                  # validators.dart, priority_policy.dart
    widgets/                # AppButton, StateView, GlowCircleButton, StatusBadge, AppBottomSheet, AppDialog
  l10n/                     # app_tr.arb, app_en.arb
  features/<feature>/
    data/                   # Firestore/Hive kodu, DTO dönüşümü, repository uygulaması
    domain/                 # entity, repository arayüzü, iş kuralı fonksiyonları
    presentation/           # *_screen.dart, *_controller.dart, widgets/, sheets/
test/
  core/utils/               # priority_policy, validators testleri
  features/<feature>/       # domain ve controller testleri
```

**Feature adları sabittir (§6.1):** `splash`, `onboarding`, `auth`, `profile`,
`safety_signal`, `home`, `help_request`, `assembly_points`, `whistle`, `live_feed`, `teams`,
`logistics`, `broadcast`, `demo_seed` (yalnızca debug). Yeni ad uydurulmaz.

### Katman bağımlılığı

```text
presentation ──► domain ◄── data
      │                       │
      └──► core (theme, widgets, l10n, services, utils) ◄──┘
```

- `domain/` Firebase ve UI paketi import etmez. İstisnalar: `@immutable` için
  `package:flutter/foundation.dart`, konum için `latlong2`. (`package:meta` doğrudan
  bağımlılık değildir; `depend_on_referenced_packages` uyarısı verir.)
- `presentation/` repository **arayüzünü** kullanır; somut `data/` sınıfı yalnızca
  `app.dart`'taki Provider kurulumunda görünür.
- Feature'lar birbirinin `presentation/`'ını import etmez. İstisna: `home` (A1),
  `safety_signal` ve `help_request` widget'larını gösterir; bağımlılık yalnızca bu yöndedir.
  Ortak ihtiyaç `core/`'a taşınır.

### Dosya adlandırma

| Tür | Dosya / sınıf | Örnek |
|---|---|---|
| Ekran | `<ad>_screen.dart` / `<Ad>Screen` | `live_feed_screen.dart` |
| Controller | `<ad>_controller.dart` / `<Ad>Controller` | `live_feed_controller.dart` |
| Sheet | `sheets/<ad>_sheet.dart` + `show<Ad>Sheet()` | `sheets/team_dispatch_sheet.dart` |
| Entity | `domain/<ad>.dart` | `domain/incident.dart` |
| Repository | `domain/<ad>_repository.dart` + `data/firestore_<ad>_repository.dart` | `incident_repository.dart` |

## 2. `main.dart` ve `app.dart`

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await Hive.initFlutter(); // çevrimdışı çağrı kuyruğu kutusu burada açılır (Kural 4)
  runApp(const AfetNetApp());
}
```

```dart
// app.dart
class AfetNetApp extends StatefulWidget {
  const AfetNetApp({super.key});

  @override
  State<AfetNetApp> createState() => _AfetNetAppState();
}

class _AfetNetAppState extends State<AfetNetApp> {
  late final AuthController _auth = AuthController(FirebaseAuthRepository());
  late final GoRouter _router = createAppRouter(_auth); // build içinde oluşturulmaz

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: _auth),
        Provider<IncidentRepository>(create: (_) => FirestoreIncidentRepository()),
        // diğer repository ve servisler …
      ],
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system, // T14
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, _) =>
            locale?.languageCode == 'tr' ? const Locale('tr') : const Locale('en'),
        routerConfig: _router,
      ),
    );
  }
}
```

## 3. Rotalar ve Rol Yönlendirmesi

Toplam 12 rota vardır (§3.1). Detay, Ekip Yönlendir, Görev Ata gibi işlemler için rota
**eklenmez**, sheet açılır (§3.2).

```dart
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
}
```

```dart
GoRouter createAppRouter(AuthController auth) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: auth, // oturum/rol değişince redirect yeniden çalışır
    redirect: (context, state) => _redirect(auth, state.matchedLocation),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => CitizenShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.assembly, builder: (_, _) => const AssemblyPointsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.whistle, builder: (_, _) => const WhistleScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.citizenProfile, builder: (_, _) => const CitizenProfileScreen())]),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => OfficialShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.liveFeed, builder: (_, _) => const LiveFeedScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.teams, builder: (_, _) => const TeamsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.logistics, builder: (_, _) => const LogisticsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: AppRoutes.officialProfile, builder: (_, _) => const OfficialProfileScreen())]),
        ],
      ),
    ],
  );
}

const _publicPaths = {AppRoutes.onboarding, AppRoutes.login, AppRoutes.register};
const _citizenPaths = {AppRoutes.home, AppRoutes.assembly, AppRoutes.whistle, AppRoutes.citizenProfile};
const _officialPaths = {AppRoutes.liveFeed, AppRoutes.teams, AppRoutes.logistics, AppRoutes.officialProfile};

String? _redirect(AuthController auth, String location) {
  if (auth.isInitializing) return location == AppRoutes.splash ? null : AppRoutes.splash;

  final user = auth.currentUser; // users/{uid} belgesinden AppUser?
  if (user == null) {
    if (_publicPaths.contains(location)) return null;
    return auth.onboardingDone ? AppRoutes.login : AppRoutes.onboarding;
  }

  // Onaysız yetkili hiçbir ekrana giremez (§2, R4).
  if (user.isOfficial && !user.isVerified) {
    return location == AppRoutes.login ? null : AppRoutes.login;
  }

  // Yetkiyi her zaman veritabanındaki rol belirler (§2).
  final home = user.isOfficial ? AppRoutes.liveFeed : AppRoutes.home;
  final allowed = user.isOfficial ? _officialPaths : _citizenPaths;
  return allowed.contains(location) ? null : home;
}
```

**Onaysız yetkili ve rol uyuşmazlığı (§2):** Kontrol iki yerde yapılır.
1. `AuthController`: hem `signIn` içinde hem `authStateChanges` dinleyicisinde (uygulama
   yeniden açılınca Firebase oturumu geri yükler, `signIn` çalışmaz). `role == official &&
   !isVerified` ise `signOut()` çağrılır ve `pendingApproval` hatası state'e yazılır; Giriş
   ekranı "Hesabınız yönetici onayı bekliyor" metnini ARB'den gösterir. Girişte seçilen tür
   `users.role` ile uyuşmazsa `signIn` içinde aynı şekilde oturum kapatılır.
2. `_redirect`: `signOut` tamamlanana kadar geçen sürede bile yetkili ekranı açılmasın diye.

### Alt menü (shell)

```dart
class CitizenShell extends StatelessWidget {
  const CitizenShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: l10n.navHome),
          NavigationDestination(icon: const Icon(Icons.place_outlined), label: l10n.navAssembly),
          NavigationDestination(icon: const Icon(Icons.campaign_outlined), label: l10n.navWhistle),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: l10n.navProfile),
        ],
      ),
    );
  }
}
```

`OfficialShell` aynı yapıdadır: Canlı Akış / Ekipler / Lojistik / Profil (T10: SOS / MESH /
MAP / CONFIG yazılmaz). `indexedStack` sekmeleri canlı tutar; sekme değişince ekran
controller'ı dispose olmaz.

### Navigasyon kuralları

- Sekme: `shell.goBranch(i)`. Rol ekranları arası: `context.go(...)`.
- Sheet/diyalog kapatma: `Navigator.of(context).pop(sonuç)`.
- Çıkış Yap: yalnızca `auth.signOut()`; `refreshListenable` kullanıcıyı Giriş'e götürür.
- Harici bağlantı (`tel:112`, `sms:`, yasal metin URL'leri): `url_launcher` `launchUrl`.

## 4. Tema (§3.4, T14)

- Hex değerleri **yalnızca** `core/theme/` içindeki token sınıfında yazılır (§3.4 tablosu).
  Y1 mor panik pini rengi de burada bir token olarak tanımlanır.
- `ThemeData(useMaterial3: true)`; renkler `ColorScheme(...)` içine açıkça verilir
  (`fromSeed` kullanılmaz, tasarım renkleri bozulur).
- Durum renkleri `ThemeExtension<AppStatusColors>`: `critical` (danger), `urgent` (warning),
  `normal` (success), `whistle`, `panic`; `copyWith` ve `lerp` uygulanır.
  `forPriority(int)` yardımcı metodu öncelik → renk eşlemesini tek yerde tutar.
- Koyu ve açık tema aynı token'lardan üretilir (`AppTheme.dark()` / `AppTheme.light()`);
  ekranlarda ayrı açık-tema rengi yazılmaz. Açık temada `primary` (#00E1FF) beyaz zeminde
  metin rengi olarak okunaksızdır: metinde `onSurface`, vurguda dolgu kullanılır.
- Yazı tipleri `assets/fonts/` altına gömülür (internetsiz): Space Grotesk (başlık), Inter
  (gövde), JetBrains Mono (etiket). `google_fonts` paketi kullanılmaz.

Ekranda kullanım:

| İhtiyaç | Kullan |
|---|---|
| Arka plan, kart, metin, ana buton | `Theme.of(context).colorScheme` |
| Öncelik, düdük, panik, stok etiketi | `Theme.of(context).extension<AppStatusColors>()!` |
| Yazı stili | `Theme.of(context).textTheme` |

## 5. Dil (ARB)

- `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`,
  `output-localization-file: app_localizations.dart`; `pubspec.yaml`'da `flutter: generate: true`.
- Anahtar adı camelCase, `<ekran/feature><Ne>`: `loginTitle`, `homePanicHold`,
  `requestPendingSend`, `disclaimerNotOfficial`. Ortak metinler önek almaz: `cancel`, `save`,
  `retry`, `genericError`.
- Parametre ve çoğul ICU biçimiyle yazılır. `app_en.arb` örneği:

```json
{
  "peopleCount": "{count, plural, =1{1 person} other{{count} people}}",
  "@peopleCount": { "placeholders": { "count": { "type": "int" } } },
  "teamDispatchedTo": "Team dispatched — {teamName}",
  "@teamDispatchedTo": { "placeholders": { "teamName": { "type": "String" } } }
}
```

- Enum metinleri ARB'den gelir; enum içine Türkçe metin yazılmaz:

```dart
extension HelpTypeL10n on HelpType {
  String label(AppLocalizations l10n) => switch (this) {
        HelpType.debris => l10n.helpTypeDebris,
        HelpType.medical => l10n.helpTypeMedical,
        HelpType.shelter => l10n.helpTypeShelter,
        HelpType.heating => l10n.helpTypeHeating,
        HelpType.babyFood => l10n.helpTypeBabyFood,
        HelpType.water => l10n.helpTypeWater,
        HelpType.other => l10n.helpTypeOther,
      };
}
```

- Seed verisindeki ad ("Arama Kurtarma Tim 4") veridir, ARB'ye girmez.
- T5: "Giriş Yap" / "Sign In", "Kayıt Ol" / "Sign Up". T15: "Resmi kurum uygulaması değildir ·
  Acil durumda 112" metni O2 ve O3'te.
