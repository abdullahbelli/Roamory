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

  @override
  String get commonAll => 'All';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonSeeAll => 'See All';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonShare => 'Share';

  @override
  String get commonPrivateBadge => 'Private Journal';

  @override
  String get commonPublicBadge => 'Public';

  @override
  String get commonDraftBadge => 'Draft';

  @override
  String get commonSavedSuccess => 'Saved successfully.';

  @override
  String get commonDeletedSuccess => 'Record deleted.';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get homeGreetingPrefix => 'Hello,';

  @override
  String get homeGreetingSubtitle =>
      'Which route would you like to discover or log today?';

  @override
  String get homePassportBadge => 'DIGITAL PASSPORT SUMMARY';

  @override
  String get homePassportTitle => 'Your Travel Footprint';

  @override
  String get homePassportCountries => 'Countries';

  @override
  String get homePassportCities => 'Cities';

  @override
  String get homePassportVisits => 'Visits';

  @override
  String get homePassportWishlist => 'Wishlist';

  @override
  String get homeQuickAddVisit => 'Log Visit';

  @override
  String get homeQuickPlanTrip => 'Plan Trip';

  @override
  String get homeQuickMyJournal => 'My Journal';

  @override
  String get homeQuickWishlist => 'Wishlist';

  @override
  String get homeUpcomingTripTitle => 'Upcoming Trip';

  @override
  String get homeUpcomingTripEmpty =>
      'You don\'t have an active planned trip yet.';

  @override
  String get homeFeaturedTitle => 'Featured Destinations';

  @override
  String get homeRecentMemoriesTitle => 'Recent Travel Memories';

  @override
  String get homeRecentMemoriesEmpty =>
      'You haven\'t logged a visit yet. Record your first memory!';

  @override
  String get homeCommunityHighlightTitle => 'Community Inspiration';

  @override
  String get homeCommunityHighlightEmpty =>
      'No published posts in the community yet.';

  @override
  String get exploreHeaderBadge => 'ROAMORY GUIDE';

  @override
  String get exploreSearchHint => 'Search country, city, or place...';

  @override
  String get exploreFilterButton => 'Filter';

  @override
  String get exploreWishlistButton => 'My Wishlist';

  @override
  String get exploreViewMap => 'View on Map';

  @override
  String get exploreViewList => 'List View';

  @override
  String get exploreFeaturedBadge => 'CURATED ROUTE';

  @override
  String get exploreTrendingTitle => 'Places Worth Discovering';

  @override
  String get exploreCuratedTitle => 'Suggestions by Category';

  @override
  String get exploreEmptyTitle => 'No catalog places found yet';

  @override
  String get exploreEmptyMessage =>
      'There are no published catalog places in the database or no matches for your filters. You can add your own private place from the map or visit screen.';

  @override
  String get searchTitle => 'Search & Filters';

  @override
  String get searchCountryLabel => 'Country';

  @override
  String get searchCountryHint => 'e.g. Turkey, Italy';

  @override
  String get searchCityLabel => 'City';

  @override
  String get searchCityHint => 'e.g. Izmir, Kyoto';

  @override
  String get searchCategoryLabel => 'Category';

  @override
  String get searchMinRatingLabel => 'Minimum Rating';

  @override
  String get searchSortLabel => 'Sort By';

  @override
  String get searchSortNewest => 'Newest';

  @override
  String get searchSortAlphabetical => 'Alphabetical (A-Z)';

  @override
  String searchResultsCount(int count) {
    return '$count places found';
  }

  @override
  String get searchClearFilters => 'Clear Filters';

  @override
  String get placeDetailsStoryTitle => 'Place Story';

  @override
  String get placeDetailsCoordinatesTitle => 'Location & Map';

  @override
  String get placeDetailsCommunityTitle => 'Traveler Stories';

  @override
  String get placeDetailsCommunityEmpty =>
      'No community posts shared for this place yet.';

  @override
  String get placeDetailsActionWishlistAdd => 'Add to Wishlist';

  @override
  String get placeDetailsActionWishlistRemove => 'In Wishlist';

  @override
  String get placeDetailsActionAddToTrip => 'Add to Trip';

  @override
  String get placeDetailsActionMarkVisited => 'Visited / Log Journal';

  @override
  String get placeDetailsPrivateNotice =>
      'This place was privately created for your personal map.';

  @override
  String get wishlistTitle => 'My Wishlist';

  @override
  String wishlistSubtitle(int count) {
    return '$count saved destinations';
  }

  @override
  String get wishlistEmptyTitle => 'Your wishlist is empty';

  @override
  String get wishlistEmptyMessage =>
      'Save coves, cities, and cultural stops from Explore to plan future routes.';

  @override
  String get wishlistExploreCta => 'Start Exploring';

  @override
  String get wishlistNoteHint => 'Short note (e.g. Visit in spring)';

  @override
  String get wishlistAddToTrip => 'Add to Trip';

  @override
  String get wishlistRemoveConfirmTitle => 'Remove from Wishlist';

  @override
  String get wishlistRemoveConfirmMessage =>
      'Are you sure you want to remove this place from your wishlist?';

  @override
  String get mapAttribution => '© OpenStreetMap contributors';

  @override
  String mapStatsPill(int visits, int wishlist) {
    return '$visits Visits • $wishlist Wishlist';
  }

  @override
  String get mapFilterButton => 'Map Filters';

  @override
  String get mapHistoryButton => 'Visit History';

  @override
  String get mapAddVisitFab => 'Log New Visit';

  @override
  String get mapLegendVisited => 'Visited';

  @override
  String get mapLegendWishlist => 'Wishlist';

  @override
  String get mapLegendCommunity => 'Catalog';

  @override
  String get mapEmptyOverlay =>
      'No pins to display on the map yet. Log your first visit or save a wishlist place!';

  @override
  String get mapFilterLayerTitle => 'Visible Pins';

  @override
  String get mapFilterLayerAll => 'All';

  @override
  String get mapFilterLayerVisited => 'My Visits';

  @override
  String get mapFilterLayerWishlist => 'My Wishlist';

  @override
  String get mapFilterOnlyFavorites => 'Only 4+ Star Favorites';

  @override
  String get mapFilterYearLabel => 'Visit Year';

  @override
  String get visitsHistoryTitle => 'Visit History';

  @override
  String visitsHistorySubtitle(int count) {
    return '$count personal travel entries';
  }

  @override
  String get visitsEmptyTitle => 'No visit entries yet';

  @override
  String get visitsEmptyMessage =>
      'Start logging places you\'ve visited, your ratings, and photos in your private field journal.';

  @override
  String get visitAddStep1Title => 'Log Visit (Step 1 / 2)';

  @override
  String get visitAddSelectPlaceLabel => 'Select Place or Create New';

  @override
  String get visitAddCreateCustomPlace => 'Create Custom Private Place';

  @override
  String get visitAddPlaceNameLabel => 'Place Name';

  @override
  String get visitAddPlaceNameHint => 'e.g. Kabak Bay Viewpoint';

  @override
  String get visitAddLatitudeLabel => 'Latitude';

  @override
  String get visitAddLongitudeLabel => 'Longitude';

  @override
  String get visitAddDateLabel => 'Visit Date';

  @override
  String get visitAddTodayButton => 'Select Today';

  @override
  String get visitAddRatingLabel => 'Your Personal Rating';

  @override
  String get visitAddCategoriesLabel => 'Experience Tags';

  @override
  String get visitAddContinueToJournal => 'Continue to Journal Details';

  @override
  String get visitJournalStep2Title => 'Travel Journal (Step 2 / 2)';

  @override
  String get visitJournalTitleLabel => 'Memory Title';

  @override
  String get visitJournalTitleHint => 'e.g. Misty dawn trail walk';

  @override
  String get visitJournalNotesLabel => 'Private Journal Notes';

  @override
  String get visitJournalNotesHint =>
      'Write about the atmosphere, local flavors, and details you never want to forget...';

  @override
  String get visitJournalPhotosLabel => 'Visit Photos (Up to 10 MB)';

  @override
  String get visitJournalAddPhoto => 'Upload Photo';

  @override
  String get visitJournalPrivacyBanner =>
      'Your personal visits and journal notes are private by default and never shared publicly without your consent.';

  @override
  String get visitDetailsTitle => 'Visit Details';

  @override
  String get visitDetailsDeleteConfirmTitle => 'Delete Visit Entry';

  @override
  String get visitDetailsDeleteConfirmMessage =>
      'Are you sure you want to permanently delete this visit and its photos?';

  @override
  String get visitDetailsConvertToPostTitle =>
      'Share This Memory with Community';

  @override
  String get visitDetailsConvertToPostSubtitle =>
      'Your private journal notes remain hidden; a new public post is created with the summary you choose.';

  @override
  String get visitDetailsConvertToPostButton => 'Convert to Post';

  @override
  String get visitDetailsPlanRouteButton => 'Plan as Route';

  @override
  String get visitValidationPlaceRequired =>
      'Please select a place or enter a custom place name and coordinates.';

  @override
  String get visitValidationCountryInvalid =>
      'Please enter a valid country name or 2-letter ISO country code (e.g. Turkey, Italy, TR, IT).';

  @override
  String get visitValidationCityInvalid =>
      'Please enter a valid city or region name (at least 2 letters, no numbers).';

  @override
  String get visitValidationCoordinateInvalid =>
      'Please enter a valid latitude (-90..90) and longitude (-180..180).';

  @override
  String get visitValidationRatingInvalid => 'Rating must be between 1 and 5.';

  @override
  String get visitPhotoSizeError => 'Visit photo must be 10 MB or smaller.';

  @override
  String get tripsTabPlanned => 'Planned';

  @override
  String get tripsTabOngoing => 'Ongoing';

  @override
  String get tripsTabCompleted => 'Completed';

  @override
  String get tripsCreateButton => 'Plan New Trip';

  @override
  String get tripsEmptyTitle => 'No trips planned yet';

  @override
  String get tripsEmptyMessage =>
      'Turn your wishlist places into day-by-day itineraries, order stops, and manage your packing checklist.';

  @override
  String get tripCreateTitle => 'Create Trip Plan';

  @override
  String get tripEditTitle => 'Edit Trip';

  @override
  String get tripEditPreserveDaysNotice =>
      'Your existing days, stops, and checklist remain preserved; changing dates will never delete your data.';

  @override
  String get tripTitleLabel => 'Trip Title';

  @override
  String get tripTitleHint => 'e.g. Lycian Way & Kas Route';

  @override
  String get tripCountryLabel => 'Destination Country';

  @override
  String get tripCityLabel => 'Destination City / Region';

  @override
  String get tripStartDateLabel => 'Start Date';

  @override
  String get tripEndDateLabel => 'End Date';

  @override
  String get tripStatusLabel => 'Status';

  @override
  String get tripDescriptionLabel => 'Route Notes';

  @override
  String get tripDescriptionHint =>
      'General purpose of this trip, transport notes, or reminders...';

  @override
  String get tripValidationTitleRequired => 'Please enter a trip title.';

  @override
  String get tripValidationDateOrder =>
      'End date cannot be earlier than start date.';

  @override
  String tripDetailsDaysStat(int count) {
    return '$count Days';
  }

  @override
  String tripDetailsStopsStat(int count) {
    return '$count Stops';
  }

  @override
  String tripDetailsChecklistStat(int done, int total) {
    return '$done/$total Checklist';
  }

  @override
  String get tripDetailsItineraryButton => 'Edit Daily Itinerary';

  @override
  String get tripDetailsChecklistButton => 'Trip Checklist';

  @override
  String get tripDetailsDeleteConfirmTitle => 'Delete Trip Plan';

  @override
  String get tripDetailsDeleteConfirmMessage =>
      'Are you sure you want to delete this trip plan, all its days, stops, and checklist?';

  @override
  String get itineraryTitle => 'Daily Itinerary Planner';

  @override
  String itineraryDayLabel(int day) {
    return 'Day $day';
  }

  @override
  String get itineraryDayNotesHint => 'Theme or key note for today...';

  @override
  String get itineraryAddStopButton => 'Add New Stop';

  @override
  String get itineraryStopNoteHint =>
      'Stop note or time slot (e.g. 10:00 - Breakfast)';

  @override
  String get itineraryEmptyStops => 'No stops added to this day yet.';

  @override
  String get itineraryNoPlacesAvailable =>
      'No places available to add as a stop yet. Add a private place or visit first.';

  @override
  String get itineraryAddPrivatePlaceAction => 'Add Private Place';

  @override
  String get checklistTitle => 'Trip Checklist';

  @override
  String get checklistProgressTitle => 'Preparation Progress';

  @override
  String get checklistFilterAll => 'All';

  @override
  String get checklistFilterPending => 'Pending';

  @override
  String get checklistFilterCompleted => 'Completed';

  @override
  String get checklistCategoryDocs => 'Documents & Tickets';

  @override
  String get checklistCategoryGear => 'Luggage & Gear';

  @override
  String get checklistCategoryHotel => 'Bookings';

  @override
  String get checklistCategoryGeneral => 'General Prep';

  @override
  String get checklistAddItemHint => 'Add new checklist item...';

  @override
  String get checklistEmptyMessage =>
      'No checklist items added for this trip yet.';

  @override
  String get communityFeedExploreTab => 'Explore';

  @override
  String get communityFeedFollowingTab => 'Following';

  @override
  String get communityCreatePostButton => 'New Post';

  @override
  String get communityEmptyExplore =>
      'No published posts in the community yet. Be the first to share a story!';

  @override
  String get communityEmptyFollowing =>
      'Travelers you follow haven\'t shared posts yet, or you aren\'t following anyone yet.';

  @override
  String get communityLikeAction => 'Like';

  @override
  String get communityCommentAction => 'Comment';

  @override
  String get communitySaveAction => 'Save';

  @override
  String get communityReportAction => 'Report Content';

  @override
  String get communityBlockUserAction => 'Block User';

  @override
  String get communityUnblockUserAction => 'Unblock';

  @override
  String get communityFollowAction => 'Follow';

  @override
  String get communityFollowingAction => 'Following';

  @override
  String get postCreateTitle => 'Create Community Post';

  @override
  String get postCreateTitleLabel => 'Post Title';

  @override
  String get postCreateTitleHint => 'e.g. Sunrise balloons over Cappadocia';

  @override
  String get postCreateCaptionLabel => 'Your Story & Tips';

  @override
  String get postCreateCaptionHint =>
      'Share route tips and your experience for fellow travelers...';

  @override
  String get postCreateSelectPlaceLabel => 'Related Place (Optional)';

  @override
  String get postCreateLinkVisitLabel => 'Linked Visit Entry';

  @override
  String get postCreateLinkTripLabel => 'Linked Trip Plan';

  @override
  String get postCreatePrivacyNotice =>
      'Your private journal notes stay hidden; only the text and photos you select here will be published.';

  @override
  String get postCreateSaveDraft => 'Save Draft';

  @override
  String get postCreatePublish => 'Publish Now';

  @override
  String get postValidationCaptionRequired =>
      'Please enter a title or caption for your post.';

  @override
  String get postDetailsTitle => 'Post Details';

  @override
  String get postDetailsDeleteConfirmTitle => 'Delete Post';

  @override
  String get postDetailsDeleteConfirmMessage =>
      'Are you sure you want to delete this community post?';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get commentsEmptyMessage =>
      'No comments yet. Write the first comment!';

  @override
  String get commentsInputHint => 'Add a respectful comment...';

  @override
  String get commentsSendButton => 'Post';

  @override
  String get commentsDeleteConfirmTitle => 'Delete Comment';

  @override
  String get commentsDeleteConfirmMessage =>
      'Are you sure you want to delete your comment?';

  @override
  String get reportSheetTitle => 'Report Content or User';

  @override
  String get reportReasonSpam => 'Spam or misleading content';

  @override
  String get reportReasonInappropriate => 'Inappropriate or offensive content';

  @override
  String get reportReasonHarassment =>
      'Harassment or community guideline violation';

  @override
  String get reportDetailsHint => 'Additional details (optional)';

  @override
  String get reportSubmittedMessage =>
      'Your report has been submitted for review. Thank you.';

  @override
  String get blockConfirmTitle => 'Block Traveler';

  @override
  String get blockConfirmMessage =>
      'When you block this user, you will no longer see each other\'s posts or profiles, and any existing follow relation will be removed.';

  @override
  String get blockSuccessMessage => 'User blocked.';

  @override
  String get travelerProfileTitle => 'Traveler Profile';

  @override
  String get travelerPostsStat => 'Posts';

  @override
  String get travelerFollowersStat => 'Followers';

  @override
  String get travelerFollowingStat => 'Following';

  @override
  String get followersTitle => 'Followers';

  @override
  String get followingTitle => 'Following';

  @override
  String get followersEmptyMessage => 'No followers yet.';

  @override
  String get followingEmptyMessage => 'Not following any travelers yet.';

  @override
  String get myProfileTitle => 'My Profile';

  @override
  String get myProfileEditButton => 'Edit Profile';

  @override
  String get myProfileTabPosts => 'My Posts';

  @override
  String get myProfileTabJournal => 'Private Journal';

  @override
  String get myProfileTabTrips => 'My Trips';

  @override
  String get myProfileTabSaved => 'Saved Posts';

  @override
  String get myProfilePassportButton => 'Interactive Passport Map';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editProfileHomeCityLabel => 'Home City';

  @override
  String get editProfileHomeCountryLabel => 'Home Country';

  @override
  String get editProfilePublicToggleTitle => 'Public Traveler Profile';

  @override
  String get editProfilePublicToggleSubtitle =>
      'When enabled, other travelers can view your profile and published posts.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark All Read';

  @override
  String get notificationsFilterAll => 'All';

  @override
  String get notificationsFilterFollows => 'Followers';

  @override
  String get notificationsFilterInteractions => 'Interactions';

  @override
  String get notificationsFilterSystem => 'System';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptyMessage =>
      'New followers, likes, and comments will appear here.';

  @override
  String get settingsAccountSection => 'Account & Security';

  @override
  String get settingsPreferencesSection => 'Appearance & Language';

  @override
  String get settingsPrivacySection => 'Privacy & Safety';

  @override
  String get settingsBlockedUsersTitle => 'Blocked Travelers';

  @override
  String get settingsBlockedUsersEmpty => 'You haven\'t blocked any users.';

  @override
  String get settingsAboutSection => 'About & Licenses';

  @override
  String get settingsOsmAttribution =>
      'Map data © OpenStreetMap contributors under ODbL license.';

  @override
  String get accountSecurityTitle => 'Account & Security';

  @override
  String get accountSecurityEmailLabel => 'Registered Email';

  @override
  String get accountSecurityChangePasswordTitle => 'Update Password';

  @override
  String get accountSecurityNewPasswordLabel => 'New Password';

  @override
  String get accountSecurityConfirmPasswordLabel => 'Confirm New Password';

  @override
  String get accountSecurityUpdatePasswordButton => 'Update Password';

  @override
  String get accountSecurityPasswordUpdated =>
      'Your password has been updated successfully.';

  @override
  String get accountSecurityDeleteTitle => 'Account & Data Deletion Request';

  @override
  String get accountSecurityDeleteSubtitle =>
      'Closing your account permanently removes all your private visits, trip plans, and posts.';

  @override
  String get accountSecurityDeleteButton => 'Start Account Deletion';

  @override
  String get accountSecurityDeleteConfirmTitle =>
      'Are You Sure You Want to Close Your Account?';

  @override
  String get accountSecurityDeleteConfirmMessage =>
      'For security, your personal data will be cleared and you will be signed out. This action cannot be undone.';

  @override
  String get mapMyLocationTooltip => 'My Location';

  @override
  String get mapLocationPermissionDenied =>
      'Location permission denied. You can grant location permission for Roamory in device settings.';

  @override
  String get mapLocationServiceDisabled =>
      'Location service (GPS) is disabled or device location is currently unavailable.';

  @override
  String get visitAddUseCurrentLocation => 'Use My Current Location';

  @override
  String get itineraryAddDayButton => '+ Add Day';

  @override
  String get wishlistAddedToTripMessage =>
      'Place added to the selected trip day.';

  @override
  String get errorDatabaseTablePermissionMessage =>
      'You are signed in, but write permission (GRANT INSERT) for this table is not yet granted in the database.';

  @override
  String get checklistValidationTitleRequired =>
      'Please enter a title for the checklist item.';

  @override
  String get checklistValidationInvalidCategory =>
      'Checklist item category does not match the database check constraint; please update the category constraint or try another category.';
}
