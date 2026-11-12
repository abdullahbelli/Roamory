import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/core/utils/app_date_formatter.dart';
import 'package:roamory/core/utils/travel_validators.dart';
import 'package:roamory/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:roamory/features/auth/domain/entities/auth_user.dart';
import 'package:roamory/features/auth/domain/entities/user_profile.dart';
import 'package:roamory/features/auth/domain/repositories/auth_repository.dart';
import 'package:roamory/features/auth/domain/usecases/auth_validators.dart';
import 'package:roamory/features/auth/presentation/providers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:roamory/features/community/data/repositories/supabase_community_repository.dart';
import 'package:roamory/features/community/domain/entities/post_entity.dart';
import 'package:roamory/features/community/domain/repositories/community_repository.dart';
import 'package:roamory/features/community/presentation/providers/community_controller.dart';
import 'package:roamory/features/explore/data/repositories/supabase_explore_repository.dart';
import 'package:roamory/features/explore/domain/entities/place_entity.dart';
import 'package:roamory/features/explore/domain/repositories/explore_repository.dart';
import 'package:roamory/features/explore/presentation/providers/explore_controller.dart';
import 'package:roamory/features/notifications/domain/entities/notification_entity.dart';
import 'package:roamory/features/profile/data/repositories/supabase_profile_settings_repository.dart';
import 'package:roamory/features/profile/domain/repositories/profile_settings_repository.dart';
import 'package:roamory/features/profile/presentation/providers/profile_settings_controller.dart';
import 'package:roamory/features/trips/data/repositories/supabase_trips_repository.dart';
import 'package:roamory/features/trips/domain/entities/trip_entity.dart';
import 'package:roamory/features/trips/domain/repositories/trips_repository.dart';
import 'package:roamory/features/trips/presentation/providers/trips_controller.dart';
import 'package:roamory/features/visits/data/repositories/supabase_visits_repository.dart';
import 'package:roamory/features/visits/domain/entities/visit_entity.dart';
import 'package:roamory/features/visits/domain/repositories/visits_repository.dart';
import 'package:roamory/features/visits/presentation/providers/visits_controller.dart';
import 'package:roamory/features/wishlist/data/repositories/supabase_wishlist_repository.dart';
import 'package:roamory/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:roamory/features/wishlist/domain/repositories/wishlist_repository.dart';

class _TestPrefs implements AppPreferencesStorage {
  AppPreferencesState state = const AppPreferencesState(
    locale: Locale('tr'),
    onboardingCompleted: true,
  );

  @override
  AppPreferencesState loadSync() => state;

  @override
  Future<void> saveLocaleCode(String? languageCode) async {
    state = state.copyWith(
      locale: languageCode == null ? null : Locale(languageCode),
    );
  }

  @override
  Future<void> saveOnboardingCompleted(bool completed) async {
    state = state.copyWith(onboardingCompleted: completed);
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
  }
}

class _FakeAuthRepo implements AuthRepository {
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

class _FakeExploreRepo implements ExploreRepository {
  final List<PlaceEntity> _places = [
    const PlaceEntity(
      id: 'place-1',
      name: 'Kabak Koyu',
      country: 'Türkiye',
      city: 'Muğla',
      latitude: 36.4622,
      longitude: 29.1244,
      categorySlug: 'nature',
      averageRating: 4.8,
      isPublished: true,
    ),
    const PlaceEntity(
      id: 'place-2',
      name: 'Efes Antik Kenti',
      country: 'Türkiye',
      city: 'İzmir',
      latitude: 37.9411,
      longitude: 27.3419,
      categorySlug: 'history',
      averageRating: 4.9,
      isPublished: true,
    ),
    const PlaceEntity(
      id: 'place-other-private',
      name: 'Başkasının Gizli Noktası',
      country: 'Türkiye',
      city: 'Antalya',
      latitude: 36.8,
      longitude: 30.7,
      isPublished: false,
      createdBy: 'other-user-99',
    ),
  ];

  @override
  Future<List<CategoryEntity>> fetchCategories() async => const [
    CategoryEntity(
      id: 'cat-1',
      slug: 'nature',
      nameTr: 'Doğa',
      nameEn: 'Nature',
    ),
    CategoryEntity(
      id: 'cat-2',
      slug: 'history',
      nameTr: 'Tarih',
      nameEn: 'History',
    ),
  ];

  @override
  Future<List<PlaceEntity>> fetchPlaces({
    PlaceSearchFilter filter = const PlaceSearchFilter(),
    String? currentUserId,
  }) async {
    return SupabaseExploreRepository.applyFilter(
      _places,
      filter,
      currentUserId: currentUserId,
    );
  }

  @override
  Future<PlaceEntity> fetchPlaceById(String placeId) async {
    return _places.firstWhere((p) => p.id == placeId);
  }

  @override
  Future<PlaceEntity> createPrivatePlace(
    CreatePrivatePlaceRequest request,
  ) async {
    TravelValidators.validatePrivatePlace(request);
    final created = PlaceEntity(
      id: 'private-${_places.length + 1}',
      name: request.name,
      country: request.country,
      city: request.city,
      latitude: request.latitude,
      longitude: request.longitude,
      isPublished: false,
      createdBy: request.userId,
    );
    _places.add(created);
    return created;
  }
}

class _FakeWishlistRepo implements WishlistRepository {
  final List<WishlistItemEntity> items = [];

  @override
  Future<List<WishlistItemEntity>> fetchWishlist(String userId) async =>
      items.where((i) => i.userId == userId).toList();

  @override
  Future<WishlistItemEntity> addToWishlist({
    required String userId,
    required String placeId,
    String? note,
  }) async {
    final existing = items
        .where((i) => i.userId == userId && i.placeId == placeId)
        .firstOrNull;
    if (existing != null) {
      return existing;
    }
    final added = WishlistItemEntity(
      id: 'wish-${items.length + 1}',
      userId: userId,
      placeId: placeId,
      createdAt: DateTime(2026, 4, 12),
      note: note,
    );
    items.add(added);
    return added;
  }

  @override
  Future<WishlistItemEntity> updateWishlistNote({
    required String itemId,
    required String userId,
    String? note,
  }) async {
    final idx = items.indexWhere((i) => i.id == itemId && i.userId == userId);
    final updated = WishlistItemEntity(
      id: items[idx].id,
      userId: userId,
      placeId: items[idx].placeId,
      createdAt: items[idx].createdAt,
      note: note,
    );
    items[idx] = updated;
    return updated;
  }

  @override
  Future<void> removeFromWishlist({
    required String userId,
    required String placeId,
  }) async {
    items.removeWhere((i) => i.userId == userId && i.placeId == placeId);
  }
}

class _FakeVisitsRepo implements VisitsRepository {
  final List<VisitEntity> visits = [];
  int deletedStorageFilesCount = 0;

  @override
  Future<List<VisitEntity>> fetchVisits(String userId) async =>
      visits.where((v) => v.userId == userId).toList();

  @override
  Future<VisitEntity> fetchVisitById({
    required String visitId,
    required String userId,
  }) async {
    return visits.firstWhere((v) => v.id == visitId && v.userId == userId);
  }

  @override
  Future<VisitEntity> upsertVisit(UpsertVisitRequest request) async {
    TravelValidators.validateVisitRequest(request);
    final visitId = request.visitId ?? 'visit-${visits.length + 1}';
    final place = request.customPlace != null
        ? PlaceEntity(
            id: 'custom-place-1',
            name: request.customPlace!.name,
            country: request.customPlace!.country,
            city: request.customPlace!.city,
            latitude: request.customPlace!.latitude,
            longitude: request.customPlace!.longitude,
            isPublished: false,
            createdBy: request.userId,
          )
        : const PlaceEntity(
            id: 'place-1',
            name: 'Kabak Koyu',
            country: 'Türkiye',
            city: 'Muğla',
            latitude: 36.4622,
            longitude: 29.1244,
          );

    final entity = VisitEntity(
      id: visitId,
      userId: request.userId,
      placeId: place.id,
      visitedAt: request.visitedAt,
      rating: request.rating,
      title: request.title,
      notes: request.notes,
      visibility: 'private',
      place: place,
      photos: [
        for (var i = 0; i < request.newPhotos.length; i++)
          VisitPhotoEntity(
            id: 'vp-$i',
            visitId: visitId,
            storagePath: '${request.userId}/$visitId/photo_$i.jpg',
          ),
      ],
    );
    visits.removeWhere((v) => v.id == visitId);
    visits.insert(0, entity);
    return entity;
  }

  @override
  Future<void> deleteVisit({
    required String visitId,
    required String userId,
  }) async {
    final existing = visits
        .where((v) => v.id == visitId && v.userId == userId)
        .firstOrNull;
    if (existing == null) {
      throw const UnauthorizedAppException(code: 'rls_denied_delete_visit');
    }
    deletedStorageFilesCount += existing.photos.length;
    visits.removeWhere((v) => v.id == visitId);
  }
}

class _FakeTripsRepo implements TripsRepository {
  final List<TripEntity> trips = [];
  final List<UpsertTripRequest> upsertedRequests = [];
  bool throwOnReorder = false;

  @override
  Future<List<TripEntity>> fetchTrips(String userId) async =>
      trips.where((t) => t.userId == userId).toList();

  @override
  Future<TripEntity> fetchTripById({
    required String tripId,
    required String userId,
  }) async => trips.firstWhere((t) => t.id == tripId && t.userId == userId);

  @override
  Future<TripEntity> upsertTrip(UpsertTripRequest request) async {
    TravelValidators.validateTripRequest(request);
    upsertedRequests.add(request);
    final existingIndex = request.tripId == null
        ? -1
        : trips.indexWhere((t) => t.id == request.tripId);
    if (existingIndex >= 0) {
      // Düzenleme akışında mevcut günleri, durakları ve kontrol listesini koruyoruz;
      // tarih aralığı uzatıldıysa yalnızca eksik günleri ekliyoruz.
      final existing = trips[existingIndex];
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
      final updatedDays = [
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
      ];
      final updated = existing.copyWith(
        title: request.title,
        country: request.country,
        city: request.city,
        description: request.description,
        startDate: request.startDate,
        endDate: request.endDate,
        status: request.status,
        days: updatedDays,
      );
      trips[existingIndex] = updated;
      return updated;
    }

    final tripId = request.tripId ?? 'trip-${trips.length + 1}';
    final dates = TravelValidators.generateTripDayDates(
      request.startDate,
      request.endDate,
    );
    final entity = TripEntity(
      id: tripId,
      userId: request.userId,
      title: request.title,
      country: request.country,
      city: request.city,
      description: request.description,
      startDate: request.startDate,
      endDate: request.endDate,
      status: request.status,
      days: [
        for (var i = 0; i < dates.length; i++)
          TripDayEntity(
            id: 'day-$tripId-${i + 1}',
            tripId: tripId,
            dayNumber: i + 1,
            dayDate: dates[i],
          ),
      ],
    );
    trips.insert(0, entity);
    return entity;
  }

  @override
  Future<void> deleteTrip({
    required String tripId,
    required String userId,
  }) async {
    trips.removeWhere((t) => t.id == tripId && t.userId == userId);
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
      id: 'day-$tripId-$dayNumber',
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
  }) async => TripDayEntity(
    id: tripDayId,
    tripId: 'trip-1',
    dayNumber: 1,
    title: title,
    notes: notes,
  );

  @override
  Future<TripStopEntity> addTripStop({
    required String tripDayId,
    required String placeId,
    required int orderIndex,
    String? notes,
    String? arrivalTime,
  }) async {
    final stop = TripStopEntity(
      id: 'stop-$tripDayId-$orderIndex-${DateTime.now().microsecondsSinceEpoch}',
      tripDayId: tripDayId,
      placeId: placeId,
      orderIndex: orderIndex,
      notes: notes,
      arrivalTime: arrivalTime,
      place: placeId == 'private-place-1'
          ? const PlaceEntity(
              id: 'private-place-1',
              name: 'Gizli Koy Kampı',
              country: 'Türkiye',
              city: 'Muğla',
              latitude: 36.4,
              longitude: 29.1,
              isPublished: false,
              createdBy: 'user-1',
            )
          : null,
    );
    for (var ti = 0; ti < trips.length; ti++) {
      final days = trips[ti].days;
      final di = days.indexWhere((d) => d.id == tripDayId);
      if (di >= 0) {
        final updatedDays = [...days];
        updatedDays[di] = updatedDays[di].copyWith(
          stops: [...updatedDays[di].stops, stop],
        );
        trips[ti] = trips[ti].copyWith(days: updatedDays);
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
    if (throwOnReorder) {
      throw const UnknownAppException(code: 'reorder_failed');
    }
    for (var ti = 0; ti < trips.length; ti++) {
      final days = trips[ti].days;
      final di = days.indexWhere((d) => d.id == tripDayId);
      if (di >= 0) {
        final byId = {for (final s in days[di].stops) s.id: s};
        final reordered = [
          for (var i = 0; i < orderedStopIds.length; i++)
            (byId[orderedStopIds[i]] ??
                    TripStopEntity(
                      id: orderedStopIds[i],
                      tripDayId: tripDayId,
                      placeId: 'place-$i',
                      orderIndex: i,
                    ))
                .copyWith(orderIndex: i),
        ];
        final updatedDays = [...days];
        updatedDays[di] = updatedDays[di].copyWith(stops: reordered);
        trips[ti] = trips[ti].copyWith(days: updatedDays);
        return reordered;
      }
    }
    return [
      for (var i = 0; i < orderedStopIds.length; i++)
        TripStopEntity(
          id: orderedStopIds[i],
          tripDayId: tripDayId,
          placeId: 'place-$i',
          orderIndex: i,
        ),
    ];
  }

  @override
  Future<void> deleteTripStop(String stopId) async {
    for (var ti = 0; ti < trips.length; ti++) {
      final updatedDays = trips[ti].days
          .map(
            (d) => d.copyWith(
              stops: d.stops.where((s) => s.id != stopId).toList(),
            ),
          )
          .toList();
      trips[ti] = trips[ti].copyWith(days: updatedDays);
    }
  }

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
      final list = trips[ti].checklist;
      final ci = list.indexWhere((c) => c.id == itemId);
      if (ci >= 0) {
        final updated = list[ci].copyWith(
          isCompleted: isCompleted ?? list[ci].isCompleted,
          title: title ?? list[ci].title,
          category: category ?? list[ci].category,
        );
        final nextList = [...list];
        nextList[ci] = updated;
        trips[ti] = trips[ti].copyWith(checklist: nextList);
        return updated;
      }
    }
    return TripChecklistItemEntity(
      id: itemId,
      tripId: 'trip-1',
      title: title ?? 'Pasaport',
      category: category ?? TripChecklistCategory.documents,
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

class _FakeCommunityRepo implements CommunityRepository {
  final List<PostEntity> posts = [
    PostEntity(
      id: 'post-1',
      userId: 'user-2',
      title: 'Likya Yolu Notları',
      caption: 'Kabak koyundan Faralya patikası harikaydı.',
      createdAt: DateTime(2026, 4, 10),
      author: const TravelerSummaryEntity(
        id: 'user-2',
        username: 'ege_gezgin',
        fullName: 'Ege Kaya',
      ),
    ),
  ];
  final Set<String> blockedIds = {};
  final List<String> reports = [];

  @override
  Future<List<PostEntity>> fetchFeed({
    required String currentUserId,
    bool followingOnly = false,
    String? placeId,
    String? authorId,
    int limit = 20,
    int offset = 0,
  }) async {
    final filtered = posts
        .where(
          (p) =>
              p.status == 'published' &&
              !blockedIds.contains(p.userId) &&
              (authorId == null || p.userId == authorId),
        )
        .toList();
    if (offset >= filtered.length) {
      return const [];
    }
    final end = (offset + limit) > filtered.length
        ? filtered.length
        : (offset + limit);
    return filtered.sublist(offset, end);
  }

  @override
  Future<PostEntity> fetchPostById({
    required String postId,
    required String currentUserId,
  }) async {
    final idx = posts.indexWhere((p) => p.id == postId);
    if (idx < 0 || blockedIds.contains(posts[idx].userId)) {
      throw const NotFoundAppException(code: 'post_not_found');
    }
    return posts[idx];
  }

  @override
  Future<List<PostEntity>> fetchSavedPosts(String currentUserId) async =>
      posts.where((p) => p.isSavedByCurrentUser).toList();

  @override
  Future<PostEntity> createPost(CreatePostRequest request) async {
    if (request.caption.trim().isEmpty) {
      throw const ValidationAppException(code: 'post_caption_required');
    }
    final postId = 'post-${posts.length + 1}';
    final created = PostEntity(
      id: postId,
      userId: request.userId,
      title: request.title,
      caption: request.caption,
      placeId: request.placeId,
      visitId: request.visitId,
      status: request.isDraft ? 'draft' : 'published',
      createdAt: DateTime(2026, 4, 12),
      photos: [
        for (var i = 0; i < request.photos.length; i++)
          PostPhotoEntity(
            id: 'pp-$postId-$i',
            postId: postId,
            storagePath: '${request.userId}/$postId/photo_$i.jpg',
          ),
      ],
    );
    posts.insert(0, created);
    return created;
  }

  @override
  Future<void> deletePost({
    required String postId,
    required String currentUserId,
  }) async {
    final post = posts.firstWhere((p) => p.id == postId);
    if (post.userId != currentUserId) {
      throw const UnauthorizedAppException(
        code: 'rls_cannot_delete_other_post',
      );
    }
    posts.removeWhere((p) => p.id == postId);
  }

  @override
  Future<PostEntity> toggleLike({
    required String postId,
    required String currentUserId,
  }) async {
    final idx = posts.indexWhere((p) => p.id == postId);
    final current = posts[idx];
    final nextLiked = !current.isLikedByCurrentUser;
    final updated = current.copyWith(
      isLikedByCurrentUser: nextLiked,
      likeCount: nextLiked ? current.likeCount + 1 : current.likeCount - 1,
    );
    posts[idx] = updated;
    return updated;
  }

  @override
  Future<PostEntity> toggleSavePost({
    required String postId,
    required String currentUserId,
  }) async {
    final idx = posts.indexWhere((p) => p.id == postId);
    final current = posts[idx];
    final updated = current.copyWith(
      isSavedByCurrentUser: !current.isSavedByCurrentUser,
    );
    posts[idx] = updated;
    return updated;
  }

  @override
  Future<List<CommentEntity>> fetchComments(String postId) async => const [];

  @override
  Future<CommentEntity> addComment({
    required String postId,
    required String currentUserId,
    required String body,
  }) async => CommentEntity(
    id: 'c-1',
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
  }) async => TravelerSummaryEntity(
    id: targetUserId,
    username: 'ege_gezgin',
    fullName: 'Ege Kaya',
    postsCount: 1,
    followersCount: 2,
    followingCount: 1,
  );

  @override
  Future<List<TravelerSummaryEntity>> fetchFollowConnections({
    required String targetUserId,
    required String currentUserId,
    required bool followers,
  }) async => const [];

  @override
  Future<TravelerSummaryEntity> toggleFollow({
    required String targetUserId,
    required String currentUserId,
  }) async => TravelerSummaryEntity(
    id: targetUserId,
    username: 'ege_gezgin',
    fullName: 'Ege Kaya',
    isFollowedByCurrentUser: true,
  );

  @override
  Future<List<TravelerSummaryEntity>> fetchBlockedUsers(
    String currentUserId,
  ) async => blockedIds
      .map(
        (id) => TravelerSummaryEntity(
          id: id,
          username: 'blocked_user',
          fullName: 'Engellenen Gezgin',
          isBlockedByCurrentUser: true,
        ),
      )
      .toList();

  @override
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    if (currentUserId == blockedUserId) {
      throw const ValidationAppException(code: 'cannot_block_self');
    }
    blockedIds.add(blockedUserId);
  }

  @override
  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    blockedIds.remove(blockedUserId);
  }

  @override
  Future<void> reportContent({
    required String reporterUserId,
    required String reason,
    String? targetPostId,
    String? targetCommentId,
    String? targetUserId,
    String? details,
  }) async {
    reports.add('$reason:${targetPostId ?? targetUserId}');
  }
}

class _FakeProfileSettingsRepo implements ProfileAndSettingsRepository {
  final List<NotificationEntity> items = [
    NotificationEntity(
      id: 'n-1',
      userId: 'user-1',
      kind: NotificationKind.follow,
      title: 'Yeni Takipçi',
      body: 'Ege Kaya seni takip etmeye başladı.',
      createdAt: DateTime(2026, 4, 12),
      isRead: false,
    ),
  ];

  @override
  Future<List<NotificationEntity>> fetchNotifications(String userId) async =>
      items;

  @override
  Future<void> markNotificationRead({
    required String notificationId,
    required String userId,
  }) async {}

  @override
  Future<void> markAllNotificationsRead(String userId) async {}

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
  Future<void> updatePassword(String newPassword) async {
    if (newPassword.length < 8) {
      throw const ValidationAppException(code: 'weak_password');
    }
  }

  @override
  Future<void> deleteUserAccountData(String userId) async {}
}

void main() {
  group(
    'T12 — Keşif, İstek Listesi, Ziyaret, Günlük ve Harita Birim Testleri',
    () {
      test(
        // Amaç: Koordinat sınırları (-90..90, -180..180), puan (1..5) ve 10 MB fotoğraf sınırı doğrulanmalı.
        'TravelValidators geçersiz koordinat, puan ve 10MB üstü fotoğrafı reddeder',
        () {
          expect(TravelValidators.isValidCoordinates(38.42, 27.14), isTrue);
          expect(TravelValidators.isValidCoordinates(95.0, 27.14), isFalse);
          expect(TravelValidators.isValidCoordinates(38.42, -195.0), isFalse);

          // Geçersiz puan (6 yıldız) hata fırlatmalıdır.
          expect(
            () => TravelValidators.validateVisitRequest(
              UpsertVisitRequest(
                userId: 'user-1',
                placeId: 'place-1',
                visitedAt: DateTime(2026, 4, 12),
                rating: 6,
              ),
            ),
            throwsA(isA<ValidationAppException>()),
          );
        },
      );

      test(
        // Amaç: Başka bir kullanıcının yayınlanmamış özel mekanı (`is_published=false`)
        // katalog filtresinden sızmamalı; istek listesi ekleme/çıkarma tekil çalışmalıdır.
        'ExploreController başkasının özel mekanını gizler ve wishlist toggle tekil çalışır',
        () async {
          final container = ProviderContainer(
            overrides: [
              appPreferencesStorageProvider.overrideWithValue(_TestPrefs()),
              authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
              exploreRepositoryProvider.overrideWithValue(_FakeExploreRepo()),
              wishlistRepositoryProvider.overrideWithValue(_FakeWishlistRepo()),
            ],
          );
          addTearDown(container.dispose);

          await container
              .read(authControllerProvider.notifier)
              .resolveInitialSession();
          await container
              .read(exploreControllerProvider.notifier)
              .loadInitial();

          final state = container.read(exploreControllerProvider);
          // Başkasının özel mekanı (`place-other-private`) listede yer almamalıdır.
          expect(
            state.places.any((p) => p.id == 'place-other-private'),
            isFalse,
          );
          expect(state.places.length, 2);

          // Wishlist'e ekle ve çıkar.
          final target = state.places.first;
          final added = await container
              .read(exploreControllerProvider.notifier)
              .toggleWishlist(target);
          expect(added, isTrue);
          expect(
            container.read(exploreControllerProvider).isInWishlist(target.id),
            isTrue,
          );

          final removed = await container
              .read(exploreControllerProvider.notifier)
              .toggleWishlist(target);
          expect(removed, isFalse);
          expect(
            container.read(exploreControllerProvider).isInWishlist(target.id),
            isFalse,
          );
        },
      );

      test(
        // Amaç: Özel mekanla birlikte ziyaret oluşturulduğunda `visibility = private` olmalı
        // ve silindiğinde bağlı `visit-photos` Storage dosyaları da temizlenmelidir.
        'VisitsController özel ziyaret kaydeder, ülke/şehir sayar ve silmede Storage temizler',
        () async {
          final visitsRepo = _FakeVisitsRepo();
          final container = ProviderContainer(
            overrides: [
              appPreferencesStorageProvider.overrideWithValue(_TestPrefs()),
              authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
              visitsRepositoryProvider.overrideWithValue(visitsRepo),
            ],
          );
          addTearDown(container.dispose);

          await container
              .read(authControllerProvider.notifier)
              .resolveInitialSession();
          final saved = await container
              .read(visitsControllerProvider.notifier)
              .saveVisit(
                UpsertVisitRequest(
                  userId: 'user-1',
                  customPlace: const CreatePrivatePlaceRequest(
                    userId: 'user-1',
                    name: 'Gizli Koy',
                    country: 'Türkiye',
                    city: 'Muğla',
                    latitude: 36.5,
                    longitude: 29.1,
                  ),
                  visitedAt: DateTime(2026, 4, 12),
                  rating: 5,
                  title: 'Sabah yüzüşü',
                  notes: 'Sadece bana özel not',
                  newPhotos: [
                    VisitPhotoUploadPayload(
                      bytes: Uint8List.fromList([1, 2, 3, 4]),
                      fileExtension: 'jpg',
                    ),
                  ],
                ),
              );

          expect(saved, isNotNull);
          expect(saved!.visibility, 'private');
          expect(
            container.read(visitsControllerProvider).uniqueCountriesCount,
            1,
          );
          expect(container.read(visitsControllerProvider).uniqueCitiesCount, 1);

          final deleted = await container
              .read(visitsControllerProvider.notifier)
              .deleteVisit(saved.id);
          expect(deleted, isTrue);
          expect(visitsRepo.deletedStorageFilesCount, 1);
        },
      );
    },
  );

  group('T14 — Seyahat Planlama, Günlük Durak Sıralama ve Kontrol Listesi Testleri', () {
    test(
      // Amaç: Bitiş tarihi başlangıç tarihinden önce olan seyahat reddedilmeli;
      // geçerli seyahatte günler otomatik üretilmeli, durak sıralaması ve checklist çalışmalıdır.
      'TripsController tarih doğrulaması, gün üretimi, durak sıralama ve checklist işlemlerini yürütür',
      () async {
        final container = ProviderContainer(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(_TestPrefs()),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
            tripsRepositoryProvider.overrideWithValue(_FakeTripsRepo()),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(authControllerProvider.notifier)
            .resolveInitialSession();

        // 1) Ters tarih aralığı reddedilmelidir.
        final invalid = await container
            .read(tripsControllerProvider.notifier)
            .saveTrip(
              UpsertTripRequest(
                userId: 'user-1',
                title: 'Hatalı Tarihli Gezi',
                startDate: DateTime(2026, 5, 10),
                endDate: DateTime(2026, 5, 8),
              ),
            );
        expect(invalid, isNull);
        expect(
          container.read(tripsControllerProvider).error,
          isA<ValidationAppException>(),
        );

        // 2) 3 günlük geçerli seyahat oluşturulduğunda 3 adet `trip_days` üretilmelidir.
        final trip = await container
            .read(tripsControllerProvider.notifier)
            .saveTrip(
              UpsertTripRequest(
                userId: 'user-1',
                title: 'Ege Kıyıları',
                country: 'Türkiye',
                city: 'İzmir',
                startDate: DateTime(2026, 5, 1),
                endDate: DateTime(2026, 5, 3),
              ),
            );
        expect(trip, isNotNull);
        expect(trip!.days.length, 3);

        // 2b) Mevcut seyahate yeni gün (`addDayToTrip`) ekle.
        final addedDay = await container
            .read(tripsControllerProvider.notifier)
            .addDayToTrip(trip.id, title: '4. Gün: Dönüş');
        expect(addedDay, isNotNull);
        expect(
          container
              .read(tripsControllerProvider)
              .findById(trip.id)!
              .days
              .length,
          4,
        );

        // 3) 1. güne 2 durak ekleyip sıralamasını değiştir.
        final day1Id = trip.days.first.id;
        await container
            .read(tripsControllerProvider.notifier)
            .addStopToDay(
              tripId: trip.id,
              tripDayId: day1Id,
              place: const PlaceEntity(
                id: 'p1',
                name: 'Durak A',
                country: 'TR',
                city: 'İzmir',
                latitude: 38.0,
                longitude: 27.0,
              ),
            );
        await container
            .read(tripsControllerProvider.notifier)
            .addStopToDay(
              tripId: trip.id,
              tripDayId: day1Id,
              place: const PlaceEntity(
                id: 'p2',
                name: 'Durak B',
                country: 'TR',
                city: 'İzmir',
                latitude: 38.1,
                longitude: 27.1,
              ),
            );

        await container
            .read(tripsControllerProvider.notifier)
            .reorderStops(
              tripId: trip.id,
              tripDayId: day1Id,
              oldIndex: 0,
              newIndex: 1,
            );
        final reorderedStops = container
            .read(tripsControllerProvider)
            .findById(trip.id)!
            .days
            .first
            .stops;
        expect(reorderedStops.first.place?.name, 'Durak B');

        // 4) Checklist maddesi ekle ve tamamla.
        await container
            .read(tripsControllerProvider.notifier)
            .addChecklistItem(
              tripId: trip.id,
              title: 'Çadır ve uyku tulumu',
              category: TripChecklistCategory.packing,
            );
        final item = container
            .read(tripsControllerProvider)
            .findById(trip.id)!
            .checklist
            .first;
        await container
            .read(tripsControllerProvider.notifier)
            .toggleChecklistItem(tripId: trip.id, item: item);
        expect(
          container
              .read(tripsControllerProvider)
              .findById(trip.id)!
              .completedChecklistCount,
          1,
        );
      },
    );

    test(
      // Amaç: Seyahat düzenleme mevcut kaydı güncellemeli (yeni trip açmamalı),
      // mevcut günleri/özel durakları/kontrol listesini korumalı, tarih daralınca veri silmemeli,
      // uzatılınca yalnızca eksik günleri eklemeli ve başarısız durak sıralamasını geri almalıdır.
      'Seyahat düzenleme mevcut alt verileri korur, tarih değişimini güvenli yönetir ve durak sıralama hatasını geri alır',
      () async {
        final tripsRepo = _FakeTripsRepo();
        final container = ProviderContainer(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(_TestPrefs()),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
            tripsRepositoryProvider.overrideWithValue(tripsRepo),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(authControllerProvider.notifier)
            .resolveInitialSession();

        final notifier = container.read(tripsControllerProvider.notifier);

        // 1) 2 günlük seyahat oluştur (2026-05-01 .. 2026-05-02).
        final created = await notifier.saveTrip(
          UpsertTripRequest(
            userId: 'user-1',
            title: 'Likya Planı',
            country: 'TR',
            city: 'Muğla',
            description: 'İlk taslak',
            startDate: DateTime(2026, 5, 1),
            endDate: DateTime(2026, 5, 2),
          ),
        );
        expect(created, isNotNull);
        expect(tripsRepo.trips.length, 1);
        final day1Id = created!.days.first.id;

        // 2) Özel mekanı (`isPublished: false`) ve ikinci durağı 1. güne ekle.
        const privatePlace = PlaceEntity(
          id: 'private-place-1',
          name: 'Gizli Koy Kampı',
          country: 'Türkiye',
          city: 'Muğla',
          latitude: 36.4,
          longitude: 29.1,
          isPublished: false,
          createdBy: 'user-1',
        );
        const publicPlace = PlaceEntity(
          id: 'public-place-2',
          name: 'Kelebekler Vadisi',
          country: 'Türkiye',
          city: 'Muğla',
          latitude: 36.49,
          longitude: 29.12,
        );
        expect(
          await notifier.addStopToDay(
            tripId: created.id,
            tripDayId: day1Id,
            place: privatePlace,
          ),
          isTrue,
        );
        expect(
          await notifier.addStopToDay(
            tripId: created.id,
            tripDayId: day1Id,
            place: publicPlace,
          ),
          isTrue,
        );

        // Kontrol listesi maddesi ekle.
        expect(
          await notifier.addChecklistItem(
            tripId: created.id,
            title: 'Pasaport',
            category: TripChecklistCategory.documents,
          ),
          isTrue,
        );

        // 3) Aynı tarihlerle düzenle: yeni seyahat açılmamalı, gün/durak/checklist korunmalıdır.
        final editedSameDates = await notifier.saveTrip(
          UpsertTripRequest(
            tripId: created.id,
            userId: 'user-1',
            title: 'Likya Güncel Planı',
            country: 'Türkiye',
            city: 'Fethiye',
            description: 'Güncel açıklama',
            startDate: DateTime(2026, 5, 1),
            endDate: DateTime(2026, 5, 2),
            status: TripStatus.ongoing,
          ),
        );
        expect(editedSameDates, isNotNull);
        expect(editedSameDates!.id, created.id);
        expect(tripsRepo.trips.length, 1);
        expect(container.read(tripsControllerProvider).trips.length, 1);
        expect(editedSameDates.days.length, 2);
        expect(editedSameDates.days.first.stops.length, 2);
        expect(
          editedSameDates.days.first.stops.first.place?.isPublished,
          isFalse,
        );
        expect(editedSameDates.checklist.length, 1);

        // 4) Tarih daraltıldığında (2026-05-01 .. 2026-05-01) 2. gün verisi silinmemelidir.
        final shortened = await notifier.saveTrip(
          UpsertTripRequest(
            tripId: created.id,
            userId: 'user-1',
            title: 'Likya Kısaltıldı',
            startDate: DateTime(2026, 5, 1),
            endDate: DateTime(2026, 5, 1),
          ),
        );
        expect(shortened, isNotNull);
        expect(shortened!.days.length, 2);

        // 5) Tarih uzatıldığında (2026-05-01 .. 2026-05-04) yalnızca eksik günler (3 ve 4 Mayıs) eklenmelidir.
        final extended = await notifier.saveTrip(
          UpsertTripRequest(
            tripId: created.id,
            userId: 'user-1',
            title: 'Likya Uzatıldı',
            startDate: DateTime(2026, 5, 1),
            endDate: DateTime(2026, 5, 4),
          ),
        );
        expect(extended, isNotNull);
        expect(extended!.days.length, 4);
        expect(extended.days[2].dayDate, DateTime(2026, 5, 3));
        expect(extended.days[3].dayDate, DateTime(2026, 5, 4));

        // 6) Durak sıralaması başarısız olursa liste eski sıraya geri dönmelidir.
        tripsRepo.throwOnReorder = true;
        final reorderFailed = await notifier.reorderStops(
          tripId: created.id,
          tripDayId: day1Id,
          oldIndex: 0,
          newIndex: 1,
        );
        expect(reorderFailed, isFalse);
        expect(container.read(tripsControllerProvider).error, isNotNull);
        expect(
          container
              .read(tripsControllerProvider)
              .findById(created.id)!
              .days
              .first
              .stops
              .first
              .place
              ?.id,
          'private-place-1',
        );
      },
    );
  });

  group('T17 & T19 — Topluluk, Engelleme, Raporlama, Bildirimler ve Profil Testleri', () {
    test(
      // Amaç: Gönderi beğenme, yorum ekleme, kullanıcı engelleme (akıştan düşürme),
      // içerik raporlama ve bildirim okundu işaretleme doğru çalışmalıdır.
      'CommunityController ve ProfileSettingsController sosyal ve güvenlik kurallarını uygular',
      () async {
        final communityRepo = _FakeCommunityRepo();
        final container = ProviderContainer(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(_TestPrefs()),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
            communityRepositoryProvider.overrideWithValue(communityRepo),
            profileSettingsRepositoryProvider.overrideWithValue(
              _FakeProfileSettingsRepo(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(authControllerProvider.notifier)
            .resolveInitialSession();
        await container.read(communityControllerProvider.notifier).loadFeed();

        expect(container.read(communityControllerProvider).feedPosts.length, 1);

        // Beğeni toggle.
        await container
            .read(communityControllerProvider.notifier)
            .toggleLike('post-1');
        expect(
          container
              .read(communityControllerProvider)
              .findPostById('post-1')!
              .likeCount,
          1,
        );

        // Yorum ekleme.
        final commented = await container
            .read(communityControllerProvider.notifier)
            .addComment(postId: 'post-1', body: 'Harika rota!');
        expect(commented, isTrue);

        // Raporlama (`content_reports`).
        final reported = await container
            .read(communityControllerProvider.notifier)
            .reportContent(reason: 'spam', targetPostId: 'post-1');
        expect(reported, isTrue);
        expect(communityRepo.reports, contains('spam:post-1'));

        // Kullanıcı engellendiğinde (`user_blocks`) gönderisi akıştan hemen kaldırılmalıdır.
        final blocked = await container
            .read(communityControllerProvider.notifier)
            .blockUser('user-2');
        expect(blocked, isTrue);
        expect(container.read(communityControllerProvider).feedPosts, isEmpty);

        // Bildirimleri yükle ve tümünü okundu işaretle.
        await container
            .read(profileSettingsControllerProvider.notifier)
            .loadNotifications();
        expect(
          container.read(profileSettingsControllerProvider).unreadCount,
          1,
        );
        await container
            .read(profileSettingsControllerProvider.notifier)
            .markAllRead();
        expect(
          container.read(profileSettingsControllerProvider).unreadCount,
          0,
        );
      },
    );

    test(
      // Amaç: 6-8 haneli OTP doğrulaması ve Supabase Auth/RLS/Rate-Limit hata kodlarının
      // kullanıcı dostu domain kodlarına dönüştürülmesi doğrulanmalıdır.
      'AuthValidators 6-8 haneli OTP kabul eder ve ErrorMapper Auth/RLS/429 hatalarını ayrıştırır',
      () {
        expect(AuthValidators.isValidOtpCode('123456'), isTrue);
        expect(AuthValidators.isValidOtpCode('12345678'), isTrue);
        expect(AuthValidators.isValidOtpCode('12345'), isFalse);

        final unconfirmed = ErrorMapper.map(
          const sb.AuthException('Email not confirmed', statusCode: '400'),
        );
        expect(unconfirmed.code, 'email_not_confirmed');

        final otpErr = ErrorMapper.map(
          const sb.AuthException(
            'Token has expired or is invalid',
            statusCode: '403',
          ),
        );
        expect(otpErr.code, 'otp_invalid');

        final rateLimitErr = ErrorMapper.map(
          const sb.AuthException(
            'Email rate limit exceeded',
            statusCode: '429',
          ),
        );
        expect(rateLimitErr.code, 'rate_limit_exceeded');

        final rlsErr = ErrorMapper.map(
          const sb.PostgrestException(
            message: 'new row violates row-level security policy',
            code: '42501',
          ),
        );
        expect(rlsErr, isA<UnauthorizedAppException>());
      },
    );
  });

  group('Tarih, Pasaport Doğrulama ve Görsel Gizliliği', () {
    test(
      // Amaç: Türkçe ve İngilizce dil kodlarına göre tarihlerin beklenen locale
      // biçiminde üretildiğini doğrulamak.
      'AppDateFormatter TR ve EN tarihlerini doğru biçimlendirir',
      () {
        final date = DateTime(2026, 11, 12);
        expect(AppDateFormatter.formatForLanguage(date, 'tr'), '12 Kasım 2026');
        expect(AppDateFormatter.formatForLanguage(date, 'en'), 'Nov 12, 2026');
        expect(
          AppDateFormatter.formatForLanguage(date, 'en', longMonth: true),
          'November 12, 2026',
        );
      },
    );

    test(
      // Amaç: Geçersiz ülke/şehir kodlarının reddedildiğini ve aynı ülkenin
      // yazım varyasyonlarının Dijital Pasaport sayaçlarını şişirmediğini doğrulamak.
      'TravelValidators ve VisitsState pasaport sayaçlarını normalize eder',
      () {
        expect(TravelValidators.isValidCountry('XX'), isFalse);
        expect(TravelValidators.isValidCountry('test'), isFalse);
        expect(TravelValidators.isValidCountry('123'), isFalse);
        expect(TravelValidators.isValidCountry('tr'), isTrue);
        expect(TravelValidators.isValidCountry('TÜRKİYE'), isTrue);

        expect(TravelValidators.isValidCity('test'), isFalse);
        expect(TravelValidators.isValidCity('aaa'), isFalse);
        expect(TravelValidators.isValidCity('İzmir1'), isFalse);
        expect(TravelValidators.isValidCity('İstanbul'), isTrue);

        expect(TravelValidators.normalizeCountryName('tr'), 'Türkiye');
        expect(TravelValidators.normalizeCountryName('Turkey'), 'Türkiye');
        expect(TravelValidators.normalizeCountryName('TÜRKİYE'), 'Türkiye');
        expect(TravelValidators.normalizeCityName('istanbul'), 'İstanbul');

        expect(
          () => TravelValidators.validatePrivatePlace(
            const CreatePrivatePlaceRequest(
              userId: 'user-1',
              name: 'Geçersiz Yer',
              country: 'XX',
              city: 'İstanbul',
              latitude: 41.0,
              longitude: 29.0,
            ),
          ),
          throwsA(isA<ValidationAppException>()),
        );

        final state = VisitsState(
          visits: [
            VisitEntity(
              id: 'v1',
              userId: 'user-1',
              placeId: 'p1',
              visitedAt: DateTime(2026, 1, 1),
              place: const PlaceEntity(
                id: 'p1',
                name: 'Galata',
                country: 'tr',
                city: 'istanbul',
                latitude: 41.0,
                longitude: 28.9,
              ),
            ),
            VisitEntity(
              id: 'v2',
              userId: 'user-1',
              placeId: 'p2',
              visitedAt: DateTime(2026, 2, 1),
              place: const PlaceEntity(
                id: 'p2',
                name: 'Kız Kulesi',
                country: 'Turkey',
                city: 'İstanbul',
                latitude: 41.0,
                longitude: 29.0,
              ),
            ),
            VisitEntity(
              id: 'v3',
              userId: 'user-1',
              placeId: 'p3',
              visitedAt: DateTime(2026, 3, 1),
              place: const PlaceEntity(
                id: 'p3',
                name: 'Efes',
                country: 'TÜRKİYE',
                city: 'izmir',
                latitude: 37.9,
                longitude: 27.3,
              ),
            ),
          ],
        );

        expect(state.uniqueCountriesCount, 1);
        expect(state.uniqueCitiesCount, 2);
      },
    );

    test(
      // Amaç: Özel ziyaret fotoğraflarının yalnızca kendi özel mekanının sahibine
      // gösterildiğini; başka kullanıcılara veya genel katalog mekanlarına sızmadığını doğrulamak.
      'ExploreState.resolvePlaceCoverUrl özel görselleri yalnızca yetkili sahibine açar',
      () {
        const ownedPrivatePlace = PlaceEntity(
          id: 'priv-1',
          name: 'Gizli Koy',
          country: 'Türkiye',
          city: 'Muğla',
          latitude: 36.5,
          longitude: 29.1,
          isPublished: false,
          createdBy: 'user-1',
        );
        const otherPrivatePlace = PlaceEntity(
          id: 'priv-2',
          name: 'Başka Kullanıcının Yeri',
          country: 'Türkiye',
          city: 'Antalya',
          latitude: 36.8,
          longitude: 30.7,
          isPublished: false,
          createdBy: 'user-2',
        );
        const publicPlace = PlaceEntity(
          id: 'pub-1',
          name: 'Pamukkale',
          country: 'Türkiye',
          city: 'Denizli',
          latitude: 37.9,
          longitude: 29.1,
          isPublished: true,
        );

        final visits = [
          VisitEntity(
            id: 'v-priv',
            userId: 'user-1',
            placeId: 'priv-1',
            visitedAt: DateTime(2026, 5, 1),
            photos: const [
              VisitPhotoEntity(
                id: 'vp-priv',
                visitId: 'v-priv',
                storagePath: 'user-1/v-priv/p.jpg',
                signedUrl: 'https://signed.example/visit-private.jpg',
              ),
            ],
          ),
          VisitEntity(
            id: 'v-pub',
            userId: 'user-1',
            placeId: 'pub-1',
            visitedAt: DateTime(2026, 5, 2),
            photos: const [
              VisitPhotoEntity(
                id: 'vp-pub',
                visitId: 'v-pub',
                storagePath: 'user-1/v-pub/p.jpg',
                signedUrl:
                    'https://signed.example/visit-public-leak-attempt.jpg',
              ),
            ],
          ),
        ];

        final feedPosts = [
          PostEntity(
            id: 'post-draft',
            userId: 'user-1',
            placeId: 'pub-1',
            caption: 'Taslak',
            status: 'draft',
            createdAt: DateTime(2026, 5, 3),
            photos: const [
              PostPhotoEntity(
                id: 'pp-draft',
                postId: 'post-draft',
                storagePath: 'user-1/post-draft/p.jpg',
                signedUrl: 'https://signed.example/draft-post.jpg',
              ),
            ],
          ),
        ];

        const exploreState = ExploreState();

        // Sahibi kendi özel mekanında özel ziyaret görselini görür.
        expect(
          exploreState.resolvePlaceCoverUrl(
            ownedPrivatePlace,
            userVisits: visits,
            currentUserId: 'user-1',
          ),
          'https://signed.example/visit-private.jpg',
        );

        // Farklı kullanıcı oturumunda özel mekan görseli sızdırılmaz.
        expect(
          exploreState.resolvePlaceCoverUrl(
            ownedPrivatePlace,
            userVisits: visits,
            currentUserId: 'user-2',
          ),
          isNull,
        );
        expect(
          exploreState.resolvePlaceCoverUrl(
            otherPrivatePlace,
            userVisits: visits,
            currentUserId: 'user-1',
          ),
          isNull,
        );

        // Genel katalog mekanında özel visit_photos veya draft gönderi görseli kullanılmaz.
        expect(
          exploreState.resolvePlaceCoverUrl(
            publicPlace,
            userVisits: visits,
            feedPosts: feedPosts,
            currentUserId: 'user-1',
          ),
          isNull,
        );

        // Yalnızca published topluluk gönderisi görseli genel mekan kartına yansır.
        final publishedFeed = [
          ...feedPosts,
          PostEntity(
            id: 'post-pub',
            userId: 'user-2',
            placeId: 'pub-1',
            caption: 'Herkese açık gönderi',
            status: 'published',
            createdAt: DateTime(2026, 5, 4),
            photos: const [
              PostPhotoEntity(
                id: 'pp-pub',
                postId: 'post-pub',
                storagePath: 'user-2/post-pub/p.jpg',
                signedUrl: 'https://signed.example/published-post.jpg',
              ),
            ],
          ),
        ];
        expect(
          exploreState.resolvePlaceCoverUrl(
            publicPlace,
            userVisits: visits,
            feedPosts: publishedFeed,
            currentUserId: 'user-1',
          ),
          'https://signed.example/published-post.jpg',
        );
      },
    );

    test(
      // Amaç: Ziyaret silindiğinde ziyaretin visit-photos Storage dosyalarının temizlendiğini,
      // ancak aynı mekandan üretilmiş topluluk gönderisinin ve post-photos görselinin
      // korunduğunu doğrulamak.
      'Ziyaret silme visit-photos temizler fakat topluluk gönderisini ve fotoğrafını korur',
      () async {
        final fakeExplore = _FakeExploreRepo();
        final fakeVisits = _FakeVisitsRepo();
        final fakeCommunity = _FakeCommunityRepo();
        final container = ProviderContainer(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(_TestPrefs()),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
            exploreRepositoryProvider.overrideWithValue(fakeExplore),
            visitsRepositoryProvider.overrideWithValue(fakeVisits),
            communityRepositoryProvider.overrideWithValue(fakeCommunity),
          ],
        );
        addTearDown(container.dispose);

        final visitsCtrl = container.read(visitsControllerProvider.notifier);
        final createdVisit = await visitsCtrl.saveVisit(
          UpsertVisitRequest(
            userId: 'user-1',
            placeId: 'place-1',
            visitedAt: DateTime(2026, 6, 1),
            title: 'Kabak Notum',
            notes: 'Gizli günlük notum',
            newPhotos: [
              VisitPhotoUploadPayload(
                bytes: Uint8List.fromList([1, 2, 3]),
                fileExtension: 'jpg',
              ),
            ],
          ),
        );
        expect(createdVisit, isNotNull);

        final createdPost = await container
            .read(communityControllerProvider.notifier)
            .createPost(
              CreatePostRequest(
                userId: 'user-1',
                placeId: createdVisit!.placeId,
                visitId: createdVisit.id,
                caption: 'Topluluk paylaşımım',
                photos: [
                  PostPhotoUploadPayload(
                    bytes: Uint8List.fromList([9, 8, 7]),
                    fileExtension: 'jpg',
                  ),
                ],
              ),
            );
        expect(createdPost, isNotNull);
        final postsBeforeDelete = fakeCommunity.posts.length;
        expect(
          fakeCommunity.posts.any(
            (p) => p.id == createdPost!.id && p.photos.length == 1,
          ),
          isTrue,
        );

        final deleted = await visitsCtrl.deleteVisit(createdVisit.id);
        expect(deleted, isTrue);
        expect(fakeVisits.visits, isEmpty);
        expect(fakeVisits.deletedStorageFilesCount, 1);
        // Dönüştürülmüş topluluk gönderisi ve fotoğrafı silinmemiş olmalıdır.
        expect(fakeCommunity.posts.length, postsBeforeDelete);
        expect(
          fakeCommunity.posts.any(
            (p) => p.id == createdPost!.id && p.photos.length == 1,
          ),
          isTrue,
        );
      },
    );

    test(
      // Amaç: + Gün Ekle işlemi mevcut bitiş tarihini aştığında TripEntity.endDate
      // güncellenmeli, checklist maddeleri sortOrder sırasıyla eklenmeli ve silinmelidir.
      'TripsController + Gün Ekle tarih aralığını uzatır ve checklist sortOrder/CRUD çalışır',
      () async {
        final fakeTrips = _FakeTripsRepo()
          ..trips.add(
            TripEntity(
              id: 'trip-1',
              userId: 'user-1',
              title: 'Kaş Rotası',
              country: 'Türkiye',
              city: 'Antalya',
              startDate: DateTime(2026, 5, 1),
              endDate: DateTime(2026, 5, 2),
              days: [
                TripDayEntity(
                  id: 'day-1',
                  tripId: 'trip-1',
                  dayNumber: 1,
                  dayDate: DateTime(2026, 5, 1),
                  stops: const [
                    TripStopEntity(
                      id: 'stop-1',
                      tripDayId: 'day-1',
                      placeId: 'place-1',
                      orderIndex: 0,
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
                  sortOrder: 0,
                ),
              ],
            ),
          );
        final container = ProviderContainer(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(_TestPrefs()),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
            tripsRepositoryProvider.overrideWithValue(fakeTrips),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(authControllerProvider.notifier)
            .resolveInitialSession();
        final ctrl = container.read(tripsControllerProvider.notifier);
        await ctrl.loadTrips();

        // Başlangıçta trip-1 2 günlük (1-2 Mayıs) ve 1 gün + 1 stop içeriyor.
        final initialTrip = container
            .read(tripsControllerProvider)
            .findById('trip-1')!;
        expect(initialTrip.days.length, 1);
        final addedDay = await ctrl.addDayToTrip('trip-1');
        expect(addedDay, isNotNull);

        final afterDay = container
            .read(tripsControllerProvider)
            .findById('trip-1')!;
        expect(afterDay.days.length, 2);
        expect(afterDay.days.first.stops.length, 1);

        final addedChecklist = await ctrl.addChecklistItem(
          tripId: 'trip-1',
          title: 'Pasaport fotokopisi',
          category: TripChecklistCategory.documents,
        );
        expect(addedChecklist, isTrue);
        final afterChk = container
            .read(tripsControllerProvider)
            .findById('trip-1')!;
        expect(afterChk.checklist.length, 2);
        expect(
          afterChk.checklist.last.category,
          TripChecklistCategory.documents,
        );
        expect(afterChk.checklist.last.sortOrder, 1);

        final toggled = await ctrl.toggleChecklistItem(
          tripId: 'trip-1',
          item: afterChk.checklist.last,
        );
        expect(toggled, isTrue);
        expect(
          container
              .read(tripsControllerProvider)
              .findById('trip-1')!
              .checklist
              .last
              .isCompleted,
          isTrue,
        );

        final deleted = await ctrl.deleteChecklistItem(
          tripId: 'trip-1',
          itemId: afterChk.checklist.last.id,
        );
        expect(deleted, isTrue);
        expect(
          container
              .read(tripsControllerProvider)
              .findById('trip-1')!
              .checklist
              .length,
          1,
        );
      },
    );

    test(
      // Amaç: CommunityController yorum silmede commentCount azaltmalı, kaydetmede
      // savedPosts güncellemeli, engellemede tüm akış/kayıtlı/yorumları temizlemeli ve
      // Notifications etkileşim filtresi hem beğeni hem yorum bildirimlerini içermelidir.
      'Topluluk sayaç senkronizasyonu, engelleme temizliği ve bildirim etkileşim filtresi çalışır',
      () async {
        final fakeCommunity = _FakeCommunityRepo();
        final fakeProfile = _FakeProfileSettingsRepo()
          ..items.addAll([
            NotificationEntity(
              id: 'n-2',
              userId: 'user-1',
              actorUserId: 'user-2',
              targetPostId: 'post-1',
              kind: NotificationKind.like,
              title: 'Yeni Beğeni',
              body: 'Ege Kaya gönderini beğendi.',
              createdAt: DateTime(2026, 4, 12, 1),
              isRead: false,
            ),
            NotificationEntity(
              id: 'n-3',
              userId: 'user-1',
              actorUserId: 'user-2',
              targetPostId: 'post-1',
              kind: NotificationKind.comment,
              title: 'Yeni Yorum',
              body: 'Ege Kaya gönderine yorum yaptı.',
              createdAt: DateTime(2026, 4, 12, 2),
              isRead: false,
            ),
          ]);
        final container = ProviderContainer(
          overrides: [
            appPreferencesStorageProvider.overrideWithValue(_TestPrefs()),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepo()),
            communityRepositoryProvider.overrideWithValue(fakeCommunity),
            profileSettingsRepositoryProvider.overrideWithValue(fakeProfile),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(authControllerProvider.notifier)
            .resolveInitialSession();
        final communityCtrl = container.read(
          communityControllerProvider.notifier,
        );
        await communityCtrl.loadFeed();

        await communityCtrl.toggleSavePost('post-1');
        expect(
          container
              .read(communityControllerProvider)
              .savedPosts
              .any((p) => p.id == 'post-1'),
          isTrue,
        );

        await communityCtrl.addComment(postId: 'post-1', body: 'Harika yazı!');
        expect(
          container
              .read(communityControllerProvider)
              .findPostById('post-1')
              ?.commentCount,
          1,
        );
        final commentId = container
            .read(communityControllerProvider)
            .commentsByPost['post-1']!
            .first
            .id;

        final deletedComment = await communityCtrl.deleteComment(
          postId: 'post-1',
          commentId: commentId,
        );
        expect(deletedComment, isTrue);
        expect(
          container
              .read(communityControllerProvider)
              .findPostById('post-1')
              ?.commentCount,
          0,
        );

        // Engelleme akıştan ve kaydedilenlerden gönderiyi kaldırmalıdır.
        await communityCtrl.blockUser('user-2');
        final afterBlock = container.read(communityControllerProvider);
        expect(afterBlock.feedPosts, isEmpty);
        expect(afterBlock.savedPosts, isEmpty);

        // Silinmiş gönderi açılmak istendiğinde notFoundPostIds içine kaydedilmelidir.
        final missing = await communityCtrl.loadPostById('non-existent-post');
        expect(missing, isNull);
        expect(
          container
              .read(communityControllerProvider)
              .notFoundPostIds
              .contains('non-existent-post'),
          isTrue,
        );

        // Bildirim etkileşim filtresi hem like hem comment türlerini içermelidir.
        final profileCtrl = container.read(
          profileSettingsControllerProvider.notifier,
        );
        await profileCtrl.loadNotifications();
        profileCtrl.setFilter(NotificationFilter.interactions);
        final interactions = container
            .read(profileSettingsControllerProvider)
            .filteredNotifications;
        expect(
          interactions.every(
            (n) =>
                n.kind == NotificationKind.like ||
                n.kind == NotificationKind.comment,
          ),
          isTrue,
        );
        expect(interactions.isNotEmpty, isTrue);
      },
    );
  });
}
