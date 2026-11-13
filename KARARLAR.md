# AfetNet — Şartnameye Göre Nihai Kararlar

Hocanın verdiği şartname (`original-project-md/PROJECT.md`) ile teslim edilen uygulamanın karşılaştırması. Ayrıntılı kapsam `PROJECT_NEW.md`'de, aşama aşama ilerleme `DONE.md`'de.

**Durum:** ✅ Yapıldı · 🔄 Değiştirilerek yapıldı · ❌ Yapılmadı (gerekçeli)

## 1. Temel Kararlar

- **Platform:** Android. Test ve demo Android'de yapıldı. iOS derlemesi bozulmadı ama push bildirimi kurulmadı, çünkü ücretli Apple Developer hesabı gerekiyor.
- **Ücretsiz Firebase (Spark plan):** Cloud Functions yok. Bu yüzden öncelik ve mükerrer birleştirme istemcide hesaplanıyor; doğruluklarını Security Rules denetliyor.
- **Tek kaynak kuralı:** Ekranlar yalnızca `design/` klasöründeki 12 tasarımdan, veritabanı yalnızca `database/` taslağından yapıldı. Tasarımı olmayan özellikler kapsam dışı bırakıldı. Küçük işlemler yeni ekran yerine bottom sheet veya diyalog olarak eklendi.
- **Resmi kurum değildir:** Tasarımlardaki AFAD, AKUT ve Kızılay adlarıyla logoları kaldırıldı; mağazalar kurum taklidini reddediyor. Onboarding'de ve Giriş'te "Resmi kurum uygulaması değildir · Acil durumda 112" uyarısı var.
- **Roller:** `citizen` (Afetzede) ve `official` (Saha Koordinatörü). Yetkili hesap onaysız açılıyor; Firebase Console'dan onaylanmadan hiçbir veriyi göremiyor.

## 2. Modül 1 — Afetzede

| Şartname | Durum | Ne yapıldı |
|---|---|---|
| GÜVENDEYİM / TEHLİKEDEYİM butonu | ✅ | 2 sn basılı tutunca konum ve zamanla birlikte sinyal gidiyor. Sinyal yetkilinin haritasında mor pin olarak görünüyor ve yetkiliye bildirim düşüyor. |
| Acil yardım çağrısı (tür, kişi sayısı, adres) | ✅ | 7 ihtiyaç türü, kişi sayısı, adres tarifi ve açıklama. Aktif çağrı kartı ekibin durumuyla canlı güncelleniyor; çağrı iptal edilebiliyor. |
| Çağrıya fotoğraf yükleme | ❌ | Tasarımda yok. `photoUrls` alanı ileride kullanılmak üzere ayrıldı. |
| Düdük modu (internetsiz) | ✅ | Yüksek sesli düdük; telefon sessizdeyken de çalıyor. |
| Mors kodlu flaş | ❌ | Tasarımda yok. |
| SMS köprüsü | 🔄 | İnternet yoksa SMS uygulaması, acil durum yakınının numarası ve konum linkiyle hazır açılıyor; kullanıcı Gönder'e basıyor. Play, otomatik SMS iznini (`SEND_SMS`) yalnızca varsayılan SMS uygulamalarına veriyor. |
| Toplanma alanları ve sahra hastaneleri | ✅ | Haritada pin olarak; mesafe, doluluk yüzdesi ve hizmetlerle. |
| Kayıp / yakın arama panosu | ❌ | Tasarımı yok. `missing_persons` koleksiyonu ayrıldı, kurallarla kapalı. |
| Profil | ✅ | Tıbbi kimlik (ayrı KVKK açık rızasıyla), acil durum yakını, adres, Dil seçimi, Hesabı Sil. |

## 3. Modül 2 — Saha Koordinatörü

| Şartname | Durum | Ne yapıldı |
|---|---|---|
| Canlı kriz haritası ve çağrı akışı | ✅ | Firestore stream ile harita ve liste. Öncelik renkli pinler, mor panik pinleri, filtre chip'leri, Detay sheet'i (telefon ve tıbbi özet). |
| Görev atama ve durum akışı | ✅ | Ekip Yönlendir veya Görev Ata ile başlıyor: Atandı → Yola Çıktı → Olay Yerinde → Kurtarıldı. Geri adım yok. Her geçişte görev, olay, çağrılar ve ekip tek batch'te güncelleniyor. |
| Sahra deposu ve stok takibi | ✅ | 2 depo. Giriş ve çıkış tek Transaction; eksi stok yok, her hareket `movements`'a yazılıyor. Kritik / Orta / Yeterli etiketleri, kritik uyarı kartı ve bildirim. |
| Gönüllü havuzu ve vardiya yönetimi | ❌ | Tasarımı yok. `volunteers` ve `shifts` koleksiyonları ayrıldı, kurallarla kapalı. |
| Tahliye anonsu (FCM broadcast) | 🔄 | Yetkili, kendi konumu merkez olacak şekilde tür (Tahliye / Artçı), yarıçap ve mesaj seçiyor. Uygulaması açık olan ve yarıçap içindeki afetzedeye yerel bildirim gidiyor. Uygulaması kapalı cihazlara bildirim Firebase Console'dan `all_users` topic'ine gönderiliyor; Spark planda sunucudan push gönderilemiyor. |

## 4. İş Kuralları

| # | Şartname | Durum | Ne yapıldı |
|---|---|---|---|
| 1 | Öncelik skoru (triage) | ✅ | Öncelik `PriorityPolicy`'de hesaplanıyor: enkaz ve tıbbi müdahale Kritik (1); barınma, ısınma ve bebek maması Acil (2); su ve diğer Normal (3). Liste önce önceliğe, sonra zamana göre sıralanıyor. |
| 2 | 50 m mükerrer çağrı filtresi | ✅ | Arama geohash'le 9 hücrede yapılıyor, ardından gerçek mesafeyle ≤ 50 m süzülüyor. Eşleşen çağrı mevcut olaya bağlanıyor ve çağrı sayısı artıyor. İşlem Transaction içinde. |
| 3 | Stok düşüşü Transaction ile | ✅ | Demoda 50 koli su çıkışı stoğu kritik seviyeye indiriyor ve uyarı çıkıyor. |
| 4 | Çevrimdışı dayanıklılık | ✅ | Çağrı Hive kuyruğuna yazılıyor ve "Gönderilmeyi Bekliyor" görünüyor. İnternet gelince otomatik gönderiliyor. Çağrı ID'si istemcide `uuid` ile üretildiği için çift kayıt olmuyor. Bağlantı, Wi-Fi durumuna değil sunucu onayına göre anlaşılıyor. |
| 5 | Gizlilik kalkanı | ✅ | Ad, telefon, adres ve tıbbi bilgi yalnızca `private/contact` alt belgelerinde. Bunları sahibi ve onaylı yetkili okuyabiliyor; Security Rules ile korunuyor ve testleri var. |

## 5. Teknolojiler

| Şartname | Durum | Seçim / not |
|---|---|---|
| Flutter + Dart null safety | ✅ | |
| Clean Architecture | ✅ | `core` + feature bazlı klasörler (`data`, `domain`, `presentation`), 14 feature. |
| Firebase Auth | 🔄 | E-posta ve şifre. Rol, custom claim yerine `users/{uid}.role` alanında tutuluyor, çünkü custom claim yazmak sunucu gerektiriyor. Google Sign-In opsiyoneldi, eklenmedi. |
| Cloud Firestore | ✅ | Stream, alt koleksiyon, composite index, Transaction ve batch kullanıldı. Kurallar canlıda, test modu kapalı. |
| Firebase Storage + ImagePicker | ❌ | Tasarımda fotoğraf yok. Profilde fotoğraf yerine ad baş harfli avatar kullanıldı. |
| FCM + `flutter_local_notifications` | ✅ | `all_users` topic'i ve "Kritik uyarılar" kanalı; uygulama açıkken yerel bildirim. |
| Crashlytics + Analytics | 🔄 | Crashlytics bağlı, Flutter ve platform hatalarını kaydediyor. Analytics paketi kurulu ama özel event yazılmadı. |
| State management | ✅ | Provider + `ChangeNotifier` / `ValueNotifier`. |
| GoRouter | ✅ | Her rol için ayrı `StatefulShellRoute` (kalıcı alt menü) ve rol bazlı yönlendirme. Deep link kullanılmadı. |
| Yerel depolama | ✅ | Çevrimdışı kuyruk Hive'da. Onboarding durumu, dil ve son konum etiketi SharedPreferences'ta. |
| Material 3, açık / koyu tema | ✅ | Renkler tasarımdan alındı; uygulama sistem temasını izliyor. Onboarding'de CustomPainter grafikleri var, Hero animasyonu yok. |
| Form ve validasyon | ✅ | `Form` + `GlobalKey<FormState>`, Regex, `+90 5XX XXX XX XX` telefon maskesi, şifre kuralı ve güç göstergesi. |
| Kalite | ✅ | `flutter analyze` temiz, 160 Flutter testi ve 38 Firestore kural testi geçiyor, ekranlarda taşma yok. |
| Git-Flow | ✅ | `main`, `development` ve `feat/` / `fix/<isim>-…` branch'leri; birleştirmeler PR ile yapıldı. |
| Harita (şartnamede yok) | ✅ | `flutter_map` + OpenStreetMap; API anahtarı gerektirmiyor. |
| Dil (şartnamede yok) | ✅ | Türkçe ve İngilizce. Varsayılan Türkçe; Profil'den İngilizce seçilebiliyor. |

## 6. Mağaza, Yasal ve Teslim

- ✅ **Yasal metinler:** Gizlilik Politikası, KVKK Aydınlatma Metni, Kullanım Koşulları ve Hesap Silme sayfası Firebase Hosting'de, Türkçe ve İngilizce yayında.
- ✅ **Hesabı Sil:** Mağaza zorunluluğu. Şifre yeniden soruluyor, ardından kişisel veriler ve Auth hesabı siliyor.
- ✅ **Demo:** 2 fiziksel Android (afetzede1, afetzede2; Fake GPS ile Antakya) ve projeksiyonda emülatör (yetkili). Ekip, depo ve toplanma alanları debug derlemedeki "Demo Verisini Sıfırla" ile yükleniyor.
- ❌ **Mağazaya yükleme:** Hedef yalnızca "yüklenmeye hazır" MVP'ydi. İmzalı release AAB ve `store/` klasörü (açıklamalar, ekran görüntüleri, Veri Güvenliği formu) tamamlanmadı.
- ❌ **Görev matrisi:** Şartnamedeki katman bazlı (UI, API, DTO…) dağılım uygulanmadı. Bunun yerine `GOREV_DAGILIMI.md`'deki 6 aşamalı, feature bazlı dağılım kullanıldı; her aşamayı G1 inceledi.
