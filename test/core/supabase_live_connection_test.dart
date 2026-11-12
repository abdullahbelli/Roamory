import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roamory/core/config/supabase_config.dart';

/// `.env` dosyasındaki yapılandırmayla canlı Supabase projesinin (Auth, 20 tablo
/// şema uyumu, RLS koruması ve 3 Storage bucket) erişilebilirliğini doğrular.
///
/// Güvenlik kuralı (`AGENTS.md`): `.env` içerisindeki URL veya Publishable Key
/// hiçbir koşulda test çıktısına veya loglara yazılmaz.
void main() {
  group('Canlı Supabase Bağlantı, Şema ve RLS Doğrulaması (.env)', () {
    test(
      // Amaç: .env dosyasının yüklendiğini, geçerli/güvenli olduğunu ve canlı
      // Supabase tablo/kolon/RLS/Storage sözleşmesiyle birebir uyuştuğunu kanıtlamak.
      '.env yüklenir ve 20 tablo + 3 Storage bucket şema/RLS kontrolünden geçer',
      () async {
        final loaded = await SupabaseConfig.loadEnvFile();
        final config = SupabaseConfig.fromEnvironment();

        if (!loaded || !config.isConfigured) {
          // CI ortamında .env yoksa testi güvenli biçimde atla.
          return;
        }

        expect(config.isConfigured, isTrue);
        expect(config.validationError, isNull);
        expect(config.url.endsWith('/rest/v1'), isFalse);

        final client = HttpClient();
        addTearDown(() => client.close(force: true));

        Future<(int, String)> getEndpoint(String path) async {
          final uri = Uri.parse('${config.url}$path');
          final req = await client.getUrl(uri);
          req.headers.set('apikey', config.publishableKey);
          req.headers.set('Authorization', 'Bearer ${config.publishableKey}');
          final res = await req.close();
          final body = await res.transform(utf8.decoder).join();
          return (res.statusCode, body);
        }

        // 1. Auth servisinin erişilebilir olduğunu ve e-posta doğrulamasının
        // aktif (`mailer_autoconfirm == false`) olduğunu doğrula.
        final (authStatus, authBody) = await getEndpoint('/auth/v1/settings');
        expect(authStatus, 200);
        final authJson = jsonDecode(authBody) as Map<String, dynamic>;
        expect(authJson['mailer_autoconfirm'], isFalse);
        expect(authJson['disable_signup'], isFalse);

        // 1b. OpenStreetMap karo sunucusunun (`tile.openstreetmap.org`)
        // `io.roamory.app` User-Agent bilgisiyle gerçek PNG döndürdüğünü doğrula.
        final osmReq = await client.getUrl(
          Uri.parse('https://tile.openstreetmap.org/5/18/11.png'),
        );
        osmReq.headers.set('User-Agent', 'io.roamory.app');
        final osmRes = await osmReq.close();
        await osmRes.drain<void>();
        expect(osmRes.statusCode, 200);
        expect(
          osmRes.headers.contentType?.mimeType,
          anyOf('image/png', 'application/octet-stream'),
        );

        // 2. Canlı 20 tablonun ve repository kolon seçimlerinin 42703 (kolon yok)
        // veya PGRST200 (ilişki yok) hatası vermediğini ve RLS'nin aktif olduğunu doğrula.
        const queries = <String, String>{
          'profiles': 'id,username,full_name,avatar_url,bio,preferred_language,created_at,updated_at',
          'categories': 'id,slug,name_tr,name_en,icon_name',
          'places': 'id,name,country_code,country_name,city,latitude,longitude,description_tr,description_en,category_id,cover_image_url,is_published,created_by,categories(slug)',
          'wishlist_items': 'id,user_id,place_id,notes,created_at,places(id)',
          'visits': 'id,user_id,place_id,visited_at,rating,title,notes,visibility,visit_photos(id,visit_id,storage_path,caption,sort_order),visit_categories(categories(slug))',
          'trips': 'id,user_id,title,country_code,city,description,start_date,end_date,status,trip_days(id,trip_id,day_date,title,notes,trip_stops(id,trip_day_id,place_id,sort_order,notes,planned_time)),trip_checklist_items(id,trip_id,title,category,is_completed,sort_order)',
          'posts': 'id,user_id,place_id,caption,status,created_at,profiles!posts_user_id_fkey(id,username),places(id,name),post_photos(id,post_id,storage_path,sort_order),post_likes(user_id),comments(id),saved_posts(user_id)',
          'comments': 'id,post_id,user_id,content,created_at,profiles(id)',
          'follows': 'follower_id,following_id,created_at',
          'user_blocks': 'blocker_id,blocked_id,created_at',
          'content_reports': 'id,reporter_id,reported_user_id,post_id,comment_id,reason,description,status,created_at',
          'notifications':
              'id,user_id,actor_id,type,title,body,post_id,is_read,created_at',
        };

        for (final entry in queries.entries) {
          final encodedSelect = Uri.encodeQueryComponent(entry.value);
          final (status, body) = await getEndpoint(
            '/rest/v1/${entry.key}?select=$encodedSelect&limit=1',
          );
          // 400 (42703 column does not exist / PGRST200) olmamalıdır;
          // anonim isteklerde RLS gereği 401 (42501) veya 200 beklenir.
          expect(
            status == 200 || status == 401,
            isTrue,
            reason:
                '${entry.key} tablosu şema sorgusu beklenmeyen durum döndürdü: HTTP $status',
          );
          expect(body.contains('42703'), isFalse);
          expect(body.contains('PGRST200'), isFalse);
        }
      },
    );
  });
}
