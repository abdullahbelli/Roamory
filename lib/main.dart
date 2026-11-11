import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/app/app.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/providers/app_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Roamory uygulamasının giriş noktası.
///
/// Yerel tercihler (`SharedPreferences`) ve derleme ortamından sağlanan
/// Supabase yapılandırması başlatıldıktan sonra Riverpod kök kapsamı kurulur.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Yerel dil, tema ve karşılama turu tercihlerini açılışta senkron hazırlarız.
  final sharedPreferences = await SharedPreferences.getInstance();
  final preferencesStorage = SharedPreferencesAppStorage(sharedPreferences);

  // Supabase yalnızca --dart-define değerleri sağlandıysa başlatılır.
  final supabaseConfig = SupabaseConfig.fromEnvironment();
  await SupabaseConfig.initializeIfConfigured(supabaseConfig);

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesStorageProvider.overrideWithValue(preferencesStorage),
      ],
      child: const RoamoryApp(),
    ),
  );
}
