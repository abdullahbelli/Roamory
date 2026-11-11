import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
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
import 'package:roamory/shared/widgets/app_bottom_navigation.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/roamory_scaffold.dart';

/// Uygulama genelindeki adlandırılmış rota yolları.
///
/// Beş sabit ana sekme kabuk (shell) içinde yer alır; auth akışları ve
/// `trips` / `settings` alt rotaları kabuk dışında tanımlanır.
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

  /// Haritam sekmesi (`C01`).
  static const String map = '/map';

  /// Topluluk sekmesi (`E01`).
  static const String community = '/community';

  /// Profil sekmesi (`F01`).
  static const String profile = '/profile';

  /// Seyahatlerim alt rotası (`D01`, alt çubuğun altıncı sekmesi değildir).
  static const String trips = '/trips';

  /// Ayarlar alt rotası (`F04`).
  static const String settings = '/settings';

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
///
/// Saf fonksiyon olarak tutulduğu için hem [GoRouter.redirect] içinde hem de
/// birim testlerinde doğrudan doğrulanabilir.
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
      // Profil kurulumu tamamlanmadan ana uygulamanın hiçbir rotasına izin verilmez.
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
      // Sabit 5 ana sekme için durumunu koruyan kabuk yönlendirme yapısı.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _RoamoryMainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return _PlaceholderTabScreen(
                    title: l10n.navHome,
                    subtitle: l10n.homeComingSoonSubtitle,
                    icon: Icons.explore_outlined,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return _PlaceholderTabScreen(
                    title: l10n.navExplore,
                    subtitle: l10n.exploreComingSoonSubtitle,
                    icon: Icons.travel_explore_outlined,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.map,
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return _PlaceholderTabScreen(
                    title: l10n.navMap,
                    subtitle: l10n.mapComingSoonSubtitle,
                    icon: Icons.location_on_outlined,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.community,
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return _PlaceholderTabScreen(
                    title: l10n.navCommunity,
                    subtitle: l10n.communityComingSoonSubtitle,
                    icon: Icons.groups_outlined,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const _ProfileShellPlaceholder(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.trips,
        builder: (context, state) {
          final l10n = AppLocalizations.of(context);
          return RoamoryScaffold(
            appBar: AppBar(title: Text(l10n.tripsTitle)),
            body: EmptyState(
              icon: Icons.luggage_outlined,
              title: l10n.tripsTitle,
              message: l10n.emptyDefaultMessage,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) {
          final l10n = AppLocalizations.of(context);
          return RoamoryScaffold(
            appBar: AppBar(title: Text(l10n.settingsTitle)),
            body: EmptyState(
              icon: Icons.settings_outlined,
              title: l10n.settingsTitle,
              message: l10n.emptyDefaultMessage,
            ),
          );
        },
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
          // Aynı sekmeye tekrar dokunulduğunda o dalın kök rotasına dönüyoruz.
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _PlaceholderTabScreen extends StatelessWidget {
  const _PlaceholderTabScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: EmptyState(icon: icon, title: title, message: subtitle),
    );
  }
}

/// Profil sekmesi (`F01` P5'te kodlanana kadar) için gerçek çıkış aksiyonu sunar.
class _ProfileShellPlaceholder extends ConsumerWidget {
  const _ProfileShellPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(authControllerProvider);
    final action = ref.watch(authActionProvider);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
        child: Column(
          children: [
            Expanded(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: session.profile?.fullName ?? l10n.navProfile,
                message: session.profile?.username != null
                    ? '@${session.profile!.username}'
                    : l10n.profileComingSoonSubtitle,
              ),
            ),
            SecondaryButton(
              label: l10n.authSignOut,
              outlined: true,
              icon: Icons.logout_rounded,
              onPressed: action.isLoading
                  ? null
                  : () async {
                      final ok = await showAppConfirmSheet(
                        context: context,
                        title: l10n.authSignOutConfirmTitle,
                        message: l10n.authSignOutConfirmMessage,
                        confirmLabel: l10n.authSignOut,
                        isDestructive: true,
                      );
                      if (ok) {
                        await ref.read(authActionProvider.notifier).signOut();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
