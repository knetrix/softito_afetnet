---
name: flutter-feature-scaffold
description: >
  AfetNet'te yeni bir feature modülü (lib/features/<feature>/) açarken kullanılır.
  PROJECT_NEW.md §6.1'deki Clean Architecture yapısını (data / domain / presentation),
  Provider + ChangeNotifier controller'ı, repository arayüzünü, Firestore uygulamasını ve
  controller unit testini üretir. "teams feature'ını kur", "logistics klasörünü aç",
  "yeni feature iskeleti" gibi isteklerde tetiklenir. Var olan bir feature'a dosya eklemek
  veya hata düzeltmek için kullanılmaz; kodlama kuralları flutter-development skill'indedir.
---

# AfetNet Feature Scaffold

Sıra sana geldiğinde (`GOREV_DAGILIMI.md`, G1 → G6) sorumlu olduğun feature'ın iskeletini
spesifikasyona uygun açar. Bu skill yalnızca **iskeleti** kurar; ekran, iş kuralı ve Firestore
desenleri `flutter-development` skill'indedir.

## Ne Zaman Kullanılır?

| Durum | Bu skill? |
|---|---|
| `lib/features/<f>/` henüz yok, ilk kez açılacak | ✅ |
| Feature var, yeni sheet/widget eklenecek | ❌ Elle ekle (`flutter-development` rehberleri) |
| Eski prototip klasörü var (`auth/`, `onboarding/`, `emergency_call/`, `crisis_map/`) | ❌ Script çalışmaz; bkz. SSS |
| §6.1 listesinde olmayan feature | ⚠️ Önce G1'e danış |

## Temel Kurallar

1. **Feature adları sabittir (§6.1):** `splash`, `onboarding`, `auth`, `profile`,
   `safety_signal`, `home`, `help_request`, `assembly_points`, `whistle`, `live_feed`, `teams`,
   `logistics`, `broadcast`, `demo_seed`.
2. **Üç katman, tek yön:** `presentation → domain ← data`. `domain/` Firebase ve UI paketi
   import etmez (`@immutable` için yalnızca `package:flutter/foundation.dart`).
   `presentation/` `cloud_firestore` import etmez.
3. **State (§6):** Ekran durumu `ChangeNotifier` controller'da, ekranda
   `ChangeNotifierProvider` ile kurulur. Tek değerli yerel durum `ValueNotifier`.
   Bloc, Riverpod, GetX, GetIt **kullanılmaz**.
4. **Yeni ekran değil sheet:** Feature'ın ekranı §3.1'deki 12 ekrandan biridir. Ek işlemler
   `presentation/sheets/` altında `AppBottomSheet` / `AppDialog` ile yapılır (§3.2).
5. **Sabit metin ve renk yok:** `AppLocalizations.of(context)!` ve `Theme.of(context)`;
   her anahtar `app_tr.arb` + `app_en.arb`'ye eklenir.
6. **Üzerine yazma yok:** Proje bayrak yarışıdır; önceki kişinin kodu korunur. Script hedef
   klasör varsa durur.

## Üretilen Yapı

```text
lib/features/<feature>/
  domain/
    <feature>_entity.dart                # @immutable entity (TODO: gerçek ad ve alanlar)
    <feature>_repository.dart            # abstract interface class
  data/
    firestore_<feature>_repository.dart  # Firestore uygulaması, DTO dönüşümü
  presentation/
    <feature>_screen.dart                # ChangeNotifierProvider + _View + StateView
    <feature>_controller.dart            # ChangeNotifier, stream aboneliği, dispose
    widgets/<feature>_tile.dart          # StatelessWidget, taşmaya dayanıklı
test/features/<feature>/
  <feature>_controller_test.dart         # Sahte repository: loading / empty / ready / failure
```

`--ui-only` (`whistle`, `splash`, `onboarding` gibi Firestore'suz ekranlar): yalnızca
`presentation/` (`ValueNotifier`'lı controller + ekran) ve testi üretilir.

## Adım Adım

### Adım 1: Ön koşullar

- `git checkout development && git pull`, ardından `feature/<isim>-<konu>` dalı.
- `pubspec.yaml`'da çözülmemiş merge çakışması (`<<<<<<<`) olmamalı; varsa script durur.
- G2'nin ortak dosyaları: `lib/core/widgets/state_view.dart` (`ViewStatus` enum'u dahil) ve
  `lib/l10n/app_tr.arb` + `app_en.arb`. Yoksa script uyarır; üretilen kod bu dosyalar gelene
  kadar derlenmez.

### Adım 2: Script'i repo kökünden çalıştır

```bash
bash .agents/skills/flutter-feature-scaffold/script/generate_feature.sh teams
bash .agents/skills/flutter-feature-scaffold/script/generate_feature.sh whistle --ui-only
```

Script: repo kökünü ve `pubspec.yaml`'ı doğrular, paket adını oradan okur, adı §6.1 listesine
göre denetler (`--allow-custom-name` ile aşılır), var olan klasörün üzerine yazmayı reddeder,
`lib/` içinde göreli, `test/` içinde `package:` import kullanır (`avoid_relative_lib_imports`),
eksik ortak dosyaları listeler.

### Adım 3: TODO'ları doldur

1. **Entity:** `<feature>_entity.dart`'ı gerçek adla yeniden adlandır (`team.dart` / `Team`).
   Alanları `database/` ve §5.2–5.3'ten **aynen** al; enum'lar `core/constants/`'tan.
2. **Repository arayüzü:** Ekranın gerçekten ihtiyaç duyduğu metotlar
   (`watchTeams()`, `advanceAssignment(...)`). `watchAll` / `save` yalnızca örnektir.
3. **Firestore uygulaması:** Koleksiyon adı (§5.1), sorgu + index (§5.4); Transaction/batch
   gerekiyorsa `flutter-development/references/state-management-with-provider.md` §5.
4. **İş kuralı:** `domain/` içinde saf fonksiyon (`assignment_flow.dart`, `stock_level.dart`)
   ve unit testi.
5. **ARB:** `<feature>Title`, `<feature>Empty` ve ekrandaki tüm metinler iki ARB'ye.
6. **Bağla:** Repository'yi `app.dart` `MultiProvider`'a, ekranı `core/router/` içindeki ilgili
   branch'e ekle (G1'in koyduğu boş ekranın yerine).

### Adım 4: Doğrula

```bash
flutter analyze
flutter test test/features/<feature>
```

İkisi de temiz değilse PR açılmaz. PR base'i `development`.

## Feature → Sorumlu → İçerik

| Feature | Sahibi | Ekran | Not |
|---|---|---|---|
| `auth` | G1 | O3, O4 | Kayıt tek batch: `users` + `private/contact`; rol + onay kontrolü |
| `splash`, `onboarding` | G2 | O1, O2 | `--ui-only`; `onboardingDone` SharedPreferences |
| `profile` | G2 | A4, Y4 | Düzenleme sheet'leri, tıbbi bilgi açık rıza; Hesabı Sil akışı G6 |
| `safety_signal` | G3 | A1 içinde | `safety_signals/{uid}`, `hasPendingWrites` 10 sn, SMS diyaloğu |
| `home` | G3 | A1 | Panik butonu + `help_request` kartını gösterir |
| `whistle` | G3 | A3 | `--ui-only`; `audioplayers`, iOS `playback` |
| `help_request` | G4 | A1 sheet + kart | `PriorityPolicy`, 50 m birleştirme Transaction, Hive kuyruğu |
| `assembly_points` | G4 | A2 | `flutter_map`, mesafe, doluluk, hizmetler |
| `live_feed` | G5 | Y1 | Olay + panik pinleri, filtreler; Detay / Ekip Yönlendir / Ulaşıldı sheet'leri |
| `teams` | G5 | Y2 | Görev Ata / Güncelle; `assignments` tek batch, yalnızca ileri adım |
| `logistics` | G6 | Y3 | Stok Transaction, Kritik / Orta / Yeterli, kritik bildirim |
| `broadcast` | G6 | Y1/Y2 sheet | `broadcasts`, yarıçap 100–20000 m, yerel bildirim |
| `demo_seed` | G6 | Y4 (debug) | Yalnızca `kDebugMode`; release'de yok |

## Örnekler ve Referanslar

- [State Akışı](references/state_flow.md): katman sorumlulukları, veri akışı, yaşam döngüsü, hata yönetimi.
- [Örnek Feature](examples/sample_screen.dart): `logistics` (Y3) stok kartları + giriş/çıkış sheet'i;
  katmanları tek dosyada gösteren okuma örneği.
- [Script](script/generate_feature.sh): iskelet üretici.

## SSS

**Script "zaten var" diyor.** Klasörü silmeden önce içine bak ve
`git log -- lib/features/<f>` ile kimin yazdığını kontrol et. Senin işin değilse silme,
sahibine sor.

**`auth` veya `onboarding` klasörü eski prototipten zaten var.** Script bu ikisinde çalışmaz.
`auth` için eksik `domain/` ve `data/` klasörlerini Üretilen Yapı'ya bakarak elle ekle, mevcut
`presentation/` dosyalarını koru. `onboarding` içindeki `screens/` ve `widgets/` klasörleri
§6.1'e göre `presentation/` altına taşınır; `splash` ayrı feature olarak script ile açılabilir.

**Entity için `freezed` / `json_serializable` kullanabilir miyim?** Hayır, §6.2 listesinde yok.
Elle `copyWith` ve `==` yeterli; Firestore dönüşümü `data/`'da yapılır.
