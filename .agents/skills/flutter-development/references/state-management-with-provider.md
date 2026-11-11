# Provider ile State Yönetimi ve Veri Desenleri

Kaynak: `PROJECT_NEW.md` §6 (State: Provider + `ChangeNotifier` / `ValueNotifier`), §4 (iş
kuralları), §5 (veritabanı). Değerler (öncelik tablosu, stok eşikleri, index'ler) o
belgededir; buradaki kod onları uygular.

## 1. Hangisi Ne Zaman?

| İhtiyaç | Araç | Örnek |
|---|---|---|
| Ekranın yüklenme/hata/veri durumu, Firestore stream'i, kullanıcı aksiyonu | `ChangeNotifier` controller + `ChangeNotifierProvider` | Canlı Akış, Ekipler, Lojistik, Profil |
| Uygulama genelinde tek örnek | `ChangeNotifierProvider` (`app.dart`) | `AuthController`, bağlantı servisi |
| State'siz repository / servis | `Provider<T>` | `IncidentRepository`, konum servisi |
| Tek küçük değer, tek widget | `ValueNotifier` + `ValueListenableBuilder` | Düdük açık/kapalı, şifre göster/gizle, panik basılı tutma ilerlemesi |
| Yalnızca animasyon | `StatefulWidget` + `AnimationController` | Splash logosu, panik butonu parlaması |

Bloc, Riverpod, GetX, GetIt, MobX **kullanılmaz**.

## 2. Katmanlar: Örnek Akış (Canlı Akış)

```text
LiveFeedScreen ──watch──► LiveFeedController ──► IncidentRepository (domain arayüzü)
                                                         ▲ implements
                                       FirestoreIncidentRepository (data) ── incidents stream
```

### 2.1. Entity (`domain/incident.dart`)

`@immutable`, `final` alanlar, Firestore tipi (`Timestamp`, `GeoPoint`) içermez.

```dart
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

@immutable
class Incident {
  const Incident({
    required this.id,
    required this.location,
    required this.type,
    required this.priority,
    required this.requestCount,
    required this.primaryRequestId,
    required this.status,
    required this.isOpen,
    required this.createdAt,
    this.assignedTeamId,
  });

  final String id;
  final LatLng location;
  final HelpType type;
  final int priority; // 1 kritik · 2 acil · 3 normal (Kural 1)
  final int requestCount;
  final String primaryRequestId;
  final CaseStatus status;
  final bool isOpen;
  final DateTime createdAt;
  final String? assignedTeamId;

  bool get canBeClosedDirectly => assignedTeamId == null; // Kural 7
}
```

### 2.2. Repository arayüzü (`domain/incident_repository.dart`)

```dart
abstract interface class IncidentRepository {
  /// Açık olaylar, priority + createdAt sıralı (Kural 1, index §5.4).
  Stream<List<Incident>> watchOpenIncidents();

  Future<void> closeIncident(String incidentId);
}
```

### 2.3. Firestore uygulaması (`data/firestore_incident_repository.dart`)

```dart
class FirestoreIncidentRepository implements IncidentRepository {
  FirestoreIncidentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('incidents');

  @override
  Stream<List<Incident>> watchOpenIncidents() {
    return _col
        .where('isOpen', isEqualTo: true)
        .orderBy('priority')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> closeIncident(String incidentId) {
    return _col.doc(incidentId).update({
      'status': CaseStatus.resolved.name,
      'isOpen': false,
      'updatedAt': FieldValue.serverTimestamp(),
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  Incident _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final geo = d['location'] as GeoPoint;
    return Incident(
      id: doc.id, // id belgenin içine yazılmaz (§5.2)
      location: LatLng(geo.latitude, geo.longitude),
      type: HelpType.values.byName(d['type'] as String),
      priority: d['priority'] as int,
      requestCount: d['requestCount'] as int? ?? 1,
      primaryRequestId: d['primaryRequestId'] as String,
      status: CaseStatus.values.byName(d['status'] as String),
      isOpen: d['isOpen'] as bool? ?? true,
      // serverTimestamp yerel yazımda null gelebilir
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedTeamId: d['assignedTeamId'] as String?,
    );
  }
}
```

### 2.4. Controller (`presentation/live_feed_controller.dart`)

- Durum tek alanda: `ViewStatus { loading, ready, empty, failure }` (`core/widgets/state_view.dart`).
- Hata metin olarak değil tür/enum olarak tutulur; ekran ARB'den çevirir.
- Stream aboneliği `dispose()`'da iptal edilir; dispose sonrası `notifyListeners()` yok.
- Filtreler istemcide uygulanır (Kural 1: ek index gerekmez).
- Yazma sonrası liste elle güncellenmez; stream yeni snapshot'ı getirir.

```dart
enum FeedFilter { all, critical, urgent, normal, medical }

class LiveFeedController extends ChangeNotifier {
  LiveFeedController(this._repo) {
    _sub = _repo.watchOpenIncidents().listen(_onData, onError: (Object _) => _setStatus(ViewStatus.failure));
  }

  final IncidentRepository _repo;
  late final StreamSubscription<List<Incident>> _sub;
  bool _disposed = false;

  ViewStatus _status = ViewStatus.loading;
  ViewStatus get status => _status;

  List<Incident> _all = const [];
  FeedFilter _filter = FeedFilter.all;
  FeedFilter get filter => _filter;

  List<Incident> get visible => switch (_filter) {
        FeedFilter.all => _all,
        FeedFilter.critical => _all.where((i) => i.priority == 1).toList(),
        FeedFilter.urgent => _all.where((i) => i.priority == 2).toList(),
        FeedFilter.normal => _all.where((i) => i.priority == 3).toList(),
        FeedFilter.medical => _all.where((i) => i.type == HelpType.medical).toList(),
      };

  void setFilter(FeedFilter f) {
    if (f == _filter) return;
    _filter = f;
    _notify();
  }

  /// Başarıyı döner; SnackBar'ı ekran gösterir.
  Future<bool> closeIncident(Incident i) async {
    if (!i.canBeClosedDirectly) return false;
    try {
      await _repo.closeIncident(i.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _onData(List<Incident> items) {
    _all = items;
    _setStatus(items.isEmpty ? ViewStatus.empty : ViewStatus.ready);
  }

  void _setStatus(ViewStatus s) {
    _status = s;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub.cancel();
    super.dispose();
  }
}
```

> Y1 kartı olay belgesinde olmayan bilgileri de gösterir (ad, kişi sayısı, adres tarifi,
> açıklama). Gerçek controller bunları `primaryRequestId` çağrısından ve o çağrının
> `private/contact.fullName` alanından alıp bir görünüm modelinde (`FeedItem`) birleştirir.

## 3. Provider Kurulumu ve Okuma

Ekran controller'ı **ekranın kendisinde** kurulur; ekran ağaçtan çıkınca Provider dispose eder.
Repository'ler `app.dart`'taki `MultiProvider`'dan okunur.

```dart
class LiveFeedScreen extends StatelessWidget {
  const LiveFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => LiveFeedController(ctx.read<IncidentRepository>()),
      child: const _LiveFeedView(),
    );
  }
}
```

| Okuma | Ne zaman |
|---|---|
| `context.watch<T>()` | `build` içinde, değişince yeniden çizilmesi gereken yer |
| `context.select<T, R>((c) => c.alan)` | Yalnızca tek alan değişince çizilsin |
| `context.read<T>()` | Callback (`onPressed`), `create:`, `initState` |
| `Consumer<T>` | Ağacın küçük bir kısmını yeniden çizmek için |

`build` içinde `context.read` ile state okumak yanlıştır (değişiklik görünmez).

## 4. `ValueNotifier` ile Küçük Durum (Düdük, A3)

```dart
class WhistleController {
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final AudioPlayer _player = AudioPlayer();

  Future<void> toggle() async {
    if (isPlaying.value) {
      await _player.stop();
    } else {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/whistle.mp3')); // internetsiz, assets/sounds/
    }
    isPlaying.value = !isPlaying.value;
  }

  void dispose() {
    _player.dispose();
    isPlaying.dispose();
  }
}
```

iOS'ta sessiz modda çalması için ses oturumu `playback` kategorisinde ayarlanır (§6.2).

## 5. Firestore Desenleri

### 5.0. Genel kurallar

- Koleksiyon ve alan adları `database/` ve §5.2–5.3 ile **birebir**.
- Belge kimliği istemcide: `const Uuid().v4()`. `id` belgenin içine yazılmaz.
- Zaman: `FieldValue.serverTimestamp()`; okurken `Timestamp?` (yerel yazımda `null` olabilir).
- Enum'lar `name` ile yazılır, `values.byName` ile okunur.
- Gizli alanlar (ad, telefon, adres, tıbbi) yalnızca `.../private/contact` (Kural 5).
- Çok alanlı filtre/sıralama composite index ister: §5.4 ve `firestore.indexes.json`.
- Flutter'da **Transaction içinde sorgu yapılamaz**, yalnızca `tx.get(docRef)`. Sorgu
  Transaction dışında yapılır, aday belge Transaction içinde yeniden okunur.

### 5.1. Öncelik (Kural 1) — `core/utils/priority_policy.dart`

```dart
abstract final class PriorityPolicy {
  /// Değerler PROJECT_NEW.md §4 Kural 1 tablosundandır.
  static int of(HelpType type) => switch (type) {
        HelpType.debris || HelpType.medical => 1,
        HelpType.shelter || HelpType.heating || HelpType.babyFood => 2,
        HelpType.water || HelpType.other => 3,
      };

  /// İki önceliğin en yükseği (küçük sayı = yüksek öncelik).
  static int merge(int a, int b) => a < b ? a : b;
}
```

`switch` `default` içermez; yeni `HelpType` eklenirse derleyici uyarır.

### 5.2. Mükerrer birleştirme (Kural 2) — `help_request/data/`

```dart
String geohash8(GeoPoint p) => GeoFirePoint(p).geohash.substring(0, 8);

/// 7 haneli hücre + 8 komşusu = 9 hücre.
List<String> searchCells(GeoPoint p) {
  final cell7 = GeoFirePoint(p).geohash.substring(0, 7);
  return [cell7, ...neighborGeohashesOf(geohash: cell7)];
}

Future<String?> _findMatchingIncidentId(GeoPoint p) async {
  final snaps = await Future.wait(searchCells(p).map((cell) => _db
      .collection('incidents')
      .where('isOpen', isEqualTo: true)
      .where('geohash', isGreaterThanOrEqualTo: cell)
      .where('geohash', isLessThan: '$cell~') // önek (prefix) sorgusu
      .get()));
  for (final doc in snaps.expand((s) => s.docs)) {
    final loc = doc.data()['location'] as GeoPoint;
    if (Geolocator.distanceBetween(p.latitude, p.longitude, loc.latitude, loc.longitude) <= 50) {
      return doc.id;
    }
  }
  return null;
}
```

Gönderim tek `runTransaction`:
1. `help_requests/{uuid}` okunur; **varsa çık** (kuyruk tekrar denese de çift kayıt yok, Kural 4).
2. Aday olay `tx.get` ile yeniden okunur; hâlâ `isOpen` ise `requestCount: FieldValue.increment(1)`,
   `priority: PriorityPolicy.merge(...)`, `updatedAt`. Değilse yeni `incidents` belgesi
   (`requestCount: 1`, `status: pending`, `isOpen: true`, `primaryRequestId`).
3. `help_requests/{uuid}` (`status: pending`, `priority: PriorityPolicy.of(type)`,
   `geohash: geohash8(...)`, `photoUrls: []`, `incidentId`) ve
   `help_requests/{uuid}/private/contact` (`fullName`, `phone`) `tx.set` ile yazılır.

### 5.3. Çevrimdışı kuyruk (Kural 4)

Çevrimdışıyken Transaction ya askıda kalır ya da hemen `unavailable` hatasıyla düşer; ikisi de
"çevrimdışı" sayılır, aksi hâlde çağrı kaybolur.

```dart
bool _isOffline(Object e) =>
    e is TimeoutException || (e is FirebaseException && e.code == 'unavailable');

Future<SubmitResult> submitOrQueue(HelpRequestDraft draft) async {
  try {
    await _repo.submit(draft).timeout(const Duration(seconds: 10));
    return SubmitResult.sent;
  } catch (e) {
    if (!_isOffline(e)) rethrow;
    await _box.put(draft.id, draft.copyWith(createdOffline: true).toJson());
    return SubmitResult.queued; // kartta "Gönderilmeyi Bekliyor"
  }
}

/// Uygulama açılışında ve bağlantı geri gelince çağrılır.
Future<void> flush() async {
  for (final key in _box.keys.toList()) {
    final draft = HelpRequestDraft.fromJson(Map<String, dynamic>.from(_box.get(key)));
    try {
      await _repo.submit(draft).timeout(const Duration(seconds: 10));
      await _box.delete(key);
    } catch (e) {
      if (_isOffline(e)) return; // kayıt kutuda kalır, sonra tekrar
      rethrow;
    }
  }
}
```

Hive kutusunda `Map` tutulur (`TypeAdapter` gerekmez); uygulama kapanıp açılsa da korunur.

### 5.4. Panik sinyali ve bağlantı tespiti (Kural 8)

```dart
Future<SignalDelivery> sendDanger(String uid, GeoPoint p) async {
  final ref = _db.collection('safety_signals').doc(uid);
  unawaited(ref.set({ // çevrimdışıyken bu Future tamamlanmaz; beklenmez
    'state': 'danger',
    'location': p,
    'geohash': geohash8(p),
    'updatedAt': FieldValue.serverTimestamp(),
  }));
  try {
    await ref
        .snapshots(includeMetadataChanges: true)
        .firstWhere((s) => !s.metadata.hasPendingWrites)
        .timeout(const Duration(seconds: 10));
    return SignalDelivery.confirmed; // "Merkeze iletildi" yalnızca bu durumda
  } on TimeoutException {
    return SignalDelivery.pending; // Firestore kuyruğunda bekler → SMS diyaloğu
  }
}
```

SMS otomatik gönderilmez: `launchUrl(Uri(scheme: 'sms', path: telefon, queryParameters:
{'body': l10n.smsPanicBody(konumLinki)}))`. `connectivity_plus` yalnızca "ağ değişti"
sinyalidir; çevrimiçi kararı sunucu onayıyla verilir (R8).

### 5.5. Görev durumu (Kural 6)

```dart
enum AssignmentStatus { assigned, enRoute, onSite, resolved }

extension AssignmentFlow on AssignmentStatus {
  /// Geri adım yok; resolved son durumdur.
  AssignmentStatus? get next => switch (this) {
        AssignmentStatus.assigned => AssignmentStatus.enRoute,
        AssignmentStatus.enRoute => AssignmentStatus.onSite,
        AssignmentStatus.onSite => AssignmentStatus.resolved,
        AssignmentStatus.resolved => null,
      };
}
```

Her geçiş **tek `WriteBatch`**: `assignments.status` (+ `updatedBy`, `updatedAt`),
`incidents.status` (`resolved`'da `isOpen: false`, `resolvedAt`), bağlı ve `cancelled`
olmayan tüm `help_requests.status`, ekibin `status` (`onDuty` / `available`) ve `currentTask`
(`resolved`'da `FieldValue.delete()`). Bir olayda aynı anda tek aktif görev olur.

### 5.6. Stok (Kural 3)

```dart
enum StockLevel { critical, medium, sufficient }

/// Eşikler PROJECT_NEW.md §4 Kural 3 tablosundandır.
StockLevel stockLevelOf(InventoryItem i) {
  if (i.quantity <= i.criticalLevel) return StockLevel.critical;
  if (i.quantity < i.targetLevel * 0.5) return StockLevel.medium;
  return StockLevel.sufficient;
}

double stockRatio(InventoryItem i) =>
    i.targetLevel <= 0 ? 0 : (i.quantity / i.targetLevel).clamp(0.0, 1.0);
```

Giriş/çıkış tek `runTransaction`: kalem `tx.get`, çıkışta `quantity < miktar` ise domain
hatası (`InsufficientStockFailure`), değilse `quantity` güncellenir ve
`movements/{uuid}` (`itemId`, `type: in/out`, `quantity > 0`, `createdBy`, `createdAt`)
yazılır. Kritiğe düşen kalem için yetkiliye yerel bildirim.

### 5.7. Kayıt ve hesap silme (§7)

- Kayıt: `createUserWithEmailAndPassword` → **tek batch**: `users/{uid}` (`role`,
  `isVerified: false`, `notificationsOptIn`, `consents`, `createdAt`; `teamId` / `unitName` /
  `region` yazılmaz) + `users/{uid}/private/contact` (`email`, `phone`).
- Hesabı Sil: onay → `reauthenticateWithCredential` → kullanıcının çağrılarındaki
  `private/contact` → `safety_signals/{uid}` → `users/{uid}/private/contact` → `users/{uid}` →
  `user.delete()`. Çağrı belgeleri kalır.

## 6. Test

| Ne | Nerede | Nasıl |
|---|---|---|
| `PriorityPolicy`, `stockLevelOf`, `AssignmentFlow.next`, `searchCells`, validator'lar | `test/core/utils/`, `test/features/<f>/` | `flutter test`, Firebase'siz; sınır değerleri dahil |
| Controller durumları | `test/features/<f>/` | Sahte repository (`implements XRepository`) + `StreamController` |
| Security Rules (§5.5 listesi) | G6 | Firebase Emulator + `@firebase/rules-unit-testing` |
