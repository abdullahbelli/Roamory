# Roamory — Supabase Gerçek Şema Envanteri ve Entegrasyon

> **Önemli:** Bu doküman görüşmede SQL Editor üzerinden oluşturulduğu ve denetlendiği bildirilen mevcut şemanın özetidir; tam SQL dump DEĞİLDİR. Antigravity **önce gerçek PostgreSQL katalog/şema sorgusu ile kolonları, FK'leri, grant'leri, policy ifadelerini ve trigger'ları doğrulamalı**. Şema farkında varsayım yapmamalı. Canlı projede `DROP`, `TRUNCATE`, `DELETE` veya reset/migration push işlemlerini kullanıcı onayı olmadan çalıştırma.

## Mevcut Supabase
- Organization / Project: `Roamory / roamory`.
- Veritabanı bölgesi: `eu-west-1` (Ireland), Free.
- Email/Password ve Google sağlayıcısı enabled; Google OAuth web client ve callback yapılandırılmış.
- Mobil auth redirect allowlist: `io.roamory.app://login-callback/`; Flutter Android/iOS deep linking henüz kodlanmadı.
- SMTP/domain **kurulmadı**. Varsayılan mail servisinin test/alıcı limitleri var.
- API: **publishable** anahtar istemcide kullanılabilir; hiçbir secret/service-role Flutter'a konulamaz. Gerçek değerler `--dart-define` veya local ignored config ile verilir.

## 20 public tablonun envanteri
| Modül | Tablolar | Dikkat |
|---|---|---|
| Kullanıcı | `profiles` | `id` -> `auth.users`; username/full_name/avatar_url/bio/preferred_language; otomatik profil trigger'ı mevcut |
| Keşif | `categories`, `places` | category slug/name_tr/name_en; place coords + country/city; is_published; `created_by` sonradan eklendi; sadece owner private veya published gösterimi |
| Ziyaret | `visits`, `visit_photos`, `visit_categories` | user_id, place_id, visited_at, rating, visibility; photo storage_path; etiket ilişkisi; **visibility=public başkalarına otomatik görünür yapmaz** |
| Wishlist | `wishlist_items` | unique `(user_id, place_id)` |
| Seyahat | `trips`, `trip_days`, `trip_stops`, `trip_checklist_items` | owner, tarih, status; day_date trip tarihleriyle uyumlu; stop place_id; checklist categories |
| Sosyal | `posts`, `post_photos`, `post_likes`, `comments`, `follows`, `saved_posts` | draft/published; paylaşımlar günlükten bağımsız; engelleme politikaları güncellendi |
| Güvenlik | `notifications`, `user_blocks`, `content_reports` | bildirimler client INSERT değildir; engellemede takip temizleme trigger'ı; moderation server-only olmalı |

## Storage
- `avatars`: public, 5 MB, JPEG/PNG/WebP; `userUUID/file` path.
- `visit-photos`: private, 10 MB, JPEG/PNG/WebP; `userUUID/visitUUID/file`.
- `post-photos`: private, 10 MB, JPEG/PNG/WebP; `userUUID/postUUID/file`.
- Her bucket için 4 policy tanımlandı; politika SAYISI güvenliği kanıtlamaz. Private bucket için signed URL veya authenticated download; server URL süresi dikkatli yönetilir.

## RLS durumu
- 20/20 tabloda RLS enabled, 20/20 tabloda en az bir policy raporlandı.
- İki test hesabıyla private visit, trips, wishlist, post visibility + block, insert/update/delete senaryoları SQL Editor üzerinden geçildiği bildirildi; **mobil istemciden tekrar test et**.
- `private.is_blocked(uuid)` security-definer fonksiyonu ve `private.remove_follows_on_block()` trigger'ı var; `private` schema API'ye açılmamalı.
- `profiles` görünürlüğü block kontrolüyle sınırlandırıldı; profil alanları arasında hassas değerler eklenirse yeni politikaya ihtiyaç var.

## Mevcut tasarım/backend boşlukları (bloklayıcıları gizleme)
1. Private `places` desteklendi ama `visits`, `wishlist_items`, `trip_stops` RLS ve place erişimi farklı olabilir. Özellikle wishlist/trip_stops `is_published=true` koşulunu kullanıyor: **özel mekanı plana/wishlist'e ekleyebilmek için güvenli ve onaylı migration gerekir**.
2. `trips` şeması ortak gezi üyeliği/davet, rezervasyon, harcama alanlarını içermiyor; Stitch'teki bu öğeler mevcut özellik olarak gösterilemez.
3. `posts` sadece draft/published; Stitch'teki takipçilere özel paylaşım için `visibility` ve buna bağlı RLS yok. UI gösteriyorsa onaylı migration veya sadeleştirme yapılmalı.
4. `profiles` için tüm `authenticated` kullanıcılarına `SELECT` grant'i mevcut; block kuralı var; hassas veri barındırma. `avatar_url` private olmamalı.
5. `notifications` tabloda okunabilir fakat bildirim üreten otomatik güvenli trigger'lar tamamlanmadı.
6. Sosyal photo policy `posts` okumasına ve block kontrolüne bağımlı; eski imzalı linkler süresi bitene kadar açık kalabilir. Storage policy'lerini gerçek iki ayrı token ile doğrula.
7. `updated_at` alanlarını güncelleyen genel trigger doğrulanmadı; yazma davranışını test et.
8. Harita araması için `PostGIS` henüz etkinleştirildiği doğrulanmadı; basit lat/lon kullanılabilir, yakınlık sorgusu gerekiyorsa migration planla.
9. Database seed: `categories` 8 kayıt oluşturuldu, `places` kataloğunun boş olması beklenebilir. Map tile/geocoding/place index servisleri ayrı sağlayıcı gerektirir.

## Veri sözleşmesi
- Auth ID tek kaynak `auth.uid()`; UI gönderdiği `user_id` manipüle edilse dahi RLS güvence altında olmalı.
- Ziyaret oluştur -> id al -> fotoğrafı storage path'e yükle -> `visit_photos` metadata oluştur. Hata olursa orphan dosya için telafi ve cleanup.
- Post oluştur -> id al -> görsel upload -> metadata -> kullanıcı açıkça yayınlar.
- Medya silme: Storage dosyasını ayrıca kaldır; cascade veritabanı satırı Storage objesini otomatik silmez.
- Kağıt üstü `No errors detected` doğrulaması yetmez; uygulama istemcisiyle negatif izin testleri yaz.

## Şema yönetimi
- Önce Supabase CLI link (gerekli yetkiyle), schema diff/dump, migration geçmişini kontrol. Panelde daha önce SQL Editor ile yapılan adımları **yeni migration dosyasına körlemesine tekrar yazma**.
- Mevcut şemayı `supabase/migrations` altında başlangıç snapshot/baseline biçiminde belgele; kullanıcı onayı olmadan üretim üzerinde çalıştırma.
- Her önerilen migration için neyi değiştirir, geriye uyumluluğu, RLS/grant etkisi, geri alma ve test planı yaz.
