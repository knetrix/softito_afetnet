# AfetNet — Canlı Kriz Yönetimi ve Acil Yardım Ağı

> **Ekip:** SoftITO 4. Dönem Mobil — 2. Grup (6 kişi): Hasibe Esra Ergün, Meryem Duymuş, Furkan Çalışkan, Somaya Arab, Tuba Aydın, Mustafa Ersoy
> **Platform:** Flutter, **Android** (geliştirme, test ve demo Android emülatörü/cihazında; iOS'ta yalnızca ücretsiz yapılandırmalar, bkz. 7) · **Mimari:** Clean Architecture + Firebase (ücretsiz Spark plan)
> **Teslim & Demo Day:** 13 Kasım 2026 Cuma
> **Hedef:** Google Play'e *yüklenmeye hazır* MVP. Uygulama mağazaya yüklenmez.

**Tek kaynak kuralı:** Ekranlar yalnızca `design/` klasöründeki tasarımlardan oluşur. Veritabanında yalnızca `database/` klasöründeki mimari (koleksiyonlar ve `help_requests` alan tablosu) kullanılır. Bu belge ikisinin dışına çıkmaz; tasarımdaki bir butonun gerektirdiği küçük işlemler yeni ekran değil, ilgili ekranın üzerinde açılan **bottom sheet / diyalog** olarak yapılır (bkz. 3.2).

---

## 1. Proje Özeti

Deprem, sel ve yangın gibi kriz anlarında afetzedeleri arama-kurtarma ekipleri ve saha koordinatörleriyle gerçek zamanlı buluşturan bir uygulama. Afetzede tek dokunuşla panik sinyali ve yardım çağrısı gönderir. Yetkili, çağrıları canlı akışta önceliğe göre görür, ekip yönlendirir ve sahra deposu stoğunu yönetir.

- Dağınık yardım çağrılarını **tek, önceliklendirilmiş ve mükerrersiz** bir akışta toplamak.
- Ekip ve depo durumunu **canlı** göstererek doğru kaynağı doğru noktaya yönlendirmek.
- İnternet yokken de afetzedenin sesini duyurmak: çevrimdışı düdük, SMS köprüsü, çevrimdışı çağrı kuyruğu.

> [!IMPORTANT]
> **Resmi kurum değildir.** AfetNet bağımsız bir öğrenci projesidir. Uygulamada, örnek verilerde ve mağaza sayfasında AFAD, AKUT, Kızılay gibi kurum adları ve logoları kullanılmaz (mağazalar kurum taklidini reddeder). "Resmi kurum uygulaması değildir — hayati tehlikede 112'yi arayın" uyarısı Onboarding'de ve Giriş ekranında görünür.

---

## 2. Roller

İki rol vardır. Giriş ve Kayıt ekranlarındaki "Giriş Türü / Hesap Türü" menüsü bu iki rolü gösterir.

| `users.role` | Arayüzde | Ne yapar |
|---|---|---|
| `citizen` | Sivil Kullanıcı (Afetzede) | Panik sinyali, yardım çağrısı, toplanma alanları, düdük, profil |
| `official` | Saha Koordinatörü (Yetkili) | Canlı akış, ekip yönlendirme, görev durumu, lojistik, tahliye anonsu |

- **Yetkili hesap onayı:** Kayıtta "Saha Koordinatörü" seçilebilir, ancak hesap `isVerified: false` olarak açılır ve hiçbir yetkili verisini göremez. Yönetici Firebase Console'dan `isVerified: true`, `unitName`, `region` ve `teamId` alanlarını yazar. Onaysız yetkili giriş yapınca oturum kapatılır ve "Hesabınız yönetici onayı bekliyor" mesajı gösterilir.
- **Rol kontrolü:** Girişte seçilen tür ile `users.role` uyuşmazsa oturum kapatılır. Yetkiyi her zaman veritabanındaki rol belirler.
- **Kapsam dışı:** Ekip sohbetindeki ek yetkilerin (onaylı gönüllü, koordinatör) ekran tasarımı yoktur, bu yüzden MVP'de yer almazlar. `volunteers` ve `shifts` koleksiyonları ileride bu ekranlar için ayrılmıştır.

---

## 3. Ekranlar

### 3.1. Ekran Listesi (12 ekran)

| # | Ekran | Tasarım dosyası (`design/`) | İçerik |
|---|---|---|---|
| O1 | Splash | `2026-11-11 at 09.45.39` | Logo animasyonu, "AfetNet — Canlı Kriz Yönetimi Ağı", yükleniyor göstergesi. Firebase başlatma, oturum ve rol kontrolü. |
| O2 | Onboarding (ilk kurulum) | `09.45.51`, `09.46.08` | 2 sayfa: "Tek Dokunuşla Güvendesiniz" (Sivil Kullanıcı) ve "Krizi Canlı Yönetin" (Saha Yönetimi). Atla / İleri / Başla. 1. sayfanın altında resmi değildir + 112 uyarısı. |
| O3 | Giriş | `09.32.09` | Giriş Türü, e-posta, şifre (göster/gizle), Şifremi Unuttum, Üye Olun. Altta resmi değildir + 112 bağlantısı. |
| O4 | Kayıt | `09.32.23` | Hesap Türü, Ad Soyad, E-posta, Telefon, Şifre + güç göstergesi, Şifre Tekrar, Kritik Afet Uyarı Bildirimleri onayı, KVKK + Gizlilik onayı (metinler web sayfası olarak açılır). |
| A1 | Ana Sayfa | `2026-11-09 at 19.20.02` | Üstte ad + konum (il, ilçe). PANİĞİM / TEHLİKEDEYİM butonu (2 sn basılı tutma). Aktif çağrı kartı: durum, çağrı türü, yönlendirilen ekip, sorumlu, Çağrıyı İptal Et. Yardım Çağrısı Ekle butonu. |
| A2 | Toplanma | `19.43.29` | Harita: konumum, toplanma alanı / sahra hastanesi / çadır alanı pinleri ve mesafe etiketleri. Seçili nokta kartı (mesafe, doluluk %, hizmetler), alt panel (açıklama). Konuma git, yakınlaştır/uzaklaştır. |
| A3 | Düdük | `19.49.53`, `19.50.06` | Bekleme (turuncu, "DÜDÜK") ve çalıyor (kırmızı, "ÇALIYOR") durumları; dokunarak başlat/durdur. İnternetsiz çalışır. |
| A4 | Profil (Afetzede) | `19.52.36` | Ad, rol + konum rozeti. Tıbbi & Sağlık Kimliği (kan grubu, ilaçlar, kronik hastalık/alerji), yaş, kilo, 1. derece acil durum yakını (arama butonu), kayıtlı ikamet adresi. Çıkış Yap. |
| Y1 | Canlı Akış | `20.27.33` | Üstte harita (öncelik renkli olay pinleri + mor panik sinyali pinleri). Filtre chip'leri (Tümü / Kritik / Acil / Normal / Medikal …). Olay kartları: ad, kişi sayısı, mesafe, adres tarifi, açıklama, süre, öncelik rozeti. Butonlar: Detay, Ekip Yönlendir. Tahliye Anonsu butonu. |
| Y2 | Ekipler | `20.27.45` | Özet (tim ve personel sayısı), tür filtreleri, mini harita. Ekip kartı: ad, lider, mesafe, konum, mevcut görev, durum (Görevde / Boşta), Görev Ata / Görev Güncelle. Tahliye Anonsu butonu. |
| Y3 | Lojistik | `20.27.59` | Depo kartı, kritik stok uyarı kartı, envanter filtreleri (Tümü / Kritik / Orta / Yeterli), stok kartları (miktar, birim, stok düzeyi çubuğu ve %, etiket). |
| Y4 | Profil (Yetkili) | `20.28.08` | Ad, "Saha Koordinatörü" rozeti, birim adı, sorumlu bölge, bağlı ekip. Sistemden Çıkış Yap. |

- **Afetzede alt menüsü:** Ana Sayfa / Toplanma / Düdük / Profil
- **Yetkili alt menüsü:** Canlı Akış / Ekipler / Lojistik / Profil

### 3.2. Ekran Üstü Etkileşimler (bottom sheet / diyalog)

Bunlar ayrı ekran değildir. Ortak `AppBottomSheet` ve `AppDialog` bileşenleriyle, tasarımın renk ve stilinde yapılır.

| Ekran | Tetikleyen | Açılan |
|---|---|---|
| A1 | Yardım Çağrısı Ekle | Çağrı formu: ihtiyaç türü chip'leri, kişi sayısı, adres tarifi, açıklama, Gönder |
| A1 | Çağrıyı İptal Et | Onay diyaloğu |
| A1 | Panik gönderildi, internet yok | "SMS ile ailene haber ver" diyaloğu → SMS uygulaması hazır metinle açılır |
| A4 | Kart üzerindeki düzenle simgesi | Tıbbi bilgi (KVKK açık rıza onayıyla), fiziksel bilgiler, acil durum yakını, adres düzenleme |
| A4, Y4 | Çıkış Yap / Hesabı Sil | Onay diyaloğu |
| Y1 | Detay | Çağrı sahibinin telefonu (arama butonu) ve tıbbi özeti, bağlı çağrı sayısı, görev durumu, Olayı Kapat |
| Y1 | Ekip Yönlendir | Boştaki ekipler listesi (mesafeye göre) → seçilen ekibe görev |
| Y1 | Mor panik pini | Konum, zaman, Ulaşıldı |
| Y1, Y2 | Tahliye Anonsu | Tür (Acil Tahliye / Artçı Sarsıntı), yarıçap, mesaj, Gönder (merkez = yetkilinin konumu) |
| Y2 | Görev Ata | Açık olaylar listesi (önceliğe göre) → seçilen olaya görev |
| Y2 | Görev Güncelle | Sonraki durum butonu (Yola Çıktı → Olay Yerinde → Kurtarıldı) |
| Y3 | Stok kartına dokunma | Giriş / Çıkış miktarı + Kaydet |

### 3.3. Tasarım Düzeltmeleri (kodlarken uygulanır)

| # | Ekran | Tasarımda | Uygulamada |
|---|---|---|---|
| T1 | O2, O3, Y1, Y2, Y4, A2 | AFAD, AKUT, UMKE, Kızılay, "afetnet.gov.tr", "AFAD & AKUT Entegrasyonu ONLINE" | Kurum adları kaldırılır. Örnek veriler: "Arama Kurtarma Tim 4", "Sağlık Ekibi 1", "Aşevi Ekibi". O2'deki kart "Otomatik Önceliklendirme" olur. |
| T2 | O2, Y1, Y2, Y4 | LoRa, Mesh, Telsiz, "Düğüm Atlamalı", AES-256, frekans, pil yüzdesi satırı | Kaldırılır. "Detay & Telsiz" → "Detay", Y2'deki "Telsiz #" butonu çıkar, Y4'teki "Telsiz & Mesh Ağı" bölümü çıkar, O2'deki "Telsiz & Tim Takibi" → "Ekip Takibi". |
| T3 | O3 | "E-posta veya Kimlik No" | Yalnızca e-posta. |
| T4 | O4 | Telefon ve KVKK onayı yok | Telefon (`+90 5XX XXX XX XX` maskesi) ve KVKK + Gizlilik onay kutusu eklenir. |
| T5 | O3, O4 | "SIGN IN" / "SIGN UP" | "Giriş Yap" / "Kayıt Ol" (İngilizce dilde "Sign In" / "Sign Up"). |
| T6 | O2 | Sayfa göstergesi tutarsız (2 ve 3 nokta) | 2 sayfa, 2 nokta. |
| T7 | Y3 | 6 stok etiketi, "Acil İkmal İste", depo kapasite % | 3 hesaplanan etiket (Kritik / Orta / Yeterli, bkz. Kural 3). Diğerleri kaldırılır. |
| T8 | A1 | GÜVENDEYİM durumu yok | Sinyal açıkken buton "GÜVENDEYİM — Sinyali kapat" görünümüne geçer. |
| T9 | Y1 | "Rota Çiz", "Müdahale Et", "Koli Rezerve Et", "Gönüllü Çağrısı Aç", "Sektör B-2" | Kartta yalnızca **Detay** ve **Ekip Yönlendir** kalır. Sektör yerine adres tarifi gösterilir. |
| T10 | Y1 (eski sürüm) | Alt menü SOS / MESH / MAP / CONFIG | Canlı Akış / Ekipler / Lojistik / Profil. |
| T11 | Y4 | Kurum Sicil No, Aktif Mesai Saati, Vardiya | Kaldırılır; birim, sorumlu bölge ve ekip gösterilir. |
| T12 | A4, Y4 | Gerçek kişi fotoğrafı | Ad baş harfli avatar (fotoğraf yükleme yok). |
| T13 | A4, Y4 | Hesabı Sil ve gizlilik bağlantısı yok | Çıkış Yap'ın altına küçük "Gizlilik Politikası" ve "Hesabı Sil" bağlantıları (mağaza zorunluluğu). |
| T15 | O2, O3 | Resmi olmama uyarısı yok | O2 1. sayfanın altına ve O3'ün altına (eski "AFAD & AKUT uyumlu" satırı yerine) "Resmi kurum uygulaması değildir · Acil durumda 112" metni; 112'ye dokununca arama açılır. |
| T14 | Tümü | Yalnızca koyu tema | Açık tema aynı renk token'larından türetilir; uygulama sistem temasını izler. |

### 3.4. Tasarım Sistemi

Değerler ekran görüntülerinden **yaklaşık** okunmuştur.

| Token | Değer | Kullanım |
|---|---|---|
| `background` | `#0D0F12` | Sayfa arka planı |
| `surface` / `surfaceHigh` | `#16191E` / `#1E2228` | Kartlar, alt menü, giriş alanları |
| `primary` | `#00E1FF` | Ana butonlar, seçili sekme |
| `danger` | `#FF2D55` | Panik, kritik öncelik, düdük çalıyor |
| `whistle` | `#FF7A00` | Düdük bekleme |
| `warning` | `#FFB020` | Acil öncelik, orta stok |
| `success` | `#1FE07A` | Normal öncelik, yeterli stok, boşta ekip |
| `textPrimary` / `textSecondary` | `#EDEFF2` / `#9AA3AD` | Metin |

- **Yazı tipleri:** Space Grotesk (başlık), Inter (gövde), JetBrains Mono (etiket). `assets/fonts/` altına gömülür (internetsiz çalışır).
- **Tema:** Material 3; renkler `ColorScheme` içine açıkça verilir, durum renkleri `ThemeExtension<AppStatusColors>` ile. Koyu ve açık tema; `ThemeMode.system`.
- **Dil:** Türkçe + İngilizce (ARB). Uygulama **cihaz dilini** izler; Türkçe dışındaki dillerde İngilizce açılır. Ekranlarda sabit metin yazılmaz.

---

## 4. İş Kuralları

1. **Öncelik (triage):** Öncelik ihtiyaç türünden yalnızca `PriorityPolicy` içinde hesaplanır.

   | `HelpType` | Arayüz (TR / EN) | `priority` | Rozet |
   |---|---|---|---|
   | `debris`, `medical` | Enkaz Altında / Trapped, Tıbbi Müdahale / Medical | 1 | 🔴 Kritik |
   | `shelter`, `heating`, `babyFood` | Barınma / Shelter, Isınma / Heating, Bebek Maması / Baby Food | 2 | 🟠 Acil |
   | `water`, `other` | Su / Water, Diğer / Other | 3 | 🟢 Normal |

   Canlı Akış sıralaması: `orderBy('priority').orderBy('createdAt')`. Filtre chip'leri (öncelik, tür) yüklenen liste üzerinde istemcide uygulanır; ek index gerekmez.

2. **Mükerrer çağrı birleştirme (50 m):** Aynı noktadan gelen çağrılar tek bir `incidents` belgesinde birleşir.
   - Çağrıda `location` (geopoint) ve `geohash` ayrı alanlardır. `geohash` 8 hanedir: `GeoFirePoint(location).geohash.substring(0, 8)`.
   - Arama: yeni noktanın 7 haneli hücresi + `neighborGeohashesOf` ile 8 komşusu = 9 hücre. Her hücre için açık olaylarda `geohash` önek (prefix) sorgusu yapılır, sonuçlar `Geolocator.distanceBetween(...) <= 50` ile süzülür. (7 haneli hücre ~153 m olduğu için 9 hücre 50 m'yi her yönde kapsar; 8 haneli hücre ~38×19 m olduğundan arama için yetersizdir.)
   - Eşleşen açık olay varsa çağrı ona bağlanır: `requestCount` +1, `priority` iki önceliğin en yükseği. Yoksa yeni olay açılır. Olay belgesinin okunup güncellenmesi Transaction içinde yapılır.

3. **Stok:** Giriş/çıkış tek bir Transaction'dır. Kalem okunur; çıkışta `quantity < miktar` ise reddedilir (eksi stok yok). Başarılıysa `quantity` güncellenir ve `movements` kaydı yazılır.

   | Koşul | Etiket |
   |---|---|
   | `quantity <= criticalLevel` | 🔴 Kritik |
   | `quantity < targetLevel × 0.5` | 🟠 Orta |
   | diğer | 🟢 Yeterli |

   Stok düzeyi % = `quantity / targetLevel` (en fazla %100). Kritik kalemler Lojistik'in üstündeki uyarı kartında görünür ve yetkiliye yerel bildirim düşer.

4. **Çevrimdışı çağrı:** Çağrı ID'si istemcide `uuid` olarak üretilir, kuyruk tekrar denense de çift kayıt olmaz. Transaction çevrimdışı çalışmadığı için 10 sn içinde tamamlanmazsa çağrı **Hive** kuyruğuna yazılır (`createdOffline: true`) ve kartta "Gönderilmeyi Bekliyor" yazar. İnternet gelince kuyruk otomatik işlenir; uygulama kapatılıp açılsa da kuyruk korunur.

5. **Gizli bilgi:** Ad, telefon, adres ve tıbbi bilgi yalnızca `private/contact` alt belgelerindedir; bunları yalnızca sahibi ve doğrulanmış yetkili okur. Canlı Akış kartı yalnızca adı gösterir (olayın `primaryRequestId` çağrısının `private/contact` belgesinden). Telefon `help_requests/{id}/private/contact`'tan, tıbbi özet `users/{createdBy}/private/contact`'tan yalnızca Detay sheet'inde okunur. Tıbbi bilgi KVKK'da özel nitelikli veridir: Profil'de ilk kez kaydedilirken ayrı açık rıza alınır.

6. **Görev durumu:** `assignments` belgesi `assigned → enRoute → onSite → resolved` (Atandı → Yola Çıktı → Olay Yerinde → Kurtarıldı) akışını izler; **geri adım yoktur**.
   - Her geçiş aynı batch'te: `assignments.status`, `incidents.status`, bağlı açık `help_requests.status` ve ekibin `status` / `currentTask` alanları güncellenir.
   - Bir olayda aynı anda tek aktif görev bulunur. `resolved` ile olay kapanır (`isOpen: false`) ve ekip `available` olur.
   - Afetzedenin aktif çağrı kartı kendi `help_requests` belgesinden canlı beslenir; ekip adı ve lider `teams/{assignedTeamId}`'den okunur.

7. **İptal ve kapatma:** Afetzede çağrısını `resolved` olmadan önce iptal edebilir (`status: cancelled`); yetkili bu çağrıya bir daha dokunmaz. Görev atanmamış bir olayı yetkili Detay'dan **Olayı Kapat** ile doğrudan `resolved` yapabilir.

8. **Panik sinyali:** TEHLİKEDEYİM (2 sn basılı tutma) `safety_signals/{uid}` belgesine durum, konum ve zamanı yazar; yetkili haritasında mor pin belirir ve yetkiliye bildirim düşer. GÜVENDEYİM sinyali kapatır. Yetkili "Ulaşıldı" işaretleyebilir; yeni panik önceki "Ulaşıldı" kaydını (`handledBy`, `handledAt`) siler, bu yüzden `handledBy` doluysa son sinyale ulaşılmıştır.
   - **Bağlantı tespiti:** Yazılan belgenin snapshot'ında `hasPendingWrites` 10 sn içinde `false` olmazsa uygulama çevrimdışı kabul edilir. Sinyal Firestore'un kuyruğunda bekler, internet gelince gider. Ekranda "Merkeze iletildi" yalnızca sunucu onayıyla yazar.
   - İnternet yoksa SMS uygulaması acil durum yakını ve konum linkiyle (`sms:`) hazır açılır, kullanıcı Gönder'e basar. SMS otomatik gönderilmez (`SEND_SMS` izni Play politikasınca yalnızca varsayılan SMS uygulamalarına verilir).

9. **Konum etiketi:** Ana Sayfa ve Profil'deki "Antakya Merkez, Hatay" metni `geocoding` paketiyle (cihazın yerel servisi, ücretsiz) bulunur. İnternet yoksa son bilinen etiket gösterilir.

10. **Tahliye anonsu:** Yetkili anonsu `broadcasts` koleksiyonuna yazar. Uygulaması açık olan afetzedeler, konumları yarıçap içindeyse yerel bildirim alır. Uygulaması kapalı cihazlara ulaşmak için Console → Messaging'den `all_users` topic'ine duyuru gönderilir (Spark planda otomatik push yoktur).

---

## 5. Veritabanı (Cloud Firestore)

Mimari `database/` klasöründeki taslaktır; koleksiyon ve alan adları aynen kullanılır. Bu belge yalnızca taslakta alanları belirtilmemiş koleksiyonların alanlarını tanımlar.

### 5.1. Koleksiyonlar

```text
users/{uid}                     → AppUser          herkese açık profil (giriş yapmış kullanıcılar)
  └─ private/contact            → PrivateContact   GİZLİ: sahibi + doğrulanmış yetkili
volunteers/{uid}                → Volunteer        (MVP'de kullanılmaz — tasarımı yok)
shifts/{shiftId}                → VolunteerShift   (MVP'de kullanılmaz — tasarımı yok)
teams/{teamId}                  → Team             arama kurtarma ekibi
safety_signals/{signalId}       → SafetySignal     GÜVENDEYİM / TEHLİKEDEYİM (signalId = kullanıcının uid'si)
help_requests/{requestId}       → HelpRequest      yardım çağrısı
  └─ private/contact            → PrivateContact   GİZLİ
incidents/{incidentId}          → Incident         mükerrer çağrılar burada birleşir
assignments/{assignmentId}      → Assignment       ekip görev ataması
warehouses/{warehouseId}        → Warehouse        sahra deposu
  ├─ inventory/{itemId}         → InventoryItem    stok kalemi
  └─ movements/{movementId}     → StockMovement    stok giriş/çıkış kaydı
assembly_points/{pointId}       → AssemblyPoint    toplanma alanı / sahra hastanesi / barınma
missing_persons/{personId}      → MissingPerson    (MVP'de kullanılmaz — tasarımı yok)
broadcasts/{broadcastId}        → EvacuationBroadcast  tahliye / artçı uyarısı
```

Çevrimiçi veriler Firestore'da, çevrimdışı çağrı kuyruğu Hive'da tutulur. Veritabanı konumu `eur3` (sonradan değiştirilemez).

### 5.2. `help_requests/{requestId}` (ekip tablosu)

| Alan | Tip | Zorunlu | Not |
|---|---|---|---|
| `id` | doc id | evet | Belgenin içine yazılmaz; istemcide `uuid` |
| `createdBy` | string | evet | Çağrı sahibinin `uid`'si |
| `type` | string (`HelpType`) | evet | Kural 1 |
| `priority` | number (`RequestPriority`) | evet | 1 kritik, 2 acil, 3 normal |
| `status` | string (`CaseStatus`) | hayır | `pending` · `assigned` · `enRoute` · `onSite` · `resolved` · `cancelled` |
| `peopleCount` | number | hayır | |
| `addressText` | string | hayır | ≤ 300 karakter |
| `description` | string | hayır | ≤ 500 karakter |
| `location` | geopoint | evet | |
| `geohash` | string | evet | 8 hane (Kural 2) |
| `photoUrls` | array | hayır | MVP'de boş: tasarımda fotoğraf yok |
| `incidentId` | string | hayır | Bağlı olay |
| `assignedTeamId` | string | hayır | |
| `createdOffline` | boolean | hayır | Hive kuyruğundan geldiyse `true` |
| `createdAt` | timestamp | evet | |
| `updatedAt` | timestamp | hayır | |
| `resolvedAt` | timestamp | hayır | |

`help_requests/{id}/private/contact`: `fullName`, `phone` (çağrı anında kopyalanır).

### 5.3. Diğer Koleksiyonların Alanları

| Koleksiyon | Alanlar |
|---|---|
| `users/{uid}` | `fullName`, `role` (`citizen`/`official`), `isVerified`, `unitName`?, `region`?, `teamId`?, `notificationsOptIn`, `consents` {`privacyVersion`, `kvkkVersion`, `acceptedAt`}, `createdAt` |
| `users/{uid}/private/contact` | `email`, `phone`, `address` {`text`, `geopoint`, `floor`}?, `emergencyContact` {`name`, `relation`, `phone`}?, `medical` {`bloodType`, `medications`, `conditions`, `birthYear`, `weightKg`}?, `medicalConsentAt`? |
| `safety_signals/{uid}` | `state` (`danger`/`safe`), `location`, `geohash`, `updatedAt`, `handledBy`?, `handledAt`? |
| `incidents/{incidentId}` | `location`, `geohash`, `type`, `priority`, `requestCount`, `primaryRequestId`, `status` (`CaseStatus`, `cancelled` hariç), `isOpen`, `assignedTeamId`?, `createdAt`, `updatedAt`, `resolvedAt`? |
| `assignments/{assignmentId}` | `incidentId`, `teamId`, `status` (`assigned`/`enRoute`/`onSite`/`resolved`), `assignedBy`, `updatedBy`, `createdAt`, `updatedAt` |
| `teams/{teamId}` | `name`, `type` (`searchRescue`/`medical`/`fire`/`logistics`), `leaderName`, `memberCount`, `location`, `geohash`, `locationText`?, `status` (`available`/`onDuty`), `currentTask`?, `updatedAt` |
| `warehouses/{warehouseId}` | `name`, `location`, `locationText`? |
| `…/inventory/{itemId}` | `name`, `unit`, `category` (`water`/`food`/`shelter`/`medical`/`energy`/`other`), `quantity` (≥ 0), `targetLevel`, `criticalLevel`, `updatedAt` |
| `…/movements/{movementId}` | `itemId`, `type` (`in`/`out`), `quantity` (> 0), `teamId`?, `createdBy`, `createdAt` |
| `assembly_points/{pointId}` | `name`, `type` (`assembly`/`fieldHospital`/`shelter`), `description`?, `location`, `geohash`, `capacity`, `currentCount`, `services` (`water`/`health`/`food`/`tent`), `isOpen`, `updatedAt` |
| `broadcasts/{broadcastId}` | `type` (`evacuation`/`aftershock`), `title`, `body`, `center` (geopoint), `radiusMeters` (100–20000), `createdBy`, `createdAt` |

`?` = opsiyonel. Ekip, depo, stok kalemi ve toplanma noktası kayıtları tasarımda yönetim ekranı olmadığı için **seed verisi** ve Firebase Console üzerinden girilir.

### 5.4. Index'ler

| Koleksiyon | Alanlar | Kullanım |
|---|---|---|
| `incidents` | `isOpen ASC, priority ASC, createdAt ASC` | Canlı Akış |
| `help_requests` | `incidentId ASC, createdAt ASC` | Detay'da bağlı çağrılar |
| `safety_signals` | `state ASC, updatedAt DESC` | Panik pinleri |
| `assignments` | `teamId ASC, status ASC` | Ekibin aktif görevi |

Mükerrer arama (yalnızca `geohash` aralığı, `isOpen` istemcide süzülür) ve afetzedenin aktif çağrı kartı (yalnızca `createdBy` eşitliği, sıralama istemcide) bileşik index istemez; tek alan index'leri otomatiktir.

### 5.5. Security Rules

Tanımlar: **Sahibi** = belgenin sahibi · **Yetkili** = `role == 'official' && isVerified == true`.

| Koleksiyon | Okuma | Yazma |
|---|---|---|
| `users/{uid}` | Giriş yapmış herkes | Oluşturma: sahibi; `isVerified == false`, `teamId`/`unitName`/`region` yok. Güncelleme: sahibi, yalnızca `fullName`, `notificationsOptIn`. `role`, `isVerified`, `teamId`, `unitName`, `region` yalnızca Console'dan. Silme: sahibi |
| `users/{uid}/private/contact` | Sahibi; Yetkili | Sahibi |
| `safety_signals/{uid}` | Sahibi; Yetkili | Sahibi: tüm alanlar; `handledBy` ve `handledAt`'i yazamaz, yalnızca silebilir (yeni panik). Yetkili: yalnızca `handledBy == auth.uid`, `handledAt` |
| `help_requests/{id}` | Sahibi; Yetkili | Oluşturma: sahibi; `createdBy == auth.uid`, `status == 'pending'`, `priority` türle uyumlu. Güncelleme: sahibi yalnızca `status → cancelled`; Yetkili yalnızca `status` (ileri adım, `cancelled` hariç), `assignedTeamId`, `updatedAt`, `resolvedAt` |
| `help_requests/{id}/private/contact` | Sahibi; Yetkili | Sahibi (oluşturma ve silme) |
| `incidents/{id}` | Giriş yapmış herkes (kişisel veri yok) | Oluşturma: giriş yapmış herkes; `requestCount == 1`, `status == 'pending'`, `isOpen == true`. Güncelleme: afetzede yalnızca `requestCount` +1, `priority`, `updatedAt`; Yetkili `status`, `isOpen`, `assignedTeamId`, `updatedAt`, `resolvedAt` |
| `assignments`, `teams`, `warehouses/**` | Yetkili (`teams`: giriş yapmış herkes — afetzede ekip adını görür) | Yetkili; `inventory.quantity >= 0`; görev durumu yalnızca ileri adım |
| `assembly_points` | Giriş yapmış herkes | Yetkili (yalnızca seed kullanır; uygulamada düzenleme ekranı yok) |
| `broadcasts` | Giriş yapmış herkes | Yetkili; `createdBy == auth.uid`, `radiusMeters` 100–20000 |
| `volunteers`, `shifts`, `missing_persons` | Kapalı (MVP'de kullanılmaz) | Kapalı |

**Kural testleri** (Firebase Emulator, `@firebase/rules-unit-testing`): afetzede başkasının çağrısını, sinyalini veya `private/contact` belgesini okuyamaz; afetzede `role` / `isVerified` değiştiremez; onaysız yetkili yetkili verisini okuyamaz; afetzede `priority`'yi yanlış yazamaz ve olay durumunu değiştiremez; görev durumu geri alınamaz; eksi stok yazılamaz.

**Kabul edilen sınır:** Sunucu kodu olmadığı için (Spark plan) birleştirme ve öncelik istemcide hesaplanır. Kurallar değerlerin biçimini doğrular ama çağrının gerçekten 50 m içindeki olaya bağlandığını doğrulayamaz.

---

## 6. Teknoloji

| Alan | Seçim |
|---|---|
| Dil & framework | Flutter (güncel kararlı), Dart null safety |
| Mimari | Clean Architecture (`core`, `data`, `domain`, `presentation`), feature-first |
| Kimlik | Firebase Auth (e-posta/şifre); rol `users/{uid}.role` |
| Veri | Cloud Firestore: stream, alt koleksiyon, composite sorgu, Transaction, batch |
| Bildirim | FCM (`all_users` topic) + `flutter_local_notifications` (uygulama açıkken) |
| Hata & analitik | Firebase Crashlytics + Analytics |
| State | Provider + `ChangeNotifier` / `ValueNotifier` |
| Navigasyon | GoRouter: rol başına `StatefulShellRoute` (alt menü) + rol bazlı yönlendirme |
| Yerel depolama | Hive (çevrimdışı çağrı kuyruğu) + SharedPreferences (`onboardingDone`) |
| Harita | `flutter_map` + OpenStreetMap (API anahtarı gerekmez) |
| Dil | `flutter_localizations` + `intl`: `app_tr.arb` + `app_en.arb` |
| Kalite | `flutter analyze` temiz, `RenderFlex overflow` yok, `await` sonrası `mounted` kontrolü, iş kuralları için unit test |

### 6.1. Klasör Yapısı

```text
lib/
  main.dart · app.dart
  core/
    config/       # app_config.dart (tile URL, yasal metin URL'leri)
    constants/    # enum'lar
    theme/        # renk token'ları, AppStatusColors, koyu/açık tema
    router/       # GoRouter, alt menüler, rol yönlendirmesi
    services/     # location, connectivity, notification, offline_queue
    utils/        # validators, priority_policy
    widgets/      # AppButton, StateView, GlowCircleButton, StatusBadge, AppBottomSheet, AppDialog
  l10n/           # app_tr.arb, app_en.arb
  features/<feature>/{data,domain,presentation}
assets/  fonts/  sounds/
hosting/legal/    # Gizlilik, KVKK, Kullanım Koşulları, hesap silme (Firebase Hosting)
firestore.rules · firestore.indexes.json
```

**Feature'lar:** `splash`, `onboarding`, `auth`, `profile`, `safety_signal`, `home`, `help_request`, `assembly_points`, `whistle`, `live_feed`, `teams`, `logistics`, `broadcast`, `demo_seed` (yalnızca debug)

### 6.2. Paketler

| Amaç | Paket |
|---|---|
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`, `firebase_crashlytics`, `firebase_analytics` |
| State & navigasyon | `provider`, `go_router` |
| Yerel depolama | `hive_ce`, `hive_ce_flutter`, `shared_preferences` |
| Konum & harita | `geolocator`, `geocoding`, `flutter_map`, `latlong2`, `geoflutterfire_plus` (yalnızca geohash ve komşu hücre hesabı) |
| Bildirim | `flutter_local_notifications` |
| Acil durum | `connectivity_plus`, `audioplayers` (düdük; iOS'ta `playback`, sessiz modda da çalar), `url_launcher` (`tel:`, `sms:`, harita) |
| Form & dil | `mask_text_input_formatter`, `flutter_localizations`, `intl` |
| Mağaza | `flutter_launcher_icons`, `flutter_native_splash` |
| Yardımcı | `uuid`, `permission_handler` |

---

## 7. Hesap, Yasal ve Mağaza

- **Kayıt:** Şifre en az 8 karakter, 1 büyük harf, 1 rakam. KVKK + Gizlilik onayı zorunludur. Kayıt tek batch'te `users/{uid}` ve `users/{uid}/private/contact` belgelerini oluşturur.
- **Giriş:** Şifremi Unuttum = `sendPasswordResetEmail`.
- **Hesabı Sil** (mağaza zorunluluğu), Profil'den. Onay → yeniden şifre sorulur → sırayla silinir:
  1. Kullanıcının çağrılarındaki `private/contact` belgeleri,
  2. `safety_signals/{uid}`,
  3. `users/{uid}/private/contact` ve `users/{uid}`,
  4. Firebase Auth hesabı.

  Çağrı belgeleri (tür, konum, durum) operasyonel kayıt olarak kalır; kişisel bilgi taşımazlar.
- **Yasal metinler:** Gizlilik Politikası, KVKK Aydınlatma Metni, Kullanım Koşulları ve hesap silme talep sayfası, TR + EN olarak **Firebase Hosting**'de yayınlanır. Kayıt ekranındaki onay kutusundan ve Profil'deki bağlantıdan açılır. Metinler konum, telefon, acil durum yakını ve **tıbbi bilgi (açık rıza)** işlenmesini; verileri yalnızca doğrulanmış yetkililerin gördüğünü ve silme yolunu belirtir.
- **Kurulum:**
  - Kimlik: `name: afetnet`, Android `applicationId` ve iOS Bundle ID `com.softito.afetnet`; `flutterfire configure`'dan önce yapılır.
  - İzinler: `ACCESS_FINE_LOCATION` (+ `ACCESS_COARSE_LOCATION`), `POST_NOTIFICATIONS`, `INTERNET`. Arka plan konumu istenmez. Android `targetSdk` 36. `<queries>`'te `sms` ve `tel` şemaları; FCM için varsayılan bildirim kanalı (`default_notification_channel_id`, "Kritik uyarılar").
  - **iOS:** Test ve demo Android'de yapılır. iOS'ta yalnızca ücretsiz yapılandırmalar yapılır: konum izin metni (`NSLocationWhenInUseUsageDescription`, TR + EN) ve düdük için `playback` ses oturumu. Ücretli Apple Developer hesabı gerektiren APNs/push ve `AppDelegate` push kurulumu yapılmaz. `ios/` derlemesi bozulmamalı.
  - OpenStreetMap: `userAgentPackageName: 'com.softito.afetnet'` ve haritada "© OpenStreetMap contributors" atfı.
  - Gizli tutulacaklar: `*.jks` ve `key.properties` repoya eklenmez.
- **Mağaza hazırlığı (Google Play):** Release derlemesinde seed kodu ve test hesabı bulunmaz. `flutter build appbundle --release` başarılı olmalı. `store/` klasöründe TR + EN açıklama ("resmi değildir" ifadesiyle), iki rolden ekran görüntüleri, ikonlar ve Play Veri Güvenliği formu taslağı (ad, e-posta, telefon, konum, sağlık bilgisi, çökme logları).

---

## 8. Demo Day

**Demo hesapları** (yalnızca geliştirme projesi). Hesaplar uygulamadan kayıt olarak bir kez açılır; yetkilinin onayı ve `teamId`'si Console'dan yazılır, afetzede 1'in tıbbi bilgisi Profil'den doldurulur. Seed yalnızca ekip, depo, stok ve toplanma noktası verisini yükler:

| Hesap | Rol | Cihaz |
|---|---|---|
| `afetzede1@afetnet.demo` | citizen (tıbbi bilgisi dolu) | Fiziksel Android (düdük, GPS) |
| `afetzede2@afetnet.demo` | citizen | Fiziksel Android, afetzede 1'in 50 m yakınında |
| `yetkili@afetnet.demo` | official (onaylı), `teamId: team_04` | Projeksiyondaki emülatör |

**Hazırlık:** "Demo Verisini Sıfırla" (yalnızca debug derlemede, yetkili profilinde) çalıştırılır. Telefon hotspot'u kullanılır, yedek ekran kaydı hazır tutulur. Tüm cihazlar Antakya'ya sabitlenir (ekip, depo ve toplanma noktaları orada; adım 3 ve 7 aynı bölgeyi ister):
- **Emülatör (yetkili):** `adb emu geo fix 36.1620 36.2030` (boylam, enlem), sonra uygulamayı yeniden açın.
- **Telefonlar:** Play Store'dan "Fake GPS Location" (Lexa) kurulur; Geliştirici seçenekleri → Sahte konum uygulamasını seç → Fake GPS; Ayarlar → Konum → Google Konum Doğruluğu, Wi-Fi ve Bluetooth taraması kapatılır. Afetzede 1: `36.2025, 36.1610`, afetzede 2: `36.2027, 36.1611` (~25 m). Ana Sayfa'da "Antakya, Hatay" görünmelidir. Demodan sonra Fake GPS durdurulur ve ayarlar geri açılır.

**Akış:**
1. Afetzede 1 PANİĞİM'e 2 sn basar → yetkilinin Canlı Akış haritasında mor pin ve bildirim belirir.
2. Afetzede 1 "Enkaz Altında" çağrısı açar → kırmızı kart listenin en üstünde belirir.
3. Afetzede 2, 50 m içinden "Tıbbi Müdahale" çağrısı açar → yeni kart oluşmaz, olayın çağrı sayısı 2 olur.
4. Yetkili **Detay**'da telefonu ve tıbbi özeti gösterir, **Ekip Yönlendir** ile Tim 4'ü atar → afetzedenin kartı "Ekip Yönlendirildi — Arama Kurtarma Tim 4" olur.
5. Ekipler'de **Görev Güncelle**: Yola Çıktı → Olay Yerinde → Kurtarıldı → afetzedenin kartı her adımda canlı güncellenir.
6. Lojistik'te 50 koli su çıkışı yapılır → stok düşer, kritik uyarı ve bildirim çıkar.
7. Tahliye Anonsu gönderilir → afetzede cihazında bildirim. Afetzede uygulaması kapatılır, Console'dan `all_users` duyurusu gönderilir → kapalı uygulamaya bildirim gelir (Android).
8. Afetzede 1 GÜVENDEYİM ile sinyali kapatır, uçak moduna geçer ve PANİĞİM'e basar → SMS uygulaması hazır açılır, düdük çalınır. Yeni çağrı "Gönderilmeyi Bekliyor" görünür → internet açılınca otomatik gönderilir.
9. Profil'de Dil → English seçilir → uygulama İngilizce olur (varsayılan Türkçe, cihaz dilinden bağımsız). Profil'de Hesabı Sil akışı gösterilir.

---

## 9. Riskler

| # | Risk | Önlem |
|---|---|---|
| R1 | Süre ~2 gün, iş sıralı ilerliyor. | Demo akışı (8) kesin kapsamdır. Biten iş hemen `development`'a birleştirilir. |
| R2 | Sunucu yok: uygulama kapalıyken otomatik push gelmez; arka planda Firestore dinlemesi güvenilir değildir. | Uygulama açıkken yerel bildirim; kapalı uygulamaya Console topic duyurusu. |
| R4 | Kayıtta "Saha Koordinatörü" seçilebilir. | Hesap onaysız açılır, hiçbir veriye erişemez; onay yalnızca Console'dan. |
| R5 | Tıbbi bilgi KVKK'da özel nitelikli veridir. | Ayrı açık rıza, yalnızca `private/contact`'ta, yalnızca sahibi + doğrulanmış yetkili okur. |
| R6 | Tasarımda kurum adları ve uygulanmayan özellikler var. | Düzeltmeler (3.3) kodlarken uygulanır. |
| R7 | İstemci öncelik ve sayaçları yazıyor. | Kurallar biçimi doğrular (5.5). |
| R8 | Wi-Fi'ye bağlı ama internetsiz cihaz "çevrimiçi" sanılabilir. | Sunucu onayıyla bağlantı kararı (Kural 8). |
| R9 | Emülatörde GPS ve bildirim sınırlı; salonda internet kopabilir. | Emülatör konumu sabitlenir (Google Play imajlı emülatör), düdük ve push fiziksel Android cihazda gösterilir, hotspot ve yedek video hazır. |
