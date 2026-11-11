import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
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
        const empty = SupabaseConfig(url: '', publishableKey: '');
        const partial = SupabaseConfig(
          url: 'https://example.supabase.co',
          publishableKey: ' ',
        );
        const valid = SupabaseConfig(
          url: 'https://example.supabase.co',
          publishableKey: 'sb_publishable_test',
        );

        expect(empty.isConfigured, isFalse);
        expect(partial.isConfigured, isFalse);
        expect(valid.isConfigured, isTrue);
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
      // Amaç: RLS ihlali (42501) ve 401/403 Auth hataları UnauthorizedAppException olmalı.
      'Postgrest RLS ve Auth 401/403 hataları yetkisiz erişim hatasına eşlenir',
      () {
        final rlsError = PostgrestException(
          message: 'RLS denied',
          code: '42501',
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

        expect(ErrorMapper.map(rlsError), isA<UnauthorizedAppException>());
        expect(ErrorMapper.map(notFound), isA<NotFoundAppException>());
        expect(ErrorMapper.map(authError), isA<UnauthorizedAppException>());
        expect(ErrorMapper.map(storageError), isA<UnauthorizedAppException>());
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
