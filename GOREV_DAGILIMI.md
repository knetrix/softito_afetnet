# AfetNet — MVP Görev Dağılımı

Proje **bayrak yarışı** gibi ilerler: G1 işini bitirip `development`'a birleştirir, sonra G2 başlar; G2 bitirince G3 başlar ve bu böyle devam eder. Her kişi bir öncekinin bitmiş işinin üzerine ekler. Aynı anda tek kişi kod yazdığı için çakışma (conflict) olmaz.

Ayrıntılar `PROJECT_NEW.md`'dedir; parantez içindeki numaralar o belgenin bölümleridir. Ekranlar yalnızca `design/`, veritabanı yalnızca `database/` klasöründeki taslağa göre yapılır.

**Herkes için geçerli:**
- Ekrana yazılan her metin hem `app_tr.arb` hem `app_en.arb` dosyasına eklenir (İngilizce MVP'dedir).
- Tasarım düzeltmeleri (3.3) kodlanırken uygulanır: kurum adı, LoRa/telsiz/mesh ifadesi yazılmaz.
- Testler ve demo **Android** emülatörü/cihazında yapılır (Google Play imajlı emülatör). iOS'ta yalnızca ücretsiz yapılandırmalar yapılır, APNs/push yapılmaz (7); `ios/` derlemesi bozulmamalı.

## Sıra Sana Gelince (GitHub adımları)

```bash
git checkout development
git pull                                  # bir öncekinin işini al
git checkout -b feature/<isim>-<konu>     # örn. feature/tuba-help-request
# ... kodla, sık sık commit at:
git add .
git commit -m "feat: yardım çağrısı formu"
git push -u origin feature/<isim>-<konu>
```

Bitirince GitHub'da Pull Request aç. **base** kutusunu `development` yap (varsayılan `main` gelir). G1 (Mustafa) inceleyip birleştirir. Sonra ekip grubuna "Bitti, sıra sende @<sıradaki>" yaz.

## Adımlar

### G1 — Mustafa · Temel ve Giriş
1. Kimlik: `name: afetnet`, Android + iOS `com.softito.afetnet` (7).
2. Firebase projesi (`eur3`), ekibi Editor ekle, `flutterfire configure`. Firestore **test modunda** açılır; kuralları G6 yazar.
3. Tüm paketler `pubspec.yaml`'a (6.2), klasör yapısı (6.1), `app_config.dart`.
4. Router: iki alt menü (afetzede: Ana Sayfa / Toplanma / Düdük / Profil; yetkili: Canlı Akış / Ekipler / Lojistik / Profil). Her sekme şimdilik boş ekran.
5. `validators.dart`: e-posta, telefon maskesi, şifre kuralı (7).
6. Giriş (O3) ve Kayıt (O4): `users` + `private/contact` oluşturma, rol kontrolü, onaysız yetkili uyarısı, rolüne göre yönlendirme (2).

**Çıktı:** Kayıt olan kullanıcı rolüne göre boş ana sayfaya düşüyor.

### G2 — Sümeyye · Görünüm ve Profil
1. Tema (3.4): renk token'ları, yazı tipleri, koyu + açık tema (sistem temasını izler).
2. Ortak widget'lar: `AppButton`, `StateView` (Yükleniyor / Hata / Boş), `GlowCircleButton`, `StatusBadge`, `AppBottomSheet`, `AppDialog`.
3. Dil kurulumu: `app_tr.arb` + `app_en.arb`, cihaz dilini izleme. G1'in ekran metinlerini ARB'ye taşı.
4. Splash (O1) + Onboarding (O2, 2 sayfa). Giriş ve Kayıt'a tasarımı uygula.
5. Profil (A4 afetzede, Y4 yetkili) ve düzenleme sheet'leri: tıbbi bilgi (açık rıza), fiziksel bilgiler, acil durum yakını, adres (3.2). Çıkış Yap.

**Çıktı:** Uygulama tasarımdaki gibi görünüyor, TR/EN çalışıyor, profil dolduruluyor.

### G3 — Furkan · Panik, Ana Sayfa ve Düdük
1. Servisler: konum + konum etiketi (`geocoding`, Kural 9; A1 başlığı ve A4 konum rozeti), bağlantı tespiti (10 sn, Kural 8), yerel bildirim + FCM `all_users` aboneliği.
2. Panik sinyali (`safety_signals`): PANİĞİM (2 sn basılı tut), GÜVENDEYİM, internet yoksa SMS diyaloğu (Kural 8).
3. Ana Sayfa (A1) yerleşimi: ad + konum, panik butonu, "Yardım Çağrısı Ekle" butonu (sheet'i G4 yazar).
4. Düdük (A3): internetsiz düdük, döngüde çalar; iOS'ta sessiz modda da çalar (`playback`).

**Çıktı:** Afetzede panik sinyali gönderebiliyor, düdük çalıyor.

### G4 — Tuba · Yardım Çağrısı ve Toplanma
1. Yardım Çağrısı sheet'i (3.2): tür, kişi sayısı, adres, açıklama; öncelik hesabı (`priority_policy.dart`, Kural 1).
2. Mükerrer birleştirme: 8 haneli `geohash`, 9 hücre araması, 50 m, `incidents` Transaction'ı (Kural 2).
3. Çevrimdışı kuyruk: Hive, "Gönderilmeyi Bekliyor" (Kural 4).
4. Ana Sayfa'ya aktif çağrı kartı: durum, tür, ekip, sorumlu, İptal Et (Kural 6–7).
5. Toplanma (A2): harita, noktalar, mesafe, doluluk, hizmetler.

**Çıktı:** Afetzede tarafı tamamen çalışıyor.

### G5 — Esra · Canlı Akış ve Ekipler
1. Canlı Akış (Y1): harita (olay pinleri + mor panik pinleri), öncelik sıralı olay kartları, filtreler.
2. Y1 sheet'leri (3.2): Detay (telefon, tıbbi özet, Olayı Kapat), Ekip Yönlendir, panik pini (Ulaşıldı).
3. Ekipler (Y2): özet, filtreler, mini harita, ekip kartları; Görev Ata ve Görev Güncelle sheet'leri.
4. Görev akışı (`assignments`): Atandı → Yola Çıktı → Olay Yerinde → Kurtarıldı, tek batch güncelleme (Kural 6).

**Çıktı:** Yetkili çağrıyı görüp ekip atayabiliyor; afetzedenin kartı canlı güncelleniyor.

### G6 — Meryem · Lojistik, Anons ve Teslime Hazırlık
1. Lojistik (Y3): depo, envanter, stok etiketi, giriş/çıkış sheet'i + Transaction, kritik stok uyarısı (Kural 3).
2. Tahliye Anonsu sheet'i (`broadcasts`), yarıçap içindeki afetzedelere bildirim (Kural 10).
3. Demo verisi: ekipler, depo, stok, toplanma noktaları ve "Demo Verisini Sıfırla" servisi (buton Y4'te debug derlemede hazır); demo hesaplarını kayıt olarak aç, yetkiliyi Console'dan onayla (8).
4. Yasal metinler TR/EN (`hosting/legal/`, Firebase Hosting). Hesabı Sil akışı (7) G2'de yapıldı; G6 yalnızca kurallarda silme izinlerini verir ve akışı dener.
5. `firestore.rules` + index'ler (5.4, 5.5); test modu kapatılır, demo akışı baştan sona tekrar denenir.

**Çıktı:** Demo akışının (8) tamamı TR ve EN çalışıyor.

### Son Tur — 13 Kasım sabah
- **G1:** release derlemesi (AAB).
- **G2:** `store/` ekran görüntüleri ve açıklamalar (TR + EN).
- **Herkes:** demo akışını dener, hataları sahibine iletir; ardından demo provası.
