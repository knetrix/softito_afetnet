# AfetNet — Aşama Durumu

Adımlar `GOREV_DAGILIMI.md`'deki sırayla ilerler. Aşamasını bitiren kişi kendi satırlarını günceller ve bu dosyayı PR'ına ekler.

**Durum:** ✅ Tamamlandı · 🟡 Kısmen / bekleyen iş var · ⏳ Başlamadı

| Aşama | Sahip | Durum | PR |
|---|---|---|---|
| G1 — Temel ve Giriş | Mustafa | 🟡 Kod tamam, 2 iş bekliyor | [#8](https://github.com/knetrix/softito_afetnet/pull/8), [#9](https://github.com/knetrix/softito_afetnet/pull/9) |
| G2 — Görünüm ve Profil | Sümeyye | ⏳ Sıradaki | — |
| G3 — Panik, Ana Sayfa ve Düdük | Furkan | ⏳ | — |
| G4 — Yardım Çağrısı ve Toplanma | Tuba | ⏳ | — |
| G5 — Canlı Akış ve Ekipler | Esra | ⏳ | — |
| G6 — Lojistik, Anons ve Teslime Hazırlık | Meryem | ⏳ | — |
| Son Tur — 13 Kasım sabah | Herkes | ⏳ | — |

---

## G1 — Mustafa · Temel ve Giriş

**Çıktı:** Kayıt olan kullanıcı rolüne göre boş ana sayfaya düşüyor. 🟡 Birim testleriyle doğrulandı; emülatör/cihazda henüz denenmedi.

| # | Adım | Durum | Not |
|---|---|---|---|
| 1 | Kimlik: `name: afetnet`, `com.softito.afetnet` | ✅ | Conflict işaretli platform dosyaları yeniden üretildi; `macos/` ve `web/` kaldırıldı |
| 2 | Firebase projesi (`eur3`), `flutterfire configure`, Firestore test modu | ✅ | Proje `afetnet-softito`. Test modu kuralları 11 Aralık 2026'ya kadar geçerli. E-posta/Şifre girişi açık |
| 2 | Ekibi Firebase Console'a Editor ekle | ⏳ | Ekip üyelerinin e-postaları gerekiyor |
| 3 | Paketler (6.2), klasör yapısı (6.1), `app_config.dart` | ✅ | `pubspec.lock` repoda |
| 4 | Router: iki alt menü, boş sekmeler | ✅ | `core/router/` |
| 5 | `validators.dart`: e-posta, telefon maskesi, şifre kuralı | ✅ | Birim testli |
| 6 | Giriş (O3) ve Kayıt (O4): `users` + `private/contact`, rol kontrolü, onaysız yetkili uyarısı, rolüne göre yönlendirme | ✅ | T3, T4, T5, T15 uygulandı |
| — | Kayıt akışını emülatör/cihazda dene | ⏳ | Bu bilgisayarda emülatör yok |

**Kontroller:** `flutter analyze` temiz · 23 test geçiyor · `flutter build apk --debug` ve `flutter build ios --debug --no-codesign` başarılı.

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

| # | Adım | Durum |
|---|---|---|
| 1 | Tema (3.4): renk token'ları, yazı tipleri, koyu + açık tema | ⏳ |
| 2 | Ortak widget'lar: `AppButton`, `StateView`, `GlowCircleButton`, `StatusBadge`, `AppBottomSheet`, `AppDialog` | ⏳ |
| 3 | Dil kurulumu (ARB, cihaz dili), G1 metinlerini ARB'ye taşıma | ⏳ |
| 4 | Splash (O1) + Onboarding (O2), Giriş ve Kayıt'a tasarım | ⏳ |
| 5 | Profil (A4, Y4) ve düzenleme sheet'leri, Çıkış Yap | ⏳ |

**Çıktı:** Uygulama tasarımdaki gibi görünüyor, TR/EN çalışıyor, profil dolduruluyor. ⏳

## G3 — Furkan · Panik, Ana Sayfa ve Düdük

| # | Adım | Durum |
|---|---|---|
| 1 | Servisler: konum + konum etiketi, bağlantı tespiti, yerel bildirim + FCM `all_users` | ⏳ |
| 2 | Panik sinyali: PANİĞİM, GÜVENDEYİM, SMS diyaloğu | ⏳ |
| 3 | Ana Sayfa (A1) yerleşimi | ⏳ |
| 4 | Düdük (A3): internetsiz, iOS sessiz modda da çalar | ⏳ |

**Çıktı:** Afetzede panik sinyali gönderebiliyor, düdük çalıyor. ⏳

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
| 3 | Demo verisi, "Demo Verisini Sıfırla", demo hesapları | ⏳ |
| 4 | Hesabı Sil akışı + yasal metinler (Firebase Hosting) | ⏳ |
| 5 | `firestore.rules` + index'ler; test modunu kapat, demo akışını dene | ⏳ |

**Çıktı:** Demo akışının (8) tamamı TR ve EN çalışıyor. ⏳

## Son Tur — 13 Kasım sabah

| Kim | İş | Durum |
|---|---|---|
| G1 | Release derlemeleri (AAB + iOS `--no-codesign`) | ⏳ |
| G2 | `store/` ekran görüntüleri ve açıklamalar (TR + EN) | ⏳ |
| Herkes | Demo akışını dene, hataları sahibine ilet, demo provası | ⏳ |
