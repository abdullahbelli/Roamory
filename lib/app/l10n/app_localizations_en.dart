// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Roamory';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navMap => 'My Map';

  @override
  String get navCommunity => 'Community';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonOfflineNotice =>
      'Unable to connect to the internet right now';

  @override
  String get errorGenericTitle => 'Something went wrong';

  @override
  String get errorGenericMessage =>
      'The action could not be completed. Please try again later.';

  @override
  String get errorNetworkTitle => 'Connection Error';

  @override
  String get errorNetworkMessage =>
      'Please check your internet connection and try again.';

  @override
  String get errorUnauthorizedMessage =>
      'You need to be signed in or have permission for this action.';

  @override
  String get errorNotFoundMessage => 'The requested record could not be found.';

  @override
  String get errorValidationMessage =>
      'Please check the information you entered.';

  @override
  String get errorSupabaseNotConfigured =>
      'Supabase connection settings are not configured.';

  @override
  String get emptyDefaultTitle => 'Nothing here yet';

  @override
  String get emptyDefaultMessage => 'There is no content to display here yet.';

  @override
  String get confirmUnsavedTitle => 'Unsaved Changes';

  @override
  String get confirmUnsavedMessage =>
      'Your changes have not been saved yet. Are you sure you want to leave?';

  @override
  String get confirmDiscardAction => 'Discard Changes';

  @override
  String get confirmKeepEditingAction => 'Keep Editing';

  @override
  String get authLoginTitle => 'Sign In';

  @override
  String get authOnboardingTitle => 'Welcome';

  @override
  String get homeComingSoonSubtitle =>
      'Your personal travel summary and upcoming trips will appear here.';

  @override
  String get exploreComingSoonSubtitle =>
      'New destinations, categories, and your wishlist will appear here.';

  @override
  String get mapComingSoonSubtitle =>
      'Places you visited and saved will be displayed on the map.';

  @override
  String get communityComingSoonSubtitle =>
      'Real routes and stories shared by travelers will appear here.';

  @override
  String get profileComingSoonSubtitle =>
      'Your profile, visits, trips, and settings will appear here.';

  @override
  String get tripsTitle => 'My Trips';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get splashBadge => 'Field Journal & Wayfinding';

  @override
  String get splashTagline => 'Explore. Remember. Share.';

  @override
  String get splashSubtitle => 'Crafted for discerning wayfarers';

  @override
  String get splashCheckingSession => 'Checking session...';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get onboardingAlreadyHaveAccount => 'Already have an account?';

  @override
  String get onboardingSignInLink => 'Sign In';

  @override
  String get onboardingTagExplore => 'Explore';

  @override
  String get onboardingTagMemories => 'Memories';

  @override
  String get onboardingTagRoutes => 'Routes';

  @override
  String get onboardingStep1Title => 'Explore the World at Your Own Pace';

  @override
  String get onboardingStep1Body =>
      'Hidden coves, mountain trails, and local flavors right at your fingertips.';

  @override
  String get onboardingStep1CardTitle => 'Undiscovered Natural Routes';

  @override
  String get onboardingStep1CardSubtitle =>
      'Quiet trails and hidden valleys await you';

  @override
  String get onboardingStep2Title => 'Keep Memories in Your Private Journal';

  @override
  String get onboardingStep2Body =>
      'Safely archive photos, ratings, and notes for every visit.';

  @override
  String get onboardingStep2CardTitle => 'Personal Field Journal';

  @override
  String get onboardingStep2CardSubtitle =>
      'All entries remain private to you by default';

  @override
  String get onboardingStep3Title => 'Plan Your Trips Day by Day';

  @override
  String get onboardingStep3Body =>
      'Organize stops, prepare checklists, and share with the community when you choose.';

  @override
  String get onboardingStep3CardTitle => 'Smart Route Planner';

  @override
  String get onboardingStep3CardSubtitle =>
      'Turn your wishlist into real itineraries';

  @override
  String get loginBadge => 'Travel Journal';

  @override
  String get loginHeadline => 'Welcome Back';

  @override
  String get loginSubheadline =>
      'Continue your travel routes and memories right where you left off.';

  @override
  String get loginGoogleButton => 'Continue with Google';

  @override
  String get loginOrDivider => 'or with email';

  @override
  String get loginEmailLabel => 'Email Address';

  @override
  String get loginEmailHint => 'name@roamory.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginRememberMe => 'Remember Me';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginSubmit => 'Sign In';

  @override
  String get loginSubmitting => 'Signing In...';

  @override
  String get loginInfoTitle => 'Access Your Digital Passport';

  @override
  String get loginInfoSubtitle =>
      'Your visits, routes, and travel memories stay safely synced in your account.';

  @override
  String get loginNoAccount => 'Don\'t have a Roamory account yet?';

  @override
  String get loginCreateAccountLink => 'Sign Up';

  @override
  String get loginSuccessMessage => 'Signed in, redirecting...';

  @override
  String get registerBadge => 'New Travel Journal';

  @override
  String get registerHeadline => 'Join Roamory';

  @override
  String get registerSubheadline =>
      'Log your discoveries, get inspired, and connect with fellow travelers.';

  @override
  String get registerFullNameLabel => 'Full Name';

  @override
  String get registerFullNameHint => 'Alex Morgan';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordRule =>
      'At least 8 characters, 1 letter and 1 number';

  @override
  String get registerConfirmPasswordLabel => 'Confirm Password';

  @override
  String get registerTermsText =>
      'I have read and agree to the Terms of Use and Privacy Policy.';

  @override
  String get registerSubmit => 'Create Account';

  @override
  String get registerSubmitting => 'Creating Account...';

  @override
  String get registerOrDivider => 'OR';

  @override
  String get registerGoogleButton => 'Sign up with Google';

  @override
  String get registerSecurityNote => 'Secure & Encrypted Traveler Journal';

  @override
  String get registerHasAccount => 'Already have an account?';

  @override
  String get registerSignInLink => 'Sign In';

  @override
  String get forgotBadge => 'SECURE RESET';

  @override
  String get forgotHeadline => 'Forgot Password?';

  @override
  String get forgotDescription =>
      'No worries! Enter the email linked to your account and we will send you a one-time link to reset your password safely.';

  @override
  String get forgotEmailHelper => 'Email linked to your Roamory travel journal';

  @override
  String get forgotSubmit => 'Send Password Reset Link';

  @override
  String get forgotSentBannerTitle => 'Reset link sent!';

  @override
  String forgotSentBannerBody(String email) {
    return 'Don\'t forget to check $email and your spam folder.';
  }

  @override
  String get forgotDidNotReceive => 'Didn\'t receive the email?';

  @override
  String get forgotResend => 'Resend';

  @override
  String forgotResendCooldown(int seconds) {
    return 'Resend (${seconds}s)';
  }

  @override
  String get forgotBackToLogin => 'Back to Sign In';

  @override
  String get forgotSmtpNotice =>
      'Note: Custom SMTP/domain is not configured yet, so emails are subject to Supabase default rate limits.';

  @override
  String get verifyStepBadge => 'STEP 2 / 2';

  @override
  String get verifyHeadline => 'Verify Your Email';

  @override
  String get verifyDescription =>
      'One step left to join! Confirm via the link sent to your inbox or enter the 6-digit code:';

  @override
  String get verifySentAddressLabel => 'Sent To';

  @override
  String get verifyChangeEmail => 'Change';

  @override
  String get verifyCodeLabel => 'Enter Security Code';

  @override
  String get verifyEncryptedBadge => 'End-to-End Encrypted';

  @override
  String get verifyCheckButton => 'Check Verification';

  @override
  String get verifyNotConfirmedYet =>
      'Email verification is not completed yet. Click the link in your inbox or enter the 6-digit code.';

  @override
  String get verifyNoCodePrompt => 'Didn\'t get the code?';

  @override
  String get verifyResendButton => 'Resend Email';

  @override
  String get verifySpamHint => 'Please check both your inbox and spam folder.';

  @override
  String get verifyResentSuccess => 'Verification email has been resent.';

  @override
  String get verifyBackToLogin => 'Back to Sign In';

  @override
  String get profileSetupHeader => 'Step 2 / 2 • Profile Setup';

  @override
  String get profileSetupSkip => 'Skip for Now';

  @override
  String get profileSetupBadge => 'NEW JOURNEY';

  @override
  String get profileSetupHeadline => 'Create Your Traveler Identity';

  @override
  String get profileSetupDescription =>
      'Personalize your profile for tailored route suggestions and inspiring travel memories.';

  @override
  String get profileSetupAddPhoto => 'Add Photo';

  @override
  String get profileSetupDisplayNameLabel => 'Display Name';

  @override
  String get profileSetupDisplayNameHint => 'Alex Morgan';

  @override
  String get profileSetupUsernameLabel => 'Unique Username';

  @override
  String get profileSetupUsernameHint => 'alex_morgan';

  @override
  String get profileSetupUsernameAvailable => 'Available';

  @override
  String get profileSetupUsernameTaken => 'This username is already taken';

  @override
  String get profileSetupUsernameInvalid =>
      'Use 3-24 characters: lowercase letters, numbers, or underscore';

  @override
  String get profileSetupBioLabel => 'Bio (Optional)';

  @override
  String get profileSetupBioHint =>
      'Share your travel style, favorite trails, or dream routes...';

  @override
  String get profileSetupInterestsTitle => 'Travel Interests';

  @override
  String get profileSetupInterestsSubtitle =>
      'Choose the types of experiences you\'d like to discover on your map.';

  @override
  String get profileSetupInterestsHint => 'At least 3 recommended';

  @override
  String get profileSetupLanguageTitle => 'App Language';

  @override
  String get profileSetupLanguageTr => 'Türkçe (Default)';

  @override
  String get profileSetupLanguageEn => 'English';

  @override
  String get profileSetupSubmit => 'Explore Roamory';

  @override
  String get profileSetupFooterTerms =>
      'By completing setup, you agree to our Travel Guidelines & Terms.';

  @override
  String get profileSetupRequiredBeforeApp =>
      'Please set a display name and a valid username before continuing.';

  @override
  String get profileSetupAvatarSizeError =>
      'Profile photo must be 5 MB or smaller.';

  @override
  String get interestNature => 'Nature';

  @override
  String get interestCamping => 'Camping';

  @override
  String get interestHistory => 'History';

  @override
  String get interestCulture => 'Culture';

  @override
  String get interestFood => 'Gastronomy';

  @override
  String get interestCoast => 'Coast & Sea';

  @override
  String get interestAdventure => 'Adventure';

  @override
  String get interestCity => 'City Walks';

  @override
  String get validationEmailInvalid => 'Please enter a valid email address.';

  @override
  String get validationPasswordWeak =>
      'Password must be at least 8 characters with 1 letter and 1 number.';

  @override
  String get validationPasswordMismatch => 'Passwords do not match.';

  @override
  String get validationFullNameInvalid =>
      'Please enter at least 2 characters for your name.';

  @override
  String get validationTermsRequired =>
      'You must accept the terms of use to continue.';

  @override
  String get validationOtpInvalid =>
      'Please enter the complete 6-digit verification code.';

  @override
  String get authSignOut => 'Sign Out';

  @override
  String get authSignOutConfirmTitle => 'Sign Out';

  @override
  String get authSignOutConfirmMessage =>
      'Are you sure you want to sign out of your account?';
}
