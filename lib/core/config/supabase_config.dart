import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// `.env` dosyası veya `--dart-define` üzerinden gelen Supabase istemci
/// yapılandırmasını yönetir.
///
/// Güvenlik kuralı (`AGENTS.md`) gereği istemci koduna yalnızca proje URL'si
/// (`SUPABASE_URL`) ve herkese açık publishable key (`SUPABASE_PUBLISHABLE_KEY`)
/// verilir; hiçbir `service_role` veya `sb_secret_` anahtarı kabul edilmez.
@immutable
class SupabaseConfig {
  /// Normalize edilmiş bağlantı değerleriyle yeni bir [SupabaseConfig] oluşturur.
  SupabaseConfig({required String url, required String publishableKey})
    : url = normalizeUrl(url),
      publishableKey = normalizeKey(publishableKey);

  /// Önce `--dart-define` derleme parametrelerini, boşsa yüklenmiş `.env`
  /// değerlerini okuyarak [SupabaseConfig] örneği üretir.
  ///
  /// Birim testlerinde [envOverride] haritası verilerek gerçek `.env` dosyasına
  /// bağımlı olmadan farklı yapılandırma senaryoları doğrulanabilir.
  factory SupabaseConfig.fromEnvironment({Map<String, String>? envOverride}) {
    // 1. Öncelik: Derleme anında --dart-define ile verilen değerler (CI/CD uyumu).
    const defineUrl = String.fromEnvironment('SUPABASE_URL');
    const defineKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

    // 2. Yedek: Uygulama açılışında flutter_dotenv ile yüklenen .env değerleri.
    final Map<String, String> dotEnvMap =
        envOverride ?? (dotenv.isInitialized ? dotenv.env : const {});

    final resolvedUrl = defineUrl.trim().isNotEmpty
        ? defineUrl
        : (dotEnvMap['SUPABASE_URL'] ?? '');
    final resolvedKey = defineKey.trim().isNotEmpty
        ? defineKey
        : (dotEnvMap['SUPABASE_PUBLISHABLE_KEY'] ?? '');

    return SupabaseConfig(url: resolvedUrl, publishableKey: resolvedKey);
  }

  /// Supabase proje kök adresi (`https://<project-ref>.supabase.co`).
  final String url;

  /// İstemci tarafı güvenli publishable anahtar (`sb_publishable_...` veya `eyJ...` anon).
  final String publishableKey;

  /// `.env` dosyasını güvenli biçimde belleğe yükler.
  ///
  /// Test ortamında veya `.env` dosyasının bulunmadığı CI ortamlarında
  /// uygulamanın çökmemesi için hata yakalanır ve `--dart-define` yedeği devreye girer.
  static Future<bool> loadEnvFile({String fileName = '.env'}) async {
    try {
      await dotenv.load(fileName: fileName);
      return true;
    } catch (_) {
      // .env dosyası mevcut değilse sessizce devam edilir; doğrulama isConfigured'da yapılır.
      return false;
    }
  }

  /// URL içerisindeki tırnak işaretlerini, sondaki `/` karakterlerini ve
  /// yanlışlıkla eklenen `/rest/v1` gibi alt yolları temizler.
  static String normalizeUrl(String rawUrl) {
    var cleaned = _stripQuotes(rawUrl.trim());
    while (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    // Kullanıcı .env içine REST endpoint adresini yapıştırdıysa kök URL'ye indirgeriz.
    if (cleaned.toLowerCase().endsWith('/rest/v1')) {
      cleaned = cleaned.substring(0, cleaned.length - '/rest/v1'.length);
    }
    while (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    return cleaned;
  }

  /// Anahtar içerisindeki olası sarma tırnaklarını ve boşlukları temizler.
  static String normalizeKey(String rawKey) {
    return _stripQuotes(rawKey.trim());
  }

  static String _stripQuotes(String input) {
    if (input.length >= 2) {
      final startsSingle = input.startsWith("'") && input.endsWith("'");
      final startsDouble = input.startsWith('"') && input.endsWith('"');
      if (startsSingle || startsDouble) {
        return input.substring(1, input.length - 1).trim();
      }
    }
    return input;
  }

  /// Yapılandırmada eksik, örnek (placeholder) veya yasaklı (`service_role`/`secret`)
  /// bir değer varsa açıklayıcı hata kodunu döner; geçerliyse `null` döner.
  ///
  /// Güvenlik gereği hata mesajına gerçek URL veya anahtar değeri asla yazılmaz.
  String? get validationError {
    if (url.isEmpty || publishableKey.isEmpty) {
      return 'SUPABASE_URL veya SUPABASE_PUBLISHABLE_KEY tanımlı değil.';
    }

    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('your-project.supabase.co') ||
        lowerUrl.contains('<project-ref>')) {
      return 'SUPABASE_URL hâlâ örnek (placeholder) değer içeriyor.';
    }

    final parsedUri = Uri.tryParse(url);
    if (parsedUri == null ||
        !parsedUri.hasScheme ||
        (parsedUri.scheme != 'https' && parsedUri.scheme != 'http') ||
        parsedUri.host.isEmpty) {
      return 'SUPABASE_URL geçerli bir http/https adresi değil.';
    }

    final lowerKey = publishableKey.toLowerCase();
    if (lowerKey.contains('your_publishable_key_here') ||
        lowerKey == 'sb_publishable_...') {
      return 'SUPABASE_PUBLISHABLE_KEY hâlâ örnek (placeholder) değer içeriyor.';
    }

    // AGENTS.md kuralı: Secret veya service_role anahtarı istemcide kesinlikle kullanılamaz.
    if (lowerKey.startsWith('sb_secret_') ||
        lowerKey.contains('service_role')) {
      return 'Güvenlik ihlali: İstemci uygulamasında secret veya service_role anahtarı kullanılamaz.';
    }

    return null;
  }

  /// Zorunlu bağlantı bilgilerinin geçerli, güvenli ve kullanıma hazır olduğunu doğrular.
  bool get isConfigured => validationError == null;

  /// Yapılandırma geçerliyse `Supabase.initialize` çağrısını güvenli biçimde yürütür.
  ///
  /// Eksik veya hatalı yapılandırmada uygulama çökmesini önlemek için `false` döner;
  /// gizli anahtarları loglara sızdırmadan yalnızca durum bilgisini yazar.
  static Future<bool> initializeIfConfigured(SupabaseConfig config) async {
    final error = config.validationError;
    if (error != null) {
      debugPrint('[SupabaseConfig] Yapılandırma doğrulanamadı: $error');
      return false;
    }

    try {
      // supabase_flutter 2.x PKCE kimlik doğrulama akışıyla başlatılır.
      await Supabase.initialize(
        url: config.url,
        publishableKey: config.publishableKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('[SupabaseConfig] Supabase başlatılırken hata oluştu.');
      return false;
    }
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
  try {
    return Supabase.instance.client;
  } catch (_) {
    // Birim/widget testlerinde Supabase.initialize çağrılmadıysa güvenli null döner.
    return null;
  }
});
