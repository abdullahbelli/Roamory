import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/app/app.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Roamory uygulamasının giriş noktası.
///
/// Uygulama başlamadan önce `.env` ortam dosyası yüklenir, yerel tercihler
/// (`SharedPreferences`) hazırlanır ve Supabase bağlantısı doğrulanarak başlatılır.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Kök dizindeki .env dosyasını yükle (--dart-define verildiyse yedek olarak çalışır).
  await SupabaseConfig.loadEnvFile();

  // 2. Yerel dil, tema ve karşılama turu tercihlerini açılışta hazırla.
  final sharedPreferences = await SharedPreferences.getInstance();
  final preferencesStorage = SharedPreferencesAppStorage(sharedPreferences);

  // 3. .env veya --dart-define üzerinden Supabase yapılandırmasını oku ve başlat.
  final supabaseConfig = SupabaseConfig.fromEnvironment();
  await SupabaseConfig.initializeIfConfigured(supabaseConfig);

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesStorageProvider.overrideWithValue(preferencesStorage),
        supabaseConfigProvider.overrideWithValue(supabaseConfig),
      ],
      child: const RoamoryApp(),
    ),
  );
}
