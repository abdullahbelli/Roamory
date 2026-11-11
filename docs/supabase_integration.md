# Roamory — Supabase Flutter Entegrasyonu

1. Supabase URL ve `sb_publishable_...` key'i `--dart-define` ile geçir. `supabase_flutter` sürüm API'sini kontrol et; `Supabase.initialize(url: ..., publishableKey: ...)` mevcut sürümde doğrula.
2. URL placeholder'u `project.md` veya public kod dosyasına gizli bilgi gibi kopyalama; gerçek URL Antigravity'ye yerel ortamdan verilir. `sb_secret` ve service_role hiçbir istemci dosyasında bulunmaz.
3. Google OAuth web client Supabase tarafında etkin; mobil deep link `io.roamory.app://login-callback/`, Android/iOS manifest ve provider callback kontrol edilmeli. Native Google SDK yöntemi seçilecekse platform-specific client IDs ayrıca incelenir.
4. E-posta signup/reset akışında default SMTP sınırlaması var. UI gerçek başarısızlığı kullanıcıya doğru gösterir.
5. Auth SDK session değişimleri tek kaynaktan; HTTP ve Storage istekleri kullanıcının access token'ıyla çalışır; kendi SQL/RLS bypass yok.
6. Supabase Storage bucket path sözleşmeleri `database.md`'de. Yükleme önce DB ID, sonra Storage object, ardından metadata. Hata halinde dosya cleanup.
7. Supabase `auth.users` otomatik `profiles` trigger'ı mevcut; redundant profile insert'lerini race-safe tasarla.
8. İçerik gizliliği RLS + istemci UI olarak çift katmanlı; private not hiçbir zaman `posts` içine otomatik kopyalanmaz.
9. Değişken isimleri örnek:
```text
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```
10. Kullanıcıdan secret paylaşmasını isteme; gerçekten gerekli değerleri kendi yerel terminali/konfigürasyonu üzerinden ayarlamasını anlat.
