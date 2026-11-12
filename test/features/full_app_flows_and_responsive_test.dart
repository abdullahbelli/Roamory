import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roamory/app/app.dart';
import 'package:roamory/app/router/app_router.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_theme.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/features/community/presentation/screens/create_post_screen.dart';
import 'package:roamory/features/community/presentation/screens/post_details_screen.dart';
import 'package:roamory/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:roamory/features/auth/domain/entities/auth_user.dart';
import 'package:roamory/features/auth/domain/entities/user_profile.dart';
import 'package:roamory/features/auth/domain/repositories/auth_repository.dart';
import 'package:roamory/features/community/data/repositories/supabase_community_repository.dart';
import 'package:roamory/features/community/domain/entities/post_entity.dart';
import 'package:roamory/features/community/domain/repositories/community_repository.dart';
import 'package:roamory/features/explore/data/repositories/supabase_explore_repository.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/explore/domain/repositories/explore_repository.dart';
import 'package:roamory/features/notifications/domain/entities/notification_entity.dart';
import 'package:roamory/features/profile/data/repositories/supabase_profile_settings_repository.dart';
import 'package:roamory/features/profile/domain/repositories/profile_settings_repository.dart';
import 'package:roamory/features/profile/presentation/providers/profile_settings_controller.dart';
import 'package:roamory/features/trips/data/repositories/supabase_trips_repository.dart';
import 'package:roamory/features/trips/domain/entities/trip_entity.dart';
import 'package:roamory/features/trips/domain/repositories/trips_repository.dart';
import 'package:roamory/features/trips/presentation/screens/create_trip_screen.dart';
import 'package:roamory/features/trips/presentation/screens/daily_itinerary_screen.dart';
import 'package:roamory/features/trips/presentation/screens/trip_checklist_screen.dart';
import 'package:roamory/features/trips/presentation/screens/trip_details_screen.dart';
import 'package:roamory/features/visits/data/repositories/supabase_visits_repository.dart';
import 'package:roamory/features/visits/domain/entities/visit_entity.dart';
import 'package:roamory/features/visits/domain/repositories/visits_repository.dart';
import 'package:roamory/features/wishlist/data/repositories/supabase_wishlist_repository.dart';
import 'package:roamory/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:roamory/features/wishlist/domain/repositories/wishlist_repository.dart';

class _WidgetPrefs implements AppPreferencesStorage {
  Locale? locale = const Locale('tr');
  ThemeMode themeMode = ThemeMode.light;
  bool onboardingCompleted = true;

  @override
  AppPreferencesState loadSync() => AppPreferencesState(
    locale: locale,
    themeMode: themeMode,
    onboardingCompleted: onboardingCompleted,
  );

  @override
  Future<void> saveLocaleCode(String? languageCode) async {
    locale = languageCode == null ? null : Locale(languageCode);
  }

  @override
  Future<void> saveOnboardingCompleted(bool completed) async {
    onboardingCompleted = completed;
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    themeMode = mode;
  }
}

class _AuthenticatedAuthRepo implements AuthRepository {
  @override
  AuthUser? getCurrentUser() => const AuthUser(
    id: 'user-1',
    email: 'deniz@roamory.com',
    emailVerified: true,
    fullName: 'Deniz Aksoy',
  );

  @override
  Stream<AuthUser?> watchAuthChanges() => const Stream.empty();

  @override
  Future<UserProfile?> fetchProfile(String userId) async => const UserProfile(
    id: 'user-1',
    username: 'deniz_aksoy',
    fullName: 'Deniz Aksoy',
    bio: 'Doğa ve tarih gezgini',
  );

  @override
  Future<bool> isUsernameAvailable({
    required String username,
    required String currentUserId,
  }) async => true;

  @override
  Future<AuthUser?> refreshCurrentUser() async => getCurrentUser();

  @override
  Future<void> resendVerificationEmail({required String email}) async {}

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async => getCurrentUser()!;

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser?> signUpWithEmail(SignUpRequest request) async =>
      getCurrentUser();

  @override
  Future<UserProfile> upsertProfile(ProfileUpsertRequest request) async =>
      UserProfile(
        id: request.userId,
        username: request.username,
        fullName: request.fullName,
        preferredLanguage: request.preferredLanguage,
      );

  @override
  Future<AuthUser> verifyEmailOtp({
    required String email,
    required String token,
  }) async => getCurrentUser()!;
}

class _WidgetExploreRepo implements ExploreRepository {
  static const samplePlace = PlaceEntity(
    id: 'place-1',
    name: 'Kabak Koyu',
    country: 'Türkiye',
    city: 'Muğla',
    latitude: 36.4622,
    longitude: 29.1244,
    description: 'Likya yolu üzerinde sakin koy.',
    categorySlug: 'nature',
    averageRating: 4.8,
  );

  @override
  Future<List<CategoryEntity>> fetchCategories() async => const [
    CategoryEntity(id: 'c1', slug: 'nature', nameTr: 'Doğa', nameEn: 'Nature'),
  ];

  @override
  Future<List<PlaceEntity>> fetchPlaces({
    PlaceSearchFilter filter = const PlaceSearchFilter(),
    String? currentUserId,
  }) async => SupabaseExploreRepository.applyFilter(
    const [samplePlace],
    filter,
    currentUserId: currentUserId,
  );

  @override
  Future<PlaceEntity> fetchPlaceById(String placeId) async => samplePlace;

  @override
  Future<PlaceEntity> createPrivatePlace(
    CreatePrivatePlaceRequest request,
  ) async => samplePlace;
}

class _WidgetWishlistRepo implements WishlistRepository {
  final List<WishlistItemEntity> items = [
    WishlistItemEntity(
      id: 'w-1',
      userId: 'user-1',
      placeId: 'place-1',
      createdAt: DateTime(2026, 4, 12),
      note: 'Baharda gidilecek',
      place: _WidgetExploreRepo.samplePlace,
    ),
  ];

  @override
  Future<List<WishlistItemEntity>> fetchWishlist(String userId) async => items;

  @override
  Future<WishlistItemEntity> addToWishlist({
    required String userId,
    required String placeId,
    String? note,
  }) async => items.first;

  @override
  Future<WishlistItemEntity> updateWishlistNote({
    required String itemId,
    required String userId,
    String? note,
  }) async => items.first;

  @override
  Future<void> removeFromWishlist({
    required String userId,
    required String placeId,
  }) async {
    items.removeWhere((w) => w.placeId == placeId);
  }
}

class _WidgetVisitsRepo implements VisitsRepository {
  final List<VisitEntity> visits = [
    VisitEntity(
      id: 'v-1',
      userId: 'user-1',
      placeId: 'place-1',
      visitedAt: DateTime(2026, 4, 10),
      rating: 5,
      title: 'Kabak Koyu Gün Doğumu',
      notes: 'Kişisel saha günlüğü notum.',
      place: _WidgetExploreRepo.samplePlace,
    ),
  ];

  @override
  Future<List<VisitEntity>> fetchVisits(String userId) async => visits;

  @override
  Future<VisitEntity> fetchVisitById({
    required String visitId,
    required String userId,
  }) async => visits.first;

  @override
  Future<VisitEntity> upsertVisit(UpsertVisitRequest request) async {
    final created = VisitEntity(
      id: 'v-2',
      userId: request.userId,
      placeId: request.placeId ?? 'place-1',
      visitedAt: request.visitedAt,
      rating: request.rating,
      title: request.title,
      notes: request.notes,
      place: _WidgetExploreRepo.samplePlace,
    );
    visits.insert(0, created);
    return created;
  }

  @override
  Future<void> deleteVisit({
    required String visitId,
    required String userId,
  }) async {
    visits.removeWhere((v) => v.id == visitId);
  }
}

class _WidgetTripsRepo implements TripsRepository {
  static const privatePlace = PlaceEntity(
    id: 'place-private-1',
    name: 'Gizli Kamping Alanım',
    country: 'Türkiye',
    city: 'Antalya',
    latitude: 36.2,
    longitude: 29.6,
    isPublished: false,
    createdBy: 'user-1',
  );

  final List<UpsertTripRequest> upsertedRequests = [];
  final List<TripEntity> trips = [
    TripEntity(
      id: 'trip-1',
      userId: 'user-1',
      title: 'Likya Rotası',
      country: 'TR',
      city: 'Muğla',
      description: 'Güney kıyı yürüyüşü',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 2),
      days: const [
        TripDayEntity(
          id: 'day-1',
          tripId: 'trip-1',
          dayNumber: 1,
          stops: [
            TripStopEntity(
              id: 'stop-1',
              tripDayId: 'day-1',
              placeId: 'place-1',
              orderIndex: 0,
              place: _WidgetExploreRepo.samplePlace,
            ),
          ],
        ),
      ],
      checklist: const [
        TripChecklistItemEntity(
          id: 'chk-1',
          tripId: 'trip-1',
          title: 'Kafa lambası',
          category: TripChecklistCategory.packing,
          isCompleted: false,
        ),
      ],
    ),
  ];

  @override
  Future<List<TripEntity>> fetchTrips(String userId) async => trips;

  @override
  Future<TripEntity> fetchTripById({
    required String tripId,
    required String userId,
  }) async => trips.firstWhere((t) => t.id == tripId);

  @override
  Future<TripEntity> upsertTrip(UpsertTripRequest request) async {
    upsertedRequests.add(request);
    final idx = request.tripId == null
        ? -1
        : trips.indexWhere((t) => t.id == request.tripId);
    if (idx >= 0) {
      final existing = trips[idx];
      final missingDayPayloads =
          SupabaseTripsRepository.buildMissingDaysForExtendedTrip(
            tripId: existing.id,
            existingDays: existing.days,
            newStartDate: request.startDate,
            newEndDate: request.endDate,
          );
      final maxDayNumber = existing.days.fold<int>(
        0,
        (maxVal, day) => day.dayNumber > maxVal ? day.dayNumber : maxVal,
      );
      final updated = existing.copyWith(
        title: request.title,
        country: request.country,
        city: request.city,
        description: request.description,
        startDate: request.startDate,
        endDate: request.endDate,
        status: request.status,
        days: [
          ...existing.days,
          for (var i = 0; i < missingDayPayloads.length; i++)
            TripDayEntity(
              id: 'day-${existing.id}-${maxDayNumber + i + 1}',
              tripId: existing.id,
              dayNumber: maxDayNumber + i + 1,
              dayDate: DateTime.parse(
                missingDayPayloads[i]['day_date'].toString(),
              ),
              title: missingDayPayloads[i]['title']?.toString(),
            ),
        ],
      );
      trips[idx] = updated;
      return updated;
    }
    final created = TripEntity(
      id: 'trip-${trips.length + 1}',
      userId: request.userId,
      title: request.title,
      country: request.country,
      city: request.city,
      description: request.description,
      startDate: request.startDate,
      endDate: request.endDate,
      status: request.status,
      days: [
        TripDayEntity(
          id: 'day-new-1',
          tripId: 'trip-${trips.length + 1}',
          dayNumber: 1,
          dayDate: request.startDate,
        ),
      ],
    );
    trips.insert(0, created);
    return created;
  }

  @override
  Future<void> deleteTrip({
    required String tripId,
    required String userId,
  }) async {
    trips.removeWhere((t) => t.id == tripId);
  }

  @override
  Future<TripDayEntity> addTripDay({
    required String tripId,
    required int dayNumber,
    DateTime? dayDate,
    String? title,
    String? notes,
  }) async {
    final day = TripDayEntity(
      id: 'day-$dayNumber',
      tripId: tripId,
      dayNumber: dayNumber,
      dayDate: dayDate,
      title: title,
      notes: notes,
    );
    final idx = trips.indexWhere((t) => t.id == tripId);
    if (idx >= 0) {
      trips[idx] = trips[idx].copyWith(days: [...trips[idx].days, day]);
    }
    return day;
  }

  @override
  Future<TripDayEntity> updateTripDay({
    required String tripDayId,
    String? title,
    String? notes,
  }) async => trips.first.days.first;

  @override
  Future<TripStopEntity> addTripStop({
    required String tripDayId,
    required String placeId,
    required int orderIndex,
    String? notes,
    String? arrivalTime,
  }) async {
    final stop = TripStopEntity(
      id: 'stop-$tripDayId-$orderIndex',
      tripDayId: tripDayId,
      placeId: placeId,
      orderIndex: orderIndex,
      notes: notes,
      arrivalTime: arrivalTime,
      place: placeId == privatePlace.id
          ? privatePlace
          : _WidgetExploreRepo.samplePlace,
    );
    for (var ti = 0; ti < trips.length; ti++) {
      final di = trips[ti].days.indexWhere((d) => d.id == tripDayId);
      if (di >= 0) {
        final days = [...trips[ti].days];
        days[di] = days[di].copyWith(stops: [...days[di].stops, stop]);
        trips[ti] = trips[ti].copyWith(days: days);
        break;
      }
    }
    return stop;
  }

  @override
  Future<List<TripStopEntity>> reorderTripStops({
    required String tripDayId,
    required List<String> orderedStopIds,
  }) async {
    for (var ti = 0; ti < trips.length; ti++) {
      final di = trips[ti].days.indexWhere((d) => d.id == tripDayId);
      if (di >= 0) {
        final byId = {for (final s in trips[ti].days[di].stops) s.id: s};
        final reordered = [
          for (var i = 0; i < orderedStopIds.length; i++)
            byId[orderedStopIds[i]]!.copyWith(orderIndex: i),
        ];
        final days = [...trips[ti].days];
        days[di] = days[di].copyWith(stops: reordered);
        trips[ti] = trips[ti].copyWith(days: days);
        return reordered;
      }
    }
    return trips.first.days.first.stops;
  }

  @override
  Future<void> deleteTripStop(String stopId) async {}

  @override
  Future<TripChecklistItemEntity> addChecklistItem({
    required String tripId,
    required String title,
    String category = TripChecklistCategory.other,
    int sortOrder = 0,
  }) async {
    final item = TripChecklistItemEntity(
      id: 'chk-${DateTime.now().microsecondsSinceEpoch}',
      tripId: tripId,
      title: title,
      category: category,
      sortOrder: sortOrder,
    );
    final idx = trips.indexWhere((t) => t.id == tripId);
    if (idx >= 0) {
      trips[idx] = trips[idx].copyWith(
        checklist: [...trips[idx].checklist, item],
      );
    }
    return item;
  }

  @override
  Future<TripChecklistItemEntity> updateChecklistItem({
    required String itemId,
    bool? isCompleted,
    String? title,
    String? category,
  }) async {
    for (var ti = 0; ti < trips.length; ti++) {
      final ci = trips[ti].checklist.indexWhere((c) => c.id == itemId);
      if (ci >= 0) {
        final updated = trips[ti].checklist[ci].copyWith(
          isCompleted: isCompleted ?? trips[ti].checklist[ci].isCompleted,
          title: title ?? trips[ti].checklist[ci].title,
          category: category ?? trips[ti].checklist[ci].category,
        );
        final list = [...trips[ti].checklist];
        list[ci] = updated;
        trips[ti] = trips[ti].copyWith(checklist: list);
        return updated;
      }
    }
    return TripChecklistItemEntity(
      id: itemId,
      tripId: 'trip-1',
      title: 'Kafa lambası',
      isCompleted: isCompleted ?? true,
    );
  }

  @override
  Future<void> deleteChecklistItem(String itemId) async {
    for (var ti = 0; ti < trips.length; ti++) {
      trips[ti] = trips[ti].copyWith(
        checklist: trips[ti].checklist.where((c) => c.id != itemId).toList(),
      );
    }
  }
}

class _WidgetCommunityRepo implements CommunityRepository {
  final List<PostEntity> posts = [
    PostEntity(
      id: 'post-1',
      userId: 'user-2',
      title: 'Faralya Keşfi',
      caption: 'Kelebekler Vadisi üst patika notları.',
      createdAt: DateTime(2026, 4, 11),
      author: const TravelerSummaryEntity(
        id: 'user-2',
        username: 'ege_kaya',
        fullName: 'Ege Kaya',
      ),
      place: _WidgetExploreRepo.samplePlace,
    ),
  ];

  @override
  Future<List<PostEntity>> fetchFeed({
    required String currentUserId,
    bool followingOnly = false,
    String? placeId,
    String? authorId,
    int limit = 20,
    int offset = 0,
  }) async => posts;

  @override
  Future<PostEntity> fetchPostById({
    required String postId,
    required String currentUserId,
  }) async => posts.firstWhere((p) => p.id == postId);

  @override
  Future<List<PostEntity>> fetchSavedPosts(String currentUserId) async =>
      const [];

  @override
  Future<PostEntity> createPost(CreatePostRequest request) async => posts.first;

  @override
  Future<void> deletePost({
    required String postId,
    required String currentUserId,
  }) async {}

  @override
  Future<PostEntity> toggleLike({
    required String postId,
    required String currentUserId,
  }) async => posts.first.copyWith(likeCount: 1, isLikedByCurrentUser: true);

  @override
  Future<PostEntity> toggleSavePost({
    required String postId,
    required String currentUserId,
  }) async => posts.first.copyWith(isSavedByCurrentUser: true);

  @override
  Future<List<CommentEntity>> fetchComments(String postId) async => [
    CommentEntity(
      id: 'c-1',
      postId: postId,
      userId: 'user-2',
      body: 'Muhteşem manzara!',
      createdAt: DateTime(2026, 4, 11),
      author: const TravelerSummaryEntity(
        id: 'user-2',
        username: 'ege_kaya',
        fullName: 'Ege Kaya',
      ),
    ),
  ];

  @override
  Future<CommentEntity> addComment({
    required String postId,
    required String currentUserId,
    required String body,
  }) async => CommentEntity(
    id: 'c-2',
    postId: postId,
    userId: currentUserId,
    body: body,
    createdAt: DateTime(2026, 4, 12),
  );

  @override
  Future<void> deleteComment({
    required String commentId,
    required String currentUserId,
  }) async {}

  @override
  Future<TravelerSummaryEntity> fetchTravelerProfile({
    required String targetUserId,
    required String currentUserId,
  }) async => const TravelerSummaryEntity(
    id: 'user-2',
    username: 'ege_kaya',
    fullName: 'Ege Kaya',
    postsCount: 1,
    followersCount: 3,
    followingCount: 2,
  );

  @override
  Future<List<TravelerSummaryEntity>> fetchFollowConnections({
    required String targetUserId,
    required String currentUserId,
    required bool followers,
  }) async => const [
    TravelerSummaryEntity(
      id: 'user-2',
      username: 'ege_kaya',
      fullName: 'Ege Kaya',
    ),
  ];

  @override
  Future<TravelerSummaryEntity> toggleFollow({
    required String targetUserId,
    required String currentUserId,
  }) async => const TravelerSummaryEntity(
    id: 'user-2',
    username: 'ege_kaya',
    fullName: 'Ege Kaya',
    isFollowedByCurrentUser: true,
  );

  @override
  Future<List<TravelerSummaryEntity>> fetchBlockedUsers(
    String currentUserId,
  ) async => const [];

  @override
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {}

  @override
  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {}

  @override
  Future<void> reportContent({
    required String reporterUserId,
    required String reason,
    String? targetPostId,
    String? targetCommentId,
    String? targetUserId,
    String? details,
  }) async {}
}

class _WidgetProfileSettingsRepo implements ProfileAndSettingsRepository {
  int markReadCalls = 0;
  int markAllReadCalls = 0;

  @override
  Future<List<NotificationEntity>> fetchNotifications(String userId) async => [
    NotificationEntity(
      id: 'n-1',
      userId: userId,
      actorUserId: 'user-2',
      kind: NotificationKind.follow,
      title: 'Yeni Takipçi',
      body: 'Ege Kaya seni takip etmeye başladı.',
      createdAt: DateTime(2026, 4, 12),
    ),
    NotificationEntity(
      id: 'n-2',
      userId: userId,
      actorUserId: 'user-2',
      targetPostId: 'post-1',
      kind: NotificationKind.comment,
      title: 'Yeni Yorum',
      body: 'Ege Kaya: Çok güzel rota!',
      createdAt: DateTime(2026, 4, 13),
    ),
  ];

  @override
  Future<void> markNotificationRead({
    required String notificationId,
    required String userId,
  }) async {
    markReadCalls++;
  }

  @override
  Future<void> markAllNotificationsRead(String userId) async {
    markAllReadCalls++;
  }

  @override
  Future<UserProfile> updateExtendedProfile({
    required String userId,
    required String fullName,
    required String username,
    required String preferredLanguage,
    String? bio,
    String? homeCity,
    String? homeCountry,
    bool isPublic = true,
    Uint8List? avatarBytes,
    String? avatarFileExtension,
  }) async => UserProfile(
    id: userId,
    fullName: fullName,
    username: username,
    bio: bio,
    homeCity: homeCity,
    homeCountry: homeCountry,
    isPublic: isPublic,
    preferredLanguage: preferredLanguage,
  );

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  Future<void> deleteUserAccountData(String userId) async {}
}

List<dynamic> _buildOverrides(
  _WidgetPrefs prefs, {
  TripsRepository? tripsRepo,
  VisitsRepository? visitsRepo,
  ProfileAndSettingsRepository? profileRepo,
}) => [
  appPreferencesStorageProvider.overrideWithValue(prefs),
  authRepositoryProvider.overrideWithValue(_AuthenticatedAuthRepo()),
  exploreRepositoryProvider.overrideWithValue(_WidgetExploreRepo()),
  wishlistRepositoryProvider.overrideWithValue(_WidgetWishlistRepo()),
  visitsRepositoryProvider.overrideWithValue(visitsRepo ?? _WidgetVisitsRepo()),
  tripsRepositoryProvider.overrideWithValue(tripsRepo ?? _WidgetTripsRepo()),
  communityRepositoryProvider.overrideWithValue(_WidgetCommunityRepo()),
  profileSettingsRepositoryProvider.overrideWithValue(
    profileRepo ?? _WidgetProfileSettingsRepo(),
  ),
];

void main() {
  testWidgets(
    // Amaç: 5 ana sekme (B01 Home, B02 Explore, C01 Map, E01 Community, F01 Profile)
    // ve alt rotalar (B03-B05, C02-C06, D01-D05, E02-E06, F02-F05) gerçek verilerle
    // ve hatasız şekilde görüntülenip gezilebilmelidir.
    'Tüm 5 ana sekme ve alt özellik ekranları uçtan uca yönlendirme ile çalışır',
    (tester) async {
      final prefs = _WidgetPrefs();
      final container = ProviderContainer(
        overrides: _buildOverrides(prefs).cast(),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      // 1) B01 Home Screen: Dijital Pasaport özeti ve gerçek ziyaret/rota verisi görünür.
      expect(find.text('Seyahat İzin'), findsOneWidget);
      expect(find.text('Likya Rotası'), findsOneWidget);

      final router = container.read(appRouterProvider);

      // 2) B02 Explore Screen & B03 Search & B04 Place Details & B05 Wishlist.
      router.go(AppRoutes.explore);
      await tester.pumpAndSettle();
      expect(find.text('Kabak Koyu'), findsOneWidget);

      router.push(AppRoutes.exploreSearch);
      await tester.pumpAndSettle();
      expect(find.text('Arama ve Filtreler'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();

      router.push(AppRoutes.placeDetailsPath('place-1'));
      await tester.pumpAndSettle();
      expect(find.text('Gittim / Günlüğe Ekle'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('© OpenStreetMap katkıda bulunanlar'),
        200,
      );
      await tester.pumpAndSettle();
      expect(find.text('© OpenStreetMap katkıda bulunanlar'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();

      router.push(AppRoutes.wishlist);
      await tester.pumpAndSettle();
      expect(find.text('İstek Listem'), findsOneWidget);
      expect(find.text('Baharda gidilecek'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();

      // 3) C01 My Map (flutter_map + OSM attribution) & C02 Map Filter & C03-C06 Visits/Journal.
      router.go(AppRoutes.map);
      await tester.pumpAndSettle();
      expect(find.text('© OpenStreetMap katkıda bulunanlar'), findsOneWidget);
      expect(find.text('1 Ziyaret • 1 İstek Listesi'), findsOneWidget);

      await tester.tap(find.text('Harita Filtresi'));
      await tester.pumpAndSettle();
      expect(find.text('Gösterilecek Pinler'), findsOneWidget);
      await tester.tap(find.text('Uygula'));
      await tester.pumpAndSettle();

      router.push(AppRoutes.visitsHistory);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'visitsHistory');
      expect(find.text('Ziyaret Geçmişim'), findsOneWidget);
      expect(find.text('Kabak Koyu Gün Doğumu'), findsOneWidget);

      router.push(AppRoutes.visitDetailsPath('v-1'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'visitDetails');
      expect(find.text('Gönderiye Dönüştür'), findsOneWidget);

      router.push(AppRoutes.visitAdd);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'visitAdd');
      expect(find.text('Ziyaret Kaydı (Adım 1 / 2)'), findsOneWidget);

      router.push(AppRoutes.visitJournalPath('v-1'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'visitJournal');
      expect(find.text('Gezi Günlüğü (Adım 2 / 2)'), findsOneWidget);

      // 4) D01-D05 Trips, Create Trip, Trip Details, Daily Itinerary, Checklist.
      router.go(AppRoutes.home);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'goHome');
      router.push(AppRoutes.trips);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'trips');
      expect(find.text('Seyahatlerim'), findsOneWidget);
      expect(find.text('Likya Rotası'), findsOneWidget);

      router.push(AppRoutes.tripCreate);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'tripCreate');
      expect(find.text('Seyahat Planı Oluştur'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();

      router.push(AppRoutes.tripDetailsPath('trip-1'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'tripDetails');
      expect(find.text('Günlük Planı Düzenle'), findsOneWidget);

      router.push(AppRoutes.tripItineraryPath('trip-1'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'tripItinerary');
      expect(find.text('Günlük Rota Planlayıcı'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();

      router.push(AppRoutes.tripChecklistPath('trip-1'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'tripChecklist');
      expect(find.text('Seyahat Kontrol Listesi'), findsOneWidget);
      expect(find.text('Kafa lambası'), findsOneWidget);

      // 5) E01-E06 Community Feed, Create Post, Post Details, Comments, Traveler Profile, Connections.
      router.go(AppRoutes.community);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'community');
      expect(find.text('Faralya Keşfi'), findsOneWidget);

      router.push(AppRoutes.postCreate);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'postCreate');
      expect(find.text('Topluluk Gönderisi Oluştur'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();

      router.push(AppRoutes.postDetailsPath('post-1'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'postDetails');
      expect(find.text('Gönderi Detayı'), findsOneWidget);

      router.push(AppRoutes.postCommentsPath('post-1'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'postComments');
      expect(find.text('Muhteşem manzara!'), findsOneWidget);

      router.push(AppRoutes.travelerProfilePath('user-2'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'travelerProfile');
      expect(find.text('Gezgin Profili'), findsOneWidget);

      router.push(AppRoutes.travelerConnectionsPath('user-2'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'travelerConnections');
      expect(find.text('Takipçiler'), findsWidgets);

      // 6) F01-F05 Profile, Edit Profile, Notifications, Settings (TR/EN + Light/Dark), Security.
      router.go(AppRoutes.profile);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'profile');
      expect(find.text('Profilim'), findsOneWidget);
      expect(find.text('@deniz_aksoy'), findsOneWidget);

      router.push(AppRoutes.profileEdit);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'profileEdit');
      expect(find.text('Profili Düzenle'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();

      router.push(AppRoutes.notifications);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'notifications');
      expect(find.text('Bildirimler'), findsOneWidget);
      expect(find.text('Yeni Takipçi'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();

      router.push(AppRoutes.settings);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'settings');
      expect(find.text('Ayarlar'), findsOneWidget);

      // Dil ve tema geçişini test et (TR -> EN ve Light -> Dark).
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'settingsEN');
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'settingsDark');
      expect(prefs.themeMode, ThemeMode.dark);

      await tester.tap(find.text('Türkçe'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'settingsTR');
      expect(find.text('Ayarlar'), findsOneWidget);

      router.push(AppRoutes.accountSecurity);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'accountSecurity');
      expect(find.text('Hesap ve Güvenlik'), findsWidgets);
    },
  );

  testWidgets(
    // Amaç: 320px, 393px ve 430px dar/standart/geniş mobil genişliklerde
    // hiçbir ana ekranda RenderFlex overflow (taşma) hatası oluşmamalıdır (T20).
    '320px, 393px ve 430px ekran genişliklerinde UI taşması oluşmaz',
    (tester) async {
      for (final width in <double>[320, 393, 430]) {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1.0;

        final prefs = _WidgetPrefs();
        final container = ProviderContainer(
          overrides: _buildOverrides(prefs).cast(),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const RoamoryApp(useGoogleFonts: false),
          ),
        );
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        for (final route in [
          AppRoutes.home,
          AppRoutes.explore,
          AppRoutes.map,
          AppRoutes.community,
          AppRoutes.profile,
          AppRoutes.trips,
          AppRoutes.wishlist,
          AppRoutes.settings,
        ]) {
          router.go(route);
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'Overflow on route=$route width=$width',
          );
        }

        container.dispose();
      }
      addTearDown(tester.view.reset);
    },
  );

  testWidgets(
    // Amaç: Seçili ChoiceChip ve FilterChip bileşenlerinin Light ve Dark temada
    // arka plan (colors.primary) ve metin rengi (colors.onPrimary) kontrastını koruması.
    'Seçili filtre chip renkleri Light ve Dark temada yüksek kontrast sağlar',
    (tester) async {
      for (final entry in [
        (
          theme: AppTheme.light(useGoogleFonts: false),
          colors: RoamoryColors.light,
        ),
        (
          theme: AppTheme.dark(useGoogleFonts: false),
          colors: RoamoryColors.dark,
        ),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: entry.theme,
            home: Scaffold(
              body: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Seçili Choice'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  FilterChip(
                    label: const Text('Seçili Filter'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  ChoiceChip(
                    label: const Text('Seçili Değil'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final selectedChoiceText = tester.widget<Text>(
          find.text('Seçili Choice'),
        );
        final selectedFilterText = tester.widget<Text>(
          find.text('Seçili Filter'),
        );
        final unselectedText = tester.widget<Text>(find.text('Seçili Değil'));

        // DefaultTextStyle çözümlenmiş değerini kontrol etmek için Element üzerinden
        // efektiv TextStyle.color ve RawChip arkaplanını doğrularız.
        final choiceStyle = DefaultTextStyle.of(
          tester.element(find.text('Seçili Choice')),
        ).style;
        final filterStyle = DefaultTextStyle.of(
          tester.element(find.text('Seçili Filter')),
        ).style;
        final unselectedStyle = DefaultTextStyle.of(
          tester.element(find.text('Seçili Değil')),
        ).style;

        expect(selectedChoiceText.data, 'Seçili Choice');
        expect(selectedFilterText.data, 'Seçili Filter');
        expect(unselectedText.data, 'Seçili Değil');
        expect(choiceStyle.color, entry.colors.onPrimary);
        expect(filterStyle.color, entry.colors.onPrimary);
        expect(unselectedStyle.color, entry.colors.textPrimary);

        final chipTheme = Theme.of(tester.element(find.byType(RawChip).first))
            .chipTheme;
        expect(
          chipTheme.color?.resolve({WidgetState.selected}),
          entry.colors.primary,
        );
        expect(chipTheme.color?.resolve({}), entry.colors.surface);
        expect(chipTheme.selectedColor, entry.colors.primary);
        expect(chipTheme.checkmarkColor, entry.colors.onPrimary);
      }
    },
  );

  testWidgets(
    // Amaç: Türkçe uygulama dilinde ziyaret tarihlerinin Türkçe ay adıyla gösterilmesi ve
    // ziyareti topluluk gönderisine dönüştürürken özel günlük notunun form içine sızmaması.
    'Türkçe tarihler doğru render edilir ve ziyaretten gönderiye geçişte notlar sızmaz',
    (tester) async {
      final prefs = _WidgetPrefs()..locale = const Locale('tr');
      final container = ProviderContainer(
        overrides: _buildOverrides(prefs).cast(),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      // Ziyaret özeti B01 Home üzerinde Türkçe tarih formatında ("10 Nisan 2026")
      // listelenir; bölüm katlama altındaysa ana dikey listede kaydırarak doğrularız.
      await tester.scrollUntilVisible(
        find.textContaining('10 Nisan 2026'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('10 Nisan 2026'), findsWidgets);

      // Ziyaretten topluluk gönderisi oluşturma ekranı yalnızca mekan ve başlık
      // ön bilgisini taşır; `visit.notes` hiçbir TextFormField'a kopyalanmaz.
      final router = container.read(appRouterProvider);
      router.push('${AppRoutes.postCreate}?visitId=v-1');
      await tester.pumpAndSettle();

      expect(find.byType(CreatePostScreen), findsOneWidget);
      expect(find.text('Kabak Koyu Gün Doğumu'), findsOneWidget);
      expect(find.text('Kişisel saha günlüğü notum.'), findsNothing);
    },
  );

  testWidgets(
    // Amaç: TripDetailsScreen üzerinden Düzenle butonuna basıldığında CreateTripScreen
    // düzenleme modunda ("Seyahati Düzenle") açılmalı, mevcut alanları doldurmalı,
    // kaydettiğinde yeni seyahat oluşturmadan mevcut kaydı güncellemeli ve gün/durak/checklist
    // verilerini korumalıdır.
    'Seyahat detayından Düzenle açılır, mevcut alanları doldurur ve alt verileri koruyarak UPDATE uygular',
    (tester) async {
      tester.view.physicalSize = const Size(393, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final prefs = _WidgetPrefs()..locale = const Locale('tr');
      final tripsRepo = _WidgetTripsRepo();
      final container = ProviderContainer(
        overrides: _buildOverrides(prefs, tripsRepo: tripsRepo).cast(),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      final router = container.read(appRouterProvider);
      router.push(AppRoutes.tripDetailsPath('trip-1'));
      await tester.pumpAndSettle();
      expect(find.byType(TripDetailsScreen), findsOneWidget);

      // Düzenle butonuna dokun -> query parametresiyle CreateTripScreen açılmalı.
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(CreateTripScreen), findsOneWidget);
      expect(find.text('Seyahati Düzenle'), findsOneWidget);
      expect(find.text('Likya Rotası'), findsOneWidget);
      expect(find.text('Türkiye'), findsOneWidget);
      expect(find.text('Muğla'), findsOneWidget);
      expect(find.text('Güney kıyı yürüyüşü'), findsOneWidget);

      // Başlığı güncelleyip Kaydet'e bas.
      await tester.enterText(
        find.byType(TextFormField).first,
        'Likya Rotası Güncel',
      );
      final listFinder = find
          .descendant(
            of: find.byType(CreateTripScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      final saveButton = find.descendant(
        of: find.byType(CreateTripScreen),
        matching: find.text('Kaydet'),
      );
      await tester.dragUntilVisible(
        saveButton,
        listFinder,
        const Offset(0, -250),
      );
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Yeni seyahat oluşturulmamış olmalı; UPDATE ile dönüp detay ekranını güncellemeli.
      expect(tripsRepo.upsertedRequests.length, 1);
      expect(tripsRepo.upsertedRequests.first.tripId, 'trip-1');
      expect(tripsRepo.trips.length, 1);
      expect(tripsRepo.trips.first.days.first.id, 'day-1');
      expect(tripsRepo.trips.first.days.first.stops.first.id, 'stop-1');
      expect(tripsRepo.trips.first.checklist.first.id, 'chk-1');
      expect(find.byType(TripDetailsScreen), findsOneWidget);
      expect(find.text('Likya Rotası Güncel'), findsWidgets);
    },
  );

  testWidgets(
    // Amaç: Günlük Rota Planlayıcıda "+ Gün Ekle" ile gün eklenebilmeli, kullanıcının
    // özel mekanı ("Gizli Kamping Alanım (Özel)") durak olarak eklenebilmeli ve
    // Kontrol Listesi ekranında yeni madde eklenip tamamlanabilmelidir.
    'Günlük rota planlayıcıda gün ve özel mekan durağı eklenir; kontrol listesi öğesi eklenip işaretlenir',
    (tester) async {
      final prefs = _WidgetPrefs()..locale = const Locale('tr');
      final tripsRepo = _WidgetTripsRepo();
      final visitsRepo = _WidgetVisitsRepo()
        ..visits.add(
          VisitEntity(
            id: 'v-private',
            userId: 'user-1',
            placeId: _WidgetTripsRepo.privatePlace.id,
            visitedAt: DateTime(2026, 4, 15),
            title: 'Özel Kamp Ziyareti',
            place: _WidgetTripsRepo.privatePlace,
          ),
        );
      final container = ProviderContainer(
        overrides: _buildOverrides(
          prefs,
          tripsRepo: tripsRepo,
          visitsRepo: visitsRepo,
        ).cast(),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      final router = container.read(appRouterProvider);
      router.push(AppRoutes.tripItineraryPath('trip-1'));
      await tester.pumpAndSettle();
      expect(find.byType(DailyItineraryScreen), findsOneWidget);

      // + Gün Ekle'ye bas -> 2. Gün eklenip seçili hale gelmeli.
      await tester.tap(find.text('+ Gün Ekle'));
      await tester.pumpAndSettle();
      expect(tripsRepo.trips.first.days.length, 2);
      expect(find.text('2. Gün'), findsWidgets);

      // Yeni Durak Ekle alt sayfasını aç ve özel mekanı seçerek 2. güne ekle.
      await tester.tap(find.text('Yeni Durak Ekle').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gizli Kamping Alanım (Özel Günlük)').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ekle').last);
      await tester.pumpAndSettle();

      expect(
        tripsRepo.trips.first.days[1].stops.any(
          (s) => s.placeId == _WidgetTripsRepo.privatePlace.id,
        ),
        isTrue,
      );
      expect(find.text('Gizli Kamping Alanım'), findsOneWidget);

      // Kontrol Listesi ekranına geç, yeni madde ekle ve mevcut maddeyi tamamla.
      router.push(AppRoutes.tripChecklistPath('trip-1'));
      await tester.pumpAndSettle();
      expect(find.byType(TripChecklistScreen), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Güneş kremi');
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Güneş kremi'), findsOneWidget);
      // Varsayılan kategori veritabanına `other`, ekrana "Genel Hazırlık" olarak yansır.
      expect(
        tripsRepo.trips.first.checklist
            .firstWhere((c) => c.title == 'Güneş kremi')
            .category,
        TripChecklistCategory.other,
      );

      // Rezervasyonlar -> DB kodu `bookings` olarak eklenir.
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rezervasyonlar').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Otel onayı');
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(
        tripsRepo.trips.first.checklist
            .firstWhere((c) => c.title == 'Otel onayı')
            .category,
        TripChecklistCategory.bookings,
      );

      // Tamamlama, geri alma, filtreleme ve silme doğrulaması.
      await tester.tap(find.text('Kafa lambası'));
      await tester.pumpAndSettle();
      expect(
        tripsRepo.trips.first.checklist
            .firstWhere((c) => c.id == 'chk-1')
            .isCompleted,
        isTrue,
      );
      await tester.tap(find.text('Tamamlananlar'));
      await tester.pumpAndSettle();
      expect(find.text('Kafa lambası'), findsOneWidget);
      expect(find.text('Güneş kremi'), findsNothing);

      // Geri alma (uncheck) -> Eksikler sekmesine geçer.
      await tester.tap(find.text('Kafa lambası'));
      await tester.pumpAndSettle();
      expect(
        tripsRepo.trips.first.checklist
            .firstWhere((c) => c.id == 'chk-1')
            .isCompleted,
        isFalse,
      );
      await tester.tap(find.text('Tümü'));
      await tester.pumpAndSettle();

      // Madde silme (`Otel onayı`) ve kalan 1/2 tamamlama yüzdesi (%50).
      await tester.tap(find.byIcon(Icons.delete_outline_rounded).last);
      await tester.pumpAndSettle();
      expect(find.text('Otel onayı'), findsNothing);

      await tester.tap(find.text('Kafa lambası'));
      await tester.pumpAndSettle();
      expect(find.textContaining('50%'), findsOneWidget);
    },
  );

  testWidgets(
    // Amaç: F03 Bildirimler ekranında Etkileşimler filtresi yorum bildirimlerini
    // göstermeli, bildirime dokunulunca okundu işaretlenip ilgili gönderiye gidilmeli ve
    // Tümünü Okundu Say okunmamış sayacı sıfırlamalıdır.
    'Bildirimler ekranında etkileşim filtresi, okundu işaretleme ve gönderi yönlendirmesi çalışır',
    (tester) async {
      final prefs = _WidgetPrefs()..locale = const Locale('tr');
      final profileRepo = _WidgetProfileSettingsRepo();
      final container = ProviderContainer(
        overrides: _buildOverrides(prefs, profileRepo: profileRepo).cast(),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RoamoryApp(useGoogleFonts: false),
        ),
      );
      await tester.pumpAndSettle();

      final router = container.read(appRouterProvider);
      router.push(AppRoutes.notifications);
      await tester.pumpAndSettle();

      // Başlangıçta 2 okunmamış bildirim (follow + comment) görünmelidir.
      expect(find.text('Yeni Takipçi'), findsOneWidget);
      expect(find.text('Yeni Yorum'), findsOneWidget);

      // Etkileşimler filtresine basınca yalnızca yorum/beğeni bildirimi görünmelidir.
      await tester.tap(find.text('Etkileşimler'));
      await tester.pumpAndSettle();
      expect(find.text('Yeni Yorum'), findsOneWidget);
      expect(find.text('Yeni Takipçi'), findsNothing);

      // Yorum bildirimine dokun -> okundu işaretlenip Gönderi Detayına gitmelidir.
      await tester.tap(find.text('Yeni Yorum'));
      await tester.pumpAndSettle();
      expect(find.byType(PostDetailsScreen), findsOneWidget);
      expect(container.read(profileSettingsControllerProvider).unreadCount, 1);
      expect(profileRepo.markReadCalls, 1);

      // Geri dönüp zaten okunmuş bildirime tekrar dokun -> ek UPDATE göndermemelidir.
      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yeni Yorum'));
      await tester.pumpAndSettle();
      expect(profileRepo.markReadCalls, 1);

      // Geri dönüp Tümünü Okundu Say -> unreadCount 0 ve tek toplu güncelleme olmalıdır.
      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tümünü Okundu Say'));
      await tester.pumpAndSettle();
      expect(container.read(profileSettingsControllerProvider).unreadCount, 0);
      expect(profileRepo.markAllReadCalls, 1);
    },
  );
}
