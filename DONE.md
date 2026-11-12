# AfetNet — Aşama Durumu

Adımlar `GOREV_DAGILIMI.md`'deki sırayla ilerler. Aşamasını bitiren kişi kendi satırlarını günceller ve bu dosyayı PR'ına ekler.

**Durum:** ✅ Tamamlandı · 🟡 Kısmen / bekleyen iş var · ⏳ Başlamadı

| Aşama | Sahip | Durum | PR |
|---|---|---|---|
| G1 — Temel ve Giriş | Mustafa | 🟡 Tamam, ekip erişimi bekliyor | [#8](https://github.com/knetrix/softito_afetnet/pull/8), [#9](https://github.com/knetrix/softito_afetnet/pull/9) |
| G2 — Görünüm ve Profil | Sümeyye | ✅ Tamamlandı (G1 incelemesiyle düzeltildi) | [#11](https://github.com/knetrix/softito_afetnet/pull/11), `fix/mustafa-g2-review` |
| G3 — Panik, Ana Sayfa ve Düdük | Furkan | ✅ Tamamlandı (G1 incelemesiyle düzeltildi) | [#14](https://github.com/knetrix/softito_afetnet/pull/14), `fix/mustafa-g3-review` |
| G4 — Yardım Çağrısı ve Toplanma | Tuba | ✅ Tamamlandı (G1 incelemesiyle düzeltildi) | `development`'a doğrudan commit, `feature/tuba-g4`, [#18](https://github.com/knetrix/softito_afetnet/pull/18), `fix/mustafa-g4-assembly` |
| G5 — Canlı Akış ve Ekipler | Esra | ⏳ Sıradaki | — |
| G6 — Lojistik, Anons ve Teslime Hazırlık | Meryem | ⏳ | — |
| Son Tur — 13 Kasım sabah | Herkes | ⏳ | — |

---

## G1 — Mustafa · Temel ve Giriş

**Çıktı:** Kayıt olan kullanıcı rolüne göre boş ana sayfaya düşüyor. ✅ iOS simülatöründe gerçek Firebase'e karşı denendi.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Kimlik: `name: afetnet`, `com.softito.afetnet` | ✅ | Conflict işaretli platform dosyaları yeniden üretildi; `macos/` ve `web/` kaldırıldı |
| 2 | Firebase projesi (`eur3`), `flutterfire configure`, Firestore test modu | ✅ | Proje `afetnet-softito`. Test modu kuralları 11 Aralık 2026'ya kadar geçerli. E-posta/Şifre girişi açık |
| 2 | Ekip üyelerine Firebase projesinde Editor yetkisi ver | ⏳ | Console → Proje ayarları → Kullanıcılar ve izinler. Her üyenin Google hesabı e-postası gerekiyor. Uygulamayı çalıştırmak için gerekmez; Console'da veri görmek, yetkili onaylamak ve deploy için gerekir |
| 3 | Paketler (6.2), klasör yapısı (6.1), `app_config.dart` | ✅ | `pubspec.lock` repoda |
| 4 | Router: iki alt menü, boş sekmeler | ✅ | `core/router/` |
| 5 | `validators.dart`: e-posta, telefon maskesi, şifre kuralı | ✅ | Birim testli. G3 incelemesinde düzeltildi: `+90 5`'ten sonra `5` ile başlayan numara yazılınca `5` iki kez ekleniyordu (`5321234567` → `+90 553 212 34 56`). Biçimlendirici artık rakamları her değişiklikte baştan yorumlar; `5…`, `05…`, `+90 5…` aynı sonucu verir |
| 6 | Giriş (O3) ve Kayıt (O4): `users` + `private/contact`, rol kontrolü, onaysız yetkili uyarısı, rolüne göre yönlendirme | ✅ | T3, T4, T5, T15 uygulandı |
| — | Akışı simülatörde uçtan uca dene | ✅ | iOS simülatörü: afetzede kaydı → Ana Sayfa, çıkış, yanlış giriş türü reddi, afetzede girişi, yetkili kaydı → onay bekliyor. Yazılan `users` ve `private/contact` belgeleri kontrol edildi, test hesapları silindi |

**Kontroller:** `flutter analyze` temiz · 23 test geçiyor (G1 sonunda) · `flutter build apk --debug` ve `flutter build ios --debug --no-codesign` başarılı · iOS simülatöründe akış denendi.

**Not:** `firebase.json` içindeki `flutter` bölümü `flutterfire configure` tarafından yazılır ve iOS derlemesindeki Crashlytics betiği bu bölümü okur. Bu bölüm silinmemeli.

**G2'ye devir:** Kodda `TODO(G2)` ile işaretli. Ayrıntılar PR #8 açıklamasında.
- `auth_texts.dart` ve ekran metinleri → ARB
- `app.dart`'taki geçici tema
- Alt menü etiketleri
- Splash ve Onboarding (geçici ekranlar)
- `NotOfficialNotice`
- Şifre gücü çubuğunun renkleri
- Profil sekmelerindeki geçici Çıkış Yap butonları

---

## G2 — Sümeyye · Görünüm ve Profil

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Tema (3.4): renk token'ları, yazı tipleri, koyu + açık tema | ✅ | Yazı tipleri G1 incelemesinde gömüldü (Space Grotesk, Inter, JetBrains Mono; `assets/fonts/`, OFL lisanslı). Ekranlardaki sabit renkler temaya bağlandı. Splash ve Onboarding radar çizimleri koyu zemin için olduğundan her zaman koyu temada açılır |
| 2 | Ortak widget'lar: `AppButton`, `StateView`, `GlowCircleButton`, `StatusBadge`, `AppBottomSheet`, `AppDialog` | ✅ | `StatusBadge` metni ARB'den, rengi `AppStatusColors`'tan gelir. `AppBottomSheet` zemini `Material` ile çizilir (sheet'teki onay kutusu Flutter uyarısı veriyordu) |
| 3 | Dil kurulumu (ARB, cihaz dili), G1 metinlerini ARB'ye taşıma | ✅ | İngilizcede Türkçe kalan metinler (rozetler, "Belirtilmedi", sheet etiketleri, ipuçları, kayıt yardım metinleri) ARB'ye taşındı; 140 anahtar TR/EN eşit |
| 4 | Splash (O1) + Onboarding (O2), Giriş ve Kayıt'a tasarım | ✅ | |
| 5 | Profil (A4, Y4) ve düzenleme sheet'leri, Çıkış Yap | ✅ | Uydurma veriler kaldırıldı (konum "Antakya, Hatay", yetkili için "Merkez Koordinasyon" vb.). Acil durum yakınının telefonu `+905XXXXXXXXX` saklanır, maskeli gösterilir. Y4 "Bağlı Ekip" `teams/{teamId}.name`'den okunur (kayıt yoksa id). Doğum yılı / kilo aralık kontrolü, kayıt hatasında uyarı |
| + | Hesabı Sil (§7, aslında G6.4) | ✅ | G2 başlatmıştı; G1 incelemesinde tamamlandı: onay → şifre ile yeniden doğrulama → çağrıların `private/contact` belgeleri, `safety_signals/{uid}`, `users/{uid}/private/contact`, `users/{uid}` tek batch'te → Auth hesabı. Yanlış şifrede hiçbir şey silinmez |

**Çıktı:** Uygulama tasarımdaki gibi görünüyor, TR/EN çalışıyor, profil dolduruluyor. ✅

**Kontroller (G1 incelemesi):** `flutter analyze` temiz · 34 test geçiyor · Android ve iOS debug derlemeleri başarılı · iOS simülatöründe uçtan uca akış: onboarding (2 sayfa, 112 uyarısı), afetzede kaydı, profilin dört bölümünün doldurulması, çıkış, rol kontrolü, Hesabı Sil (yanlış ve doğru şifre; Firestore belgelerinin silindiği doğrulandı), yetkili onay bekliyor. TR-koyu, TR-açık ve EN-koyu ekran görüntüleri incelendi.

**G3'e devir (Furkan):** Kodda `TODO(G3)` işareti yalnızca A4'teki konum rozetindedir; aşağıdakiler G3'ün kendi işidir, hazır altyapı değildir.
- Hazır kullanılacaklar: `AppStatusColors` (`critical`, `urgent`, `normal`, `whistle`, `panic`), `GlowCircleButton` (panik/düdük), `AppDialog.confirm/info`, `AppBottomSheet.show`, `StateView`, `StatusBadge`, ARB (`lib/l10n/`).
- `LocationService` + konum etiketi (Kural 9): A1 başlığı ve A4 konum rozeti (`citizen_profile_screen.dart`, `TODO(G3)`).
- Acil durum yakını telefonu `users/{uid}/private/contact.emergencyContact.phone` alanında `+905XXXXXXXXX` biçimindedir; SMS köprüsünde (`sms:`) doğrudan kullanılabilir.
- Ekranlarda renk `Theme.of(context).colorScheme` / `extension<AppStatusColors>()!`, metin ARB'den; `AppColors` yalnızca `core/theme/` içinde (Onboarding hariç) kullanılır.

## G3 — Furkan · Panik, Ana Sayfa ve Düdük

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Servisler: konum + konum etiketi, bağlantı tespiti, yerel bildirim + FCM `all_users` | ✅ | `DeviceLocationService` (`geolocator` + `geocoding` + `SharedPreferences` son etiket önbelleği; A1 ve A4 `TODO(G3)` bağlandı), `DeviceConnectivityService` (`connectivity_plus`), `DeviceNotificationService` (`flutter_local_notifications` `"afetnet_critical_alerts"` kanalı + FCM `all_users` yalnızca `notificationsOptIn == true` ise abone olur, aksi durumda/çıkışta abonelikten çıkar). G1 incelemesi: bildirim izni açılışta değil, bildirimlere onay vermiş kullanıcı giriş yapınca istenir; kanal adı ARB'den gelir (TR "Kritik uyarılar", EN "Critical alerts"). Android aynı anda iki izin isteğini göstermediği için (konum isteği hiç dönmüyordu) izinler `PermissionQueue` ile sırayla istenir. Android izinleri (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `POST_NOTIFICATIONS`, `<queries>` `sms`/`tel`) ve iOS ücretsiz konum izin metni (`Info.plist` + `en.lproj`/`tr.lproj/InfoPlist.strings`) eklendi; APNs/push kurulumu yapılmadı |
| 2 | Panik sinyali: PANİĞİM, GÜVENDEYİM, SMS diyaloğu | ✅ | `features/safety_signal/` (domain/data/presentation): `safety_signals/{uid}` 8 haneli geohash, `set()` await edilmeden `snapshots(includeMetadataChanges: true)` ile 10 sn (`AppConfig.offlineTimeout`) sunucu onayı; çevrimdışı `pending` durumunda `AppDialog.confirm` + `Uri.encodeComponent` ile `sms:` köprüsü (`+` içermez); sinyal açıkken `"GÜVENDEYİM — Sinyali kapat"` (T8). Konum alınamazsa buton asılı kalmaz, Düdük ve SMS seçenekleri sunulur. G1 incelemesi: panikte konum için adres (geocoding) beklenmez, son 2 dakikada alınmış konum varsa hemen kullanılır. Önce çevrimdışı diyalog 15–19 sn'de çıkıyordu; şimdi 10 sn bekleme konum gelir gelmez başlar (emülatörde konum 4 ms, diyalog bırakmadan ~10 sn sonra). Yeni panik `SetOptions(merge: true)` ile yazılır ve önceki "Ulaşıldı" kaydını (`handledBy`, `handledAt`) açıkça siler; böylece bu alanlar her zaman son sinyale aittir (`SafetySignal.isHandled` → `handledBy != null`). Emülatörde denendi: "Ulaşıldı" kaydı olan belgeye yeni panik → alanlar silindi, sinyal sunucuya gitti |
| 3 | Ana Sayfa (A1) yerleşimi | ✅ | `HomeScreen`: ad + dokunarak yenilenen gerçek konum etiketi (sahte veri yok), profil geçişi, `PanicHoldButton` (2 sn basılı tutma ilerleme halkası + `GlowCircleButton`), yalnızca sunucu onayıyla `"Merkeze iletildi"` rozeti, G4 aktif çağrı kartı için boş yer tutucu ve bilgi diyaloğu açan `"YARDIM ÇAĞRISI EKLE"` butonu. Boş G3 prototip dosyaları (`offline_whistle_screen.dart`, `panic_dashboard_screen.dart`, `pulsing_panic_button.dart`) silindi |
| 4 | Düdük (A3): internetsiz, döngüde çalar; iOS'ta sessiz modda da çalar | ✅ | `WhistleScreen` (`--ui-only`): üretilen `assets/sounds/whistle.wav` ile `ReleaseMode.loop` internetsiz çalma; Android `AndroidUsageType.alarm` + iOS `AVAudioSessionCategory.playback`. Beklemede turuncu `"DÜDÜK"` / `"Yüksek Sesli Siren"`, çalarken kırmızı `"ÇALIYOR"` / `"Siren aktif"`. **Karar:** `CitizenShell` içindeki `indexedStack` sekmeyi canlı tuttuğu için sekme değiştiğinde düdük çalmaya devam eder. G1 incelemesi: ekran içeriği sola yaslanıyordu (normal yazı boyutunda); yatayda ortalandı ve bunu yakalayan widget testi eklendi |

**Çıktı:** Afetzede panik sinyali gönderebiliyor, düdük çalıyor. ✅ Android emülatöründe gerçek Firebase'e karşı denendi.

**Kontroller (G1 incelemesi):** `flutter analyze` temiz · 59 test geçiyor · `flutter build apk --debug` ve `flutter build ios --debug --no-codesign` başarılı · Android emülatöründe (API 37, İngilizce) uçtan uca: kayıt (bildirim izni kayıttan sonra, ardından konum izni), "Antakya, Hatay" etiketi (A1 ve A4), PANİĞİM → `safety_signals/{uid}` belgesi (`danger`, konum, 8 haneli geohash) ve "Delivered to center", GÜVENDEYİM → `safe`, internetsiz panik → "Offline Signal" diyaloğu → Mesajlar uygulaması acil yakının numarası, metin ve konum linkiyle açıldı; acil yakın yokken uyarı; internet gelince kuyruktaki sinyal 4 sn'de gitti; düdük internetsiz, alarm ses kanalında ve döngüde çaldı, sekme değişince sürdü. Test hesapları silindi.

**G4'e devir (Tuba):**
- Hazır servisler (`app.dart` `MultiProvider`): `LocationService` (`resolveCoordinates()`: son 2 dk'daki konumu beklemeden verir, adres çözmez; `currentLabel`), `ConnectivityService` (`hasNetworkInterface`, `onNetworkChanged` stream'i Hive kuyruğu `flush()` için), `NotificationService` (`showLocalNotification(...)`).
- `HomeScreen` (`lib/features/home/presentation/home_screen.dart`): `TODO(G4)` aktif yardım çağrısı kartı alanı ve `onAddHelpRequest` geri çağrısı hazır.
- `lib/features/emergency_call/` içindeki G4'e ait boş prototip dosyaları (`safe_zones_map_screen.dart`, `quick_need_grid.dart`) G4 incelemesinde silindi.

## G4 — Tuba · Yardım Çağrısı ve Toplanma

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Yardım Çağrısı sheet'i, `priority_policy.dart` | ✅ | Tür chip'leri, kişi sayısı, adres (≤300), açıklama (≤500), canlı öncelik rozeti; `PriorityPolicy` Kural 1 ile aynı. G1 incelemesi: tür artık seçili gelmez (yanlışlıkla "Enkaz Altında"/kritik gönderilmesin), seçilmeden Gönder kapalı; gönderim hata verirse buton takılı kalmıyor, hata mesajı çıkıyor; kişi sayısı butonlarının metni ARB'ye taşındı; chip'te simgeyle çakışan onay işareti kaldırıldı; konum G3'teki `resolveCoordinates()` ile alınıyor |
| 2 | Mükerrer birleştirme (geohash, 9 hücre, 50 m, Transaction) | ✅ | `FirestoreHelpRequestRepository`: 7 haneli hücre + 8 komşu, 50 m, olay Transaction içinde (`requestCount` +1, öncelik en yükseği), `uuid` ile çift kayıt yok. G1 incelemesi: sorgu bileşik index istiyordu ve index olmadığı için hiçbir çağrı gönderilemiyordu; artık yalnızca `geohash` aralığı sorgulanıyor, `isOpen` istemcide süzülüyor. Arama her zaman sunucudan yapılıyor (internet yeni gelince eksik önbellekten okuyup mükerrer olay açıyordu) |
| 3 | Çevrimdışı kuyruk (Hive, "Gönderilmeyi Bekliyor") | ✅ | `OfflineQueueService`: ağ yoksa ya da 10 sn'de gitmezse Hive'a yazılır, internet gelince ve uygulama açılınca gönderilir. G1 incelemesi: gönderilemeyen kayıt artık loglanıyor; başka aktif çağrı varken de kuyruktaki çağrı kartta "Gönderilmeyi Bekliyor" olarak gösteriliyor |
| 4 | Ana Sayfa'ya aktif çağrı kartı, İptal Et | ✅ | Durum, tür, kişi sayısı, öncelik, ekip ve sorumlu (`teams/{assignedTeamId}`), İptal Et. G1 incelemesi: kart sorgusu da bileşik index istiyordu (kart hiç görünmüyordu), sıralama istemciye alındı ve iptal edilmemiş en yeni çağrı seçiliyor; iptalden sonra kalan diğer aktif çağrı gizleniyordu, düzeltildi; iptal yalnızca `status` yazıyor (§5.5); onay penceresinde "İptal"/"Evet, İptal Et" karışıyordu, "Vazgeç" oldu; İngilizce "1 People" → "1 Person" |
| 5 | Toplanma (A2): harita, noktalar, mesafe, doluluk, hizmetler | ✅ | `feature/tuba-g4`: OSM harita, kullanıcı konumu, tür filtreleri, mesafe etiketli pinler, en yakın 3 alan, seçili nokta kartı (açık/kapalı, mesafe, doluluk %, kapasite, hizmetler, açıklama, yol tarifi), yakınlaştır/uzaklaştır, konumuma git; `assembly_points` canlı dinlenir. G1 incelemesi: Firestore boşken ya da hata olunca gösterilen uygulama içi uydurma toplanma noktaları kaldırıldı (var olmayan alan insanları yanlış yere gönderebilir), veri yoksa "Toplanma alanı bulunamadı"; konumu olmayan belge atlanıyor, bilinmeyen hizmet "Su" sanılmıyor; OSM ayarları `AppConfig`'ten ve harita üzerinde zorunlu OSM atfı; doluluk yüzdesi dile göre (TR %34, EN 34%); harita butonları seçili nokta kartının altında kalmıyor |

**Çıktı:** Afetzede tarafı tamamen çalışıyor. ✅ Android emülatöründe gerçek Firebase'e karşı denendi.

**Kontroller (G1 incelemesi):** `flutter analyze` temiz · 110 test geçiyor (sahte "50 m" testi gerçek seçim fonksiyonunu deneyen testle değiştirildi; birleştirme, en yeni aktif çağrı, iptal ve kuyruk gösterimi için testler eklendi) · Android emülatöründe gerçek Firebase'e karşı: çağrı + `private/contact` + yeni olay; aynı noktadan ikinci afetzedenin kritik çağrısı aynı olaya bağlandı (`requestCount: 2`, öncelik 3 → 1); ~200 m uzaktaki çağrı yeni olay açtı; karttan iptal; internetsiz çağrı kartta "Waiting to Send", uygulama kapatılıp açılınca da duruyor, internet gelince ~5 sn'de gönderildi (`createdOffline: true`) ve aynı noktadaki açık olaya bağlandı. Toplanma: Firestore boşken "No assembly areas found"; 3 test noktası yazılınca canlı geldi, konumsuz nokta atlandı, kart doluluk "25%" ve hizmetleri doğru gösterdi. Son turda afetzede akışının tamamı (panik, GÜVENDEYİM, çağrı, kart, iptal, düdük, profil konum rozeti) ve onaylı yetkili girişi (Y1–Y4 sekmeleri, Y4 profil) tekrar denendi. Test verisi silindi.

**G5'e devir (Esra):**
- **Index'ler hazır (12 Kasım, `READY`).** Canlı Akış (`incidents`: `isOpen`, `priority`, `createdAt`), panik pinleri (`safety_signals`: `state`, `updatedAt` azalan), Detay'da bağlı çağrılar (`help_requests`: `incidentId`, `createdAt`) ve ekibin görevi (`assignments`: `teamId`, `status`) için bileşik index'ler `firestore.indexes.json`'dan deploy edildi; üç sorgu REST ile denendi. Yeni bir sorgu `FAILED_PRECONDITION` verirse index'i bu dosyaya ekleyip `firebase deploy --only firestore:indexes --project afetnet-softito` çalıştırın (kurallara dokunmaz).
- Hazır modeller: `Incident` (`live_feed/domain/incident.dart`, §5.3 alanları; Firestore okuması G5'te yazılacak), `HelpRequest`, `HelpType`, `CaseStatus` (`core/constants/`), `PriorityPolicy` (`core/utils/`, rozet: `StatusBadge.priority(int)`), `SafetySignal` (`isHandled` = `handledBy != null`; yeni panik eski "Ulaşıldı" kaydını siler), `AssignedTeamInfo`.
- Hazır servisler: `LocationService`, `NotificationService.showLocalNotification(...)` (panik bildirimi için), `ConnectivityService`. Renkler: `AppStatusColors.panic` (mor pin), `critical`/`urgent`/`normal`.
- Yetkili menüsü (`OfficialShell`) ve boş Canlı Akış / Ekipler ekranları (`live_feed/presentation/live_feed_screen.dart`, `teams/presentation/teams_screen.dart`) router'a bağlı; onaylı yetkili girişi denendi.
- Afetzede çağrı kartı `help_requests/{id}` belgesini canlı dinler; G5 `status`, `assignedTeamId` yazınca kart (durum, ekip adı, sorumlu `teams/{id}.leaderName`) kendiliğinden güncellenir. Afetzedenin iptal ettiği (`cancelled`) çağrıya dokunulmaz (Kural 7).
- `lib/features/crisis_map/` içinde 5 boş (0 bayt) prototip dosya var ve hiçbir yerde kullanılmıyor; şartnamedeki feature `live_feed`'tir. Esra kullanmayacaksa silebilir.

## G5 — Esra · Canlı Akış ve Ekipler

| # | Adım | Durum |
|---|---|---|
| 1 | Canlı Akış (Y1): harita, olay kartları, filtreler | ⏳ |
| 2 | Y1 sheet'leri: Detay, Ekip Yönlendir, panik pini | ⏳ |
| 3 | Ekipler (Y2): özet, filtreler, mini harita, Görev Ata / Güncelle | ⏳ |
| 4 | Görev akışı (`assignments`), tek batch | ⏳ |

**Çıktı:** Yetkili çağrıyı görüp ekip atayabiliyor; afetzedenin kartı canlı güncelleniyor. ⏳

## G6 — Meryem · Lojistik, Anons ve Teslime Hazırlık

| # | Adım | Durum |
|---|---|---|
| 1 | Lojistik (Y3): envanter, stok etiketi, giriş/çıkış Transaction, kritik uyarı | ⏳ |
| 2 | Tahliye Anonsu sheet'i ve yarıçap bildirimi | ⏳ |
| 3 | Demo verisi, "Demo Verisini Sıfırla" (Y4'te debug butonu hazır, servisi bağlanacak), demo hesapları | ⏳ |
| 4 | Yasal metinler TR/EN (Firebase Hosting). Hesabı Sil akışı hazır (G2 + G1 incelemesi) | ⏳ |
| 5 | `firestore.rules` + index'ler (Hesabı Sil için sahibine silme izni: `users`, `private/contact`, `safety_signals`, çağrı `private/contact`; `safety_signals`'ta sahibi `handledBy`/`handledAt`'i yazamaz ama silebilir, bkz. §5.5); test modunu kapat, demo akışını dene | ⏳ |

**Not (G4'ten, kurallar için):** Yardım çağrısı gönderim Transaction'ı, çift kaydı önlemek için henüz var olmayan `help_requests/{id}` belgesini okur. Kurallar sahibinin bu okumasına izin vermeli (belge yokken `resource == null`), yoksa gönderim reddedilir. İptal yalnızca `status: cancelled` yazar.

**Çıktı:** Demo akışının (8) tamamı TR ve EN çalışıyor. ⏳

## Son Tur — 13 Kasım sabah

| Kim | İş | Durum |
|---|---|---|
| G1 | Release derlemesi (AAB) | ⏳ |
| G2 | `store/` ekran görüntüleri ve açıklamalar (TR + EN) | ⏳ |
| Herkes | Demo akışını dene, hataları sahibine ilet, demo provası | ⏳ |
