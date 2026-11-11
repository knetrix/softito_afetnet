---
name: flutter-development
description: >
  AfetNet (Flutter + Firebase, Clean Architecture) projesinde kod yazarken kullanılır:
  ekran, bottom sheet/diyalog, Provider + ChangeNotifier/ValueNotifier state, GoRouter
  rol yönlendirmesi, Firestore stream/Transaction/batch, Hive çevrimdışı kuyruk, tema
  token'ları ve TR/EN ARB metinleri. Bir ekranı tasarıma uydururken, iş kuralı
  (öncelik, mükerrer birleştirme, stok, görev durumu, panik sinyali) kodlarken veya PR
  öncesi kalite kontrolünde oku. Yeni feature klasörü açmak için
  flutter-feature-scaffold skill'ini kullan.
---

# AfetNet — Flutter Geliştirme Kuralları

Bu skill, AfetNet'te yazılan kodun `PROJECT_NEW.md` (spesifikasyon) ve `GOREV_DAGILIMI.md`
(kim, hangi sırayla, neyi yapar) ile uyumlu olmasını sağlar. Kuralları **özetler ve
yönlendirir**; tablo ve değerlerin tek kaynağı `PROJECT_NEW.md`'dir. Çelişki olursa
`PROJECT_NEW.md` kazanır. Parantez içindeki numaralar (§4, Kural 2, T9 …) o belgenin
bölümleridir.

## İçindekiler

- [Kaynak Hiyerarşisi](#kaynak-hiyerarşisi)
- [Teknoloji Yığını](#teknoloji-yığını)
- [Altın Kurallar](#altın-kurallar)
- [İş Kuralı Haritası](#iş-kuralı-haritası)
- [Ekran ve Sheet Haritası](#ekran-ve-sheet-haritası)
- [Görev Sırası](#görev-sırası)
- [Referans Rehberler](#referans-rehberler)
- [PR Öncesi Kontrol Listesi](#pr-öncesi-kontrol-listesi)

## Kaynak Hiyerarşisi

1. `PROJECT_NEW.md`: ekranlar, iş kuralları, veritabanı alanları, paketler.
2. `design/`: ekranların görünümü. Tasarımdaki hatalı/uygulanmayan kısımlar §3.3'e göre düzeltilir.
3. `database/`: koleksiyon ve alan adları **aynen** kullanılır; yeni alan uydurulmaz.
4. `GOREV_DAGILIMI.md`: G1 → G6 sırası ve her adımın sahibi.

> [!WARNING]
> `lib/` altındaki eski prototip kodu (`emergency_call/`, `crisis_map/`, `afetnet_*_button.dart`,
> `AppColors` içindeki hex değerleri, `screens/` klasörleri) spesifikasyona uymaz ve örnek
> alınmaz. Esas olan: §6.1 klasör yapısı, §3.4 token'ları ve ortak widget adları
> (`AppButton`, `StateView`, `GlowCircleButton`, `StatusBadge`, `AppBottomSheet`, `AppDialog`).
> Eski dosyaları, o alanın sahibi kendi adımında taşır veya siler.

## Teknoloji Yığını

| Alan | Kullanılan | Kullanılmayan |
|---|---|---|
| Mimari | Clean Architecture, feature-first: `features/<f>/{data,domain,presentation}` | Ekran + mantık tek dosyada |
| State | `provider` + `ChangeNotifier` (ekran state'i), `ValueNotifier` (küçük yerel durum) | Bloc, Riverpod, GetX, GetIt, MobX |
| Navigasyon | `go_router`: rol başına `StatefulShellRoute.indexedStack` + `redirect` | Ek işlem için yeni rota |
| Veri | `firebase_auth`, `cloud_firestore` (stream, Transaction, batch) | `http`/REST, Firebase Storage (tasarımda fotoğraf yok) |
| Yerel | `hive_ce` (çevrimdışı çağrı kuyruğu), `shared_preferences` (`onboardingDone`) | |
| Harita | `flutter_map` + OSM (`userAgentPackageName: 'com.softito.afetnet'`, atıf zorunlu) | Google Maps |
| Konum | `geolocator`, `geocoding`, `geoflutterfire_plus` (yalnızca geohash + komşu hücre) | Arka plan konumu |
| Bildirim | `flutter_local_notifications` (uygulama açıkken) + FCM `all_users` topic | Cloud Functions (Spark planda yok) |
| Dil | `flutter_localizations` + `intl`, `app_tr.arb` + `app_en.arb` | Ekranda sabit metin |

Tam paket listesi §6.2'dedir. Listede olmayan paket eklenmeden önce G1'e sorulur.

> [!NOTE]
> `geoflutterfire_plus`'ın güncel sürümü `cloud_firestore ^6.x` ister; `cloud_firestore`'un
> 7.x sürümüyle `pub get` çözümlenmez. Paketleri eklerken (G1) `cloud_firestore` ve diğer
> Firebase paketleri bu uyumlu sürüm ailesinde tutulur.

## Altın Kurallar

1. **12 ekran vardır, 13. açılmaz.** Tasarımdaki bir butonun gerektirdiği işlem
   `AppBottomSheet` veya `AppDialog` ile ilgili ekranın üstünde yapılır (§3.2).
2. **Sabit metin yok.** Her metin aynı PR'da hem `app_tr.arb` hem `app_en.arb`'ye eklenir;
   ekranda `AppLocalizations.of(context)!.anahtar` kullanılır.
3. **Sabit renk yok.** Ekranlarda `Color(0xFF…)` / `Colors.red` yazılmaz;
   `Theme.of(context).colorScheme` ve `Theme.of(context).extension<AppStatusColors>()!`
   kullanılır. Açık tema aynı token'lardan türetilir, `ThemeMode.system` (T14).
4. **Tasarım düzeltmeleri (§3.3) uygulanır:** AFAD, AKUT, UMKE, Kızılay, `gov.tr`, LoRa,
   Mesh, Telsiz, AES, frekans, sektör kodu, gerçek kişi fotoğrafı **yazılmaz**. Örnek veride
   "Arama Kurtarma Tim 4", "Sağlık Ekibi 1", "Aşevi Ekibi" kullanılır.
5. **Gizli bilgi yalnızca `private/contact`'ta** (Kural 5). Ad, telefon, adres, tıbbi bilgi
   `users` veya `help_requests` ana belgesine yazılmaz.
6. **İş kuralı UI'da hesaplanmaz.** Öncelik, stok etiketi, görev geçişi gibi kurallar
   `domain/` veya `core/utils/` içinde saf fonksiyondur ve unit test alır.
7. **`await` sonrası `mounted`:** widget içinde `if (!mounted) return;`, `BuildContext` alan
   fonksiyonda `if (!context.mounted) return;`. Controller dispose olduysa `notifyListeners()`
   çağrılmaz.
8. **Katman sınırı:** Repository arayüzü `domain/`'de, Firestore/Hive kodu `data/`'da.
   `presentation/` `cloud_firestore` import etmez.
9. **Dil:** Uygulama cihaz dilini izler; `tr` dışındaki her dilde İngilizce açılır. Tarih ve
   sayı biçimi `intl` ile.
10. **Release'de seed ve test hesabı yok.** `demo_seed` yalnızca `kDebugMode` altında görünür.

## İş Kuralı Haritası

Kodun nerede duracağını ve hangi kurala dayandığını gösterir. Değerler `PROJECT_NEW.md`'den
okunur, buraya kopyalanmaz.

| Kural | Nerede | Teknik desen |
|---|---|---|
| Öncelik (Kural 1) | `core/utils/priority_policy.dart` | `HelpType` → `priority` saf fonksiyon; başka yerde hesaplanmaz |
| Mükerrer birleştirme (Kural 2) | `features/help_request/data/` | 7 haneli hücre + 8 komşu = 9 önek sorgusu → `distanceBetween <= 50` → `runTransaction` |
| Stok (Kural 3) | `features/logistics/` | Tek `runTransaction`; çıkışta eksi stok reddi; etiket `domain/` saf fonksiyon |
| Çevrimdışı çağrı (Kural 4) | `core/services/` offline_queue | İstemci `uuid`; 10 sn timeout veya `unavailable` → Hive; bağlantı gelince kuyruk işlenir |
| Gizli bilgi (Kural 5) | ilgili `data/` repository | Ana belge + `private/contact` aynı Transaction/batch'te |
| Görev durumu (Kural 6) | `features/teams/` | Yalnızca ileri adım; tek `WriteBatch` ile 4 belge türü |
| İptal/kapatma (Kural 7) | `help_request`, `live_feed` | `cancelled` yalnızca sahibi; Olayı Kapat yalnızca görev atanmamışsa |
| Panik (Kural 8) | `features/safety_signal/` | `safety_signals/{uid}`; `hasPendingWrites` 10 sn → çevrimdışı → `sms:` |
| Konum etiketi (Kural 9) | `core/services/` location | `geocoding`; son etiket saklanır |
| Tahliye anonsu (Kural 10) | `features/broadcast/` | `broadcasts` yazılır; açık uygulamada yarıçap kontrolü → yerel bildirim |
| Rol ve onay (§2, R4) | `features/auth/` + `core/router/` | `users.role` + `isVerified`; uyuşmazlık/onaysızlıkta `signOut` |

Kod desenleri: [Provider ile State Yönetimi](references/state-management-with-provider.md) §5.

## Ekran ve Sheet Haritası

| Rol | Ekranlar (alt menü sırası sabit) | Sheet / diyalog (§3.2) |
|---|---|---|
| Ortak | O1 Splash → O2 Onboarding → O3 Giriş / O4 Kayıt | — |
| `citizen` | A1 Ana Sayfa · A2 Toplanma · A3 Düdük · A4 Profil | Yardım Çağrısı, Çağrı İptal, SMS ile haber ver, Profil düzenleme, Çıkış / Hesabı Sil |
| `official` | Y1 Canlı Akış · Y2 Ekipler · Y3 Lojistik · Y4 Profil | Detay, Ekip Yönlendir, Panik pini, Tahliye Anonsu, Görev Ata / Güncelle, Stok Giriş/Çıkış, Çıkış / Hesabı Sil |

## Görev Sırası

Proje bayrak yarışıdır: aynı anda tek kişi kod yazar, herkes bir öncekinin birleştirilmiş
işinin üzerine ekler. Başkasının alanındaki dosyayı yeniden yazma; eksik varsa sahibine bildir.

| Sıra | Kişi | Alan | Diğerlerinin dayandığı çıktı |
|---|---|---|---|
| G1 | Mustafa | Kimlik, Firebase, paketler, klasörler, router, validators, Giriş/Kayıt | `AuthController`, `app_router.dart`, boş sekmeler |
| G2 | Sümeyye | Tema, ortak widget'lar, ARB, Splash/Onboarding, Profil | `AppStatusColors`, `StateView`, `AppBottomSheet`, `AppDialog`, ARB |
| G3 | Furkan | Konum/bağlantı/bildirim servisleri, panik sinyali, A1 yerleşimi, Düdük | `LocationService`, bağlantı tespiti, A1 iskeleti |
| G4 | Tuba | Yardım çağrısı, öncelik, birleştirme, Hive kuyruğu, aktif çağrı kartı, Toplanma | `priority_policy.dart`, `incidents` yazımı |
| G5 | Esra | Canlı Akış, Y1 sheet'leri, Ekipler, görev akışı | `assignments` batch |
| G6 | Meryem | Lojistik, Tahliye Anonsu, demo verisi, Hesabı Sil, yasal metinler, rules + index | `firestore.rules`, `firestore.indexes.json` |

Dal: `feature/<isim>-<konu>`, PR **base**'i `development` (varsayılan `main` gelir). G1 birleştirir.

## Referans Rehberler

| Rehber | İçerik |
|---|---|
| [Proje Yapısı ve Navigasyon](references/project-structure-navigation.md) | Klasörler, katman bağımlılığı, `main.dart`/`app.dart`, GoRouter shell'leri, rol `redirect`, tema ve dil kurulumu |
| [Provider ile State Yönetimi](references/state-management-with-provider.md) | Entity, repository, `ChangeNotifier` controller, `ValueNotifier`, Firestore/Transaction/batch/çevrimdışı desenleri |
| [Provider'lı Ekranlar](references/screens-with-provider-integration.md) | Ekran iskeleti, `StateView`, kart, sheet/diyalog, `mounted`, harita, ekran bazlı notlar |

Komşu skill'ler: yeni feature için `flutter-feature-scaffold`, taşma hataları için
`flutter-fix-layout-issues`, testler için `dart-add-unit-test` ve `flutter-add-widget-test`.

## PR Öncesi Kontrol Listesi

- [ ] `flutter analyze` temiz.
- [ ] Ekranda sabit metin ve sabit renk yok; yeni anahtarlar iki ARB'de de var.
- [ ] 360×640 ekranda ve en büyük yazı boyutunda `RenderFlex overflow` yok.
- [ ] Her `await` sonrası `mounted` kontrolü var; controller'lar ve abonelikler dispose ediliyor.
- [ ] Yeni iş kuralı fonksiyonunun `test/` altında unit testi var ve geçiyor.
- [ ] Kurum adı, LoRa/mesh/telsiz ifadesi, gerçek fotoğraf yok (§3.3).
- [ ] Gizli alan ana belgeye yazılmıyor; Firestore alan adları `database/` ile birebir.
- [ ] Yeni ekran/rota açılmadı; ek işlem sheet/diyalog ile yapıldı.
- [ ] Dal `feature/<isim>-<konu>`, PR base'i `development`.
