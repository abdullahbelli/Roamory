// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Roamory';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navExplore => 'Keşfet';

  @override
  String get navMap => 'Haritam';

  @override
  String get navCommunity => 'Topluluk';

  @override
  String get navProfile => 'Profil';

  @override
  String get commonRetry => 'Tekrar Dene';

  @override
  String get commonCancel => 'Vazgeç';

  @override
  String get commonConfirm => 'Onayla';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonLoading => 'Yükleniyor...';

  @override
  String get commonOfflineNotice => 'İnternet bağlantısı şu anda kurulamıyor';

  @override
  String get errorGenericTitle => 'Bir sorun oluştu';

  @override
  String get errorGenericMessage =>
      'İşlem tamamlanamadı. Lütfen daha sonra tekrar deneyin.';

  @override
  String get errorNetworkTitle => 'Bağlantı Hatası';

  @override
  String get errorNetworkMessage =>
      'İnternet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get errorUnauthorizedMessage =>
      'Bu işlem için oturum açmanız veya yetkiniz olması gerekiyor.';

  @override
  String get errorNotFoundMessage => 'Aradığınız kayıt bulunamadı.';

  @override
  String get errorValidationMessage =>
      'Lütfen girdiğiniz bilgileri kontrol edin.';

  @override
  String get errorSupabaseNotConfigured =>
      'Supabase bağlantı bilgileri yapılandırılmamış.';

  @override
  String get emptyDefaultTitle => 'Henüz kayıt yok';

  @override
  String get emptyDefaultMessage =>
      'Burada görüntülenecek bir içerik henüz eklenmedi.';

  @override
  String get confirmUnsavedTitle => 'Kaydedilmemiş Değişiklikler';

  @override
  String get confirmUnsavedMessage =>
      'Yaptığınız değişiklikler henüz kaydedilmedi. Çıkmak istediğinize emin misiniz?';

  @override
  String get confirmDiscardAction => 'Değişiklikleri At';

  @override
  String get confirmKeepEditingAction => 'Düzenlemeye Dön';

  @override
  String get authLoginTitle => 'Giriş Yap';

  @override
  String get authOnboardingTitle => 'Hoş Geldiniz';

  @override
  String get homeComingSoonSubtitle =>
      'Kişisel seyahat özetiniz ve yaklaşan rotalarınız burada görünecek.';

  @override
  String get exploreComingSoonSubtitle =>
      'Yeni destinasyonlar, kategoriler ve istek listeniz burada yer alacak.';

  @override
  String get mapComingSoonSubtitle =>
      'Ziyaret ettiğiniz ve planladığınız noktalar haritada gösterilecek.';

  @override
  String get communityComingSoonSubtitle =>
      'Gezginlerin paylaştığı gerçek rotalar ve hikayeler burada yer alacak.';

  @override
  String get profileComingSoonSubtitle =>
      'Profiliniz, ziyaretleriniz, seyahatleriniz ve ayarlarınız burada yer alacak.';

  @override
  String get tripsTitle => 'Seyahatlerim';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsLanguageLabel => 'Dil';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get splashBadge => 'Saha Günlüğü & Rota Rehberi';

  @override
  String get splashTagline => 'Keşfet. Hatırla. Paylaş.';

  @override
  String get splashSubtitle => 'Bilinçli gezginler için özenle tasarlandı';

  @override
  String get splashCheckingSession => 'Oturum kontrol ediliyor...';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingContinue => 'Devam Et';

  @override
  String get onboardingStart => 'Başla';

  @override
  String get onboardingAlreadyHaveAccount => 'Zaten hesabın var mı?';

  @override
  String get onboardingSignInLink => 'Giriş Yap';

  @override
  String get onboardingTagExplore => 'Keşfet';

  @override
  String get onboardingTagMemories => 'Anılar';

  @override
  String get onboardingTagRoutes => 'Rotalar';

  @override
  String get onboardingStep1Title => 'Dünyayı Kendi Ritminle Keşfet';

  @override
  String get onboardingStep1Body =>
      'Gizli koylar, dağ patikaları ve yerel lezzetler parmaklarının ucunda.';

  @override
  String get onboardingStep1CardTitle => 'Keşfedilmemiş Doğal Rotalar';

  @override
  String get onboardingStep1CardSubtitle =>
      'Sessiz patikalar ve gizli vadiler seni bekliyor';

  @override
  String get onboardingStep2Title => 'Anılarını Özel Günlüğünde Sakla';

  @override
  String get onboardingStep2Body =>
      'Her ziyaretin fotoğraflarını, puanlarını ve notlarını güvenle arşivle.';

  @override
  String get onboardingStep2CardTitle => 'Kişisel Saha Günlüğü';

  @override
  String get onboardingStep2CardSubtitle =>
      'Tüm kayıtların varsayılan olarak yalnızca sana özeldir';

  @override
  String get onboardingStep3Title => 'Gün Gün Seyahatlerini Planla';

  @override
  String get onboardingStep3Body =>
      'Duraklarını sırala, kontrol listeni hazırla ve dilediğin an toplulukla paylaş.';

  @override
  String get onboardingStep3CardTitle => 'Akıllı Rota Planlayıcı';

  @override
  String get onboardingStep3CardSubtitle =>
      'İstek listenden gerçek seyahat planlarına geç';

  @override
  String get loginBadge => 'Yolculuk Günlüğü';

  @override
  String get loginHeadline => 'Tekrar Hoş Geldin';

  @override
  String get loginSubheadline =>
      'Seyahat rotalarına ve anılarına kaldığın yerden devam et.';

  @override
  String get loginGoogleButton => 'Google ile Devam Et';

  @override
  String get loginOrDivider => 'veya e-posta ile';

  @override
  String get loginEmailLabel => 'E-posta Adresi';

  @override
  String get loginEmailHint => 'ornek@roamory.com';

  @override
  String get loginPasswordLabel => 'Şifre';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginRememberMe => 'Beni Hatırla';

  @override
  String get loginForgotPassword => 'Şifremi Unuttum?';

  @override
  String get loginSubmit => 'Giriş Yap';

  @override
  String get loginSubmitting => 'Giriş Yapılıyor...';

  @override
  String get loginInfoTitle => 'Dijital Pasaportuna Ulaş';

  @override
  String get loginInfoSubtitle =>
      'Ziyaretlerin, rotaların ve seyahat anıların hesabında güvenle saklanır.';

  @override
  String get loginNoAccount => 'Henüz bir Roamory hesabın yok mu?';

  @override
  String get loginCreateAccountLink => 'Kayıt Ol';

  @override
  String get loginSuccessMessage => 'Oturum açıldı, yönlendiriliyorsunuz.';

  @override
  String get registerBadge => 'Yeni Seyahat Günlüğü';

  @override
  String get registerHeadline => 'Aramıza Katıl';

  @override
  String get registerSubheadline =>
      'Keşiflerini kaydet, ilham al ve gezgin topluluğuyla buluş.';

  @override
  String get registerFullNameLabel => 'Ad Soyad';

  @override
  String get registerFullNameHint => 'Deniz Aksoy';

  @override
  String get registerEmailLabel => 'E-posta';

  @override
  String get registerPasswordLabel => 'Şifre';

  @override
  String get registerPasswordRule => 'En az 8 karakter, 1 harf ve 1 rakam';

  @override
  String get registerConfirmPasswordLabel => 'Şifre Tekrarı';

  @override
  String get registerTermsText =>
      'Kullanım Koşulları ve Gizlilik Politikası\'nı okudum, kabul ediyorum.';

  @override
  String get registerSubmit => 'Kayıt Ol';

  @override
  String get registerSubmitting => 'Hesap Oluşturuluyor...';

  @override
  String get registerOrDivider => 'VEYA';

  @override
  String get registerGoogleButton => 'Google ile Kayıt Ol';

  @override
  String get registerSecurityNote => 'Güvenli & Şifrelenmiş Gezgin Günlüğü';

  @override
  String get registerHasAccount => 'Zaten bir hesabın var mı?';

  @override
  String get registerSignInLink => 'Giriş Yap';

  @override
  String get forgotBadge => 'GÜVENLİ SIFIRLAMA';

  @override
  String get forgotHeadline => 'Şifreni mi Unuttun?';

  @override
  String get forgotDescription =>
      'Endişelenme! Hesabına kayıtlı e-posta adresini gir, sana şifreni güvenle sıfırlayabileceğin tek kullanımlık bir bağlantı gönderelim.';

  @override
  String get forgotEmailHelper => 'Roamory seyahat günlüğüne bağlı e-posta';

  @override
  String get forgotSubmit => 'Şifre Sıfırlama Bağlantısı Gönder';

  @override
  String get forgotSentBannerTitle => 'Sıfırlama bağlantısı gönderildi!';

  @override
  String forgotSentBannerBody(String email) {
    return '$email adresini ve gereksiz (spam) kutunu kontrol etmeyi unutma.';
  }

  @override
  String get forgotDidNotReceive => 'E-posta gelmedi mi?';

  @override
  String get forgotResend => 'Tekrar Gönder';

  @override
  String forgotResendCooldown(int seconds) {
    return 'Tekrar Gönder (${seconds}s)';
  }

  @override
  String get forgotBackToLogin => 'Giriş Ekranına Dön';

  @override
  String get forgotSmtpNotice =>
      'Not: Özel SMTP/alan adı henüz yapılandırılmadığı için e-posta gönderimleri Supabase varsayılan kota sınırlarına tabidir.';

  @override
  String get verifyStepBadge => 'ADIM 2 / 2';

  @override
  String get verifyHeadline => 'E-postanı Doğrula';

  @override
  String get verifyDescription =>
      'Aramıza katılmana bir adım kaldı! E-posta adresine gönderilen doğrulama bağlantısını onayla veya 6 haneli kodu gir:';

  @override
  String get verifySentAddressLabel => 'Gönderilen Adres';

  @override
  String get verifyChangeEmail => 'Değiştir';

  @override
  String get verifyCodeLabel => 'Güvenlik Kodunu Girin';

  @override
  String get verifyEncryptedBadge => 'Uçtan Uca Şifreli';

  @override
  String get verifyCheckButton => 'Doğrulamayı Kontrol Et';

  @override
  String get verifyNotConfirmedYet =>
      'E-posta doğrulaması henüz tamamlanmadı. Gelen kutunuzdaki bağlantıya tıklayın veya 6 haneli kodu girin.';

  @override
  String get verifyNoCodePrompt => 'Kod ulaşmadı mı?';

  @override
  String get verifyResendButton => 'E-postayı Tekrar Gönder';

  @override
  String get verifySpamHint =>
      'Gelen kutusuyla birlikte spam klasörünüzü kontrol ediniz.';

  @override
  String get verifyResentSuccess => 'Doğrulama e-postası yeniden gönderildi.';

  @override
  String get verifyBackToLogin => 'Giriş Ekranına Dön';

  @override
  String get profileSetupHeader => 'Adım 2 / 2 • Profil Kurulumu';

  @override
  String get profileSetupSkip => 'Şimdilik Atla';

  @override
  String get profileSetupBadge => 'YENİ YOLCULUK';

  @override
  String get profileSetupHeadline => 'Gezgin Kimliğini Oluştur';

  @override
  String get profileSetupDescription =>
      'Sana özel rota önerileri ve ilham verici seyahat anıları için profilini kişiselleştir.';

  @override
  String get profileSetupAddPhoto => 'Fotoğraf Ekle';

  @override
  String get profileSetupDisplayNameLabel => 'Görünen Ad';

  @override
  String get profileSetupDisplayNameHint => 'Deniz Aksoy';

  @override
  String get profileSetupUsernameLabel => 'Benzersiz Kullanıcı Adı';

  @override
  String get profileSetupUsernameHint => 'deniz_aksoy';

  @override
  String get profileSetupUsernameAvailable => 'Kullanılabilir';

  @override
  String get profileSetupUsernameTaken => 'Bu kullanıcı adı kullanımda';

  @override
  String get profileSetupUsernameInvalid =>
      '3-24 karakter, küçük harf, rakam veya alt çizgi kullanın';

  @override
  String get profileSetupBioLabel => 'Biyografi (İsteğe Bağlı)';

  @override
  String get profileSetupBioHint =>
      'Seyahat tarzından, sevdiğin patikalardan veya hayalindeki rotalardan bahset...';

  @override
  String get profileSetupInterestsTitle => 'Seyahat İlgi Alanları';

  @override
  String get profileSetupInterestsSubtitle =>
      'Haritanda görmek istediğin deneyim türlerini belirle.';

  @override
  String get profileSetupInterestsHint => 'En az 3 seçim önerilir';

  @override
  String get profileSetupLanguageTitle => 'Uygulama Dili';

  @override
  String get profileSetupLanguageTr => 'Türkçe (Varsayılan)';

  @override
  String get profileSetupLanguageEn => 'English';

  @override
  String get profileSetupSubmit => 'Roamory\'yi Keşfet';

  @override
  String get profileSetupFooterTerms =>
      'Kurulumu tamamlayarak Seyahat İlkeleri & Koşullarını kabul etmiş olursun.';

  @override
  String get profileSetupRequiredBeforeApp =>
      'Devam etmeden önce görünen ad ve geçerli bir kullanıcı adı belirlemelisiniz.';

  @override
  String get profileSetupAvatarSizeError =>
      'Profil fotoğrafı en fazla 5 MB olabilir.';

  @override
  String get interestNature => 'Doğa';

  @override
  String get interestCamping => 'Kamp';

  @override
  String get interestHistory => 'Tarih';

  @override
  String get interestCulture => 'Kültür';

  @override
  String get interestFood => 'Gastronomi';

  @override
  String get interestCoast => 'Deniz & Sahil';

  @override
  String get interestAdventure => 'Macera';

  @override
  String get interestCity => 'Şehir Gezileri';

  @override
  String get validationEmailInvalid => 'Geçerli bir e-posta adresi girin.';

  @override
  String get validationPasswordWeak =>
      'Şifre en az 8 karakter, 1 harf ve 1 rakam içermelidir.';

  @override
  String get validationPasswordMismatch =>
      'Girilen şifreler birbiriyle eşleşmiyor.';

  @override
  String get validationFullNameInvalid =>
      'Lütfen en az 2 karakterlik ad soyad girin.';

  @override
  String get validationTermsRequired =>
      'Devam etmek için kullanım koşullarını onaylamalısınız.';

  @override
  String get validationOtpInvalid =>
      'Lütfen 6 haneli doğrulama kodunu eksiksiz girin.';

  @override
  String get authSignOut => 'Çıkış Yap';

  @override
  String get authSignOutConfirmTitle => 'Oturumu Kapat';

  @override
  String get authSignOutConfirmMessage =>
      'Hesabınızdan çıkış yapmak istediğinize emin misiniz?';
}
