# AfetNet — Aşama Durumu

Adımlar `GOREV_DAGILIMI.md`'deki sırayla ilerler. Aşamasını bitiren kişi kendi satırlarını günceller ve bu dosyayı PR'ına ekler.

**Durum:** ✅ Tamamlandı · 🟡 Kısmen / bekleyen iş var · ⏳ Başlamadı

| Aşama | Sahip | Durum | PR |
|---|---|---|---|
| G1 — Temel ve Giriş | Mustafa | ✅ Tamamlandı | [#8](https://github.com/knetrix/softito_afetnet/pull/8), [#9](https://github.com/knetrix/softito_afetnet/pull/9) |
| G2 — Görünüm ve Profil | Sümeyye | ✅ Tamamlandı (G1 incelemesiyle düzeltildi) | [#11](https://github.com/knetrix/softito_afetnet/pull/11), `fix/mustafa-g2-review` |
| G3 — Panik, Ana Sayfa ve Düdük | Furkan | ✅ Tamamlandı (G1 incelemesiyle düzeltildi) | [#14](https://github.com/knetrix/softito_afetnet/pull/14), `fix/mustafa-g3-review` |
| G4 — Yardım Çağrısı ve Toplanma | Tuba | ✅ Tamamlandı (G1 incelemesiyle düzeltildi) | `development`'a doğrudan commit, `feature/tuba-g4`, [#18](https://github.com/knetrix/softito_afetnet/pull/18), `fix/mustafa-g4-assembly` |
| G5 — Canlı Akış ve Ekipler | Esra | ✅ Tamamlandı (G1 incelemesiyle düzeltildi) | [#20](https://github.com/knetrix/softito_afetnet/pull/20), `fix/mustafa-g5-review` |
| G6 — Lojistik, Anons ve Teslime Hazırlık | Meryem | ✅ Tamam (G1 incelemesiyle düzeltildi); demo hesapları açıldı, yasal sayfalar yayında | [#22](https://github.com/knetrix/softito_afetnet/pull/22), `fix/mustafa-g6-review` |
| Son Tur — 13 Kasım sabah | Herkes | ⏳ | — |

---

## G1 — Mustafa · Temel ve Giriş

**Çıktı:** Kayıt olan kullanıcı rolüne göre boş ana sayfaya düşüyor. ✅ iOS simülatöründe gerçek Firebase'e karşı denendi.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Kimlik: `name: afetnet`, `com.softito.afetnet` | ✅ | Conflict işaretli platform dosyaları yeniden üretildi; `macos/` ve `web/` kaldırıldı |
| 2 | Firebase projesi (`eur3`), `flutterfire configure`, Firestore test modu | ✅ | Proje `afetnet-softito`. Test modu kuralları 11 Aralık 2026'ya kadar geçerli. E-posta/Şifre girişi açık |
| 2 | Ekip üyelerine Firebase projesinde Editor yetkisi ver | ✅ | 12 Kasım: tüm geliştiriciler Editor olarak eklendi (Console → Proje ayarları → Kullanıcılar ve izinler). Console'da veri görmek, yetkili onaylamak ve deploy için gerekir; davet e-postasının kabul edilmesi gerekir |
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
| 3 | Çevrimdışı kuyruk (Hive, "Gönderilmeyi Bekliyor") | ✅ | `OfflineQueueService`: ağ yoksa ya da 10 sn'de gitmezse Hive'a yazılır, internet gelince ve uygulama açılınca gönderilir. G1 incelemesi: gönderilemeyen kayıt artık loglanıyor; başka aktif çağrı varken de kuyruktaki çağrı kartta "Gönderilmeyi Bekliyor" olarak gösteriliyor. "Wi-Fi bağlı ama internet yok" durumunda internet geri gelince ağ arayüzü değişmediği için kuyruk hiç tetiklenmiyordu (R8); kuyrukta çağrı varken 30 sn'de bir yeniden deneniyor (`AppConfig.offlineQueueRetryInterval`) |
| 4 | Ana Sayfa'ya aktif çağrı kartı, İptal Et | ✅ | Durum, tür, kişi sayısı, öncelik, ekip ve sorumlu (`teams/{assignedTeamId}`), İptal Et. G1 incelemesi: kart sorgusu da bileşik index istiyordu (kart hiç görünmüyordu), sıralama istemciye alındı ve iptal edilmemiş en yeni çağrı seçiliyor; iptalden sonra kalan diğer aktif çağrı gizleniyordu, düzeltildi; iptal yalnızca `status` yazıyor (§5.5); onay penceresinde "İptal"/"Evet, İptal Et" karışıyordu, "Vazgeç" oldu; İngilizce "1 People" → "1 Person" |
| 5 | Toplanma (A2): harita, noktalar, mesafe, doluluk, hizmetler | ✅ | `feature/tuba-g4`: OSM harita, kullanıcı konumu, tür filtreleri, mesafe etiketli pinler, en yakın 3 alan, seçili nokta kartı (açık/kapalı, mesafe, doluluk %, kapasite, hizmetler, açıklama, yol tarifi), yakınlaştır/uzaklaştır, konumuma git; `assembly_points` canlı dinlenir. G1 incelemesi: Firestore boşken ya da hata olunca gösterilen uygulama içi uydurma toplanma noktaları kaldırıldı (var olmayan alan insanları yanlış yere gönderebilir), veri yoksa "Toplanma alanı bulunamadı"; konumu olmayan belge atlanıyor, bilinmeyen hizmet "Su" sanılmıyor; OSM ayarları `AppConfig`'ten ve harita üzerinde zorunlu OSM atfı; doluluk yüzdesi dile göre (TR %34, EN 34%); harita butonları seçili nokta kartının altında kalmıyor |

**Çıktı:** Afetzede tarafı tamamen çalışıyor. ✅ Android emülatöründe gerçek Firebase'e karşı denendi.

**Kontroller (G1 incelemesi):** `flutter analyze` temiz · 111 test geçiyor (sahte "50 m" testi gerçek seçim fonksiyonunu deneyen testle değiştirildi; birleştirme, en yeni aktif çağrı, iptal ve kuyruk gösterimi için testler eklendi) · Android emülatöründe gerçek Firebase'e karşı: çağrı + `private/contact` + yeni olay; aynı noktadan ikinci afetzedenin kritik çağrısı aynı olaya bağlandı (`requestCount: 2`, öncelik 3 → 1); ~200 m uzaktaki çağrı yeni olay açtı; karttan iptal; internetsiz çağrı kartta "Waiting to Send", uygulama kapatılıp açılınca da duruyor, internet gelince ~5 sn'de gönderildi (`createdOffline: true`) ve aynı noktadaki açık olaya bağlandı. Toplanma: Firestore boşken "No assembly areas found"; 3 test noktası yazılınca canlı geldi, konumsuz nokta atlandı, kart doluluk "25%" ve hizmetleri doğru gösterdi. Son turda afetzede akışının tamamı (panik, GÜVENDEYİM, çağrı, kart, iptal, düdük, profil konum rozeti) ve onaylı yetkili girişi (Y1–Y4 sekmeleri, Y4 profil) tekrar denendi. Ek denemeler: uygulama kapalıyken kuyruğa alınan çağrı, internet açıkken uygulama başlayınca gönderildi; "Wi-Fi bağlı ama internet yok" (DNS kesik) durumunda çağrı 3,3 sn'de kuyruğa düştü, internetsiz iptal kartta hemen işlendi, internet gelince uygulamaya dokunmadan kuyruk gönderildi ve iptal Firestore'a ulaştı (~70 sn; süreyi Firestore'un yeniden bağlanma aralığı belirliyor); Ana Sayfa, çağrı kartı ("Gönderilmeyi Bekliyor"), yardım çağrısı formu ve Toplanma kartı Türkçe ve koyu temada incelendi. Test verisi silindi.

**G5'e devir (Esra):**
- **Index'ler hazır (12 Kasım, `READY`).** Canlı Akış (`incidents`: `isOpen`, `priority`, `createdAt`), panik pinleri (`safety_signals`: `state`, `updatedAt` azalan), Detay'da bağlı çağrılar (`help_requests`: `incidentId`, `createdAt`) ve ekibin görevi (`assignments`: `teamId`, `status`) için bileşik index'ler `firestore.indexes.json`'dan deploy edildi; üç sorgu REST ile denendi. Yeni bir sorgu `FAILED_PRECONDITION` verirse index'i bu dosyaya ekleyip `firebase deploy --only firestore:indexes --project afetnet-softito` çalıştırın (kurallara dokunmaz).
- Hazır modeller: `Incident` (`live_feed/domain/incident.dart`, §5.3 alanları; Firestore okuması G5'te yazılacak), `HelpRequest`, `HelpType`, `CaseStatus` (`core/constants/`), `PriorityPolicy` (`core/utils/`, rozet: `StatusBadge.priority(int)`), `SafetySignal` (`isHandled` = `handledBy != null`; yeni panik eski "Ulaşıldı" kaydını siler), `AssignedTeamInfo`.
- Hazır servisler: `LocationService`, `NotificationService.showLocalNotification(...)` (panik bildirimi için), `ConnectivityService`. Renkler: `AppStatusColors.panic` (mor pin), `critical`/`urgent`/`normal`.
- Yetkili menüsü (`OfficialShell`) ve boş Canlı Akış / Ekipler ekranları (`live_feed/presentation/live_feed_screen.dart`, `teams/presentation/teams_screen.dart`) router'a bağlı; onaylı yetkili girişi denendi.
- Afetzede çağrı kartı `help_requests/{id}` belgesini canlı dinler; G5 `status`, `assignedTeamId` yazınca kart (durum, ekip adı, sorumlu `teams/{id}.leaderName`) kendiliğinden güncellenir. Afetzedenin iptal ettiği (`cancelled`) çağrıya dokunulmaz (Kural 7).
- `lib/features/crisis_map/` içindeki 5 boş (0 bayt) prototip dosya G5 incelemesinde silindi; şartnamedeki feature `live_feed`'tir.

## G5 — Esra · Canlı Akış ve Ekipler

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Canlı Akış (Y1): harita, olay kartları, filtreler | ✅ | Açık olaylar `isOpen` + `priority` + `createdAt` sırasıyla canlı (§5.4 index'i). Haritada öncelik renkli olay pinleri ve mor panik pinleri (ulaşılmış pin soluk). Filtreler (Tümü / Kritik / Acil / Normal / türler) istemcide. Kartta ad (`primaryRequestId` çağrısının `private/contact.fullName`), kişi sayısı, mesafe, adres, açıklama, süre, öncelik; butonlar yalnızca Detay ve Ekip Yönlendir (T9). Ekibi olan kartta ekip adı ve görev durumu. G1 incelemesi: İngilizcede "Dispatch Te…" diye kesilen buton metni artık kesilmiyor; iki buton yan yana sığmazsa (dar ekran, büyük yazı, uzun çeviri) alt alta dizilir |
| 2 | Y1 sheet'leri: Detay, Ekip Yönlendir, panik pini | ✅ | Detay: telefon + Ara, tıbbi özet (`users/{createdBy}/private/contact.medical`), bağlı çağrı, görev durumu; Olayı Kapat yalnızca ekip yokken (Kural 7). Ekip Yönlendir: boştaki ekipler olaya yakından uzağa. Panik pini: konum, zaman, Ulaşıldı (`handledBy`, `handledAt`). Ekran açıkken yeni panikte yetkiliye yerel bildirim (Kural 8). G1 incelemesi: bildirime onay vermemiş yetkiliden Android bildirim izni hiç istenmediği için panik bildirimi sessizce gelmiyordu; onaylı yetkili giriş yapınca izin istenir (`all_users` aboneliği yine tercihe bağlı). İnternet yokken Ulaşıldı butonu sunucu onayını bekleyip sonsuza dek dönüyordu; 10 sn sonra "bağlantı gelince iletilecek" der, kayıt Firestore kuyruğunda kalır. Detay'daki bağlı çağrı sayısı afetzedenin iptal ettiklerini ayrıca yazar ("3 (1 iptal edildi)"); `requestCount` birleşen tüm çağrıları sayar |
| 3 | Ekipler (Y2): özet, filtreler, mini harita, Görev Ata / Güncelle | ✅ | Tim ve personel sayısı, tür filtreleri, mini harita (boşta yeşil, görevde kırmızı). Görev Ata: ekip bekleyen açık olaylar (öncelik sırası). Görev Güncelle: yalnızca sonraki adım. Telsiz butonu yok (T2). G1 incelemesi: İngilizce notlarda "Rescued" yazıyordu, buton ve adım "Resolved"; birleştirildi |
| 4 | Görev akışı (`assignments`), tek batch | ✅ | `assignments`, `incidents`, bağlı açık `help_requests` ve `teams` tek atomik commit. Batch yerine Transaction: yazmadan önce olay, ekip ve görevin güncel durumu okunur; böylece iki yetkili aynı olaya ekip atayamaz, adım iki kez ilerletilemez. Geri adım yok, olayda tek aktif görev; `resolved`'da olay kapanır, ekip `available` olur. İptal edilmiş çağrıya dokunulmaz (Kural 7). G1 incelemesi: ekip atandıktan sonra aynı olaya birleşen çağrı kurallar gereği `pending` açılır (§5.5) ve görev bir sonraki adıma geçene kadar afetzedenin kartında "Ekip ataması bekleniyor" yazıyordu. Kart artık bekleyen çağrının olayını (`incidents/{incidentId}`, kişisel veri yok) dinler; olayda aktif görev varsa durum ve ekip olaydan gösterilir. Firestore'a yazılan bir şey değişmedi |

**Çıktı:** Yetkili çağrıyı görüp ekip atayabiliyor; afetzedenin kartı canlı güncelleniyor. ✅ Android emülatöründe gerçek Firebase'e karşı denendi.

**Kontroller:** `flutter analyze` temiz · 136 test geçiyor (25'i G5: görev akışı ileri/geri, Firestore dönüşümleri, Kural 7 süzgeci, filtre, panik bildirimi, ekip sıralaması, Y1/Y2 ekranları ve sheet'leri, TR/EN) · Yeni sorgu için index gerekmedi (`assignments`: tek alanlı `status in [...]`).

**Kontroller (G1 incelemesi):** `flutter analyze` temiz · 142 test geçiyor (kart butonlarının dar ve geniş ekranda dizilişi, Detay'da iptal sayısı, internetsiz Ulaşıldı, birleşen çağrının kartta olaydan ekip göstermesi) · Android emülatöründe (API 37) gerçek Firebase'e karşı iki afetzede ve onaylı yetkiliyle: Canlı Akış kartları (ad, kişi, mesafe, adres, açıklama, birleşen çağrı), harita pinleri ve filtreler; Detay (telefon, Ara, tıbbi özet); açılışta var olan panik için bildirim yok, ekran açıkken gelen yeni panikte bildirim var; Ulaşıldı yalnızca `handledBy` (= yetkili uid) ve `handledAt` yazdı; Ekip Yönlendir → olay, açık çağrı, `assignments` ve ekip birlikte güncellendi, iptal edilmiş çağrıya dokunulmadı; Ekipler (özet 3 tim · 18 personel, mini harita, Görevde/Boşta); Görev Güncelle Atandı → Yola Çıktı → Olay Yerinde → Kurtarıldı, her adımda dört belge, sonda olay kapandı ve ekip boşa çıktı; afetzede kartı ekip adı, lider ve "Yola Çıktı" gösterdi; başka yetkili aynı anda ekip atamış gibi yapılınca "Bu olaya zaten ekip atanmış", hiçbir şey yazılmadı; Olayı Kapat → olay ve çağrı `resolved`; Ekipler TR ve koyu temada incelendi. Düzeltmelerden sonra tekrar: bildirime onay vermemiş yetkiliden girişte bildirim izni istendi, ardından konum izni geldi ve panik bildirimi düştü; İngilizce kartta butonlar alt alta, metin tam; Detay "2 (1 cancelled)"; internetsiz Ulaşıldı 10 sn sonra "bağlantı gelince iletilecek" dedi, internet gelince kayıt 3 sn'de gitti; ekip atandıktan sonra birleşen çağrının kartı "Ekip Yönlendirildi", ekip adı ve lideri gösterdi (belge `pending` kaldı). Test verisi silindi.

**G6'ya devir (Meryem):**
- **Demo verisi (`teams`):** Alanlar §5.3'teki gibi; `status: available` ile başlar, `currentTask` yazılmaz. Ekip kartları, mini harita ve Ekip Yönlendir sıralaması için `location` (geopoint) gerekli. `teams/{id}.currentTask` metin değil, olayın id'sidir; ekranda tür ve durum cihaz dilinde gösterilir.
- **Kurallar (§5.5):** Görev atama ve ilerletme Transaction içinde `incidents/{id}`, `teams/{id}`, `assignments/{id}` ve bağlı `help_requests/{id}` belgelerini okur, sonra yazar. Yetkili `help_requests`'e yalnızca `status`, `assignedTeamId`, `updatedAt`, `resolvedAt`; `incidents`'a `status`, `isOpen`, `assignedTeamId`, `updatedAt`, `resolvedAt` yazar. `teams` güncellemesinde `currentTask` silinebilir (`FieldValue.delete()`). Olayı Kapat da Transaction'dır. Ulaşıldı yalnızca `handledBy` (= yetkilinin uid'si) ve `handledAt` yazar.
- **Tahliye Anonsu butonu:** Y1 ve Y2'de eklenmedi (sheet G6'da). İki ekran da `CustomScrollView`; buton `Scaffold.floatingActionButton` olarak eklenebilir.
- **Birleşen çağrı:** Ekip atandıktan sonra aynı olaya birleşen çağrının belgesi görevin bir sonraki adımında güncellenir (durum ve `assignedTeamId`); o zamana kadar afetzedenin kartı durumu ve ekibi `incidents/{id}`'den okur. Kurallarda `incidents` okuması giriş yapmış herkese açık kalmalı (§5.5).
- **Bildirim izni:** Onaylı yetkiliden giriş yapınca bildirim izni istenir (panik ve G6'daki kritik stok bildirimi için). G6 anons ve stok bildirimlerinde `NotificationService.showLocalNotification(...)` kullanılabilir.
- **Demo hesapları:** Yetkili hesabı kayıtta açılır ve Console'dan `isVerified: true` yapılır (Firestore → `users/{uid}`).

## G6 — Meryem · Lojistik, Anons ve Teslime Hazırlık

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Lojistik (Y3): envanter, stok etiketi, giriş/çıkış Transaction, kritik uyarı | ✅ | Depo seçimi, kritik stok kartı, filtreler (Tümü / Kritik / Orta / Yeterli), stok kartları; giriş/çıkış tek Transaction, eksi stok yok, `movements` kaydı (Kural 3). G1 incelemesi: Lojistik açılınca depoları kendiliğinden yazan kod kaldırıldı (seed "Demo Verisini Sıfırla"da); T7'nin kaldırılmasını istediği işlevsiz "Acil İkmal İste" butonu kaldırıldı; kritik stok bildirimi kendi bildirim altyapısını kuruyordu, `NotificationService` kullanıyor ve yalnızca kalem bu ekranda kritik düzeye inince düşüyor (her açılışta değil); stok sheet'indeki Türkçe sabit metinler ARB'ye taşındı; eksi stok reddi `InsufficientStockException` |
| 2 | Tahliye Anonsu sheet'i ve yarıçap bildirimi | ✅ | `broadcasts` yazımı, açık uygulamada yarıçap içindeki afetzedeye yerel bildirim (Kural 10). G1 incelemesi: tür seçimi eklendi (Acil Tahliye / Artçı Sarsıntı; önce yalnızca tahliye gönderilebiliyordu); merkez elle girilen koordinat değil yetkilinin konumu (§3.2); buton Ekipler'de de var (yalnızca Canlı Akış'taydı) ve son kartı örtmüyor; internetsizken 10 sn sonra "bağlantı gelince gönderilecek" der; bildirim başlığı afetzedenin dilinde (tür adı). Sheet `presentation/`a taşındı, silinmiş `crisis_map` klasörü yeniden açılmıştı, kaldırıldı. Bildirim yalnızca kayıtta bildirimlere onay veren afetzedeye düşer (izin yalnızca onlardan istenir) |
| 3 | Demo verisi, "Demo Verisini Sıfırla", demo hesapları | ✅ | G1 incelemesi: `demo_seed/data/demo_seed_service.dart` yazıldı (önce klasör boştu, kod profil ekranındaydı). Yalnızca debug derlemede, yetkili profilinden: 4 ekip (`team_04` = Arama Kurtarma Tim 4, §8), 2 depo, 8 stok kalemi, 3 toplanma alanı; eksikse oluşturur, varsa başlangıç hâline getirir (`currentTask` silinir), `isDemo` olmayan gerçek kayda dokunmaz. Su 70 koli / kritik 25: §8 adım 6'daki 50 koli çıkışı kritik uyarı ve bildirim üretir. Canlıda bir kez çalıştırıldı. §8'deki demo hesapları 12 Kasım'da açıldı (şifre ekipte): `afetzede1@afetnet.demo` (tıbbi bilgisi, acil durum yakını ve adresi dolu), `afetzede2@afetnet.demo` (ikisi de bildirimlere onaylı, anons bildirimi için gerekli), `yetkili@afetnet.demo` (`isVerified: true`, `teamId: team_04`). Çağrı, olay, görev ve panik kayıtları kurallar gereği uygulamadan silinemez; provadan sonra Console'dan temizlenir |
| 4 | Yasal metinler TR/EN (Firebase Hosting). Hesabı Sil akışı hazır (G2 + G1 incelemesi) | ✅ | Gizlilik ve Kullanım Koşulları TR/EN yayında. G1 incelemesi: uygulama `kvkk.html`, `terms.html`, `delete-account.html` adreslerini açıyordu (404) ve gizlilik bağlantısı İngilizcede de Türkçe sayfaya gidiyordu; adresler uygulama diline göre (`AppConfig.legalUrl`), KVKK Aydınlatma Metni ve Hesap Silme sayfaları TR/EN yazıldı (uygulamanın gerçekte işlediği verilere göre). Köşeli parantezli alanlar dolduruldu: işletici SoftITO 4. Dönem Mobil — 2. Grup (ticari olmayan eğitim projesi), iletişim e-postası, KVKK m.5/6 hukuki sebepleri, verilerin Firebase Avrupa bölgesinde (eur3) saklanması, saklama ve 30 günlük başvuru süresi. 12 Kasım'da yayınlandı; 8 sayfa da açılıyor |
| 5 | `firestore.rules` + index'ler; test modunu kapat, demo akışını dene | ✅ | Kurallar §5.5'e göre yazıldı, 19 kural testi (`test/firestore/firestore.rules.test.mjs`) ve canlıya yüklendi (test modu kapandı). G1 incelemesi: kurallar uygulamanın gerçek yazımlarını reddediyordu ve canlıda üç akış bozuktu: hiçbir yardım çağrısı gönderilemiyordu (gönderim henüz olmayan çağrı belgesini okur), "Ulaşıldı" denmiş afetzedenin yeni paniği reddediliyordu (sahibi `handledBy`/`handledAt`'i silemiyordu), ekip atandıktan sonra birleşen çağrı varken görev ilerletilemiyordu. Düzeltildi, uygulamanın 19 yazımını deneyen testler eklendi (`test/firestore/app_flows.rules.test.mjs`, `npm run test:rules`), 12 Kasım'da yeniden yüklendi. `firestore.indexes.json`'a kullanılmayan iki index eklenmişti, dosyadan ve canlıdan kaldırıldı (canlıda 4 index) |

**Çıktı:** Demo akışının (8) tamamı TR ve EN çalışıyor. ✅ Adımlar emülatörde ayrı ayrı denendi; tam demo provası Son Tur'da.

**Kontroller (G1 incelemesi):** `flutter analyze` temiz · 157 Flutter testi geçiyor (stok etiketi, stok sheet'i eksi stok ve İngilizce metin, demo verisinin §8 adım 6'yı sağlaması, anons sheet'i tür, merkez, konumsuz ve internetsiz durumlar, yasal adresler) · 38 kural testi geçiyor (Firestore emülatörü) · Android emülatöründe gerçek Firebase'e karşı: kural düzeltmesinden önce yardım çağrısı `PERMISSION_DENIED` ile gönderilemiyordu, sonra gönderildi; "Ulaşıldı" denmiş afetzedenin yeni paniği sunucuya gitti ve eski kayıt silindi; Demo Verisini Sıfırla 4 ekip, 2 depo, 8 kalem, 3 alan yazdı; 50 koli su çıkışı → "Kritik Stok Uyarısı" kartı ve bildirim; Ekipler'den Artçı Sarsıntı anonsu yetkilinin konumuyla yazıldı; yarıçap içindeki afetzedeye bildirim TR cihazda "Acil Tahliye", EN cihazda "Aftershock" başlığıyla geldi, yarıçap dışındakine gelmedi. Test verisi silindi; Meryem'in demo anonsu ve stok hareketi duruyor.

**Not (G4'ten, kurallar için):** Yardım çağrısı gönderim Transaction'ı, çift kaydı önlemek için henüz var olmayan `help_requests/{id}` belgesini okur. Kurallar sahibinin bu okumasına izin vermeli (belge yokken `resource == null`), yoksa gönderim reddedilir. İptal yalnızca `status: cancelled` yazar. *(G6 incelemesinde kurala eklendi.)*

**Kural değişikliği yapacaklara:** Kuralları değiştirdikten sonra `npm ci && npm run test:rules` çalıştırın (Java gerekir); uygulama akışı testleri geçmeden `firebase deploy --only firestore:rules` yapmayın.

## Son Tur — 13 Kasım sabah

| Kim | İş | Durum |
|---|---|---|
| G1 | Release derlemesi (AAB) | ⏳ |
| G2 | `store/` ekran görüntüleri ve açıklamalar (TR + EN) | ⏳ |
| Herkes | Demo akışını dene, hataları sahibine ilet, demo provası | ⏳ |
