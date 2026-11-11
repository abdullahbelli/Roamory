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
