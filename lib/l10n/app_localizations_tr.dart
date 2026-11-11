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
}
