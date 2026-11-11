import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// `--dart-define` üzerinden gelen Supabase istemci yapılandırmasını yönetir.
///
/// Güvenlik kuralı gereği yalnızca proje URL'si ve herkese açık publishable key
/// okunur; hiçbir `service_role` veya secret anahtar istemci koduna konmaz.
@immutable
class SupabaseConfig {
  /// Yapılandırma değerleriyle yeni bir [SupabaseConfig] örneği oluşturur.
  const SupabaseConfig({required this.url, required this.publishableKey});

  /// Derleme zamanında `--dart-define` parametrelerinden okunan varsayılan ayar.
  factory SupabaseConfig.fromEnvironment() {
    // Değerleri derleme anında ortam değişkenlerinden alıyoruz.
    const url = String.fromEnvironment('SUPABASE_URL');
    const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    return const SupabaseConfig(url: url, publishableKey: publishableKey);
  }

  /// Supabase proje adresi (`https://<project-ref>.supabase.co`).
  final String url;

  /// İstemci tarafı güvenli publishable anahtar (`sb_publishable_...`).
  final String publishableKey;

  /// Zorunlu bağlantı bilgilerinin geçerli ve boş olmadığını doğrular.
  bool get isConfigured =>
      url.trim().isNotEmpty && publishableKey.trim().isNotEmpty;

  /// Yapılandırma mevcutsa `Supabase.initialize` çağrısını bir kez gerçekleştirir.
  ///
  /// Eksik `--dart-define` durumunda uygulama çökmesini önlemek için `false`
  /// döner; böylece kullanıcıya anlaşılır yapılandırma/bağlantı hatası gösterilir.
  static Future<bool> initializeIfConfigured(SupabaseConfig config) async {
    if (!config.isConfigured) {
      debugPrint(
        '[SupabaseConfig] SUPABASE_URL veya SUPABASE_PUBLISHABLE_KEY tanımlı değil.',
      );
      return false;
    }

    // supabase_flutter 2.x güncel imzasıyla publishableKey parametresini kullanıyoruz.
    await Supabase.initialize(
      url: config.url.trim(),
      publishableKey: config.publishableKey.trim(),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    return true;
  }
}

/// Uygulama genelindeki aktif [SupabaseConfig] bilgisini sağlar.
final supabaseConfigProvider = Provider<SupabaseConfig>((ref) {
  return SupabaseConfig.fromEnvironment();
});

/// Başlatılmış [SupabaseClient] örneğini döner; yapılandırma yoksa `null` olur.
///
/// Data katmanındaki repository implementasyonları bu sağlayıcıyı okuyarak
/// veritabanı erişimini soyutlar; UI katmanı doğrudan istemci çağırmaz.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  if (!config.isConfigured) {
    return null;
  }
  return Supabase.instance.client;
});
