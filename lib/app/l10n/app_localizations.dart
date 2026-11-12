import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Roamory'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get navExplore;

  /// No description provided for @navMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritam'**
  String get navMap;

  /// No description provided for @navCommunity.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk'**
  String get navCommunity;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @commonRetry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get commonDelete;

  /// No description provided for @commonBack.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get commonClose;

  /// No description provided for @commonLoading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get commonLoading;

  /// No description provided for @commonOfflineNotice.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı şu anda kurulamıyor'**
  String get commonOfflineNotice;

  /// No description provided for @errorGenericTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericMessage.
  ///
  /// In tr, this message translates to:
  /// **'İşlem tamamlanamadı. Lütfen daha sonra tekrar deneyin.'**
  String get errorGenericMessage;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı Hatası'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkMessage.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantınızı kontrol edip tekrar deneyin.'**
  String get errorNetworkMessage;

  /// No description provided for @errorUnauthorizedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için oturum açmanız veya yetkiniz olması gerekiyor.'**
  String get errorUnauthorizedMessage;

  /// No description provided for @errorNotFoundMessage.
  ///
  /// In tr, this message translates to:
  /// **'Aradığınız kayıt bulunamadı.'**
  String get errorNotFoundMessage;

  /// No description provided for @errorValidationMessage.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen girdiğiniz bilgileri kontrol edin.'**
  String get errorValidationMessage;

  /// No description provided for @errorSupabaseNotConfigured.
  ///
  /// In tr, this message translates to:
  /// **'Supabase bağlantı bilgileri yapılandırılmamış.'**
  String get errorSupabaseNotConfigured;

  /// No description provided for @emptyDefaultTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıt yok'**
  String get emptyDefaultTitle;

  /// No description provided for @emptyDefaultMessage.
  ///
  /// In tr, this message translates to:
  /// **'Burada görüntülenecek bir içerik henüz eklenmedi.'**
  String get emptyDefaultMessage;

  /// No description provided for @confirmUnsavedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilmemiş Değişiklikler'**
  String get confirmUnsavedTitle;

  /// No description provided for @confirmUnsavedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Yaptığınız değişiklikler henüz kaydedilmedi. Çıkmak istediğinize emin misiniz?'**
  String get confirmUnsavedMessage;

  /// No description provided for @confirmDiscardAction.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikleri At'**
  String get confirmDiscardAction;

  /// No description provided for @confirmKeepEditingAction.
  ///
  /// In tr, this message translates to:
  /// **'Düzenlemeye Dön'**
  String get confirmKeepEditingAction;

  /// No description provided for @authLoginTitle.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get authLoginTitle;

  /// No description provided for @authOnboardingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldiniz'**
  String get authOnboardingTitle;

  /// No description provided for @homeComingSoonSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel seyahat özetiniz ve yaklaşan rotalarınız burada görünecek.'**
  String get homeComingSoonSubtitle;

  /// No description provided for @exploreComingSoonSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni destinasyonlar, kategoriler ve istek listeniz burada yer alacak.'**
  String get exploreComingSoonSubtitle;

  /// No description provided for @mapComingSoonSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret ettiğiniz ve planladığınız noktalar haritada gösterilecek.'**
  String get mapComingSoonSubtitle;

  /// No description provided for @communityComingSoonSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gezginlerin paylaştığı gerçek rotalar ve hikayeler burada yer alacak.'**
  String get communityComingSoonSubtitle;

  /// No description provided for @profileComingSoonSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Profiliniz, ziyaretleriniz, seyahatleriniz ve ayarlarınız burada yer alacak.'**
  String get profileComingSoonSubtitle;

  /// No description provided for @tripsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seyahatlerim'**
  String get tripsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get settingsThemeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get themeDark;

  /// No description provided for @splashBadge.
  ///
  /// In tr, this message translates to:
  /// **'Saha Günlüğü & Rota Rehberi'**
  String get splashBadge;

  /// No description provided for @splashTagline.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet. Hatırla. Paylaş.'**
  String get splashTagline;

  /// No description provided for @splashSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bilinçli gezginler için özenle tasarlandı'**
  String get splashSubtitle;

  /// No description provided for @splashCheckingSession.
  ///
  /// In tr, this message translates to:
  /// **'Oturum kontrol ediliyor...'**
  String get splashCheckingSession;

  /// No description provided for @onboardingSkip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get onboardingSkip;

  /// No description provided for @onboardingContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get onboardingContinue;

  /// No description provided for @onboardingStart.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get onboardingStart;

  /// No description provided for @onboardingAlreadyHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı?'**
  String get onboardingAlreadyHaveAccount;

  /// No description provided for @onboardingSignInLink.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get onboardingSignInLink;

  /// No description provided for @onboardingTagExplore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get onboardingTagExplore;

  /// No description provided for @onboardingTagMemories.
  ///
  /// In tr, this message translates to:
  /// **'Anılar'**
  String get onboardingTagMemories;

  /// No description provided for @onboardingTagRoutes.
  ///
  /// In tr, this message translates to:
  /// **'Rotalar'**
  String get onboardingTagRoutes;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In tr, this message translates to:
  /// **'Dünyayı Kendi Ritminle Keşfet'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Body.
  ///
  /// In tr, this message translates to:
  /// **'Gizli koylar, dağ patikaları ve yerel lezzetler parmaklarının ucunda.'**
  String get onboardingStep1Body;

  /// No description provided for @onboardingStep1CardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Keşfedilmemiş Doğal Rotalar'**
  String get onboardingStep1CardTitle;

  /// No description provided for @onboardingStep1CardSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz patikalar ve gizli vadiler seni bekliyor'**
  String get onboardingStep1CardSubtitle;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In tr, this message translates to:
  /// **'Anılarını Özel Günlüğünde Sakla'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Body.
  ///
  /// In tr, this message translates to:
  /// **'Her ziyaretin fotoğraflarını, puanlarını ve notlarını güvenle arşivle.'**
  String get onboardingStep2Body;

  /// No description provided for @onboardingStep2CardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Saha Günlüğü'**
  String get onboardingStep2CardTitle;

  /// No description provided for @onboardingStep2CardSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kayıtların varsayılan olarak yalnızca sana özeldir'**
  String get onboardingStep2CardSubtitle;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In tr, this message translates to:
  /// **'Gün Gün Seyahatlerini Planla'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Body.
  ///
  /// In tr, this message translates to:
  /// **'Duraklarını sırala, kontrol listeni hazırla ve dilediğin an toplulukla paylaş.'**
  String get onboardingStep3Body;

  /// No description provided for @onboardingStep3CardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Rota Planlayıcı'**
  String get onboardingStep3CardTitle;

  /// No description provided for @onboardingStep3CardSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İstek listenden gerçek seyahat planlarına geç'**
  String get onboardingStep3CardSubtitle;

  /// No description provided for @loginBadge.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuk Günlüğü'**
  String get loginBadge;

  /// No description provided for @loginHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Hoş Geldin'**
  String get loginHeadline;

  /// No description provided for @loginSubheadline.
  ///
  /// In tr, this message translates to:
  /// **'Seyahat rotalarına ve anılarına kaldığın yerden devam et.'**
  String get loginSubheadline;

  /// No description provided for @loginGoogleButton.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Devam Et'**
  String get loginGoogleButton;

  /// No description provided for @loginOrDivider.
  ///
  /// In tr, this message translates to:
  /// **'veya e-posta ile'**
  String get loginOrDivider;

  /// No description provided for @loginEmailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Adresi'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In tr, this message translates to:
  /// **'ornek@roamory.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In tr, this message translates to:
  /// **'••••••••'**
  String get loginPasswordHint;

  /// No description provided for @loginRememberMe.
  ///
  /// In tr, this message translates to:
  /// **'Beni Hatırla'**
  String get loginRememberMe;

  /// No description provided for @loginForgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum?'**
  String get loginForgotPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginSubmit;

  /// No description provided for @loginSubmitting.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yapılıyor...'**
  String get loginSubmitting;

  /// No description provided for @loginInfoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dijital Pasaportuna Ulaş'**
  String get loginInfoTitle;

  /// No description provided for @loginInfoSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaretlerin, rotaların ve seyahat anıların hesabında güvenle saklanır.'**
  String get loginInfoSubtitle;

  /// No description provided for @loginNoAccount.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir Roamory hesabın yok mu?'**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccountLink.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get loginCreateAccountLink;

  /// No description provided for @loginSuccessMessage.
  ///
  /// In tr, this message translates to:
  /// **'Oturum açıldı, yönlendiriliyorsunuz.'**
  String get loginSuccessMessage;

  /// No description provided for @registerBadge.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Seyahat Günlüğü'**
  String get registerBadge;

  /// No description provided for @registerHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Aramıza Katıl'**
  String get registerHeadline;

  /// No description provided for @registerSubheadline.
  ///
  /// In tr, this message translates to:
  /// **'Keşiflerini kaydet, ilham al ve gezgin topluluğuyla buluş.'**
  String get registerSubheadline;

  /// No description provided for @registerFullNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get registerFullNameLabel;

  /// No description provided for @registerFullNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Deniz Aksoy'**
  String get registerFullNameHint;

  /// No description provided for @registerEmailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordRule.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter, 1 harf ve 1 rakam'**
  String get registerPasswordRule;

  /// No description provided for @registerConfirmPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrarı'**
  String get registerConfirmPasswordLabel;

  /// No description provided for @registerTermsText.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Koşulları ve Gizlilik Politikası\'nı okudum, kabul ediyorum.'**
  String get registerTermsText;

  /// No description provided for @registerSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get registerSubmit;

  /// No description provided for @registerSubmitting.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluşturuluyor...'**
  String get registerSubmitting;

  /// No description provided for @registerOrDivider.
  ///
  /// In tr, this message translates to:
  /// **'VEYA'**
  String get registerOrDivider;

  /// No description provided for @registerGoogleButton.
  ///
  /// In tr, this message translates to:
  /// **'Google ile Kayıt Ol'**
  String get registerGoogleButton;

  /// No description provided for @registerSecurityNote.
  ///
  /// In tr, this message translates to:
  /// **'Güvenli & Şifrelenmiş Gezgin Günlüğü'**
  String get registerSecurityNote;

  /// No description provided for @registerHasAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten bir hesabın var mı?'**
  String get registerHasAccount;

  /// No description provided for @registerSignInLink.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get registerSignInLink;

  /// No description provided for @forgotBadge.
  ///
  /// In tr, this message translates to:
  /// **'GÜVENLİ SIFIRLAMA'**
  String get forgotBadge;

  /// No description provided for @forgotHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni mi Unuttun?'**
  String get forgotHeadline;

  /// No description provided for @forgotDescription.
  ///
  /// In tr, this message translates to:
  /// **'Endişelenme! Hesabına kayıtlı e-posta adresini gir, sana şifreni güvenle sıfırlayabileceğin tek kullanımlık bir bağlantı gönderelim.'**
  String get forgotDescription;

  /// No description provided for @forgotEmailHelper.
  ///
  /// In tr, this message translates to:
  /// **'Roamory seyahat günlüğüne bağlı e-posta'**
  String get forgotEmailHelper;

  /// No description provided for @forgotSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Sıfırlama Bağlantısı Gönder'**
  String get forgotSubmit;

  /// No description provided for @forgotSentBannerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama bağlantısı gönderildi!'**
  String get forgotSentBannerTitle;

  /// No description provided for @forgotSentBannerBody.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresini ve gereksiz (spam) kutunu kontrol etmeyi unutma.'**
  String forgotSentBannerBody(String email);

  /// No description provided for @forgotDidNotReceive.
  ///
  /// In tr, this message translates to:
  /// **'E-posta gelmedi mi?'**
  String get forgotDidNotReceive;

  /// No description provided for @forgotResend.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Gönder'**
  String get forgotResend;

  /// No description provided for @forgotResendCooldown.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Gönder ({seconds}s)'**
  String forgotResendCooldown(int seconds);

  /// No description provided for @forgotBackToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Ekranına Dön'**
  String get forgotBackToLogin;

  /// No description provided for @forgotSmtpNotice.
  ///
  /// In tr, this message translates to:
  /// **'Not: Özel SMTP/alan adı henüz yapılandırılmadığı için e-posta gönderimleri Supabase varsayılan kota sınırlarına tabidir.'**
  String get forgotSmtpNotice;

  /// No description provided for @verifyStepBadge.
  ///
  /// In tr, this message translates to:
  /// **'ADIM 2 / 2'**
  String get verifyStepBadge;

  /// No description provided for @verifyHeadline.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı Doğrula'**
  String get verifyHeadline;

  /// No description provided for @verifyDescription.
  ///
  /// In tr, this message translates to:
  /// **'Aramıza katılmana bir adım kaldı! E-posta adresine gönderilen doğrulama bağlantısını onayla veya 6 haneli kodu gir:'**
  String get verifyDescription;

  /// No description provided for @verifySentAddressLabel.
  ///
  /// In tr, this message translates to:
  /// **'Gönderilen Adres'**
  String get verifySentAddressLabel;

  /// No description provided for @verifyChangeEmail.
  ///
  /// In tr, this message translates to:
  /// **'Değiştir'**
  String get verifyChangeEmail;

  /// No description provided for @verifyCodeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik Kodunu Girin'**
  String get verifyCodeLabel;

  /// No description provided for @verifyEncryptedBadge.
  ///
  /// In tr, this message translates to:
  /// **'Uçtan Uca Şifreli'**
  String get verifyEncryptedBadge;

  /// No description provided for @verifyCheckButton.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulamayı Kontrol Et'**
  String get verifyCheckButton;

  /// No description provided for @verifyNotConfirmedYet.
  ///
  /// In tr, this message translates to:
  /// **'E-posta doğrulaması henüz tamamlanmadı. Gelen kutunuzdaki bağlantıya tıklayın veya 6 haneli kodu girin.'**
  String get verifyNotConfirmedYet;

  /// No description provided for @verifyNoCodePrompt.
  ///
  /// In tr, this message translates to:
  /// **'Kod ulaşmadı mı?'**
  String get verifyNoCodePrompt;

  /// No description provided for @verifyResendButton.
  ///
  /// In tr, this message translates to:
  /// **'E-postayı Tekrar Gönder'**
  String get verifyResendButton;

  /// No description provided for @verifySpamHint.
  ///
  /// In tr, this message translates to:
  /// **'Gelen kutusuyla birlikte spam klasörünüzü kontrol ediniz.'**
  String get verifySpamHint;

  /// No description provided for @verifyResentSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Doğrulama e-postası yeniden gönderildi.'**
  String get verifyResentSuccess;

  /// No description provided for @verifyBackToLogin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Ekranına Dön'**
  String get verifyBackToLogin;

  /// No description provided for @profileSetupHeader.
  ///
  /// In tr, this message translates to:
  /// **'Adım 2 / 2 • Profil Kurulumu'**
  String get profileSetupHeader;

  /// No description provided for @profileSetupSkip.
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik Atla'**
  String get profileSetupSkip;

  /// No description provided for @profileSetupBadge.
  ///
  /// In tr, this message translates to:
  /// **'YENİ YOLCULUK'**
  String get profileSetupBadge;

  /// No description provided for @profileSetupHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Gezgin Kimliğini Oluştur'**
  String get profileSetupHeadline;

  /// No description provided for @profileSetupDescription.
  ///
  /// In tr, this message translates to:
  /// **'Sana özel rota önerileri ve ilham verici seyahat anıları için profilini kişiselleştir.'**
  String get profileSetupDescription;

  /// No description provided for @profileSetupAddPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Ekle'**
  String get profileSetupAddPhoto;

  /// No description provided for @profileSetupDisplayNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Görünen Ad'**
  String get profileSetupDisplayNameLabel;

  /// No description provided for @profileSetupDisplayNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Deniz Aksoy'**
  String get profileSetupDisplayNameHint;

  /// No description provided for @profileSetupUsernameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Benzersiz Kullanıcı Adı'**
  String get profileSetupUsernameLabel;

  /// No description provided for @profileSetupUsernameHint.
  ///
  /// In tr, this message translates to:
  /// **'deniz_aksoy'**
  String get profileSetupUsernameHint;

  /// No description provided for @profileSetupUsernameAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Kullanılabilir'**
  String get profileSetupUsernameAvailable;

  /// No description provided for @profileSetupUsernameTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcı adı kullanımda'**
  String get profileSetupUsernameTaken;

  /// No description provided for @profileSetupUsernameInvalid.
  ///
  /// In tr, this message translates to:
  /// **'3-24 karakter, küçük harf, rakam veya alt çizgi kullanın'**
  String get profileSetupUsernameInvalid;

  /// No description provided for @profileSetupBioLabel.
  ///
  /// In tr, this message translates to:
  /// **'Biyografi (İsteğe Bağlı)'**
  String get profileSetupBioLabel;

  /// No description provided for @profileSetupBioHint.
  ///
  /// In tr, this message translates to:
  /// **'Seyahat tarzından, sevdiğin patikalardan veya hayalindeki rotalardan bahset...'**
  String get profileSetupBioHint;

  /// No description provided for @profileSetupInterestsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seyahat İlgi Alanları'**
  String get profileSetupInterestsTitle;

  /// No description provided for @profileSetupInterestsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Haritanda görmek istediğin deneyim türlerini belirle.'**
  String get profileSetupInterestsSubtitle;

  /// No description provided for @profileSetupInterestsHint.
  ///
  /// In tr, this message translates to:
  /// **'En az 3 seçim önerilir'**
  String get profileSetupInterestsHint;

  /// No description provided for @profileSetupLanguageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Dili'**
  String get profileSetupLanguageTitle;

  /// No description provided for @profileSetupLanguageTr.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe (Varsayılan)'**
  String get profileSetupLanguageTr;

  /// No description provided for @profileSetupLanguageEn.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get profileSetupLanguageEn;

  /// No description provided for @profileSetupSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Roamory\'yi Keşfet'**
  String get profileSetupSubmit;

  /// No description provided for @profileSetupFooterTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kurulumu tamamlayarak Seyahat İlkeleri & Koşullarını kabul etmiş olursun.'**
  String get profileSetupFooterTerms;

  /// No description provided for @profileSetupRequiredBeforeApp.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmeden önce görünen ad ve geçerli bir kullanıcı adı belirlemelisiniz.'**
  String get profileSetupRequiredBeforeApp;

  /// No description provided for @profileSetupAvatarSizeError.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı en fazla 5 MB olabilir.'**
  String get profileSetupAvatarSizeError;

  /// No description provided for @interestNature.
  ///
  /// In tr, this message translates to:
  /// **'Doğa'**
  String get interestNature;

  /// No description provided for @interestCamping.
  ///
  /// In tr, this message translates to:
  /// **'Kamp'**
  String get interestCamping;

  /// No description provided for @interestHistory.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get interestHistory;

  /// No description provided for @interestCulture.
  ///
  /// In tr, this message translates to:
  /// **'Kültür'**
  String get interestCulture;

  /// No description provided for @interestFood.
  ///
  /// In tr, this message translates to:
  /// **'Gastronomi'**
  String get interestFood;

  /// No description provided for @interestCoast.
  ///
  /// In tr, this message translates to:
  /// **'Deniz & Sahil'**
  String get interestCoast;

  /// No description provided for @interestAdventure.
  ///
  /// In tr, this message translates to:
  /// **'Macera'**
  String get interestAdventure;

  /// No description provided for @interestCity.
  ///
  /// In tr, this message translates to:
  /// **'Şehir Gezileri'**
  String get interestCity;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi girin.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordWeak.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az 8 karakter, 1 harf ve 1 rakam içermelidir.'**
  String get validationPasswordWeak;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Girilen şifreler birbiriyle eşleşmiyor.'**
  String get validationPasswordMismatch;

  /// No description provided for @validationFullNameInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen en az 2 karakterlik ad soyad girin.'**
  String get validationFullNameInvalid;

  /// No description provided for @validationTermsRequired.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için kullanım koşullarını onaylamalısınız.'**
  String get validationTermsRequired;

  /// No description provided for @validationOtpInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen 6 haneli doğrulama kodunu eksiksiz girin.'**
  String get validationOtpInvalid;

  /// No description provided for @authSignOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get authSignOut;

  /// No description provided for @authSignOutConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Oturumu Kapat'**
  String get authSignOutConfirmTitle;

  /// No description provided for @authSignOutConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızdan çıkış yapmak istediğinize emin misiniz?'**
  String get authSignOutConfirmMessage;

  /// No description provided for @commonAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get commonAll;

  /// No description provided for @commonEdit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get commonEdit;

  /// No description provided for @commonAdd.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get commonAdd;

  /// No description provided for @commonApply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get commonApply;

  /// No description provided for @commonReset.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get commonReset;

  /// No description provided for @commonSeeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Gör'**
  String get commonSeeAll;

  /// No description provided for @commonSearch.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get commonSearch;

  /// No description provided for @commonShare.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get commonShare;

  /// No description provided for @commonPrivateBadge.
  ///
  /// In tr, this message translates to:
  /// **'Özel Günlük'**
  String get commonPrivateBadge;

  /// No description provided for @commonPublicBadge.
  ///
  /// In tr, this message translates to:
  /// **'Herkese Açık'**
  String get commonPublicBadge;

  /// No description provided for @commonDraftBadge.
  ///
  /// In tr, this message translates to:
  /// **'Taslak'**
  String get commonDraftBadge;

  /// No description provided for @commonSavedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Başarıyla kaydedildi.'**
  String get commonSavedSuccess;

  /// No description provided for @commonDeletedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt silindi.'**
  String get commonDeletedSuccess;

  /// No description provided for @commonOptional.
  ///
  /// In tr, this message translates to:
  /// **'İsteğe Bağlı'**
  String get commonOptional;

  /// No description provided for @commonYes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get commonNo;

  /// No description provided for @homeGreetingPrefix.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba,'**
  String get homeGreetingPrefix;

  /// No description provided for @homeGreetingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugün hangi rotayı keşfetmek veya kaydetmek istersin?'**
  String get homeGreetingSubtitle;

  /// No description provided for @homePassportBadge.
  ///
  /// In tr, this message translates to:
  /// **'DİJİTAL PASAPORT ÖZETİ'**
  String get homePassportBadge;

  /// No description provided for @homePassportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seyahat İzin'**
  String get homePassportTitle;

  /// No description provided for @homePassportCountries.
  ///
  /// In tr, this message translates to:
  /// **'Ülke'**
  String get homePassportCountries;

  /// No description provided for @homePassportCities.
  ///
  /// In tr, this message translates to:
  /// **'Şehir'**
  String get homePassportCities;

  /// No description provided for @homePassportVisits.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret'**
  String get homePassportVisits;

  /// No description provided for @homePassportWishlist.
  ///
  /// In tr, this message translates to:
  /// **'İstek Listesi'**
  String get homePassportWishlist;

  /// No description provided for @homeQuickAddVisit.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret Ekle'**
  String get homeQuickAddVisit;

  /// No description provided for @homeQuickPlanTrip.
  ///
  /// In tr, this message translates to:
  /// **'Rota Planla'**
  String get homeQuickPlanTrip;

  /// No description provided for @homeQuickMyJournal.
  ///
  /// In tr, this message translates to:
  /// **'Günlüğüm'**
  String get homeQuickMyJournal;

  /// No description provided for @homeQuickWishlist.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get homeQuickWishlist;

  /// No description provided for @homeUpcomingTripTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan Seyahat'**
  String get homeUpcomingTripTitle;

  /// No description provided for @homeUpcomingTripEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz planlanmış aktif bir seyahatin yok.'**
  String get homeUpcomingTripEmpty;

  /// No description provided for @homeFeaturedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Öne Çıkan Rotalar'**
  String get homeFeaturedTitle;

  /// No description provided for @homeRecentMemoriesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Son Ziyaret Anıların'**
  String get homeRecentMemoriesTitle;

  /// No description provided for @homeRecentMemoriesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir ziyaret kaydı eklemedin. İlk anını kaydet!'**
  String get homeRecentMemoriesEmpty;

  /// No description provided for @homeCommunityHighlightTitle.
  ///
  /// In tr, this message translates to:
  /// **'Topluluktan İlham Al'**
  String get homeCommunityHighlightTitle;

  /// No description provided for @homeCommunityHighlightEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Toplulukta henüz yayınlanmış gönderi yok.'**
  String get homeCommunityHighlightEmpty;

  /// No description provided for @exploreHeaderBadge.
  ///
  /// In tr, this message translates to:
  /// **'ROAMORY REHBERİ'**
  String get exploreHeaderBadge;

  /// No description provided for @exploreSearchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ülke, şehir veya mekan ara...'**
  String get exploreSearchHint;

  /// No description provided for @exploreFilterButton.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get exploreFilterButton;

  /// No description provided for @exploreWishlistButton.
  ///
  /// In tr, this message translates to:
  /// **'İstek Listem'**
  String get exploreWishlistButton;

  /// No description provided for @exploreViewMap.
  ///
  /// In tr, this message translates to:
  /// **'Haritada Gör'**
  String get exploreViewMap;

  /// No description provided for @exploreViewList.
  ///
  /// In tr, this message translates to:
  /// **'Liste Görünümü'**
  String get exploreViewList;

  /// No description provided for @exploreFeaturedBadge.
  ///
  /// In tr, this message translates to:
  /// **'SEÇKİN ROTA'**
  String get exploreFeaturedBadge;

  /// No description provided for @exploreTrendingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Keşfedilmeye Değer Mekanlar'**
  String get exploreTrendingTitle;

  /// No description provided for @exploreCuratedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategorilere Göre Öneriler'**
  String get exploreCuratedTitle;

  /// No description provided for @exploreEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz katalog mekanı bulunamadı'**
  String get exploreEmptyTitle;

  /// No description provided for @exploreEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Veritabanında yayınlanmış mekan kaydı yok veya arama kriterlerinize uygun sonuç bulunamadı. Kendi özel mekanınızı harita veya ziyaret ekranından ekleyebilirsiniz.'**
  String get exploreEmptyMessage;

  /// No description provided for @searchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Arama ve Filtreler'**
  String get searchTitle;

  /// No description provided for @searchCountryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ülke'**
  String get searchCountryLabel;

  /// No description provided for @searchCountryHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Türkiye, İtalya'**
  String get searchCountryHint;

  /// No description provided for @searchCityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şehir'**
  String get searchCityLabel;

  /// No description provided for @searchCityHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: İzmir, Kyoto'**
  String get searchCityHint;

  /// No description provided for @searchCategoryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get searchCategoryLabel;

  /// No description provided for @searchMinRatingLabel.
  ///
  /// In tr, this message translates to:
  /// **'Minimum Puan'**
  String get searchMinRatingLabel;

  /// No description provided for @searchSortLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama'**
  String get searchSortLabel;

  /// No description provided for @searchSortNewest.
  ///
  /// In tr, this message translates to:
  /// **'En Yeni'**
  String get searchSortNewest;

  /// No description provided for @searchSortAlphabetical.
  ///
  /// In tr, this message translates to:
  /// **'İsme Göre (A-Z)'**
  String get searchSortAlphabetical;

  /// No description provided for @searchResultsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} mekan bulundu'**
  String searchResultsCount(int count);

  /// No description provided for @searchClearFilters.
  ///
  /// In tr, this message translates to:
  /// **'Filtreleri Temizle'**
  String get searchClearFilters;

  /// No description provided for @placeDetailsStoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mekan Hikayesi'**
  String get placeDetailsStoryTitle;

  /// No description provided for @placeDetailsCoordinatesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Konum & Harita'**
  String get placeDetailsCoordinatesTitle;

  /// No description provided for @placeDetailsCommunityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gezgin Paylaşımları'**
  String get placeDetailsCommunityTitle;

  /// No description provided for @placeDetailsCommunityEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu mekan için henüz topluluk gönderisi paylaşılmamış.'**
  String get placeDetailsCommunityEmpty;

  /// No description provided for @placeDetailsActionWishlistAdd.
  ///
  /// In tr, this message translates to:
  /// **'İstek Listeme Ekle'**
  String get placeDetailsActionWishlistAdd;

  /// No description provided for @placeDetailsActionWishlistRemove.
  ///
  /// In tr, this message translates to:
  /// **'İstek Listemde'**
  String get placeDetailsActionWishlistRemove;

  /// No description provided for @placeDetailsActionAddToTrip.
  ///
  /// In tr, this message translates to:
  /// **'Rotaya Ekle'**
  String get placeDetailsActionAddToTrip;

  /// No description provided for @placeDetailsActionMarkVisited.
  ///
  /// In tr, this message translates to:
  /// **'Gittim / Günlüğe Ekle'**
  String get placeDetailsActionMarkVisited;

  /// No description provided for @placeDetailsPrivateNotice.
  ///
  /// In tr, this message translates to:
  /// **'Bu mekan kişisel haritanız için özel olarak oluşturuldu.'**
  String get placeDetailsPrivateNotice;

  /// No description provided for @wishlistTitle.
  ///
  /// In tr, this message translates to:
  /// **'İstek Listem'**
  String get wishlistTitle;

  /// No description provided for @wishlistSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{count} kaydedilen destinasyon'**
  String wishlistSubtitle(int count);

  /// No description provided for @wishlistEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'İstek listen henüz boş'**
  String get wishlistEmptyTitle;

  /// No description provided for @wishlistEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet ekranından gitmek istediğin koyları, şehirleri ve kültür duraklarını buraya kaydedebilirsin.'**
  String get wishlistEmptyMessage;

  /// No description provided for @wishlistExploreCta.
  ///
  /// In tr, this message translates to:
  /// **'Keşfetmeye Başla'**
  String get wishlistExploreCta;

  /// No description provided for @wishlistNoteHint.
  ///
  /// In tr, this message translates to:
  /// **'Kısa not (örn: Baharda gidilecek)'**
  String get wishlistNoteHint;

  /// No description provided for @wishlistAddToTrip.
  ///
  /// In tr, this message translates to:
  /// **'Rotaya Dahil Et'**
  String get wishlistAddToTrip;

  /// No description provided for @wishlistRemoveConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'İstek Listesinden Çıkar'**
  String get wishlistRemoveConfirmTitle;

  /// No description provided for @wishlistRemoveConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu mekanı istek listenizden kaldırmak istediğinize emin misiniz?'**
  String get wishlistRemoveConfirmMessage;

  /// No description provided for @mapAttribution.
  ///
  /// In tr, this message translates to:
  /// **'© OpenStreetMap katkıda bulunanlar'**
  String get mapAttribution;

  /// No description provided for @mapStatsPill.
  ///
  /// In tr, this message translates to:
  /// **'{visits} Ziyaret • {wishlist} İstek Listesi'**
  String mapStatsPill(int visits, int wishlist);

  /// No description provided for @mapFilterButton.
  ///
  /// In tr, this message translates to:
  /// **'Harita Filtresi'**
  String get mapFilterButton;

  /// No description provided for @mapHistoryButton.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret Geçmişi'**
  String get mapHistoryButton;

  /// No description provided for @mapAddVisitFab.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Ziyaret Ekle'**
  String get mapAddVisitFab;

  /// No description provided for @mapLegendVisited.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret Edildi'**
  String get mapLegendVisited;

  /// No description provided for @mapLegendWishlist.
  ///
  /// In tr, this message translates to:
  /// **'İstek Listesi'**
  String get mapLegendWishlist;

  /// No description provided for @mapLegendCommunity.
  ///
  /// In tr, this message translates to:
  /// **'Katalog'**
  String get mapLegendCommunity;

  /// No description provided for @mapEmptyOverlay.
  ///
  /// In tr, this message translates to:
  /// **'Haritada gösterilecek kayıt yok. İlk ziyaretini veya istek mekanını ekle!'**
  String get mapEmptyOverlay;

  /// No description provided for @mapFilterLayerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gösterilecek Pinler'**
  String get mapFilterLayerTitle;

  /// No description provided for @mapFilterLayerAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get mapFilterLayerAll;

  /// No description provided for @mapFilterLayerVisited.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaretlerim'**
  String get mapFilterLayerVisited;

  /// No description provided for @mapFilterLayerWishlist.
  ///
  /// In tr, this message translates to:
  /// **'İstek Listem'**
  String get mapFilterLayerWishlist;

  /// No description provided for @mapFilterOnlyFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca 4+ Yıldızlı Favoriler'**
  String get mapFilterOnlyFavorites;

  /// No description provided for @mapFilterYearLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret Yılı'**
  String get mapFilterYearLabel;

  /// No description provided for @visitsHistoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret Geçmişim'**
  String get visitsHistoryTitle;

  /// No description provided for @visitsHistorySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Toplam {count} kişisel seyahat kaydı'**
  String visitsHistorySubtitle(int count);

  /// No description provided for @visitsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz ziyaret kaydın yok'**
  String get visitsEmptyTitle;

  /// No description provided for @visitsEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Gittiğin yerleri, kişisel puanlarını ve fotoğraflarını özel saha günlüğüne kaydetmeye başla.'**
  String get visitsEmptyMessage;

  /// No description provided for @visitAddStep1Title.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret Kaydı (Adım 1 / 2)'**
  String get visitAddStep1Title;

  /// No description provided for @visitAddSelectPlaceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mekan Seçin veya Yeni Ekleyin'**
  String get visitAddSelectPlaceLabel;

  /// No description provided for @visitAddCreateCustomPlace.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Özel Mekan Oluştur'**
  String get visitAddCreateCustomPlace;

  /// No description provided for @visitAddPlaceNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Mekan Adı'**
  String get visitAddPlaceNameLabel;

  /// No description provided for @visitAddPlaceNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Kabak Koyu Seyir Noktası'**
  String get visitAddPlaceNameHint;

  /// No description provided for @visitAddLatitudeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Enlem (Latitude)'**
  String get visitAddLatitudeLabel;

  /// No description provided for @visitAddLongitudeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Boylam (Longitude)'**
  String get visitAddLongitudeLabel;

  /// No description provided for @visitAddDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret Tarihi'**
  String get visitAddDateLabel;

  /// No description provided for @visitAddTodayButton.
  ///
  /// In tr, this message translates to:
  /// **'Bugünü Seç'**
  String get visitAddTodayButton;

  /// No description provided for @visitAddRatingLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Puanın'**
  String get visitAddRatingLabel;

  /// No description provided for @visitAddCategoriesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Deneyim Etiketleri'**
  String get visitAddCategoriesLabel;

  /// No description provided for @visitAddContinueToJournal.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Detaylarına Devam Et'**
  String get visitAddContinueToJournal;

  /// No description provided for @visitJournalStep2Title.
  ///
  /// In tr, this message translates to:
  /// **'Gezi Günlüğü (Adım 2 / 2)'**
  String get visitJournalStep2Title;

  /// No description provided for @visitJournalTitleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Anı Başlığı'**
  String get visitJournalTitleLabel;

  /// No description provided for @visitJournalTitleHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Sisli sabaha karşı patika yürüyüşü'**
  String get visitJournalTitleHint;

  /// No description provided for @visitJournalNotesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Günlük Notları'**
  String get visitJournalNotesLabel;

  /// No description provided for @visitJournalNotesHint.
  ///
  /// In tr, this message translates to:
  /// **'O günkü atmosferi, kokuları, yerel tatları ve unutmak istemediğin detayları yaz...'**
  String get visitJournalNotesHint;

  /// No description provided for @visitJournalPhotosLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret Fotoğrafları (En fazla 10 MB)'**
  String get visitJournalPhotosLabel;

  /// No description provided for @visitJournalAddPhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf Yükle'**
  String get visitJournalAddPhoto;

  /// No description provided for @visitJournalPrivacyBanner.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel ziyaretlerin ve günlük notların varsayılan olarak özeldir; iznin olmadan toplulukta paylaşılmaz.'**
  String get visitJournalPrivacyBanner;

  /// No description provided for @visitDetailsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret Detayı'**
  String get visitDetailsTitle;

  /// No description provided for @visitDetailsDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret Kaydını Sil'**
  String get visitDetailsDeleteConfirmTitle;

  /// No description provided for @visitDetailsDeleteConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu ziyareti ve bağlı fotoğraflarını kalıcı olarak silmek istediğinize emin misiniz?'**
  String get visitDetailsDeleteConfirmMessage;

  /// No description provided for @visitDetailsConvertToPostTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu Anıyı Toplulukla Paylaş'**
  String get visitDetailsConvertToPostTitle;

  /// No description provided for @visitDetailsConvertToPostSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Özel günlük notların gizli kalır; seçtiğin özetle yeni bir topluluk gönderisi oluşturulur.'**
  String get visitDetailsConvertToPostSubtitle;

  /// No description provided for @visitDetailsConvertToPostButton.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiye Dönüştür'**
  String get visitDetailsConvertToPostButton;

  /// No description provided for @visitDetailsPlanRouteButton.
  ///
  /// In tr, this message translates to:
  /// **'Rota Olarak Planla'**
  String get visitDetailsPlanRouteButton;

  /// No description provided for @visitValidationPlaceRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir mekan seçin veya yeni mekan adını ve koordinatlarını girin.'**
  String get visitValidationPlaceRequired;

  /// No description provided for @visitValidationCountryInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir ülke adı veya 2 harfli ISO ülke kodu (örn: Türkiye, İtalya, TR, IT) girin.'**
  String get visitValidationCountryInvalid;

  /// No description provided for @visitValidationCityInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir şehir veya bölge adı (en az 2 harf, rakamsız) girin.'**
  String get visitValidationCityInvalid;

  /// No description provided for @visitValidationCoordinateInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir enlem (-90..90) ve boylam (-180..180) değeri girin.'**
  String get visitValidationCoordinateInvalid;

  /// No description provided for @visitValidationRatingInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Puan 1 ile 5 arasında olmalıdır.'**
  String get visitValidationRatingInvalid;

  /// No description provided for @visitPhotoSizeError.
  ///
  /// In tr, this message translates to:
  /// **'Ziyaret fotoğrafı en fazla 10 MB olabilir.'**
  String get visitPhotoSizeError;

  /// No description provided for @tripsTabPlanned.
  ///
  /// In tr, this message translates to:
  /// **'Planlanan'**
  String get tripsTabPlanned;

  /// No description provided for @tripsTabOngoing.
  ///
  /// In tr, this message translates to:
  /// **'Devam Eden'**
  String get tripsTabOngoing;

  /// No description provided for @tripsTabCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan'**
  String get tripsTabCompleted;

  /// No description provided for @tripsCreateButton.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Seyahat Planla'**
  String get tripsCreateButton;

  /// No description provided for @tripsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir seyahat planlamadın'**
  String get tripsEmptyTitle;

  /// No description provided for @tripsEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'İstek listendeki mekanları gün gün rotalara dönüştür, duraklarını sırala ve hazırlık kontrol listeni yönet.'**
  String get tripsEmptyMessage;

  /// No description provided for @tripCreateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seyahat Planı Oluştur'**
  String get tripCreateTitle;

  /// No description provided for @tripEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seyahati Düzenle'**
  String get tripEditTitle;

  /// No description provided for @tripEditPreserveDaysNotice.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut günleriniz, duraklarınız ve kontrol listeniz korunur; tarih aralığı değiştirildiğinde verileriniz silinmez.'**
  String get tripEditPreserveDaysNotice;

  /// No description provided for @tripTitleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Seyahat Başlığı'**
  String get tripTitleLabel;

  /// No description provided for @tripTitleHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Likya Yolu & Kaş Rotası'**
  String get tripTitleHint;

  /// No description provided for @tripCountryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Ülke'**
  String get tripCountryLabel;

  /// No description provided for @tripCityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Şehir / Bölge'**
  String get tripCityLabel;

  /// No description provided for @tripStartDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Tarihi'**
  String get tripStartDateLabel;

  /// No description provided for @tripEndDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Tarihi'**
  String get tripEndDateLabel;

  /// No description provided for @tripStatusLabel.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get tripStatusLabel;

  /// No description provided for @tripDescriptionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Rota Notları'**
  String get tripDescriptionLabel;

  /// No description provided for @tripDescriptionHint.
  ///
  /// In tr, this message translates to:
  /// **'Bu seyahatin genel amacı, ulaşım notları veya hatırlatmalar...'**
  String get tripDescriptionHint;

  /// No description provided for @tripValidationTitleRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen bir seyahat başlığı girin.'**
  String get tripValidationTitleRequired;

  /// No description provided for @tripValidationDateOrder.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş tarihi başlangıç tarihinden önce olamaz.'**
  String get tripValidationDateOrder;

  /// No description provided for @tripDetailsDaysStat.
  ///
  /// In tr, this message translates to:
  /// **'{count} Gün'**
  String tripDetailsDaysStat(int count);

  /// No description provided for @tripDetailsStopsStat.
  ///
  /// In tr, this message translates to:
  /// **'{count} Durak'**
  String tripDetailsStopsStat(int count);

  /// No description provided for @tripDetailsChecklistStat.
  ///
  /// In tr, this message translates to:
  /// **'{done}/{total} Hazırlık'**
  String tripDetailsChecklistStat(int done, int total);

  /// No description provided for @tripDetailsItineraryButton.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Planı Düzenle'**
  String get tripDetailsItineraryButton;

  /// No description provided for @tripDetailsChecklistButton.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol Listesi'**
  String get tripDetailsChecklistButton;

  /// No description provided for @tripDetailsDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seyahat Planını Sil'**
  String get tripDetailsDeleteConfirmTitle;

  /// No description provided for @tripDetailsDeleteConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu seyahat planını, tüm günlerini, duraklarını ve kontrol listesini silmek istediğinize emin misiniz?'**
  String get tripDetailsDeleteConfirmMessage;

  /// No description provided for @itineraryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Rota Planlayıcı'**
  String get itineraryTitle;

  /// No description provided for @itineraryDayLabel.
  ///
  /// In tr, this message translates to:
  /// **'{day}. Gün'**
  String itineraryDayLabel(int day);

  /// No description provided for @itineraryDayNotesHint.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün teması veya önemli notu...'**
  String get itineraryDayNotesHint;

  /// No description provided for @itineraryAddStopButton.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Durak Ekle'**
  String get itineraryAddStopButton;

  /// No description provided for @itineraryStopNoteHint.
  ///
  /// In tr, this message translates to:
  /// **'Durak notu veya saat aralığı (örn: 10:00 - Kahvaltı)'**
  String get itineraryStopNoteHint;

  /// No description provided for @itineraryEmptyStops.
  ///
  /// In tr, this message translates to:
  /// **'Bu güne henüz durak eklenmedi.'**
  String get itineraryEmptyStops;

  /// No description provided for @itineraryNoPlacesAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Durak olarak eklenecek mekan bulunamadı. Önce özel mekan veya ziyaret ekleyebilirsiniz.'**
  String get itineraryNoPlacesAvailable;

  /// No description provided for @itineraryAddPrivatePlaceAction.
  ///
  /// In tr, this message translates to:
  /// **'Özel Mekan Ekle'**
  String get itineraryAddPrivatePlaceAction;

  /// No description provided for @checklistTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seyahat Kontrol Listesi'**
  String get checklistTitle;

  /// No description provided for @checklistProgressTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hazırlık Durumu'**
  String get checklistProgressTitle;

  /// No description provided for @checklistFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get checklistFilterAll;

  /// No description provided for @checklistFilterPending.
  ///
  /// In tr, this message translates to:
  /// **'Eksikler'**
  String get checklistFilterPending;

  /// No description provided for @checklistFilterCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlananlar'**
  String get checklistFilterCompleted;

  /// No description provided for @checklistCategoryDocs.
  ///
  /// In tr, this message translates to:
  /// **'Belgeler & Biletler'**
  String get checklistCategoryDocs;

  /// No description provided for @checklistCategoryGear.
  ///
  /// In tr, this message translates to:
  /// **'Bavul & Ekipman'**
  String get checklistCategoryGear;

  /// No description provided for @checklistCategoryHotel.
  ///
  /// In tr, this message translates to:
  /// **'Rezervasyonlar'**
  String get checklistCategoryHotel;

  /// No description provided for @checklistCategoryGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Genel Hazırlık'**
  String get checklistCategoryGeneral;

  /// No description provided for @checklistAddItemHint.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kontrol maddesi ekle...'**
  String get checklistAddItemHint;

  /// No description provided for @checklistEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu seyahat için henüz kontrol listesi maddesi eklenmedi.'**
  String get checklistEmptyMessage;

  /// No description provided for @communityFeedExploreTab.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get communityFeedExploreTab;

  /// No description provided for @communityFeedFollowingTab.
  ///
  /// In tr, this message translates to:
  /// **'Takip Edilenler'**
  String get communityFeedFollowingTab;

  /// No description provided for @communityCreatePostButton.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Gönderi'**
  String get communityCreatePostButton;

  /// No description provided for @communityEmptyExplore.
  ///
  /// In tr, this message translates to:
  /// **'Henüz toplulukta yayınlanmış bir gönderi yok. İlk hikayeyi sen paylaş!'**
  String get communityEmptyExplore;

  /// No description provided for @communityEmptyFollowing.
  ///
  /// In tr, this message translates to:
  /// **'Takip ettiğin gezginlerin henüz paylaşımı yok veya henüz kimseyi takip etmiyorsun.'**
  String get communityEmptyFollowing;

  /// No description provided for @communityLikeAction.
  ///
  /// In tr, this message translates to:
  /// **'Beğen'**
  String get communityLikeAction;

  /// No description provided for @communityCommentAction.
  ///
  /// In tr, this message translates to:
  /// **'Yorum'**
  String get communityCommentAction;

  /// No description provided for @communitySaveAction.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get communitySaveAction;

  /// No description provided for @communityReportAction.
  ///
  /// In tr, this message translates to:
  /// **'İçeriği Bildir'**
  String get communityReportAction;

  /// No description provided for @communityBlockUserAction.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcıyı Engelle'**
  String get communityBlockUserAction;

  /// No description provided for @communityUnblockUserAction.
  ///
  /// In tr, this message translates to:
  /// **'Engeli Kaldır'**
  String get communityUnblockUserAction;

  /// No description provided for @communityFollowAction.
  ///
  /// In tr, this message translates to:
  /// **'Takip Et'**
  String get communityFollowAction;

  /// No description provided for @communityFollowingAction.
  ///
  /// In tr, this message translates to:
  /// **'Takip Ediliyor'**
  String get communityFollowingAction;

  /// No description provided for @postCreateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Topluluk Gönderisi Oluştur'**
  String get postCreateTitle;

  /// No description provided for @postCreateTitleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi Başlığı'**
  String get postCreateTitleLabel;

  /// No description provided for @postCreateTitleHint.
  ///
  /// In tr, this message translates to:
  /// **'Örn: Kapadokya\'da gün doğumu balonları'**
  String get postCreateTitleHint;

  /// No description provided for @postCreateCaptionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hikayen & Tavsiyelerin'**
  String get postCreateCaptionLabel;

  /// No description provided for @postCreateCaptionHint.
  ///
  /// In tr, this message translates to:
  /// **'Diğer gezginler için rota ipuçlarını ve deneyimini paylaş...'**
  String get postCreateCaptionHint;

  /// No description provided for @postCreateSelectPlaceLabel.
  ///
  /// In tr, this message translates to:
  /// **'İlgili Mekan (İsteğe Bağlı)'**
  String get postCreateSelectPlaceLabel;

  /// No description provided for @postCreateLinkVisitLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı Ziyaret Kaydı'**
  String get postCreateLinkVisitLabel;

  /// No description provided for @postCreateLinkTripLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bağlı Seyahat Planı'**
  String get postCreateLinkTripLabel;

  /// No description provided for @postCreatePrivacyNotice.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel günlük notların gizli tutulur; yalnızca burada yazdığın metin ve seçtiğin fotoğraflar yayınlanır.'**
  String get postCreatePrivacyNotice;

  /// No description provided for @postCreateSaveDraft.
  ///
  /// In tr, this message translates to:
  /// **'Taslak Kaydet'**
  String get postCreateSaveDraft;

  /// No description provided for @postCreatePublish.
  ///
  /// In tr, this message translates to:
  /// **'Hemen Yayınla'**
  String get postCreatePublish;

  /// No description provided for @postValidationCaptionRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen paylaşımınız için bir başlık veya açıklama yazın.'**
  String get postValidationCaptionRequired;

  /// No description provided for @postDetailsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi Detayı'**
  String get postDetailsTitle;

  /// No description provided for @postDetailsDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiyi Sil'**
  String get postDetailsDeleteConfirmTitle;

  /// No description provided for @postDetailsDeleteConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu topluluk gönderisini silmek istediğinize emin misiniz?'**
  String get postDetailsDeleteConfirmMessage;

  /// No description provided for @commentsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar'**
  String get commentsTitle;

  /// No description provided for @commentsEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Henüz yorum yapılmamış. İlk yorumu sen yaz!'**
  String get commentsEmptyMessage;

  /// No description provided for @commentsInputHint.
  ///
  /// In tr, this message translates to:
  /// **'Saygılı bir yorum ekle...'**
  String get commentsInputHint;

  /// No description provided for @commentsSendButton.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get commentsSendButton;

  /// No description provided for @commentsDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yorumu Sil'**
  String get commentsDeleteConfirmTitle;

  /// No description provided for @commentsDeleteConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Yorumunuzu silmek istediğinize emin misiniz?'**
  String get commentsDeleteConfirmMessage;

  /// No description provided for @reportSheetTitle.
  ///
  /// In tr, this message translates to:
  /// **'İçeriği veya Kullanıcıyı Bildir'**
  String get reportSheetTitle;

  /// No description provided for @reportReasonSpam.
  ///
  /// In tr, this message translates to:
  /// **'Spam veya yanıltıcı içerik'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In tr, this message translates to:
  /// **'Uygunsuz veya rahatsız edici içerik'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In tr, this message translates to:
  /// **'Taciz veya topluluk kuralları ihlali'**
  String get reportReasonHarassment;

  /// No description provided for @reportDetailsHint.
  ///
  /// In tr, this message translates to:
  /// **'Ek açıklama (isteğe bağlı)'**
  String get reportDetailsHint;

  /// No description provided for @reportSubmittedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bildiriminiz incelenmek üzere kaydedildi. Teşekkür ederiz.'**
  String get reportSubmittedMessage;

  /// No description provided for @blockConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gezgini Engelle'**
  String get blockConfirmTitle;

  /// No description provided for @blockConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcıyı engellediğinizde birbirinizin gönderilerini ve profilini göremezsiniz, mevcut takip ilişkisi kaldırılır.'**
  String get blockConfirmMessage;

  /// No description provided for @blockSuccessMessage.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı engellendi.'**
  String get blockSuccessMessage;

  /// No description provided for @travelerProfileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gezgin Profili'**
  String get travelerProfileTitle;

  /// No description provided for @travelerPostsStat.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşım'**
  String get travelerPostsStat;

  /// No description provided for @travelerFollowersStat.
  ///
  /// In tr, this message translates to:
  /// **'Takipçi'**
  String get travelerFollowersStat;

  /// No description provided for @travelerFollowingStat.
  ///
  /// In tr, this message translates to:
  /// **'Takip Edilen'**
  String get travelerFollowingStat;

  /// No description provided for @followersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takipçiler'**
  String get followersTitle;

  /// No description provided for @followingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takip Edilenler'**
  String get followingTitle;

  /// No description provided for @followersEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Henüz takipçi bulunmuyor.'**
  String get followersEmptyMessage;

  /// No description provided for @followingEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Henüz takip edilen gezgin bulunmuyor.'**
  String get followingEmptyMessage;

  /// No description provided for @myProfileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profilim'**
  String get myProfileTitle;

  /// No description provided for @myProfileEditButton.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get myProfileEditButton;

  /// No description provided for @myProfileTabPosts.
  ///
  /// In tr, this message translates to:
  /// **'Gönderilerim'**
  String get myProfileTabPosts;

  /// No description provided for @myProfileTabJournal.
  ///
  /// In tr, this message translates to:
  /// **'Özel Günlüğüm'**
  String get myProfileTabJournal;

  /// No description provided for @myProfileTabTrips.
  ///
  /// In tr, this message translates to:
  /// **'Rotalarım'**
  String get myProfileTabTrips;

  /// No description provided for @myProfileTabSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilen Gönderiler'**
  String get myProfileTabSaved;

  /// No description provided for @myProfilePassportButton.
  ///
  /// In tr, this message translates to:
  /// **'İnteraktif Pasaport Haritam'**
  String get myProfilePassportButton;

  /// No description provided for @editProfileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get editProfileTitle;

  /// No description provided for @editProfileHomeCityLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yaşadığın Şehir'**
  String get editProfileHomeCityLabel;

  /// No description provided for @editProfileHomeCountryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yaşadığın Ülke'**
  String get editProfileHomeCountryLabel;

  /// No description provided for @editProfilePublicToggleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Herkese Açık Gezgin Profili'**
  String get editProfilePublicToggleTitle;

  /// No description provided for @editProfilePublicToggleSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Açık olduğunda diğer gezginler profilini ve yayınladığın gönderileri görebilir.'**
  String get editProfilePublicToggleSubtitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü Okundu Say'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get notificationsFilterAll;

  /// No description provided for @notificationsFilterFollows.
  ///
  /// In tr, this message translates to:
  /// **'Takipçiler'**
  String get notificationsFilterFollows;

  /// No description provided for @notificationsFilterInteractions.
  ///
  /// In tr, this message translates to:
  /// **'Etkileşimler'**
  String get notificationsFilterInteractions;

  /// No description provided for @notificationsFilterSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get notificationsFilterSystem;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bildirimin yok'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Yeni takipçiler, beğeniler ve yorumlar geldiğinde burada listelenir.'**
  String get notificationsEmptyMessage;

  /// No description provided for @settingsAccountSection.
  ///
  /// In tr, this message translates to:
  /// **'Hesap ve Güvenlik'**
  String get settingsAccountSection;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm ve Dil'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsPrivacySection.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve Güvenlik'**
  String get settingsPrivacySection;

  /// No description provided for @settingsBlockedUsersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Engellenen Gezginler'**
  String get settingsBlockedUsersTitle;

  /// No description provided for @settingsBlockedUsersEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Engellediğiniz bir kullanıcı bulunmuyor.'**
  String get settingsBlockedUsersEmpty;

  /// No description provided for @settingsAboutSection.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında ve Lisanslar'**
  String get settingsAboutSection;

  /// No description provided for @settingsOsmAttribution.
  ///
  /// In tr, this message translates to:
  /// **'Harita verileri © OpenStreetMap katkıda bulunanlar (ODbL) lisansı altındadır.'**
  String get settingsOsmAttribution;

  /// No description provided for @accountSecurityTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap ve Güvenlik'**
  String get accountSecurityTitle;

  /// No description provided for @accountSecurityEmailLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlı E-posta'**
  String get accountSecurityEmailLabel;

  /// No description provided for @accountSecurityChangePasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Güncelle'**
  String get accountSecurityChangePasswordTitle;

  /// No description provided for @accountSecurityNewPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre'**
  String get accountSecurityNewPasswordLabel;

  /// No description provided for @accountSecurityConfirmPasswordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Şifre Tekrarı'**
  String get accountSecurityConfirmPasswordLabel;

  /// No description provided for @accountSecurityUpdatePasswordButton.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi Güncelle'**
  String get accountSecurityUpdatePasswordButton;

  /// No description provided for @accountSecurityPasswordUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Şifreniz başarıyla güncellendi.'**
  String get accountSecurityPasswordUpdated;

  /// No description provided for @accountSecurityDeleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı ve Verileri Silme Talebi'**
  String get accountSecurityDeleteTitle;

  /// No description provided for @accountSecurityDeleteSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı kapatmak tüm özel ziyaretlerinizi, seyahat planlarınızı ve paylaşımlarınızı geri alınamaz biçimde kaldırır.'**
  String get accountSecurityDeleteSubtitle;

  /// No description provided for @accountSecurityDeleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Silme İşlemini Başlat'**
  String get accountSecurityDeleteButton;

  /// No description provided for @accountSecurityDeleteConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınızı Kapatmak İstediğinize Emin misiniz?'**
  String get accountSecurityDeleteConfirmTitle;

  /// No description provided for @accountSecurityDeleteConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik gereği kişisel verileriniz temizlenecek ve oturumunuz kapatılacaktır. Bu işlem geri alınamaz.'**
  String get accountSecurityDeleteConfirmMessage;

  /// No description provided for @mapMyLocationTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Konumuma Git'**
  String get mapMyLocationTooltip;

  /// No description provided for @mapLocationPermissionDenied.
  ///
  /// In tr, this message translates to:
  /// **'Konum izni reddedildi. Cihaz ayarlarından Roamory için konum izni verebilirsiniz.'**
  String get mapLocationPermissionDenied;

  /// No description provided for @mapLocationServiceDisabled.
  ///
  /// In tr, this message translates to:
  /// **'Konum servisi (GPS) kapalı veya şu an cihaz konumu alınamadı.'**
  String get mapLocationServiceDisabled;

  /// No description provided for @visitAddUseCurrentLocation.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Konumumu Kullan'**
  String get visitAddUseCurrentLocation;

  /// No description provided for @itineraryAddDayButton.
  ///
  /// In tr, this message translates to:
  /// **'+ Gün Ekle'**
  String get itineraryAddDayButton;

  /// No description provided for @wishlistAddedToTripMessage.
  ///
  /// In tr, this message translates to:
  /// **'Mekan seçili seyahat gününe eklendi.'**
  String get wishlistAddedToTripMessage;

  /// No description provided for @errorDatabaseTablePermissionMessage.
  ///
  /// In tr, this message translates to:
  /// **'Oturumunuz açık ancak veritabanında bu tablo için yazma yetkisi (GRANT INSERT) henüz tanımlanmamış.'**
  String get errorDatabaseTablePermissionMessage;

  /// No description provided for @checklistValidationTitleRequired.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen hazırlık maddesi için bir başlık yazın.'**
  String get checklistValidationTitleRequired;

  /// No description provided for @checklistValidationInvalidCategory.
  ///
  /// In tr, this message translates to:
  /// **'Hazırlık maddesi kategorisi veritabanı kuralıyla eşleşmiyor; lütfen kategori kuralını güncelleyin veya farklı bir kategori deneyin.'**
  String get checklistValidationInvalidCategory;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
