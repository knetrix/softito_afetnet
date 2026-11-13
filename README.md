# AfetNet

Deprem, sel ve yangın gibi kriz anlarında afetzedeleri saha koordinatörleri ve arama-kurtarma ekipleriyle **gerçek zamanlı** buluşturan acil yardım ağı. Afetzede tek dokunuşla panik sinyali ve yardım çağrısı gönderir; yetkili çağrıları canlı haritada önceliğe göre görür, ekip yönlendirir ve sahra deposunu yönetir. İnternet yokken de çalışır: düdük, SMS köprüsü ve çevrimdışı çağrı kuyruğu. Flutter ile yazılmıştır; veriler Cloud Firestore'da canlı akar, çevrimdışı kuyruk cihazda (Hive) tutulur.

> **Resmi kurum uygulaması değildir.** AfetNet bağımsız bir öğrenci projesidir; hayati tehlikede **112**'yi arayın.

### Afetzede

| Ana Sayfa | Yardım Çağrısı | Panik Sinyali |
| --- | --- | --- |
| ![Ana Sayfa](docs/screenshots/05-home.png) | ![Yardım Çağrısı](docs/screenshots/06-help-request.png) | ![Panik Sinyali](docs/screenshots/08-panic.png) |

| Ekip Yolda | Toplanma Alanları | Düdük |
| --- | --- | --- |
| ![Ekip Yolda](docs/screenshots/09-team-en-route.png) | ![Toplanma Alanları](docs/screenshots/10-assembly.png) | ![Düdük](docs/screenshots/12-whistle-on.png) |

| Profil | Acil Durum Yakını ve Dil | Tıbbi Kimlik (KVKK rızası) |
| --- | --- | --- |
| ![Profil](docs/screenshots/13-profile.png) | ![Acil Durum Yakını](docs/screenshots/14-profile-contact.png) | ![Tıbbi Kimlik](docs/screenshots/15-medical-edit.png) |

### Saha Koordinatörü

| Canlı Akış | Çağrı Detayı | Ekip Yönlendir |
| --- | --- | --- |
| ![Canlı Akış](docs/screenshots/16-live-feed.png) | ![Çağrı Detayı](docs/screenshots/17-request-detail.png) | ![Ekip Yönlendir](docs/screenshots/19-dispatch.png) |

| Ekipler | Görev Güncelle | Panik Pini |
| --- | --- | --- |
| ![Ekipler](docs/screenshots/21-teams.png) | ![Görev Güncelle](docs/screenshots/22-task-update.png) | ![Panik Pini](docs/screenshots/18-panic-pin.png) |

| Lojistik | Stok Çıkışı | Tahliye Anonsu |
| --- | --- | --- |
| ![Lojistik](docs/screenshots/23-logistics-critical.png) | ![Stok Çıkışı](docs/screenshots/24-stock-out.png) | ![Tahliye Anonsu](docs/screenshots/25-broadcast.png) |

### Açılış ve Tema

| Tanıtım | Giriş | Kayıt |
| --- | --- | --- |
| ![Tanıtım](docs/screenshots/01-onboarding-afetzede.png) | ![Giriş](docs/screenshots/03-login.png) | ![Kayıt](docs/screenshots/04-register.png) |

| Açık Tema | Açık Tema — Canlı Akış | İngilizce |
| --- | --- | --- |
| ![Açık Tema](docs/screenshots/27-home-light.png) | ![Açık Tema Canlı Akış](docs/screenshots/29-live-feed-light.png) | ![İngilizce](docs/screenshots/31-home-english.png) |

Ek görüntüler: [Tanıtım — Saha Yönetimi](docs/screenshots/02-onboarding-yetkili.png) · [Aktif çağrı kartı](docs/screenshots/07-active-request.png) · [Düdük beklemede](docs/screenshots/11-whistle.png) · [Ekip yönlendirildi](docs/screenshots/20-team-assigned.png) · [Yetkili Profili](docs/screenshots/26-official-profile.png) · [Açık tema — Toplanma](docs/screenshots/28-assembly-light.png) · [Açık tema — Lojistik](docs/screenshots/30-logistics-light.png)

## Özellikler

**Afetzede**

- Kayıt / giriş (e-posta, maskeli telefon `+90 5XX XXX XX XX`, güçlü şifre ve güç göstergesi, KVKK + Gizlilik onayı), Şifremi Unuttum
- **PANİĞİM / TEHLİKEDEYİM:** 2 sn basılı tutunca konum ve zamanla birlikte sinyal gider; yetkilinin haritasında mor pin ve bildirim belirir. "Merkeze iletildi" yalnızca sunucu onayıyla yazar; GÜVENDEYİM ile sinyal kapanır
- **Yardım çağrısı:** 7 ihtiyaç türü (Enkaz Altında, Tıbbi Müdahale, Barınma, Isınma, Bebek Maması, Su, Diğer), kişi sayısı, adres tarifi ve açıklama. Aktif çağrı kartı ekibin durumuyla canlı güncellenir ("Ekip Yönlendirildi — Arama Kurtarma Tim 4" → Yola Çıktı → Olay Yerinde → Kurtarıldı); çağrı iptal edilebilir
- **Çevrimdışı çağrı:** internet yoksa çağrı cihazda kuyruğa alınır ve kartta "Gönderilmeyi Bekliyor" yazar; internet gelince kendiliğinden gider, uygulama kapatılıp açılsa da kaybolmaz
- **SMS köprüsü:** panik internetsiz gönderilemezse SMS uygulaması acil durum yakınının numarası ve konum linkiyle hazır açılır
- **Düdük:** yüksek sesli düdük; internetsiz ve telefon sessizdeyken de çalar
- **Toplanma:** haritada toplanma alanları, sahra hastaneleri ve barınma noktaları; mesafe, doluluk yüzdesi ve hizmetler
- **Profil:** tıbbi kimlik (kan grubu, ilaçlar, kronik hastalık; ayrı KVKK açık rızasıyla), acil durum yakını, ikamet adresi, dil seçimi, Hesabı Sil
- Tahliye ve artçı sarsıntı anonslarını bildirim olarak alır (uygulama kapalıyken de, FCM topic ile)

**Saha Koordinatörü (Yetkili)**

- **Canlı Akış:** öncelik renkli olay pinleri ve mor panik pinleriyle canlı harita; Tümü / Kritik / Acil / Normal / Medikal filtreleri; olay kartlarında kişi sayısı, mesafe, adres tarifi ve süre
- **Otomatik önceliklendirme (triage):** öncelik ihtiyaç türünden hesaplanır (enkaz ve tıbbi → Kritik), liste önce önceliğe sonra zamana göre sıralanır
- **Mükerrer çağrı birleştirme:** 50 m içindeki çağrılar tek olay dosyasında birleşir, kartta çağrı sayısı artar (geohash ile 9 hücrede arama + gerçek mesafe, Transaction içinde)
- **Detay:** çağrı sahibinin telefonu (arama butonu) ve tıbbi özeti, bağlı çağrılar, görev durumu, Olayı Kapat
- **Ekipler:** Ekip Yönlendir / Görev Ata ve Görev Güncelle (Atandı → Yola Çıktı → Olay Yerinde → Kurtarıldı, geri adım yok); her adımda görev, olay, çağrılar ve ekip tek Transaction'da güncellenir
- **Lojistik:** sahra depoları ve stok kalemleri; giriş / çıkış tek Transaction, eksi stok yok, her hareket kayıt altında. Kritik / Orta / Yeterli etiketleri, kritik stok uyarı kartı ve bildirimi
- **Tahliye Anonsu:** tür (Acil Tahliye / Artçı Sarsıntı), yarıçap ve mesaj; yarıçap içindeki afetzedelere bildirim
- Yetkili hesap onaysız açılır ve hiçbir veriyi göremez; onay yalnızca Firebase Console'dan verilir

**Ortak**

- Koyu ve açık tema (sistem temasını izler), Türkçe / İngilizce (varsayılan Türkçe, Profil'den değiştirilir)
- Kişisel veriler (ad, telefon, adres, tıbbi bilgi) ayrı `private/contact` belgelerinde; yalnızca sahibi ve onaylı yetkili okuyabilir
- Gizlilik Politikası, KVKK Aydınlatma Metni, Kullanım Koşulları ve Hesap Silme sayfaları (TR + EN) Firebase Hosting'de

## Kurulum ve çalıştırma

```bash
flutter pub get
flutter analyze
flutter test           # unit + widget testleri
flutter run            # bağlı Android cihaz / emülatör
```

Firestore Security Rules testleri (Firebase emülatörü, Node.js ve Firebase CLI gerekir):

```bash
npm install
npm run test:rules
```

> Not: Uygulama Android için geliştirildi ve test edildi. iOS derlemesi çalışır, ancak push bildirimi ücretli Apple Developer hesabı gerektirdiği için kurulmadı.

Demo verisi (ekipler, depolar, stok ve toplanma noktaları) debug derlemede yetkili Profil'indeki **Demo Verisini Sıfırla** ile yüklenir.

## Mimari

Clean Architecture: ortak kodlar `core/` altında (tema, router, servisler, ortak widget'lar), her özellik `features/<özellik>/` altında `domain/` (model + repository arayüzü), `data/` (Firestore repository) ve `presentation/` (ekran + controller) katmanlarına ayrılır. State `Provider` + `ChangeNotifier`, navigasyon GoRouter (her rol için ayrı `StatefulShellRoute` ve rol bazlı yönlendirme). Ücretsiz Spark planda sunucu kodu çalışmadığı için iş mantığı istemcide, doğruluğu Security Rules ile denetlenir.

## Notlar

- Harita [OpenStreetMap](https://www.openstreetmap.org) verisiyle `flutter_map` üzerinden çizilir; API anahtarı gerekmez.
- Uygulaması kapalı cihazlara bildirim Firebase Console → Messaging'den `all_users` topic'ine gönderilir (Spark planda sunucudan otomatik push yoktur).
- SMS otomatik gönderilmez; Google Play, `SEND_SMS` iznini yalnızca varsayılan SMS uygulamalarına verir. Kullanıcı hazır mesajda Gönder'e basar.
- Tasarımlardaki AFAD, AKUT ve Kızılay adları ve logoları kaldırıldı; mağazalar kurum taklidini reddeder.

## Ekip

SoftITO 4. Dönem Mobil — 2. Grup: Hasibe Esra Ergün, Meryem Duymuş, Furkan Çalışkan, Somaya Arab, Tuba Aydın, Mustafa Ersoy
