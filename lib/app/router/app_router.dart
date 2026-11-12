import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/features/auth/domain/entities/auth_status.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:roamory/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:roamory/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:roamory/features/auth/presentation/screens/login_screen.dart';
import 'package:roamory/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:roamory/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:roamory/features/auth/presentation/screens/register_screen.dart';
import 'package:roamory/features/auth/presentation/screens/splash_screen.dart';
import 'package:roamory/features/community/presentation/screens/comments_screen.dart';
import 'package:roamory/features/community/presentation/screens/community_feed_screen.dart';
import 'package:roamory/features/community/presentation/screens/create_post_screen.dart';
import 'package:roamory/features/community/presentation/screens/post_details_screen.dart';
import 'package:roamory/features/community/presentation/screens/traveler_profile_screen.dart';
import 'package:roamory/features/explore/presentation/screens/explore_screen.dart';
import 'package:roamory/features/explore/presentation/screens/place_details_screen.dart';
import 'package:roamory/features/explore/presentation/screens/search_filter_screen.dart';
import 'package:roamory/features/home/presentation/screens/home_screen.dart';
import 'package:roamory/features/map/presentation/screens/my_map_screen.dart';
import 'package:roamory/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:roamory/features/settings/presentation/screens/settings_and_security_screens.dart';
import 'package:roamory/features/trips/presentation/screens/create_trip_screen.dart';
import 'package:roamory/features/trips/presentation/screens/daily_itinerary_screen.dart';
import 'package:roamory/features/trips/presentation/screens/my_trips_screen.dart';
import 'package:roamory/features/trips/presentation/screens/trip_checklist_screen.dart';
import 'package:roamory/features/trips/presentation/screens/trip_details_screen.dart';
import 'package:roamory/features/visits/presentation/screens/add_visit_screen.dart';
import 'package:roamory/features/visits/presentation/screens/visit_details_screen.dart';
import 'package:roamory/features/visits/presentation/screens/visit_history_screen.dart';
import 'package:roamory/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:roamory/shared/widgets/app_bottom_navigation.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Uygulama genelindeki adlandırılmış rota yolları (38 ekranın tamamı).
///
/// Beş sabit ana sekme (`home`, `explore`, `map`, `community`, `profile`) kabuk
/// (shell) içinde yer alır; auth akışları, ziyaretler, seyahat planlama (`trips`),
/// bildirimler ve ayarlar rotaları kabuk dışında tanımlanır.
abstract final class AppRoutes {
  /// Açılış ekranı (`A01`).
  static const String splash = '/splash';

  /// Karşılama turu (`A02`).
  static const String onboarding = '/onboarding';

  /// Giriş ekranı (`A03`).
  static const String login = '/auth/login';

  /// Kayıt ekranı (`A04`).
  static const String register = '/auth/register';

  /// Şifre sıfırlama ekranı (`A05`).
  static const String forgotPassword = '/auth/forgot-password';

  /// E-posta doğrulama ekranı (`A06`).
  static const String emailVerification = '/auth/verify-email';

  /// Profil kurulumu ekranı (`A07`).
  static const String profileSetup = '/auth/profile-setup';

  /// Ana Sayfa sekmesi (`B01`).
  static const String home = '/home';

  /// Keşfet sekmesi (`B02`).
  static const String explore = '/explore';

  /// Arama ve Filtreler ekranı (`B03`).
  static const String exploreSearch = '/explore/search';

  /// Mekan Detayı rotası (`B04`).
  static String placeDetailsPath(String placeId) => '/explore/places/$placeId';

  /// İstek Listesi ekranı (`B05`).
  static const String wishlist = '/wishlist';

  /// Haritam sekmesi (`C01`).
  static const String map = '/map';

  /// Ziyaret Geçmişi ekranı (`C03`).
  static const String visitsHistory = '/visits';

  /// Ziyaret Ekleme (Adım 1/2) ekranı (`C04`).
  static const String visitAdd = '/visits/add';

  /// Gezi Günlüğü Düzenleyici (Adım 2/2) rotası (`C05`).
  static String visitJournalPath(String visitId) => '/visits/$visitId/journal';

  /// Ziyaret Detayı rotası (`C06`).
  static String visitDetailsPath(String visitId) => '/visits/$visitId';

  /// Seyahatlerim listesi (`D01`, 6. alt sekme değildir).
  static const String trips = '/trips';

  /// Yeni Seyahat Oluştur ekranı (`D02`).
  static const String tripCreate = '/trips/create';

  /// Seyahat Detayı rotası (`D03`).
  static String tripDetailsPath(String tripId) => '/trips/$tripId';

  /// Günlük Rota Planlayıcı rotası (`D04`).
  static String tripItineraryPath(String tripId) => '/trips/$tripId/itinerary';

  /// Seyahat Kontrol Listesi rotası (`D05`).
  static String tripChecklistPath(String tripId) => '/trips/$tripId/checklist';

  /// Topluluk sekmesi (`E01`).
  static const String community = '/community';

  /// Yeni Gönderi Oluştur ekranı (`E02`).
  static const String postCreate = '/community/create';

  /// Gönderi Detayı rotası (`E03`).
  static String postDetailsPath(String postId) => '/community/posts/$postId';

  /// Gönderi Yorumları rotası (`E04`).
  static String postCommentsPath(String postId) =>
      '/community/posts/$postId/comments';

  /// Gezgin Profili rotası (`E05`).
  static String travelerProfilePath(String userId) =>
      '/community/travelers/$userId';

  /// Takipçiler / Takip Edilenler rotası (`E06`).
  static String travelerConnectionsPath(
    String userId, {
    bool followers = true,
  }) =>
      '/community/travelers/$userId/connections?tab=${followers ? 'followers' : 'following'}';

  /// Profilim sekmesi (`F01`).
  static const String profile = '/profile';

  /// Profili Düzenle ekranı (`F02`).
  static const String profileEdit = '/profile/edit';

  /// Bildirimler ekranı (`F03`).
  static const String notifications = '/notifications';

  /// Ayarlar ekranı (`F04`).
  static const String settings = '/settings';

  /// Hesap ve Güvenlik ekranı (`F05`).
  static const String accountSecurity = '/settings/security';

  /// Giriş yapmamış kullanıcının serbestçe gezebileceği auth alt rotaları.
  static const Set<String> publicAuthRoutes = {login, register, forgotPassword};

  /// Oturum açılmış kullanıcıya kapalı tutulan tüm giriş/kurulum rotaları.
  static const Set<String> allAuthAndIntroRoutes = {
    splash,
    onboarding,
    login,
    register,
    forgotPassword,
    emailVerification,
    profileSetup,
  };
}

/// Oturum ve tercih durumuna göre hedef yönlendirme rotasını hesaplar.
String? resolveAuthRedirect({
  required String currentLocation,
  required AuthSessionState authState,
  required bool onboardingCompleted,
}) {
  switch (authState.status) {
    case AuthFlowStatus.initializing:
      return currentLocation == AppRoutes.splash ? null : AppRoutes.splash;

    case AuthFlowStatus.unauthenticated:
      if (AppRoutes.publicAuthRoutes.contains(currentLocation)) {
        return null;
      }
      if (!onboardingCompleted) {
        return currentLocation == AppRoutes.onboarding
            ? null
            : AppRoutes.onboarding;
      }
      return AppRoutes.login;

    case AuthFlowStatus.needsEmailVerification:
      return currentLocation == AppRoutes.emailVerification
          ? null
          : AppRoutes.emailVerification;

    case AuthFlowStatus.needsProfileSetup:
      return currentLocation == AppRoutes.profileSetup
          ? null
          : AppRoutes.profileSetup;

    case AuthFlowStatus.authenticated:
      if (AppRoutes.allAuthAndIntroRoutes.contains(currentLocation) ||
          currentLocation == '/') {
        return AppRoutes.home;
      }
      return null;
  }
}

/// Riverpod auth ve tercih değişikliklerini `GoRouter.refreshListenable`a köprüler.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen<AuthSessionState>(
      authControllerProvider,
      (_, _) => notifyListeners(),
    );
    ref.listen<AppPreferencesState>(appPreferencesProvider, (previous, next) {
      if (previous?.onboardingCompleted != next.onboardingCompleted) {
        notifyListeners();
      }
    });
  }
}

/// Uygulamanın merkezi [GoRouter] örneğini Riverpod üzerinden sağlar.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final onboardingCompleted = ref
          .read(appPreferencesProvider)
          .onboardingCompleted;

      return resolveAuthRedirect(
        currentLocation: state.matchedLocation,
        authState: authState,
        onboardingCompleted: onboardingCompleted,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Sabit 5 ana sekme (`B01`, `B02`, `C01`, `E01`, `F01`).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _RoamoryMainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) => const MyMapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.community,
                builder: (context, state) => const CommunityFeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const MyProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // B03, B04, B05 — Keşif ve İstek Listesi Alt Rotaları.
      GoRoute(
        path: AppRoutes.exploreSearch,
        builder: (context, state) => const SearchFilterScreen(),
      ),
      GoRoute(
        path: '/explore/places/:placeId',
        builder: (context, state) =>
            PlaceDetailsScreen(placeId: state.pathParameters['placeId'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.wishlist,
        builder: (context, state) => const WishlistScreen(),
      ),

      // C03, C04, C05, C06 — Ziyaret ve Gezi Günlüğü Alt Rotaları.
      GoRoute(
        path: AppRoutes.visitsHistory,
        builder: (context, state) => const VisitHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.visitAdd,
        builder: (context, state) => AddVisitAndJournalScreen(
          initialPlaceId: state.uri.queryParameters['placeId'],
          initialStep: 1,
        ),
      ),
      GoRoute(
        path: '/visits/:visitId/journal',
        builder: (context, state) => AddVisitAndJournalScreen(
          editingVisitId: state.pathParameters['visitId'],
          initialStep: 2,
        ),
      ),
      GoRoute(
        path: '/visits/:visitId',
        builder: (context, state) =>
            VisitDetailsScreen(visitId: state.pathParameters['visitId'] ?? ''),
      ),

      // D01, D02, D03, D04, D05 — Seyahat Planlama Alt Rotaları.
      GoRoute(
        path: AppRoutes.trips,
        builder: (context, state) => const MyTripsScreen(),
      ),
      GoRoute(
        path: AppRoutes.tripCreate,
        builder: (context, state) => CreateTripScreen(
          editingTripId: state.uri.queryParameters['tripId'],
        ),
      ),
      GoRoute(
        path: '/trips/:tripId',
        builder: (context, state) =>
            TripDetailsScreen(tripId: state.pathParameters['tripId'] ?? ''),
      ),
      GoRoute(
        path: '/trips/:tripId/itinerary',
        builder: (context, state) =>
            DailyItineraryScreen(tripId: state.pathParameters['tripId'] ?? ''),
      ),
      GoRoute(
        path: '/trips/:tripId/checklist',
        builder: (context, state) =>
            TripChecklistScreen(tripId: state.pathParameters['tripId'] ?? ''),
      ),

      // E02, E03, E04, E05, E06 — Topluluk ve Sosyal Alt Rotaları.
      GoRoute(
        path: AppRoutes.postCreate,
        builder: (context, state) => CreatePostScreen(
          initialVisitId: state.uri.queryParameters['visitId'],
          initialPlaceId: state.uri.queryParameters['placeId'],
          initialTripId: state.uri.queryParameters['tripId'],
        ),
      ),
      GoRoute(
        path: '/community/posts/:postId',
        builder: (context, state) =>
            PostDetailsScreen(postId: state.pathParameters['postId'] ?? ''),
      ),
      GoRoute(
        path: '/community/posts/:postId/comments',
        builder: (context, state) =>
            CommentsScreen(postId: state.pathParameters['postId'] ?? ''),
      ),
      GoRoute(
        path: '/community/travelers/:userId',
        builder: (context, state) =>
            TravelerProfileScreen(userId: state.pathParameters['userId'] ?? ''),
      ),
      GoRoute(
        path: '/community/travelers/:userId/connections',
        builder: (context, state) => FollowersFollowingScreen(
          userId: state.pathParameters['userId'] ?? '',
          initialShowFollowers: state.uri.queryParameters['tab'] != 'following',
        ),
      ),

      // F02, F03, F04, F05 — Profil Düzenleme, Bildirimler ve Ayarlar Rotaları.
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountSecurity,
        builder: (context, state) => const AccountSecurityScreen(),
      ),
    ],
  );
});

class _RoamoryMainShell extends StatelessWidget {
  const _RoamoryMainShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return RoamoryScaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
