# Provider'lı Ekranlar

Kaynak: `PROJECT_NEW.md` §3.1 (ekranlar), §3.2 (sheet/diyalog), §3.3 (düzeltmeler), §6 (kalite).

## 1. Ekran İskeleti

Her ekran üç parçadır:

1. **Giriş widget'ı** (`XScreen`): controller'ı `ChangeNotifierProvider` ile kurar.
2. **Görünüm** (`_XView`): `context.watch` ile durumu okur, `StateView`'a verir.
3. **Parçalar** (`widgets/`, `sheets/`): 40 satırı geçen her blok ayrı `StatelessWidget` olur.

```dart
class _LiveFeedView extends StatelessWidget {
  const _LiveFeedView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.watch<LiveFeedController>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.liveFeedTitle)),
      floatingActionButton: EvacuationButton(onPressed: () => showBroadcastSheet(context)),
      body: SafeArea(
        child: StateView(
          status: c.status,
          emptyMessage: l10n.liveFeedEmpty,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: LiveFeedMap()),
              SliverToBoxAdapter(
                child: FeedFilterChips(selected: c.filter, onSelected: c.setFilter),
              ),
              SliverList.builder(
                itemCount: c.visible.length,
                itemBuilder: (context, i) => IncidentCard(item: c.visible[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### `StateView` sözleşmesi (G2 yazar, herkes kullanır)

```dart
StateView(
  status: ViewStatus.loading | ready | empty | failure,
  child: ...,              // ready durumunda gösterilir
  emptyMessage: String?,   // ARB'den
  onRetry: VoidCallback?,  // failure durumunda "Tekrar Dene"
)
```

Ekranlar kendi `CircularProgressIndicator`'ını ve hata metnini yazmaz; hep `StateView`.

## 2. Kart ve Rozet (Y1 örneği)

```dart
class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.item});

  final FeedItem item; // incident + primaryRequest + private/contact.fullName

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.displayName ?? l10n.unknownName,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge.priority(item.incident.priority),
              ],
            ),
            const SizedBox(height: 4),
            Text(l10n.peopleCount(item.primaryRequest.peopleCount ?? 1), style: theme.textTheme.bodySmall),
            // T9: kartta yalnızca Detay ve Ekip Yönlendir; "Rota Çiz", "Sektör B-2" yok.
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                AppButton.secondary(label: l10n.detail, onPressed: () => showIncidentDetailSheet(context, item)),
                AppButton.primary(label: l10n.dispatchTeam, onPressed: () => showTeamDispatchSheet(context, item.incident)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

**Taşma kuralları:** uzun metin `Expanded` + `maxLines` + `overflow`; yan yana butonlar
`OverflowBar` veya `Wrap`; chip grupları `Wrap`; sayfa gövdesi kaydırılabilir. Kontrol:
360×640 ekran ve en büyük sistem yazı boyutu.

## 3. Bottom Sheet (yeni ekran yerine)

Sheet'ler `presentation/sheets/` altındadır, her biri `showXSheet(...)` fonksiyonuyla açılır.
Sheet sonuç döndürür; işlemi controller yapar, SnackBar'ı **çağıran taraf** gösterir.

```dart
Future<void> showTeamDispatchSheet(BuildContext context, Incident incident) async {
  final teamId = await AppBottomSheet.show<String>(
    context,
    title: AppLocalizations.of(context)!.dispatchTeam,
    child: AvailableTeamsList(near: incident.location), // boştaki ekipler, mesafeye göre
  );
  if (teamId == null || !context.mounted) return;

  final ok = await context.read<AssignmentController>().assign(incident, teamId);
  if (!context.mounted) return;

  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(ok ? l10n.teamDispatched : l10n.genericError)),
  );
}
```

Form içeren sheet'lerde:
- `isScrollControlled: true` ve alt boşluk `MediaQuery.viewInsetsOf(context).bottom`
  (klavye formu örtmez). `AppBottomSheet` bunu varsayılan yapar.
- Form durumu sheet'e ait küçük bir `StatefulWidget` veya `ValueNotifier`'dadır; sheet
  kapanınca atılır. `TextEditingController`'lar dispose edilir.
- Gönder butonu işlem sürerken devre dışıdır (çift gönderim olmasın).
- Uzunluk sınırları §5.2'den: `addressText` ≤ 300, `description` ≤ 500 (`maxLength`).

## 4. Onay Diyaloğu

```dart
Future<void> _confirmCancel(BuildContext context, String requestId) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await AppDialog.confirm(
    context,
    title: l10n.cancelRequestTitle,
    message: l10n.cancelRequestMessage,
    confirmLabel: l10n.cancelRequestConfirm,
    destructive: true,
  );
  if (confirmed != true || !context.mounted) return;
  await context.read<ActiveRequestController>().cancel(requestId);
}
```

Diyalog kullanılan yerler (§3.2): Çağrıyı İptal Et, Çıkış Yap, Hesabı Sil, SMS ile haber ver.

## 5. `mounted` Kuralı

| Nerede | Kontrol |
|---|---|
| `State` sınıfı metodunda | `if (!mounted) return;` |
| `BuildContext` alan fonksiyon / callback | `if (!context.mounted) return;` |
| `ChangeNotifier` controller | `_disposed` bayrağı, `notifyListeners()` öncesi |

Her `await`'ten sonra `context`, `Navigator`, `ScaffoldMessenger` kullanılmadan önce kontrol
yapılır. `use_build_context_synchronously` uyarısı PR'da kabul edilmez.

## 6. Harita Ekranları (A2, Y1, Y2)

```dart
FlutterMap(
  options: MapOptions(initialCenter: center, initialZoom: 14),
  children: [
    TileLayer(
      urlTemplate: AppConfig.osmTileUrl,
      userAgentPackageName: AppConfig.userAgentPackageName, // 'com.softito.afetnet'
    ),
    MarkerLayer(markers: markers),
    const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')), // zorunlu (§7)
  ],
)
```

- Pin rengi `AppStatusColors.forPriority(priority)`; panik sinyali mor pin (`panic`).
- Pin'e dokunma sheet açar (Y1 mor pin → konum, zaman, Ulaşıldı).
- Mesafe `Geolocator.distanceBetween`, biçim `intl` `NumberFormat` ("850 m", "1,2 km").

## 7. Ekran Bazlı Notlar

| Ekran | Dikkat |
|---|---|
| O1 | Firebase başlatma, oturum ve rol kontrolü; yönlendirmeyi router `redirect` yapar |
| O2 | 2 sayfa, 2 nokta (T6); "Otomatik Önceliklendirme", "Ekip Takibi" (T1, T2); 1. sayfa altında resmi değildir + 112 (T15); bitince `onboardingDone` |
| O3 | Yalnızca e-posta (T3); "Giriş Yap" / "Sign In" (T5); Şifremi Unuttum = `sendPasswordResetEmail`; altta resmi değildir + `tel:112` (T15) |
| O4 | Telefon maskesi `+90 5XX XXX XX XX`, şifre kuralı (8+, 1 büyük, 1 rakam) ve güç göstergesi, KVKK + Gizlilik onayı zorunlu, metinler web sayfası (T4, §7) |
| A1 | Ad + konum etiketi (Kural 9); PANİĞİM 2 sn basılı tutma; sinyal açıkken "GÜVENDEYİM — Sinyali kapat" (T8); "Merkeze iletildi" yalnızca sunucu onayıyla (Kural 8); aktif çağrı kartı kendi `help_requests` belgesini dinler, ekip adı `teams/{assignedTeamId}`'den; kuyruktaysa "Gönderilmeyi Bekliyor" |
| A2 | Toplanma / sahra hastanesi / çadır pinleri, mesafe etiketi, doluluk % (`currentCount / capacity`), hizmetler; kurum adı yok (T1) |
| A3 | Bekleme turuncu "DÜDÜK" (`whistle`), çalıyor kırmızı "ÇALIYOR" (`critical`); internetsiz |
| A4, Y4 | Ad baş harfli avatar (T12); Çıkış Yap altında "Gizlilik Politikası" ve "Hesabı Sil" (T13) |
| A4 | Tıbbi bilgi ilk kayıtta ayrı açık rıza, `medicalConsentAt` (Kural 5, R5); acil durum yakını için `tel:` arama butonu |
| Y1 | Kartta yalnızca Detay + Ekip Yönlendir (T9); telefon ve tıbbi özet yalnızca Detay sheet'inde okunur (Kural 5); Olayı Kapat yalnızca görev yoksa (Kural 7) |
| Y2 | Özet (tim/personel sayısı), tür filtreleri; "Telsiz #" yok (T2); Görev Güncelle yalnızca sonraki durumu gösterir (Kural 6) |
| Y3 | 3 etiket Kritik / Orta / Yeterli (T7); "Acil İkmal İste" ve depo kapasite % yok; kritik uyarı kartı en üstte |
| Y4 | Birim, sorumlu bölge, ekip; sicil no / mesai / vardiya / telsiz bölümü yok (T2, T11); debug'da "Demo Verisini Sıfırla" |
