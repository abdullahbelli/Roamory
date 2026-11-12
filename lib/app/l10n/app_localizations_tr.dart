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

  @override
  String get commonAll => 'Tümü';

  @override
  String get commonEdit => 'Düzenle';

  @override
  String get commonAdd => 'Ekle';

  @override
  String get commonApply => 'Uygula';

  @override
  String get commonReset => 'Sıfırla';

  @override
  String get commonSeeAll => 'Tümünü Gör';

  @override
  String get commonSearch => 'Ara';

  @override
  String get commonShare => 'Paylaş';

  @override
  String get commonPrivateBadge => 'Özel Günlük';

  @override
  String get commonPublicBadge => 'Herkese Açık';

  @override
  String get commonDraftBadge => 'Taslak';

  @override
  String get commonSavedSuccess => 'Başarıyla kaydedildi.';

  @override
  String get commonDeletedSuccess => 'Kayıt silindi.';

  @override
  String get commonOptional => 'İsteğe Bağlı';

  @override
  String get commonYes => 'Evet';

  @override
  String get commonNo => 'Hayır';

  @override
  String get homeGreetingPrefix => 'Merhaba,';

  @override
  String get homeGreetingSubtitle =>
      'Bugün hangi rotayı keşfetmek veya kaydetmek istersin?';

  @override
  String get homePassportBadge => 'DİJİTAL PASAPORT ÖZETİ';

  @override
  String get homePassportTitle => 'Seyahat İzin';

  @override
  String get homePassportCountries => 'Ülke';

  @override
  String get homePassportCities => 'Şehir';

  @override
  String get homePassportVisits => 'Ziyaret';

  @override
  String get homePassportWishlist => 'İstek Listesi';

  @override
  String get homeQuickAddVisit => 'Ziyaret Ekle';

  @override
  String get homeQuickPlanTrip => 'Rota Planla';

  @override
  String get homeQuickMyJournal => 'Günlüğüm';

  @override
  String get homeQuickWishlist => 'Kaydedilenler';

  @override
  String get homeUpcomingTripTitle => 'Yaklaşan Seyahat';

  @override
  String get homeUpcomingTripEmpty =>
      'Henüz planlanmış aktif bir seyahatin yok.';

  @override
  String get homeFeaturedTitle => 'Öne Çıkan Rotalar';

  @override
  String get homeRecentMemoriesTitle => 'Son Ziyaret Anıların';

  @override
  String get homeRecentMemoriesEmpty =>
      'Henüz bir ziyaret kaydı eklemedin. İlk anını kaydet!';

  @override
  String get homeCommunityHighlightTitle => 'Topluluktan İlham Al';

  @override
  String get homeCommunityHighlightEmpty =>
      'Toplulukta henüz yayınlanmış gönderi yok.';

  @override
  String get exploreHeaderBadge => 'ROAMORY REHBERİ';

  @override
  String get exploreSearchHint => 'Ülke, şehir veya mekan ara...';

  @override
  String get exploreFilterButton => 'Filtrele';

  @override
  String get exploreWishlistButton => 'İstek Listem';

  @override
  String get exploreViewMap => 'Haritada Gör';

  @override
  String get exploreViewList => 'Liste Görünümü';

  @override
  String get exploreFeaturedBadge => 'SEÇKİN ROTA';

  @override
  String get exploreTrendingTitle => 'Keşfedilmeye Değer Mekanlar';

  @override
  String get exploreCuratedTitle => 'Kategorilere Göre Öneriler';

  @override
  String get exploreEmptyTitle => 'Henüz katalog mekanı bulunamadı';

  @override
  String get exploreEmptyMessage =>
      'Veritabanında yayınlanmış mekan kaydı yok veya arama kriterlerinize uygun sonuç bulunamadı. Kendi özel mekanınızı harita veya ziyaret ekranından ekleyebilirsiniz.';

  @override
  String get searchTitle => 'Arama ve Filtreler';

  @override
  String get searchCountryLabel => 'Ülke';

  @override
  String get searchCountryHint => 'Örn: Türkiye, İtalya';

  @override
  String get searchCityLabel => 'Şehir';

  @override
  String get searchCityHint => 'Örn: İzmir, Kyoto';

  @override
  String get searchCategoryLabel => 'Kategori';

  @override
  String get searchMinRatingLabel => 'Minimum Puan';

  @override
  String get searchSortLabel => 'Sıralama';

  @override
  String get searchSortNewest => 'En Yeni';

  @override
  String get searchSortAlphabetical => 'İsme Göre (A-Z)';

  @override
  String searchResultsCount(int count) {
    return '$count mekan bulundu';
  }

  @override
  String get searchClearFilters => 'Filtreleri Temizle';

  @override
  String get placeDetailsStoryTitle => 'Mekan Hikayesi';

  @override
  String get placeDetailsCoordinatesTitle => 'Konum & Harita';

  @override
  String get placeDetailsCommunityTitle => 'Gezgin Paylaşımları';

  @override
  String get placeDetailsCommunityEmpty =>
      'Bu mekan için henüz topluluk gönderisi paylaşılmamış.';

  @override
  String get placeDetailsActionWishlistAdd => 'İstek Listeme Ekle';

  @override
  String get placeDetailsActionWishlistRemove => 'İstek Listemde';

  @override
  String get placeDetailsActionAddToTrip => 'Rotaya Ekle';

  @override
  String get placeDetailsActionMarkVisited => 'Gittim / Günlüğe Ekle';

  @override
  String get placeDetailsPrivateNotice =>
      'Bu mekan kişisel haritanız için özel olarak oluşturuldu.';

  @override
  String get wishlistTitle => 'İstek Listem';

  @override
  String wishlistSubtitle(int count) {
    return '$count kaydedilen destinasyon';
  }

  @override
  String get wishlistEmptyTitle => 'İstek listen henüz boş';

  @override
  String get wishlistEmptyMessage =>
      'Keşfet ekranından gitmek istediğin koyları, şehirleri ve kültür duraklarını buraya kaydedebilirsin.';

  @override
  String get wishlistExploreCta => 'Keşfetmeye Başla';

  @override
  String get wishlistNoteHint => 'Kısa not (örn: Baharda gidilecek)';

  @override
  String get wishlistAddToTrip => 'Rotaya Dahil Et';

  @override
  String get wishlistRemoveConfirmTitle => 'İstek Listesinden Çıkar';

  @override
  String get wishlistRemoveConfirmMessage =>
      'Bu mekanı istek listenizden kaldırmak istediğinize emin misiniz?';

  @override
  String get mapAttribution => '© OpenStreetMap katkıda bulunanlar';

  @override
  String mapStatsPill(int visits, int wishlist) {
    return '$visits Ziyaret • $wishlist İstek Listesi';
  }

  @override
  String get mapFilterButton => 'Harita Filtresi';

  @override
  String get mapHistoryButton => 'Ziyaret Geçmişi';

  @override
  String get mapAddVisitFab => 'Yeni Ziyaret Ekle';

  @override
  String get mapLegendVisited => 'Ziyaret Edildi';

  @override
  String get mapLegendWishlist => 'İstek Listesi';

  @override
  String get mapLegendCommunity => 'Katalog';

  @override
  String get mapEmptyOverlay =>
      'Haritada gösterilecek kayıt yok. İlk ziyaretini veya istek mekanını ekle!';

  @override
  String get mapFilterLayerTitle => 'Gösterilecek Pinler';

  @override
  String get mapFilterLayerAll => 'Tümü';

  @override
  String get mapFilterLayerVisited => 'Ziyaretlerim';

  @override
  String get mapFilterLayerWishlist => 'İstek Listem';

  @override
  String get mapFilterOnlyFavorites => 'Yalnızca 4+ Yıldızlı Favoriler';

  @override
  String get mapFilterYearLabel => 'Ziyaret Yılı';

  @override
  String get visitsHistoryTitle => 'Ziyaret Geçmişim';

  @override
  String visitsHistorySubtitle(int count) {
    return 'Toplam $count kişisel seyahat kaydı';
  }

  @override
  String get visitsEmptyTitle => 'Henüz ziyaret kaydın yok';

  @override
  String get visitsEmptyMessage =>
      'Gittiğin yerleri, kişisel puanlarını ve fotoğraflarını özel saha günlüğüne kaydetmeye başla.';

  @override
  String get visitAddStep1Title => 'Ziyaret Kaydı (Adım 1 / 2)';

  @override
  String get visitAddSelectPlaceLabel => 'Mekan Seçin veya Yeni Ekleyin';

  @override
  String get visitAddCreateCustomPlace => 'Yeni Özel Mekan Oluştur';

  @override
  String get visitAddPlaceNameLabel => 'Mekan Adı';

  @override
  String get visitAddPlaceNameHint => 'Örn: Kabak Koyu Seyir Noktası';

  @override
  String get visitAddLatitudeLabel => 'Enlem (Latitude)';

  @override
  String get visitAddLongitudeLabel => 'Boylam (Longitude)';

  @override
  String get visitAddDateLabel => 'Ziyaret Tarihi';

  @override
  String get visitAddTodayButton => 'Bugünü Seç';

  @override
  String get visitAddRatingLabel => 'Kişisel Puanın';

  @override
  String get visitAddCategoriesLabel => 'Deneyim Etiketleri';

  @override
  String get visitAddContinueToJournal => 'Günlük Detaylarına Devam Et';

  @override
  String get visitJournalStep2Title => 'Gezi Günlüğü (Adım 2 / 2)';

  @override
  String get visitJournalTitleLabel => 'Anı Başlığı';

  @override
  String get visitJournalTitleHint => 'Örn: Sisli sabaha karşı patika yürüyüşü';

  @override
  String get visitJournalNotesLabel => 'Kişisel Günlük Notları';

  @override
  String get visitJournalNotesHint =>
      'O günkü atmosferi, kokuları, yerel tatları ve unutmak istemediğin detayları yaz...';

  @override
  String get visitJournalPhotosLabel => 'Ziyaret Fotoğrafları (En fazla 10 MB)';

  @override
  String get visitJournalAddPhoto => 'Fotoğraf Yükle';

  @override
  String get visitJournalPrivacyBanner =>
      'Kişisel ziyaretlerin ve günlük notların varsayılan olarak özeldir; iznin olmadan toplulukta paylaşılmaz.';

  @override
  String get visitDetailsTitle => 'Ziyaret Detayı';

  @override
  String get visitDetailsDeleteConfirmTitle => 'Ziyaret Kaydını Sil';

  @override
  String get visitDetailsDeleteConfirmMessage =>
      'Bu ziyareti ve bağlı fotoğraflarını kalıcı olarak silmek istediğinize emin misiniz?';

  @override
  String get visitDetailsConvertToPostTitle => 'Bu Anıyı Toplulukla Paylaş';

  @override
  String get visitDetailsConvertToPostSubtitle =>
      'Özel günlük notların gizli kalır; seçtiğin özetle yeni bir topluluk gönderisi oluşturulur.';

  @override
  String get visitDetailsConvertToPostButton => 'Gönderiye Dönüştür';

  @override
  String get visitDetailsPlanRouteButton => 'Rota Olarak Planla';

  @override
  String get visitValidationPlaceRequired =>
      'Lütfen bir mekan seçin veya yeni mekan adını ve koordinatlarını girin.';

  @override
  String get visitValidationCountryInvalid =>
      'Lütfen geçerli bir ülke adı veya 2 harfli ISO ülke kodu (örn: Türkiye, İtalya, TR, IT) girin.';

  @override
  String get visitValidationCityInvalid =>
      'Lütfen geçerli bir şehir veya bölge adı (en az 2 harf, rakamsız) girin.';

  @override
  String get visitValidationCoordinateInvalid =>
      'Geçerli bir enlem (-90..90) ve boylam (-180..180) değeri girin.';

  @override
  String get visitValidationRatingInvalid => 'Puan 1 ile 5 arasında olmalıdır.';

  @override
  String get visitPhotoSizeError =>
      'Ziyaret fotoğrafı en fazla 10 MB olabilir.';

  @override
  String get tripsTabPlanned => 'Planlanan';

  @override
  String get tripsTabOngoing => 'Devam Eden';

  @override
  String get tripsTabCompleted => 'Tamamlanan';

  @override
  String get tripsCreateButton => 'Yeni Seyahat Planla';

  @override
  String get tripsEmptyTitle => 'Henüz bir seyahat planlamadın';

  @override
  String get tripsEmptyMessage =>
      'İstek listendeki mekanları gün gün rotalara dönüştür, duraklarını sırala ve hazırlık kontrol listeni yönet.';

  @override
  String get tripCreateTitle => 'Seyahat Planı Oluştur';

  @override
  String get tripEditTitle => 'Seyahati Düzenle';

  @override
  String get tripEditPreserveDaysNotice =>
      'Mevcut günleriniz, duraklarınız ve kontrol listeniz korunur; tarih aralığı değiştirildiğinde verileriniz silinmez.';

  @override
  String get tripTitleLabel => 'Seyahat Başlığı';

  @override
  String get tripTitleHint => 'Örn: Likya Yolu & Kaş Rotası';

  @override
  String get tripCountryLabel => 'Hedef Ülke';

  @override
  String get tripCityLabel => 'Hedef Şehir / Bölge';

  @override
  String get tripStartDateLabel => 'Başlangıç Tarihi';

  @override
  String get tripEndDateLabel => 'Bitiş Tarihi';

  @override
  String get tripStatusLabel => 'Durum';

  @override
  String get tripDescriptionLabel => 'Rota Notları';

  @override
  String get tripDescriptionHint =>
      'Bu seyahatin genel amacı, ulaşım notları veya hatırlatmalar...';

  @override
  String get tripValidationTitleRequired => 'Lütfen bir seyahat başlığı girin.';

  @override
  String get tripValidationDateOrder =>
      'Bitiş tarihi başlangıç tarihinden önce olamaz.';

  @override
  String tripDetailsDaysStat(int count) {
    return '$count Gün';
  }

  @override
  String tripDetailsStopsStat(int count) {
    return '$count Durak';
  }

  @override
  String tripDetailsChecklistStat(int done, int total) {
    return '$done/$total Hazırlık';
  }

  @override
  String get tripDetailsItineraryButton => 'Günlük Planı Düzenle';

  @override
  String get tripDetailsChecklistButton => 'Kontrol Listesi';

  @override
  String get tripDetailsDeleteConfirmTitle => 'Seyahat Planını Sil';

  @override
  String get tripDetailsDeleteConfirmMessage =>
      'Bu seyahat planını, tüm günlerini, duraklarını ve kontrol listesini silmek istediğinize emin misiniz?';

  @override
  String get itineraryTitle => 'Günlük Rota Planlayıcı';

  @override
  String itineraryDayLabel(int day) {
    return '$day. Gün';
  }

  @override
  String get itineraryDayNotesHint => 'Bugünün teması veya önemli notu...';

  @override
  String get itineraryAddStopButton => 'Yeni Durak Ekle';

  @override
  String get itineraryStopNoteHint =>
      'Durak notu veya saat aralığı (örn: 10:00 - Kahvaltı)';

  @override
  String get itineraryEmptyStops => 'Bu güne henüz durak eklenmedi.';

  @override
  String get itineraryNoPlacesAvailable =>
      'Durak olarak eklenecek mekan bulunamadı. Önce özel mekan veya ziyaret ekleyebilirsiniz.';

  @override
  String get itineraryAddPrivatePlaceAction => 'Özel Mekan Ekle';

  @override
  String get checklistTitle => 'Seyahat Kontrol Listesi';

  @override
  String get checklistProgressTitle => 'Hazırlık Durumu';

  @override
  String get checklistFilterAll => 'Tümü';

  @override
  String get checklistFilterPending => 'Eksikler';

  @override
  String get checklistFilterCompleted => 'Tamamlananlar';

  @override
  String get checklistCategoryDocs => 'Belgeler & Biletler';

  @override
  String get checklistCategoryGear => 'Kıyafet & Ekipman';

  @override
  String get checklistCategoryHotel => 'Konaklama & Ulaşım';

  @override
  String get checklistCategoryGeneral => 'Genel Hazırlık';

  @override
  String get checklistAddItemHint => 'Yeni kontrol maddesi ekle...';

  @override
  String get checklistEmptyMessage =>
      'Bu seyahat için henüz kontrol listesi maddesi eklenmedi.';

  @override
  String get communityFeedExploreTab => 'Keşfet';

  @override
  String get communityFeedFollowingTab => 'Takip Edilenler';

  @override
  String get communityCreatePostButton => 'Yeni Gönderi';

  @override
  String get communityEmptyExplore =>
      'Henüz toplulukta yayınlanmış bir gönderi yok. İlk hikayeyi sen paylaş!';

  @override
  String get communityEmptyFollowing =>
      'Takip ettiğin gezginlerin henüz paylaşımı yok veya henüz kimseyi takip etmiyorsun.';

  @override
  String get communityLikeAction => 'Beğen';

  @override
  String get communityCommentAction => 'Yorum';

  @override
  String get communitySaveAction => 'Kaydet';

  @override
  String get communityReportAction => 'İçeriği Bildir';

  @override
  String get communityBlockUserAction => 'Kullanıcıyı Engelle';

  @override
  String get communityUnblockUserAction => 'Engeli Kaldır';

  @override
  String get communityFollowAction => 'Takip Et';

  @override
  String get communityFollowingAction => 'Takip Ediliyor';

  @override
  String get postCreateTitle => 'Topluluk Gönderisi Oluştur';

  @override
  String get postCreateTitleLabel => 'Gönderi Başlığı';

  @override
  String get postCreateTitleHint => 'Örn: Kapadokya\'da gün doğumu balonları';

  @override
  String get postCreateCaptionLabel => 'Hikayen & Tavsiyelerin';

  @override
  String get postCreateCaptionHint =>
      'Diğer gezginler için rota ipuçlarını ve deneyimini paylaş...';

  @override
  String get postCreateSelectPlaceLabel => 'İlgili Mekan (İsteğe Bağlı)';

  @override
  String get postCreateLinkVisitLabel => 'Bağlı Ziyaret Kaydı';

  @override
  String get postCreateLinkTripLabel => 'Bağlı Seyahat Planı';

  @override
  String get postCreatePrivacyNotice =>
      'Kişisel günlük notların gizli tutulur; yalnızca burada yazdığın metin ve seçtiğin fotoğraflar yayınlanır.';

  @override
  String get postCreateSaveDraft => 'Taslak Kaydet';

  @override
  String get postCreatePublish => 'Hemen Yayınla';

  @override
  String get postValidationCaptionRequired =>
      'Lütfen paylaşımınız için bir başlık veya açıklama yazın.';

  @override
  String get postDetailsTitle => 'Gönderi Detayı';

  @override
  String get postDetailsDeleteConfirmTitle => 'Gönderiyi Sil';

  @override
  String get postDetailsDeleteConfirmMessage =>
      'Bu topluluk gönderisini silmek istediğinize emin misiniz?';

  @override
  String get commentsTitle => 'Yorumlar';

  @override
  String get commentsEmptyMessage =>
      'Henüz yorum yapılmamış. İlk yorumu sen yaz!';

  @override
  String get commentsInputHint => 'Saygılı bir yorum ekle...';

  @override
  String get commentsSendButton => 'Gönder';

  @override
  String get commentsDeleteConfirmTitle => 'Yorumu Sil';

  @override
  String get commentsDeleteConfirmMessage =>
      'Yorumunuzu silmek istediğinize emin misiniz?';

  @override
  String get reportSheetTitle => 'İçeriği veya Kullanıcıyı Bildir';

  @override
  String get reportReasonSpam => 'Spam veya yanıltıcı içerik';

  @override
  String get reportReasonInappropriate => 'Uygunsuz veya rahatsız edici içerik';

  @override
  String get reportReasonHarassment => 'Taciz veya topluluk kuralları ihlali';

  @override
  String get reportDetailsHint => 'Ek açıklama (isteğe bağlı)';

  @override
  String get reportSubmittedMessage =>
      'Bildiriminiz incelenmek üzere kaydedildi. Teşekkür ederiz.';

  @override
  String get blockConfirmTitle => 'Gezgini Engelle';

  @override
  String get blockConfirmMessage =>
      'Bu kullanıcıyı engellediğinizde birbirinizin gönderilerini ve profilini göremezsiniz, mevcut takip ilişkisi kaldırılır.';

  @override
  String get blockSuccessMessage => 'Kullanıcı engellendi.';

  @override
  String get travelerProfileTitle => 'Gezgin Profili';

  @override
  String get travelerPostsStat => 'Paylaşım';

  @override
  String get travelerFollowersStat => 'Takipçi';

  @override
  String get travelerFollowingStat => 'Takip Edilen';

  @override
  String get followersTitle => 'Takipçiler';

  @override
  String get followingTitle => 'Takip Edilenler';

  @override
  String get followersEmptyMessage => 'Henüz takipçi bulunmuyor.';

  @override
  String get followingEmptyMessage => 'Henüz takip edilen gezgin bulunmuyor.';

  @override
  String get myProfileTitle => 'Profilim';

  @override
  String get myProfileEditButton => 'Profili Düzenle';

  @override
  String get myProfileTabPosts => 'Gönderilerim';

  @override
  String get myProfileTabJournal => 'Özel Günlüğüm';

  @override
  String get myProfileTabTrips => 'Rotalarım';

  @override
  String get myProfileTabSaved => 'Kaydedilen Gönderiler';

  @override
  String get myProfilePassportButton => 'İnteraktif Pasaport Haritam';

  @override
  String get editProfileTitle => 'Profili Düzenle';

  @override
  String get editProfileHomeCityLabel => 'Yaşadığın Şehir';

  @override
  String get editProfileHomeCountryLabel => 'Yaşadığın Ülke';

  @override
  String get editProfilePublicToggleTitle => 'Herkese Açık Gezgin Profili';

  @override
  String get editProfilePublicToggleSubtitle =>
      'Açık olduğunda diğer gezginler profilini ve yayınladığın gönderileri görebilir.';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get notificationsMarkAllRead => 'Tümünü Okundu Say';

  @override
  String get notificationsFilterAll => 'Tümü';

  @override
  String get notificationsFilterFollows => 'Takipçiler';

  @override
  String get notificationsFilterInteractions => 'Etkileşimler';

  @override
  String get notificationsFilterSystem => 'Sistem';

  @override
  String get notificationsEmptyTitle => 'Henüz bildirimin yok';

  @override
  String get notificationsEmptyMessage =>
      'Yeni takipçiler, beğeniler ve yorumlar geldiğinde burada listelenir.';

  @override
  String get settingsAccountSection => 'Hesap ve Güvenlik';

  @override
  String get settingsPreferencesSection => 'Görünüm ve Dil';

  @override
  String get settingsPrivacySection => 'Gizlilik ve Güvenlik';

  @override
  String get settingsBlockedUsersTitle => 'Engellenen Gezginler';

  @override
  String get settingsBlockedUsersEmpty =>
      'Engellediğiniz bir kullanıcı bulunmuyor.';

  @override
  String get settingsAboutSection => 'Hakkında ve Lisanslar';

  @override
  String get settingsOsmAttribution =>
      'Harita verileri © OpenStreetMap katkıda bulunanlar (ODbL) lisansı altındadır.';

  @override
  String get accountSecurityTitle => 'Hesap ve Güvenlik';

  @override
  String get accountSecurityEmailLabel => 'Kayıtlı E-posta';

  @override
  String get accountSecurityChangePasswordTitle => 'Şifre Güncelle';

  @override
  String get accountSecurityNewPasswordLabel => 'Yeni Şifre';

  @override
  String get accountSecurityConfirmPasswordLabel => 'Yeni Şifre Tekrarı';

  @override
  String get accountSecurityUpdatePasswordButton => 'Şifreyi Güncelle';

  @override
  String get accountSecurityPasswordUpdated =>
      'Şifreniz başarıyla güncellendi.';

  @override
  String get accountSecurityDeleteTitle => 'Hesabı ve Verileri Silme Talebi';

  @override
  String get accountSecurityDeleteSubtitle =>
      'Hesabınızı kapatmak tüm özel ziyaretlerinizi, seyahat planlarınızı ve paylaşımlarınızı geri alınamaz biçimde kaldırır.';

  @override
  String get accountSecurityDeleteButton => 'Hesap Silme İşlemini Başlat';

  @override
  String get accountSecurityDeleteConfirmTitle =>
      'Hesabınızı Kapatmak İstediğinize Emin misiniz?';

  @override
  String get accountSecurityDeleteConfirmMessage =>
      'Güvenlik gereği kişisel verileriniz temizlenecek ve oturumunuz kapatılacaktır. Bu işlem geri alınamaz.';

  @override
  String get mapMyLocationTooltip => 'Konumuma Git';

  @override
  String get mapLocationPermissionDenied =>
      'Konum izni reddedildi. Cihaz ayarlarından Roamory için konum izni verebilirsiniz.';

  @override
  String get mapLocationServiceDisabled =>
      'Konum servisi (GPS) kapalı veya şu an cihaz konumu alınamadı.';

  @override
  String get visitAddUseCurrentLocation => 'Mevcut Konumumu Kullan';

  @override
  String get itineraryAddDayButton => '+ Gün Ekle';

  @override
  String get wishlistAddedToTripMessage =>
      'Mekan seçili seyahat gününe eklendi.';

  @override
  String get errorDatabaseTablePermissionMessage =>
      'Oturumunuz açık ancak veritabanında bu tablo için yazma yetkisi (GRANT INSERT) henüz tanımlanmamış.';

  @override
  String get checklistValidationTitleRequired =>
      'Lütfen hazırlık maddesi için bir başlık yazın.';

  @override
  String get checklistValidationInvalidCategory =>
      'Hazırlık maddesi kategorisi veritabanı kuralıyla eşleşmiyor; lütfen kategori kuralını güncelleyin veya farklı bir kategori deneyin.';
}
