# AfetNet — Aşama Durumu

Adımlar `GOREV_DAGILIMI.md`'deki sırayla ilerler. Aşamasını bitiren kişi kendi satırlarını günceller ve bu dosyayı PR'ına ekler.

**Durum:** ✅ Tamamlandı · 🟡 Kısmen / bekleyen iş var · ⏳ Başlamadı

| Aşama | Sahip | Durum | PR |
|---|---|---|---|
| G1 — Temel ve Giriş | Mustafa | 🟡 Tamam, ekip erişimi bekliyor | [#8](https://github.com/knetrix/softito_afetnet/pull/8), [#9](https://github.com/knetrix/softito_afetnet/pull/9) |
| G2 — Görünüm ve Profil | Sümeyye | ✅ Tamamlandı (G1 incelemesiyle düzeltildi) | [#11](https://github.com/knetrix/softito_afetnet/pull/11), `fix/mustafa-g2-review` |
| G3 — Panik, Ana Sayfa ve Düdük | Furkan | 🟡 Kod & testler tamam, emülatör denemesi bekliyor | — |
| G4 — Yardım Çağrısı ve Toplanma | Tuba | ⏳ Sıradaki | — |
| G5 — Canlı Akış ve Ekipler | Esra | ⏳ | — |
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
| 5 | `validators.dart`: e-posta, telefon maskesi, şifre kuralı | ✅ | Birim testli |
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
| 1 | Servisler: konum + konum etiketi, bağlantı tespiti, yerel bildirim + FCM `all_users` | ✅ | `DeviceLocationService` (`geolocator` + `geocoding` + `SharedPreferences` son etiket önbelleği; A1 ve A4 `TODO(G3)` bağlandı), `DeviceConnectivityService` (`connectivity_plus`), `DeviceNotificationService` (`flutter_local_notifications` `"afetnet_critical_alerts"` kanalı + FCM `all_users` yalnızca `notificationsOptIn == true` ise abone olur, aksi durumda/çıkışta abonelikten çıkar). Android izinleri (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `POST_NOTIFICATIONS`, `<queries>` `sms`/`tel`) ve iOS ücretsiz konum izin metni (`Info.plist` + `en.lproj`/`tr.lproj/InfoPlist.strings`) eklendi; APNs/push kurulumu yapılmadı |
| 2 | Panik sinyali: PANİĞİM, GÜVENDEYİM, SMS diyaloğu | ✅ | `features/safety_signal/` (domain/data/presentation): `safety_signals/{uid}` 8 haneli geohash, `set()` await edilmeden `snapshots(includeMetadataChanges: true)` ile 10 sn (`AppConfig.offlineTimeout`) sunucu onayı; çevrimdışı `pending` durumunda `AppDialog.confirm` + `Uri.encodeComponent` ile `sms:` köprüsü (`+` içermez); sinyal açıkken `"GÜVENDEYİM — Sinyali kapat"` (T8). Konum alınamazsa buton asılı kalmaz, Düdük ve SMS seçenekleri sunulur |
| 3 | Ana Sayfa (A1) yerleşimi | ✅ | `HomeScreen`: ad + dokunarak yenilenen gerçek konum etiketi (sahte veri yok), profil geçişi, `PanicHoldButton` (2 sn basılı tutma ilerleme halkası + `GlowCircleButton`), yalnızca sunucu onayıyla `"Merkeze iletildi"` rozeti, G4 aktif çağrı kartı için boş yer tutucu ve bilgi diyaloğu açan `"YARDIM ÇAĞRISI EKLE"` butonu. Boş G3 prototip dosyaları (`offline_whistle_screen.dart`, `panic_dashboard_screen.dart`, `pulsing_panic_button.dart`) silindi |
| 4 | Düdük (A3): internetsiz, döngüde çalar; iOS'ta sessiz modda da çalar | ✅ | `WhistleScreen` (`--ui-only`): üretilen `assets/sounds/whistle.wav` ile `ReleaseMode.loop` internetsiz çalma; Android `AndroidUsageType.alarm` + iOS `AVAudioSessionCategory.playback`. Beklemede turuncu `"DÜDÜK"` / `"Yüksek Sesli Siren"`, çalarken kırmızı `"ÇALIYOR"` / `"Siren aktif"`. **Karar:** `CitizenShell` içindeki `indexedStack` sekmeyi canlı tuttuğu için sekme değiştiğinde düdük çalmaya devam eder |

**Çıktı:** Afetzede panik sinyali gönderebiliyor, düdük çalıyor. 🟡 (Kod ve testler tamam; Android emülatörde canlı akış denemesi bekliyor.)

**Kontroller:** `flutter analyze` temiz · 53 test geçiyor (G3'te konum/öncelik/SMS URI/controller ve 360×640 büyük yazı ölçekli widget testleri dahil +19 test eklendi) · `flutter build apk --debug` soğuk Gradle derlemesi uzun sürdüğü için iptal edildi; emülatörde canlı deneme ve macOS'ta `flutter build ios --debug --no-codesign` kontrolü yapılacak.

**G4'e devir (Tuba):**
- Hazır servisler (`app.dart` `MultiProvider`): `LocationService` (`resolveCoordinates()`, `currentLabel`), `ConnectivityService` (`hasNetworkInterface`, `onNetworkChanged` stream'i Hive kuyruğu `flush()` için), `NotificationService` (`showLocalNotification(...)`).
- `HomeScreen` (`lib/features/home/presentation/home_screen.dart`): `TODO(G4)` aktif yardım çağrısı kartı alanı ve `onAddHelpRequest` geri çağrısı hazır.
- `lib/features/emergency_call/` içindeki G4'e ait `safe_zones_map_screen.dart` ve `quick_need_grid.dart` dosyalarına dokunulmadı.

**G5 notu (Esra):**
- Sahibi `safety_signals/{uid}` üzerinde `handledBy` / `handledAt` alanlarına yazamadığı için (§5.5), yetkili "Ulaşıldı" işaretledikten sonra afetzede yeniden panik gönderirse eski `handledBy`/`handledAt` alanları belgede kalır. Kural: **`handledAt == null || handledAt < updatedAt` ise sinyal yeniden açık sayılır** (`SafetySignal.isHandledAfterLastSignal`).

## G4 — Tuba · Yardım Çağrısı ve Toplanma

| # | Adım | Durum |
|---|---|---|
| 1 | Yardım Çağrısı sheet'i, `priority_policy.dart` | ⏳ |
| 2 | Mükerrer birleştirme (geohash, 9 hücre, 50 m, Transaction) | ⏳ |
| 3 | Çevrimdışı kuyruk (Hive, "Gönderilmeyi Bekliyor") | ⏳ |
| 4 | Ana Sayfa'ya aktif çağrı kartı, İptal Et | ⏳ |
| 5 | Toplanma (A2): harita, noktalar, mesafe, doluluk, hizmetler | ⏳ |

**Çıktı:** Afetzede tarafı tamamen çalışıyor. ⏳

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
| 5 | `firestore.rules` + index'ler (Hesabı Sil için sahibine silme izni: `users`, `private/contact`, `safety_signals`, çağrı `private/contact`); test modunu kapat, demo akışını dene | ⏳ |

**Çıktı:** Demo akışının (8) tamamı TR ve EN çalışıyor. ⏳

## Son Tur — 13 Kasım sabah

| Kim | İş | Durum |
|---|---|---|
| G1 | Release derlemesi (AAB) | ⏳ |
| G2 | `store/` ekran görüntüleri ve açıklamalar (TR + EN) | ⏳ |
| Herkes | Demo akışını dene, hataları sahibine ilet, demo provası | ⏳ |
