// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'AfetNet';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get ok => 'Tamam';

  @override
  String get confirm => 'Onayla';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get close => 'Kapat';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get genericError => 'Bir hata oluştu, lütfen tekrar deneyin.';

  @override
  String get emptyList => 'Kayıt bulunamadı.';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get detail => 'Detay';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get officialSignOut => 'Sistemden Çıkış Yap';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get kvkkConsent => 'KVKK Aydınlatma Metni';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navAssembly => 'Toplanma';

  @override
  String get navWhistle => 'Düdük';

  @override
  String get navProfile => 'Profil';

  @override
  String get navLiveFeed => 'Canlı Akış';

  @override
  String get navTeams => 'Ekipler';

  @override
  String get navLogistics => 'Lojistik';

  @override
  String get notOfficialDisclaimer =>
      'Resmi kurum uygulaması değildir · Acil durumda ';

  @override
  String get emergencyCall => '112';

  @override
  String get roleCitizen => 'Sivil Kullanıcı (Afetzede)';

  @override
  String get roleOfficial => 'Saha Koordinatörü (Yetkili)';

  @override
  String get validationRequired => 'Bu alan zorunludur';

  @override
  String get validationInvalidEmail => 'Geçerli bir e-posta adresi girin';

  @override
  String get validationInvalidPhone =>
      'Telefonu +90 5XX XXX XX XX biçiminde girin';

  @override
  String get validationPasswordTooShort => 'Şifre en az 8 karakter olmalı';

  @override
  String get validationPasswordNoUppercase =>
      'Şifre en az 1 büyük harf içermeli';

  @override
  String get validationPasswordNoDigit => 'Şifre en az 1 rakam içermeli';

  @override
  String get validationPasswordMismatch => 'Şifreler eşleşmiyor';

  @override
  String get authFailureInvalidCredentials => 'E-posta veya şifre hatalı';

  @override
  String get authFailureEmailAlreadyInUse =>
      'Bu e-posta ile kayıtlı bir hesap var';

  @override
  String get authFailureWeakPassword => 'Şifre çok zayıf';

  @override
  String get authFailureRoleMismatch =>
      'Seçtiğiniz giriş türü bu hesapla uyuşmuyor';

  @override
  String get authFailurePendingApproval => 'Hesabınız yönetici onayı bekliyor';

  @override
  String get authFailureProfileMissing => 'Hesap profili bulunamadı';

  @override
  String get authFailureNetwork => 'İnternet bağlantısı yok, tekrar deneyin';

  @override
  String get authFailureTooManyRequests =>
      'Çok fazla deneme yapıldı, biraz sonra tekrar deneyin';

  @override
  String get authFailureProviderDisabled =>
      'E-posta ile giriş şu an kullanılamıyor';

  @override
  String get authFailureUnknown => 'Bir hata oluştu, tekrar deneyin';

  @override
  String get loginTitle => 'Giriş Yap';

  @override
  String get loginEmail => 'E-posta';

  @override
  String get loginPassword => 'Şifre';

  @override
  String get loginType => 'Giriş Türü';

  @override
  String get loginForgotPassword => 'Şifremi Unuttum';

  @override
  String get loginForgotPasswordPrompt =>
      'Şifre sıfırlama için e-posta adresinizi girin';

  @override
  String get loginForgotPasswordSent =>
      'Şifre sıfırlama bağlantısı e-postanıza gönderildi';

  @override
  String get loginSignUpPrompt => 'Hesabınız yok mu? Üye Olun';

  @override
  String get loginSubmit => 'Giriş Yap';

  @override
  String get registerTitle => 'Kayıt Ol';

  @override
  String get registerAccountType => 'Hesap Türü';

  @override
  String get registerFullName => 'Ad Soyad';

  @override
  String get registerEmail => 'E-posta';

  @override
  String get registerPhone => 'Telefon Numarası';

  @override
  String get registerPassword => 'Şifre';

  @override
  String get registerPasswordAgain => 'Şifre Tekrar';

  @override
  String get registerNotificationsOptIn =>
      'Kritik Afet Uyarı Bildirimlerini Al';

  @override
  String get registerLegalCheckbox =>
      'Gizlilik Politikası ve KVKK Aydınlatma Metnini okudum, onaylıyorum.';

  @override
  String get registerLegalError =>
      'Devam etmek için yasal metinleri onaylamalısınız';

  @override
  String get registerSubmit => 'Kayıt Ol';

  @override
  String get registerOfficialPendingTitle => 'Kayıt Alındı';

  @override
  String get registerOfficialPendingMessage =>
      'Hesabınız yönetici onayı bekliyor. Onaylandıktan sonra giriş yapabilirsiniz.';

  @override
  String get passwordStrengthWeak => 'Zayıf';

  @override
  String get passwordStrengthMedium => 'Orta';

  @override
  String get passwordStrengthStrong => 'Güçlü';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingStart => 'Başla';

  @override
  String get onboardingCivilianBadge => 'SİVİL KULLANICI';

  @override
  String get onboardingCivilianTitle => 'Tek Dokunuşla Güvendesiniz';

  @override
  String get onboardingCivilianDesc =>
      'İnternet erişimi olmasa bile acil yardım çağrısı yapın, çevrimdışı düdüğü kullanın ve en yakın güvenli toplanma alanına ulaşın.';

  @override
  String get onboardingOfficialBadge => 'SAHA YÖNETİMİ';

  @override
  String get onboardingOfficialTitle => 'Krizi Canlı Yönetin';

  @override
  String get onboardingOfficialDesc =>
      'Harita üzerinden canlı çağrıları takip edin, arama kurtarma ekiplerini yönlendirin ve sahra depolarının anlık stok durumunu yönetin.';

  @override
  String get onboardingStockPill => 'Canlı Sahra Stoğu';

  @override
  String get onboardingTeamPill => 'Ekip Takibi';

  @override
  String get onboardingAutoPriority => 'Otomatik Önceliklendirme';

  @override
  String get onboardingAutoPriorityDesc =>
      'Kural tabanlı anlık triage ve acil görev atama';

  @override
  String get splashSubtitle => 'Canlı Kriz Yönetimi Ağı';

  @override
  String get splashReady => 'AfetNet protokolü hazır.';

  @override
  String get profileCivilianTitle => 'Afetzede Profili';

  @override
  String get profileOfficialTitle => 'Saha Koordinatörü Profili';

  @override
  String get profileMedicalCardTitle => 'Tıbbi & Sağlık Kimliği';

  @override
  String get profileBloodType => 'Kan Grubu';

  @override
  String get profileMedications => 'Kullandığı İlaçlar';

  @override
  String get profileConditions => 'Kronik Hastalık / Alerji';

  @override
  String get profilePhysicalInfo => 'Fiziksel Bilgiler';

  @override
  String get profileAge => 'Yaş';

  @override
  String get profileWeight => 'Kilo (kg)';

  @override
  String get profileEmergencyContact => '1. Derece Acil Durum Yakını';

  @override
  String get profileRelation => 'Yakınlık Derecesi';

  @override
  String get profileAddress => 'Kayıtlı İkamet Adresi';

  @override
  String get profileUnit => 'Birim Adı';

  @override
  String get profileRegion => 'Sorumlu Bölge';

  @override
  String get profileTeam => 'Bağlı Ekip';

  @override
  String get profileMedicalConsent =>
      'Tıbbi verilerimin acil durumlarda arama kurtarma ekiplerince görüntülenmesine açık rıza veriyorum (KVKK m.6).';

  @override
  String get profileMedicalConsentRequired =>
      'Tıbbi bilgi kaydetmek için açık rıza gereklidir.';

  @override
  String get profileUpdated => 'Profil başarıyla güncellendi.';

  @override
  String get deleteAccountConfirmTitle => 'Hesabınızı Silmek İstiyor Musunuz?';

  @override
  String get deleteAccountConfirmMessage =>
      'Bu işlem geri alınamaz. Kişisel verileriniz ve sağlık bilgileriniz kalıcı olarak silinecektir.';

  @override
  String get signOutConfirmTitle => 'Çıkış Yap';

  @override
  String get signOutConfirmMessage =>
      'Oturumunuzu kapatmak istediğinize emin misiniz?';

  @override
  String get registerPasswordHelper =>
      'En az 8 karakter, 1 büyük harf, 1 rakam';

  @override
  String get registerNotificationsSubtitle =>
      'Tahliye ve artçı sarsıntı uyarılarını almak istiyorum';

  @override
  String get roleBadgeCitizen => 'SİVİL KULLANICI';

  @override
  String get roleBadgeOfficial => 'SAHA KOORDİNATÖRÜ';

  @override
  String get priorityCritical => 'KRİTİK';

  @override
  String get priorityUrgent => 'ACİL';

  @override
  String get priorityNormal => 'NORMAL';

  @override
  String get profileNotSpecified => 'Belirtilmedi';

  @override
  String get profileNotAssigned => 'Atanmadı';

  @override
  String get profileEmergencyContactEmpty =>
      'Acil durum yakını henüz eklenmedi.';

  @override
  String get profileAddressEmpty => 'Kayıtlı ikamet adresi bulunmuyor.';

  @override
  String get profileContactName => 'Yakının Adı Soyadı';

  @override
  String get profileRelationHint => 'Örn. Anne, Eş, Kardeş';

  @override
  String get profileMedicationsHint => 'Örn. İnsülin, Tansiyon ilacı';

  @override
  String get profileConditionsHint => 'Örn. Astım, Penisilin alerjisi';

  @override
  String get profileBirthYear => 'Doğum Yılı';

  @override
  String get profileBirthYearHint => 'Örn. 1995';

  @override
  String get profileWeightHint => 'Örn. 72';

  @override
  String get profileAddressHint =>
      'İl, ilçe, mahalle, sokak, bina ve kat bilgisi...';

  @override
  String get profileCoordinationInfo => 'Koordinasyon Bilgileri';

  @override
  String get deleteAccountConfirmMessageOfficial =>
      'Bu işlem geri alınamaz. Koordinatör hesabı kalıcı olarak silinecektir.';

  @override
  String get deleteAccountPasswordTitle => 'Şifrenizi Doğrulayın';

  @override
  String get deleteAccountPasswordMessage =>
      'Güvenliğiniz için hesabı silmeden önce şifrenizi girin.';

  @override
  String get deleteAccountFailed => 'Hesap silinemedi, tekrar deneyin.';

  @override
  String get debugToolsTitle => 'Demo & Test Araçları (Debug)';

  @override
  String get demoReset => 'Demo Verisini Sıfırla';

  @override
  String get demoResetTitle => 'Demo Verisi';

  @override
  String get onboardingActive => 'AKTİF';

  @override
  String get onboardingRadarTeam => 'TİM #04 1.2km';

  @override
  String get onboardingRadarDepot => 'DEPO %94 L-4';

  @override
  String get validationInvalidValue => 'Geçerli bir değer girin';

  @override
  String get locationFetching => 'Konum alınıyor...';

  @override
  String get locationUnavailable => 'Konum alınamadı — Yenilemek için dokunun';

  @override
  String get panicButtonTitle => 'PANİĞİM';

  @override
  String get panicButtonSubtitle => 'TEHLİKEDEYİM';

  @override
  String get panicSafeButton => 'GÜVENDEYİM';

  @override
  String get panicSafeSubtitle => 'Sinyali kapat';

  @override
  String get homePanicHoldHint => 'Basılı tutarak acil durum sinyalini iletin';

  @override
  String get homePanicActiveHint =>
      'Panik sinyaliniz aktif. Güvendeyseniz yukarıdaki butona dokunun.';

  @override
  String get panicStatusDelivered => 'Merkeze iletildi';

  @override
  String get panicStatusPending => 'Gönderilmeyi bekliyor';

  @override
  String get panicOfflineSmsTitle => 'Çevrimdışı Sinyal';

  @override
  String get panicOfflineSmsMessage =>
      'İnternet bağlantısı 10 saniye içinde doğrulanamadı. Sinyalin kuyrukta bekliyor; internet gelince otomatik gönderilecek. Acil durum yakınına SMS ile haber vermek ister misin?';

  @override
  String get panicOfflineSmsAction => 'SMS ile Haber Ver';

  @override
  String panicSmsBodyWithLocation(String locationUrl) {
    return 'ACİL DURUM (AfetNet): Tehlikedeyim, yardıma ihtiyacım var. Konumum: $locationUrl';
  }

  @override
  String get panicSmsBodyNoLocation =>
      'ACİL DURUM (AfetNet): Tehlikedeyim, yardıma ihtiyacım var. Konum bilgisi alınamadı.';

  @override
  String get panicNoEmergencyContactTitle => 'Acil Durum Yakını Yok';

  @override
  String get panicNoEmergencyContactMessage =>
      'Kayıtlı acil durum yakını numarası bulunamadı. Profil sekmesinden acil durum yakını ekleyebilirsiniz.';

  @override
  String get panicSmsOpenFailed => 'SMS uygulaması açılamadı.';

  @override
  String get panicLocationFailedTitle => 'Konum Alınamadı';

  @override
  String get panicLocationFailedMessage =>
      'Konum bilgisi alınamadığı için panik sinyali merkeze gönderilemedi. Konum iznini kontrol edebilir, çevrimdışı düdüğü çalabilir veya SMS gönderebilirsiniz.';

  @override
  String get panicOpenWhistle => 'Düdüğü Aç';

  @override
  String get panicSafeSuccess => 'Durumunuz güvende olarak güncellendi.';

  @override
  String get homeAddHelpRequest => 'YARDIM ÇAĞRISI EKLE';

  @override
  String get homeHelpRequestPendingTitle => 'Yardım Çağrısı';

  @override
  String get homeHelpRequestPendingMessage =>
      'Detaylı yardım çağrısı formu G4 aşamasında eklenecektir.';

  @override
  String get homeActiveRequestEmptyTitle => 'Aktif yardım çağrısı yok';

  @override
  String get homeActiveRequestEmptySubtitle =>
      'İhtiyaç halinde aşağıdaki butondan yardım çağrısı oluşturabilirsiniz.';

  @override
  String get whistleIdleLabel => 'DÜDÜK';

  @override
  String get whistleIdleSubtitle => 'Yüksek Sesli Siren';

  @override
  String get whistlePlayingLabel => 'ÇALIYOR';

  @override
  String get whistlePlayingSubtitle => 'Siren aktif';

  @override
  String get whistleTapToStart => 'BAŞLATMAK İÇİN DOKUNUN';

  @override
  String get whistleTapToStop => 'DURDURMAK İÇİN TEKRAR DOKUNUN';

  @override
  String get whistleOfflineNote => 'İnternet bağlantısı olmadan çalışır.';

  @override
  String get notificationChannelName => 'Kritik uyarılar';

  @override
  String get notificationChannelDescription =>
      'Acil durum, tahliye ve kritik stok bildirimleri';

  @override
  String get helpTypeDebris => 'Enkaz Altında';

  @override
  String get helpTypeMedical => 'Tıbbi Müdahale';

  @override
  String get helpTypeShelter => 'Barınma';

  @override
  String get helpTypeHeating => 'Isınma';

  @override
  String get helpTypeBabyFood => 'Bebek Maması';

  @override
  String get helpTypeWater => 'Su';

  @override
  String get helpTypeOther => 'Diğer';

  @override
  String get helpRequestSheetTitle => 'Yardım Çağrısı Ekle';

  @override
  String get helpRequestTypeSection => 'İhtiyaç Türü';

  @override
  String get helpRequestPriorityLabel => 'Öncelik Seviyesi';

  @override
  String get helpRequestPeopleCount => 'Etkilenen Kişi Sayısı';

  @override
  String get helpRequestAddress => 'Adres Tarifi';

  @override
  String get helpRequestAddressHint =>
      'Bina no, kat, daire veya belirgin çevre tarifi...';

  @override
  String get helpRequestDescription => 'Durum Açıklaması';

  @override
  String get helpRequestDescriptionHint =>
      'Durumunuzu ve aciliyetinizi kısaca açıklayın...';

  @override
  String get helpRequestSubmit => 'Gönder';

  @override
  String get helpRequestSubmitted => 'Yardım çağrınız alındı.';

  @override
  String get helpRequestMinPeople => 'Kişi sayısı en az 1 olmalıdır.';

  @override
  String get helpRequestQueuedOffline =>
      'İnternet bağlantısı kurulamadı. Çağrınız kuyruğa alındı ve bağlantı sağlandığında merkeze iletilecektir.';

  @override
  String get helpRequestStatusPendingOffline => 'Gönderilmeyi Bekliyor';

  @override
  String get cancelRequestTitle => 'Çağrıyı İptal Et';

  @override
  String get cancelRequestMessage =>
      'Yardım çağrınızı iptal etmek istediğinize emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get cancelRequestConfirm => 'Evet, İptal Et';

  @override
  String get cancelRequestAction => 'Çağrıyı İptal Et';

  @override
  String get cancelRequestSuccess => 'Yardım çağrınız iptal edildi.';

  @override
  String get activeRequestTitle => 'Aktif Yardım Çağrısı';

  @override
  String get assignedTeamLabel => 'Yönlendirilen Ekip';

  @override
  String get teamLeaderLabel => 'Sorumlu';

  @override
  String get teamWaitingLabel => 'Ekip yönlendirmesi bekleniyor...';

  @override
  String get caseStatusPending => 'Beklemede';

  @override
  String get caseStatusAssigned => 'Ekip Yönlendirildi';

  @override
  String get caseStatusEnRoute => 'Yola Çıktı';

  @override
  String get caseStatusOnSite => 'Olay Yerinde';

  @override
  String get caseStatusResolved => 'Kurtarıldı';

  @override
  String get caseStatusCancelled => 'İptal Edildi';

  @override
  String peopleCountLabel(int count) {
    return '$count Kişi';
  }

  @override
  String get assemblyScreenTitle => 'Toplanma Alanları';

  @override
  String get assemblyFilterAll => 'Tümü';

  @override
  String get assemblyFilterAssembly => 'Toplanma Alanı';

  @override
  String get assemblyFilterFieldHospital => 'Sahra Hastanesi';

  @override
  String get assemblyFilterShelter => 'Barınma / Çadır';

  @override
  String get assemblyServiceWater => 'Temiz Su';

  @override
  String get assemblyServiceHealth => 'İlk Yardım';

  @override
  String get assemblyServiceFood => 'Sıcak Yemek';

  @override
  String get assemblyServiceTent => 'Barınma';

  @override
  String assemblyOccupancyLabel(int percent) {
    return 'Doluluk: %$percent';
  }

  @override
  String assemblyCapacityLabel(String current, String capacity) {
    return '$current / $capacity Kişi';
  }

  @override
  String get assemblyGetDirections => 'Yol Tarifi Al';

  @override
  String get assemblyOpenLabel => 'Açık';

  @override
  String get assemblyClosedLabel => 'Kapalı';

  @override
  String get assemblyNearestBadge => 'En Yakın';

  @override
  String get assemblyMyLocationTooltip => 'Konumuma Git';

  @override
  String get assemblyZoomInTooltip => 'Yakınlaştır';

  @override
  String get assemblyZoomOutTooltip => 'Uzaklaştır';

  @override
  String get assemblyEmptyList => 'Toplanma alanı bulunamadı';

  @override
  String get assemblyNearestTop3 => 'En Yakın 3 Alan';

  @override
  String get assemblyServicesTitle => 'Sunulan Hizmetler';

  @override
  String get helpRequestSelectType => 'İhtiyaç türünü seçin';

  @override
  String get helpRequestPeopleDecrease => 'Azalt';

  @override
  String get helpRequestPeopleIncrease => 'Artır';

  @override
  String get cancelRequestKeep => 'Vazgeç';

  @override
  String assemblyOccupancyShort(int percent) {
    return '%$percent';
  }

  @override
  String get liveFeedTitle => 'CANLI ÇAĞRI AKIŞI';

  @override
  String liveFeedWaitingCount(int count) {
    return '$count AÇIK';
  }

  @override
  String liveFeedFilterAll(int count) {
    return 'Tümü ($count)';
  }

  @override
  String get liveFeedFilterCritical => 'Kritik';

  @override
  String get liveFeedFilterUrgent => 'Acil';

  @override
  String get liveFeedFilterNormal => 'Normal';

  @override
  String get liveFeedEmpty => 'Şu anda açık çağrı yok.';

  @override
  String get liveFeedEmptyFiltered => 'Bu filtreye uyan çağrı yok.';

  @override
  String get liveFeedUnknownName => 'Ad belirtilmemiş';

  @override
  String liveFeedMergedCalls(int count) {
    return '$count birleşik çağrı';
  }

  @override
  String get liveFeedDispatch => 'Ekip Yönlendir';

  @override
  String liveFeedAssignedTeam(String team) {
    return 'Ekip: $team';
  }

  @override
  String liveFeedPanicCount(int count) {
    return '$count panik sinyali';
  }

  @override
  String distanceMeters(int meters) {
    return '$meters m mesafe';
  }

  @override
  String distanceKm(String km) {
    return '$km km mesafe';
  }

  @override
  String get timeJustNow => 'az önce';

  @override
  String timeMinutesAgo(int count) {
    return '$count dk önce';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count sa önce';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String get incidentDetailTitle => 'Çağrı Detayı';

  @override
  String get incidentDetailCaller => 'Çağrı Sahibi';

  @override
  String get incidentDetailPhone => 'Telefon';

  @override
  String get incidentDetailCall => 'Ara';

  @override
  String get incidentDetailNoPhone => 'Telefon numarası yok';

  @override
  String get incidentDetailMedical => 'Tıbbi Özet';

  @override
  String get incidentDetailNoMedical => 'Paylaşılmış tıbbi bilgi yok.';

  @override
  String get incidentDetailLinkedCalls => 'Bağlı çağrı';

  @override
  String incidentDetailLinkedCallsValue(int count, int cancelled) {
    return '$count ($cancelled iptal edildi)';
  }

  @override
  String get incidentDetailTaskStatus => 'Görev durumu';

  @override
  String get incidentDetailNeedType => 'İhtiyaç türü';

  @override
  String get incidentDetailLoadFailed =>
      'Çağrı sahibinin bilgileri yüklenemedi.';

  @override
  String get incidentCloseAction => 'Olayı Kapat';

  @override
  String get incidentCloseConfirmTitle => 'Olay kapatılsın mı?';

  @override
  String get incidentCloseConfirmMessage =>
      'Olay ve bağlı çağrılar çözüldü olarak işaretlenecek. Bu işlem geri alınamaz.';

  @override
  String get incidentClosed => 'Olay kapatıldı.';

  @override
  String get incidentCloseFailed =>
      'Olay kapatılamadı. Ekip atanmış ya da olay zaten kapanmış olabilir.';

  @override
  String get incidentCloseHasTeam =>
      'Bu olayda görevli ekip var. Ekip Kurtarıldı\'ya geçince olay kapanır.';

  @override
  String get dispatchNoAvailableTeams => 'Şu anda boşta ekip yok.';

  @override
  String dispatchSuccess(String team) {
    return '$team yönlendirildi.';
  }

  @override
  String get assignErrorIncidentClosed => 'Bu olay kapanmış.';

  @override
  String get assignErrorAlreadyAssigned => 'Bu olaya zaten ekip atanmış.';

  @override
  String get assignErrorTeamBusy => 'Bu ekip artık boşta değil.';

  @override
  String get assignErrorInvalidTransition =>
      'Görev başka biri tarafından güncellendi. Lütfen tekrar kontrol edin.';

  @override
  String teamMembers(int count) {
    return '$count kişi';
  }

  @override
  String get panicPinTitle => 'Panik Sinyali';

  @override
  String get panicPinLocation => 'Konum';

  @override
  String get panicPinTime => 'Sinyal zamanı';

  @override
  String get panicPinReached => 'Ulaşıldı';

  @override
  String get panicPinHandled => 'Ulaşıldı olarak işaretlendi';

  @override
  String get panicPinReachedSuccess => 'Sinyal ulaşıldı olarak işaretlendi.';

  @override
  String get panicPinReachedQueued =>
      'İnternet yok; işaret bağlantı gelince iletilecek.';

  @override
  String get panicNotificationTitle => 'Yeni panik sinyali';

  @override
  String get panicNotificationBody =>
      'Bir afetzede tehlikede olduğunu bildirdi. Canlı Akış haritasındaki mor pine bakın.';

  @override
  String get teamsSummaryTitle => 'Saha Ekipleri';

  @override
  String get teamsSummarySubtitle => 'Operasyonel takip ve koordinasyon';

  @override
  String teamsSummaryCount(int teams, int members) {
    return '$teams Tim · $members Personel';
  }

  @override
  String get teamTypeSearchRescue => 'Arama Kurtarma';

  @override
  String get teamTypeMedical => 'Sağlık';

  @override
  String get teamTypeFire => 'Yangın';

  @override
  String get teamTypeLogistics => 'Lojistik';

  @override
  String get teamStatusOnDuty => 'GÖREVDE';

  @override
  String get teamStatusAvailable => 'BOŞTA';

  @override
  String teamLeaderWithName(String name) {
    return '$name (Ekip Lideri)';
  }

  @override
  String get teamCurrentTask => 'MEVCUT GÖREV';

  @override
  String get teamOperationStatus => 'OPERASYON DURUMU';

  @override
  String get teamIdleDescription => 'Hazır bekliyor, yeni görev alabilir.';

  @override
  String get teamTaskNotFound => 'Görev kaydı bulunamadı.';

  @override
  String get teamsEmpty => 'Henüz ekip kaydı yok.';

  @override
  String get assignTaskAction => 'Görev Ata';

  @override
  String get updateTaskAction => 'Görev Güncelle';

  @override
  String assignSheetSubtitle(String team) {
    return '$team için açık bir olay seçin.';
  }

  @override
  String get assignNoOpenIncidents => 'Ekip bekleyen açık olay yok.';

  @override
  String get updateSheetCurrent => 'Mevcut durum';

  @override
  String updateSheetNext(String status) {
    return '$status olarak işaretle';
  }

  @override
  String get updateSheetResolvedNote =>
      'Kurtarıldı işaretlenince olay kapanır ve ekip boşa çıkar.';

  @override
  String updateSuccess(String status) {
    return 'Görev güncellendi: $status';
  }

  @override
  String get updateNoActiveTask => 'Bu ekibin aktif görevi bulunamadı.';

  @override
  String get logisticsWarehouseLoadFailed => 'Depolar yüklenemedi.';

  @override
  String get logisticsNoWarehouses => 'Henüz kayıtlı depo bulunmuyor.';

  @override
  String get logisticsInventoryLoadFailed => 'Stok bilgileri alınamadı.';

  @override
  String get logisticsNoFilteredItems => 'Bu filtreye uygun stok bulunamadı.';

  @override
  String get logisticsTitle => 'LOJİSTİK';

  @override
  String get logisticsMissingLocation => 'Depo konumu belirtilmedi';

  @override
  String get logisticsCriticalTitle => 'KRİTİK STOK UYARISI';

  @override
  String get logisticsInventoryTitle => 'DEPO ENVANTER LİSTESİ';

  @override
  String logisticsItemCount(int count) {
    return '$count kalem';
  }

  @override
  String get logisticsAll => 'Tümü';

  @override
  String get logisticsCritical => 'Kritik';

  @override
  String get logisticsMedium => 'Orta';

  @override
  String get logisticsSufficient => 'Yeterli';

  @override
  String get logisticsStockLevel => 'Stok Düzeyi';

  @override
  String get logisticsLoginRequired => 'Stok işlemi için giriş yapmalısınız.';

  @override
  String logisticsCriticalNotification(String itemName) {
    return '$itemName kritik stok seviyesine ulaştı.';
  }

  @override
  String get broadcastButton => 'Tahliye Anonsu';

  @override
  String get broadcastTitle => 'Tahliye Anonsu';

  @override
  String get broadcastMessageLabel => 'Mesaj';

  @override
  String broadcastRadius(String km) {
    return 'Hedef yarıçap: $km km';
  }

  @override
  String get broadcastInfo =>
      'Uygulaması açık olan ve yarıçap içindeki afetzedelere bildirim düşer. Uygulaması kapalı cihazlar için Console → Messaging\'den all_users duyurusu gönderin.';

  @override
  String get broadcastRequired => 'Bu alan zorunludur.';

  @override
  String get broadcastSave => 'Gönder';

  @override
  String get broadcastSaved => 'Tahliye anonsu gönderildi.';

  @override
  String get broadcastSaveFailed => 'Anons gönderilemedi.';

  @override
  String get demoResetConfirmMessage =>
      'Demo ekipleri, depoları, stokları ve toplanma alanları başlangıç hâline getirilecek; eksik olanlar oluşturulacak. Gerçek kayıtlara dokunulmaz.';

  @override
  String demoResetDone(int teams, int warehouses, int items, int points) {
    return 'Demo verisi hazır.\n\nEkip: $teams\nDepo: $warehouses\nStok kalemi: $items\nToplanma alanı: $points';
  }

  @override
  String get demoResetFailed =>
      'Demo verisi sıfırlanamadı. Onaylı yetkili olarak giriş yaptığınızdan ve internetin açık olduğundan emin olun.';

  @override
  String get stockMovementTitle => 'Stok İşlemi';

  @override
  String get stockIn => 'Giriş';

  @override
  String get stockOut => 'Çıkış';

  @override
  String get stockCurrent => 'Mevcut Stok';

  @override
  String get stockQuantity => 'Miktar';

  @override
  String get stockQuantityHint => 'İşlem miktarını girin';

  @override
  String get stockInvalidQuantity => 'Geçerli bir miktar girin.';

  @override
  String get stockInsufficient => 'Yetersiz stok.';

  @override
  String get stockSaveIn => 'Stok Girişi Yap';

  @override
  String get stockSaveOut => 'Stok Çıkışı Yap';

  @override
  String get stockSaveFailed => 'Stok işlemi tamamlanamadı.';

  @override
  String get broadcastTypeEvacuation => 'Acil Tahliye';

  @override
  String get broadcastTypeAftershock => 'Artçı Sarsıntı';

  @override
  String get broadcastCenter => 'Merkez (konumunuz)';

  @override
  String get broadcastLocating => 'Konum alınıyor…';

  @override
  String get broadcastLocationUnavailable =>
      'Konum alınamadı. Konum iznini ve GPS\'i kontrol edin.';

  @override
  String get broadcastRetryLocation => 'Konumu yeniden al';

  @override
  String broadcastRadiusShort(String km) {
    return '$km km';
  }

  @override
  String get broadcastQueued =>
      'İnternet yok; anons bağlantı gelince gönderilecek.';
}
