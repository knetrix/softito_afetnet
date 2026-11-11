# State Yönetimi ve Veri Akışı Kılavuzu (AfetNet)

Bu kılavuz AfetNet'te durum yönetimini, katmanlar arası veri akışını ve yaşam döngüsü
kurallarını tanımlar. Kaynak: `PROJECT_NEW.md` §6 (State: Provider + `ChangeNotifier` /
`ValueNotifier`; Mimari: Clean Architecture, feature-first).

---

## 1. Temel Prensipler

1. **Araçlar:** `provider` paketi + Flutter çekirdeğindeki `ChangeNotifier`, `ValueNotifier`,
   `ValueListenableBuilder`. Bloc, Riverpod, GetX, GetIt, MobX, Redux kullanılmaz.
2. **Tek yönlü veri akışı:**
   Kullanıcı aksiyonu → controller metodu → repository (Firestore/Hive) → stream yeni veri
   üretir → controller state'i günceller → `notifyListeners()` → yalnızca dinleyen widget
   yeniden çizilir.
3. **Firestore tek doğruluk kaynağıdır.** Yazma sonrası controller listeyi elle güncellemez;
   stream yeni snapshot'ı getirir (çevrimdışıyken de yerel önbellekten snapshot gelir).
4. **Immutable entity:** Tüm alanlar `final`, sınıf `@immutable`, değişiklik `copyWith` ile.
5. **`setState` yalnızca yerel UI için:** animasyon, form alanı, göster/gizle. İş mantığı ve
   Firestore verisi `setState` ile tutulmaz.

---

## 2. Katmanlar ve Sorumluluklar

```text
┌──────────── presentation ─────────────┐
│ XScreen ──ChangeNotifierProvider──►   │
│ _XView ──context.watch──► Controller  │──┐ aksiyon: controller.move(...)
│        ◄──notifyListeners─────────────│  │
└───────────────────────────────────────┘  ▼
┌──────────── domain (saf Dart) ───────────────┐
│ Entity · Repository arayüzü · iş kuralı      │  PriorityPolicy, stockLevelOf, AssignmentFlow
└──────────────────────────────────────────────┘
                     ▲ implements
┌──────────── data ────────────────────────────┐
│ FirestoreXRepository: sorgu, Transaction,    │  cloud_firestore, hive_ce
│ batch, DTO ↔ Entity dönüşümü                 │
└──────────────────────────────────────────────┘
```

### A. Domain (`domain/`)
- Entity: `@immutable`, `final` alanlar, `copyWith`, `==` / `hashCode`.
- Firestore tipi (`Timestamp`, `GeoPoint`, `DocumentSnapshot`) içermez; `DateTime`, `LatLng`
  (latlong2) kullanır.
- Repository: `abstract interface class`; canlı veri `Stream<T>`, aksiyon `Future<T>`.
- İş kuralı: saf fonksiyon. Unit test zorunlu.

### B. Data (`data/`)
- Repository arayüzünü uygular. Koleksiyon/alan adları `database/` + §5 ile birebir.
- `fromDoc` / `toMap` burada. `id` belgenin içine yazılmaz (`doc.id`).
- Transaction (mükerrer birleştirme, stok) ve batch (görev durumu, kayıt) burada.
- Firebase hatalarını domain hatasına çevirir (`InsufficientStockFailure` gibi).

### C. Controller (`presentation/<f>_controller.dart`)
- `ChangeNotifier`; constructor'da repository alır (testte sahtesi verilir).
- Durum: `ViewStatus status` (`loading` / `ready` / `empty` / `failure`,
  `core/widgets/state_view.dart`), veri, filtre, `busy` bayrağı.
- Stream aboneliğini tutar, `dispose()`'da iptal eder; `_disposed` bayrağıyla dispose sonrası
  `notifyListeners()` engellenir.
- Aksiyonlar `Future<bool>` veya sonuç enum'u döner; SnackBar/diyalog göstermez, metin üretmez.

### D. Screen (`presentation/<f>_screen.dart`)
- `XScreen`: `ChangeNotifierProvider(create: ...)`; Provider dispose'u otomatik yapar.
- `_XView`: `context.watch<XController>()` + `StateView`.
- Callback'te `context.read<XController>()`; `await` sonrası `context.mounted` kontrolü.

### E. Widget ve Sheet (`presentation/widgets/`, `presentation/sheets/`)
- `StatelessWidget`, `const` constructor, veri parametreyle gelir.
- Renk `Theme.of(context).colorScheme` / `extension<AppStatusColors>()`, metin ARB.
- 40 satırı aşan `build` parçaları ayrı widget'a bölünür.

---

## 3. Yaşam Döngüsü

### ChangeNotifier controller (Firestore'lu ekran)

```dart
class LogisticsScreen extends StatelessWidget {
  const LogisticsScreen({super.key, required this.warehouseId});

  final String warehouseId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // 1. Ekran açılınca controller oluşur ve stream'e abone olur
      create: (ctx) => LogisticsController(ctx.read<InventoryRepository>(), warehouseId: warehouseId),
      // 2. Ekran ağaçtan çıkınca Provider controller.dispose()'u çağırır → abonelik iptal
      child: const _LogisticsView(),
    );
  }
}
```

### ValueNotifier controller (Firestore'suz ekran, `--ui-only`)

```dart
class _WhistleScreenState extends State<WhistleScreen> {
  late final WhistleController _controller = WhistleController();

  @override
  void dispose() {
    _controller.dispose(); // AudioPlayer + ValueNotifier serbest bırakılır
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isPlaying,
      builder: (context, playing, _) => WhistleButton(playing: playing, onTap: _controller.toggle),
    );
  }
}
```

### Alt menü sekmeleri

`StatefulShellRoute.indexedStack` sekmeleri canlı tutar: sekme değişince controller dispose
**olmaz**, stream açık kalır (Canlı Akış arka sekmedeyken de günceldir).

---

## 4. Hata ve Yan Etki Yönetimi

| Durum | Controller | Ekran |
|---|---|---|
| Stream hatası (izin, ağ) | `status = failure` | `StateView` hata görünümü + Tekrar Dene |
| Aksiyon başarısız | `false` veya sonuç enum'u | SnackBar, metin ARB'den |
| İş kuralı reddi (eksi stok) | Domain hatası → `MoveResult.insufficient` | `l10n.stockInsufficient` |
| Çevrimdışı (Kural 4, 8) | `SubmitResult.queued` / `SignalDelivery.pending` | "Gönderilmeyi Bekliyor", SMS diyaloğu |
| Onaysız yetkili (§2) | `AuthController` `signOut` + `pendingApproval` | "Hesabınız yönetici onayı bekliyor" |
| Çift tıklama | `busy` `true` iken aksiyon reddedilir | Buton devre dışı |

- UI katmanında `try/catch` ile iş mantığı yazılmaz.
- Hata controller'da string olarak tutulmaz; tür/enum tutulur, ekran çevirir.
- Beklenmeyen hatalar `FirebaseCrashlytics.instance.recordError` ile kaydedilir.

---

## 5. Test

- Domain fonksiyonları sınır değerleriyle (`quantity == criticalLevel`,
  `quantity == targetLevel * 0.5`, `AssignmentStatus.resolved.next == null`).
- Controller: sahte repository (`implements XRepository`) + `StreamController`;
  `loading → empty / ready / failure` geçişleri ve aksiyon sonuçları.
- Security Rules testleri Firebase Emulator'da (G6, §5.5).
