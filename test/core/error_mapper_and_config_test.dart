import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:roamory/features/community/data/repositories/supabase_community_repository.dart';
import 'package:roamory/features/explore/data/repositories/supabase_explore_repository.dart';
import 'package:roamory/features/profile/data/repositories/supabase_profile_settings_repository.dart';
import 'package:roamory/features/trips/data/repositories/supabase_trips_repository.dart';
import 'package:roamory/features/trips/domain/entities/trip_entity.dart';
import 'package:roamory/features/wishlist/data/repositories/supabase_wishlist_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tercih yönetimi testleri için bellek içi sahte depolama.
class _InMemoryPreferencesStorage implements AppPreferencesStorage {
  AppPreferencesState _current = const AppPreferencesState();

  @override
  AppPreferencesState loadSync() => _current;

  @override
  Future<void> saveLocaleCode(String? languageCode) async {
    _current = _current.copyWith(
      locale: languageCode == null ? null : Locale(languageCode),
      clearLocale: languageCode == null,
    );
  }

  @override
  Future<void> saveOnboardingCompleted(bool completed) async {
    _current = _current.copyWith(onboardingCompleted: completed);
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    _current = _current.copyWith(themeMode: mode);
  }
}

void main() {
  group('SupabaseConfig', () {
    test(
      // Amaç: Eksik URL veya key durumunda isConfigured false dönerek çökme önlenmeli.
      'boş değerlerde isConfigured false, dolu değerlerde true döner',
      () {
        final empty = SupabaseConfig(url: '', publishableKey: '');
        final partial = SupabaseConfig(
          url: 'https://example.supabase.co',
          publishableKey: ' ',
        );
        final valid = SupabaseConfig(
          url: 'https://example.supabase.co',
          publishableKey: 'sb_publishable_test',
        );

        expect(empty.isConfigured, isFalse);
        expect(partial.isConfigured, isFalse);
        expect(valid.isConfigured, isTrue);
      },
    );

    test(
      // Amaç: .env içinden okunan URL'deki /rest/v1 eki ve tırnaklar temizlenmeli,
      // secret/service_role veya placeholder anahtarlar güvenlik gereği reddedilmelidir.
      '.env haritasından okuma, URL normalizasyonu ve secret key engellemesi çalışır',
      () {
        final fromDotEnv = SupabaseConfig.fromEnvironment(
          envOverride: const {
            'SUPABASE_URL': '"https://demo-ref.supabase.co/rest/v1/"',
            'SUPABASE_PUBLISHABLE_KEY': "'sb_publishable_valid_123'",
          },
        );
        expect(fromDotEnv.url, 'https://demo-ref.supabase.co');
        expect(fromDotEnv.publishableKey, 'sb_publishable_valid_123');
        expect(fromDotEnv.isConfigured, isTrue);

        final placeholder = SupabaseConfig(
          url: 'https://your-project.supabase.co',
          publishableKey: 'your_publishable_key_here',
        );
        expect(placeholder.isConfigured, isFalse);
        expect(placeholder.validationError, isNotNull);

        final forbiddenSecret = SupabaseConfig(
          url: 'https://demo-ref.supabase.co',
          publishableKey: 'sb_secret_never_use_on_client',
        );
        expect(forbiddenSecret.isConfigured, isFalse);
        expect(forbiddenSecret.validationError, contains('Güvenlik ihlali'));
      },
    );
  });

  group('Canlı Supabase Şema Satır Eşlemeleri (20 Tablo Uyumu)', () {
    test(
      // Amaç: Canlı veritabanı kolon isimleri (country_name, description_tr, notes,
      // sort_order, planned_time, content, actor_id, post_id) domain varlıklarına hatasız eşlenmeli.
      'places, wishlist_items, trips, trip_stops, comments ve notifications canlı kolonlarıyla eşlenir',
      () {
        final place = SupabaseExploreRepository.mapPlaceRow({
          'id': 'p1',
          'name': 'Galata Kulesi',
          'country_code': 'TR',
          'country_name': 'Türkiye',
          'city': 'İstanbul',
          'latitude': 41.0256,
          'longitude': 28.9741,
          'description_tr': 'Tarihi kule',
          'is_published': true,
          'categories': {'slug': 'tarih'},
        });
        expect(place.country, 'Türkiye');
        expect(place.description, 'Tarihi kule');
        expect(place.categorySlug, 'tarih');
        expect(
          SupabaseExploreRepository.normalizeCountryCode('Türkiye'),
          equals('TR'),
        );

        final wishlist = SupabaseWishlistRepository.mapWishlistRow({
          'id': 'w1',
          'user_id': 'u1',
          'place_id': 'p1',
          'notes': 'Gün batımında gidilecek',
          'created_at': '2026-05-01T10:00:00Z',
        });
        expect(wishlist.note, 'Gün batımında gidilecek');

        final trip = SupabaseTripsRepository.mapTripRow({
          'id': 't1',
          'user_id': 'u1',
          'title': 'Ege Rotası',
          'country_code': 'TR',
          'city': 'İzmir',
          'status': 'planned',
          'trip_days': [
            {
              'id': 'd1',
              'trip_id': 't1',
              'day_date': '2026-06-01',
              'title': '1. Gün',
              'trip_stops': [
                {
                  'id': 's1',
                  'trip_day_id': 'd1',
                  'place_id': 'p1',
                  'sort_order': 2,
                  'planned_time': '09:30',
                },
              ],
            },
          ],
        });
        expect(trip.country, 'TR');
        expect(trip.days.single.dayNumber, 1);
        expect(trip.days.single.stops.single.orderIndex, 2);
        expect(trip.days.single.stops.single.arrivalTime, '09:30');

        final comment = SupabaseCommunityRepository.mapCommentRow({
          'id': 'c1',
          'post_id': 'post1',
          'user_id': 'u1',
          'content': 'Harika bir rota!',
          'created_at': '2026-05-01T12:00:00Z',
        });
        expect(comment.body, 'Harika bir rota!');

        final notification =
            SupabaseProfileSettingsRepository.mapNotificationRow({
              'id': 'n1',
              'user_id': 'u1',
              'actor_id': 'u2',
              'post_id': 'post1',
              'type': 'like',
              'title': 'Yeni beğeni',
              'body': 'Gönderini beğendi',
              'is_read': false,
              'created_at': '2026-05-01T12:00:00Z',
            });
        expect(notification.actorUserId, 'u2');
        expect(notification.targetPostId, 'post1');
      },
    );
  });

  group('ErrorMapper', () {
    test(
      // Amaç: Teknik ağ ve zaman aşımı hataları NetworkAppException'a dönüştürülmeli.
      'SocketException ve TimeoutException ağ hatasına eşlenir',
      () {
        expect(
          ErrorMapper.map(const SocketException('offline')),
          isA<NetworkAppException>(),
        );
        expect(
          ErrorMapper.map(TimeoutException('timeout')),
          isA<NetworkAppException>(),
        );
      },
    );

    test(
      // Amaç: RLS ihlali (42501), tablo GRANT eksikliği (permission denied for table)
      // ve 401/403 Auth hataları doğru alt kodlarla UnauthorizedAppException olmalı.
      'Postgrest RLS, tablo GRANT eksikliği ve Auth 401/403 hataları yetkisiz erişim hatasına eşlenir',
      () async {
        final rlsError = PostgrestException(
          message:
              'new row violates row-level security policy for table "visits"',
          code: '42501',
        );
        final tableGrantError = PostgrestException(
          message: 'permission denied for table places',
          code: '42501',
          hint: 'Grant the required privileges to the current role with: GRANT INSERT ON public.places TO authenticated;',
        );
        final notFound = PostgrestException(
          message: 'No rows',
          code: 'PGRST116',
        );
        final authError = AuthException('Forbidden', statusCode: '403');
        final storageError = StorageException(
          'Unauthorized',
          statusCode: '401',
        );

        final mappedRls = ErrorMapper.map(rlsError);
        final mappedTableGrant = ErrorMapper.map(tableGrantError);

        expect(mappedRls, isA<UnauthorizedAppException>());
        expect(mappedRls.code, equals('42501'));
        expect(mappedTableGrant, isA<UnauthorizedAppException>());
        expect(mappedTableGrant.code, equals('db_table_permission_denied'));
        expect(ErrorMapper.map(notFound), isA<NotFoundAppException>());
        expect(ErrorMapper.map(authError), isA<UnauthorizedAppException>());
        expect(ErrorMapper.map(storageError), isA<UnauthorizedAppException>());

        // 23514 `trip_checklist_items_category_check` ihlali kategori hatasına eşlenmelidir.
        final checklistCheckError = PostgrestException(
          message: 'new row for relation "trip_checklist_items" violates check constraint "trip_checklist_items_category_check"',
          code: '23514',
        );
        final mappedChecklistCheck = ErrorMapper.map(checklistCheckError);
        expect(mappedChecklistCheck, isA<ValidationAppException>());
        expect(mappedChecklistCheck.code, equals('checklist_invalid_category'));

        // Kanonik checklist kategori normalizasyonu ve sort_order okuma doğrulaması.
        expect(TripChecklistCategory.isValid('other'), isTrue);
        expect(TripChecklistCategory.isValid('documents'), isTrue);
        expect(TripChecklistCategory.isValid('packing'), isTrue);
        expect(TripChecklistCategory.isValid('bookings'), isTrue);
        expect(TripChecklistCategory.isValid('general'), isFalse);
        expect(TripChecklistCategory.isValid('docs'), isFalse);
        expect(TripChecklistCategory.isValid('Genel Hazırlık'), isFalse);
        expect(TripChecklistCategory.normalize('docs'), 'documents');
        expect(TripChecklistCategory.normalize('gear'), 'packing');
        expect(TripChecklistCategory.normalize('hotel'), 'bookings');
        expect(TripChecklistCategory.normalize('general'), 'other');
        final mappedChecklist = SupabaseTripsRepository.mapChecklistRow({
          'id': 'chk-10',
          'trip_id': 't1',
          'title': 'Pasaport',
          'category': 'documents',
          'is_completed': true,
          'sort_order': 3,
        });
        expect(mappedChecklist.category, 'documents');
        expect(mappedChecklist.sortOrder, 3);
        await expectLater(
          () => SupabaseTripsRepository(
            null,
          ).updateChecklistItem(itemId: 'chk-10', category: 'Genel Hazırlık'),
          throwsA(
            isA<ValidationAppException>().having(
              (e) => e.code,
              'code',
              'checklist_invalid_category',
            ),
          ),
        );
      },
    );
  });

  group('AppPreferencesNotifier', () {
    test(
      // Amaç: Dil, tema ve onboarding güncellemeleri state'e ve depoya yansımalıdır.
      'dil, tema ve onboarding durumu güncellenir ve kalıcı depoya yazılır',
      () async {
        final storage = _InMemoryPreferencesStorage();
        final container = ProviderContainer(
          overrides: [appPreferencesStorageProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(appPreferencesProvider.notifier);
        await notifier.setLocale(const Locale('en'));
        await notifier.setThemeMode(ThemeMode.dark);
        await notifier.completeOnboarding();

        final state = container.read(appPreferencesProvider);
        expect(state.locale, const Locale('en'));
        expect(state.themeMode, ThemeMode.dark);
        expect(state.onboardingCompleted, isTrue);

        final reloaded = storage.loadSync();
        expect(reloaded.locale, const Locale('en'));
        expect(reloaded.themeMode, ThemeMode.dark);
        expect(reloaded.onboardingCompleted, isTrue);
      },
    );
  });
}
