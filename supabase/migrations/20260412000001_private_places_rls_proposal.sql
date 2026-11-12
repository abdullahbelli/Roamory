-- =============================================================================
-- Roamory — T11/T12/T13/T14 Özel Mekan (Private Places) Tablo Yetkisi (GRANT) ve RLS Kaydı
-- Dosya: supabase/migrations/20260412000001_private_places_rls_proposal.sql
-- Durum: KULLANICI TARAFINDAN CANLI SUPABASE'DE MANUEL UYGULANDI
--        (Bu dosyayı canlı veritabanında otomatik/tekrar çalıştırma.)
-- =============================================================================
--
-- CANLI SUPABASE MANUEL UYGULAMA ÖZETİ:
-- 1. `authenticated` rolüne `public.places` tablosu üzerinde `INSERT` yetkisi
--    verildi (`places` özel mekan oluşturma C05 akışı emülatörde doğrulandı).
-- 2. `public.wishlist_items` tablosundaki `"Add to own wishlist"` ve
--    `"Update own wishlist"` RLS politikaları, kullanıcının kendi oluşturduğu
--    özel mekanları (`p.is_published = true or p.created_by = auth.uid()`) da
--    istek listesine ekleyip güncelleyebilmesi için güncellendi.
-- 3. `public.trip_stops` tablosundaki `"Manage own trip stops"` RLS politikası,
--    seyahat sahipliğini (`trip_days` -> `trips.user_id = auth.uid()`) koruyup
--    kullanıcının kendi özel mekanını (`p.is_published = true or p.created_by = auth.uid()`)
--    durak olarak ekleyebilmesine izin verecek şekilde güncellendi.
-- =============================================================================
--
-- CANLI EMÜLATÖR KÖK NEDEN TESPİTİ (C05 Gezi Günlüğü Kaydet Hatası):
-- Canlı Supabase projesinde `AddVisitAndJournalScreen` (C05) üzerinden yeni bir
-- gezi günlüğü ve özel mekan kaydedilirken ilk istek olan:
--   `POST /rest/v1/places?select=id`
-- şu yanıtla reddedilmiştir:
--   - HTTP Durumu      : 403 Forbidden
--   - PostgREST Kodu   : 42501 (insufficient_privilege)
--   - Hata Mesajı      : "permission denied for table places"
--   - PostgREST İpucu  : "Grant the required privileges to the current role with:
--                         GRANT INSERT ON public.places TO authenticated;"
--   - İlgili Tablo     : public.places
--
-- NEDEN OLUŞTU?
-- PostgreSQL'de RLS (Row Level Security) politikaları değerlendirilmeden ÖNCE
-- tablo düzeyindeki `GRANT` yetkileri kontrol edilir. Canlı veritabanında diğer
-- tüm kullanıcı tablolarında (`visits`, `visit_categories`, `visit_photos`,
-- `wishlist_items`, `trips`, `posts` vb.) `authenticated` rolüne
-- `GRANT SELECT, INSERT, UPDATE, DELETE` verilmişken, `public.places` tablosu
-- başlangıçta salt-okunur katalog olarak tasarlandığından yalnızca
-- `GRANT SELECT ON public.places TO anon, authenticated;` yetkisine sahiptir.
--
-- GÜVENLİ ÇÖZÜM:
-- 1. `public.places` tablosunda `authenticated` rolüne `INSERT, UPDATE, DELETE`
--    tablo yetkisi (`GRANT`) verilir (`anon` rolü yalnızca `SELECT` kalır).
-- 2. RLS politikaları gevşetilmeden, kullanıcının yalnızca KENDİ oluşturduğu
--    ve yayınlanmamış (`is_published = false AND created_by = auth.uid()`)
--    özel mekanları ekleyebilmesi, güncelleyebilmesi ve silebilmesi zorunlu tutulur.
--    Yayınlanmış katalog mekanları (`is_published = true`) istemci tarafından
--    değiştirilemez ve silinemez.
-- 3. `visits`, `wishlist_items` ve `trip_stops` tablolarındaki `INSERT` RLS
--    kontrollerinin hem genel katalog mekanlarını (`p.is_published = true`) hem de
--    kullanıcının kendi özel mekanlarını (`p.created_by = auth.uid()`) kabul
--    ettiği garanti altına alınır.
-- =============================================================================

begin;

-- 1. Tablo düzeyinde (PostgreSQL Privilege) authenticated rolüne yazma izni verilmesi
-- Not: Gerçek güvenlik sınırı aşağıdaki RLS politikaları ile satır bazında korunur.
grant select, insert, update, delete on table public.places to authenticated;

-- 2. public.places üzerinde RLS'nin aktif olduğundan emin olunması
alter table public.places enable row level security;

-- 3. public.places SELECT politikası:
-- Herkes yayınlanmış katalog mekanlarını görebilir; giriş yapmış kullanıcı kendi
-- özel mekanlarını (`created_by = auth.uid()`) da görebilir.
drop policy if exists "places_select_published_or_own" on public.places;
create policy "places_select_published_or_own"
on public.places
for select
to anon, authenticated
using (
  is_published = true
  or created_by = (select auth.uid())
);

-- 4. public.places INSERT politikası:
-- Giriş yapmış kullanıcı yalnızca `is_published = false` ve `created_by = auth.uid()`
-- olan özel mekan kaydı oluşturabilir (genel kataloğa doğrudan yayın yapamaz).
drop policy if exists "places_insert_own_private" on public.places;
create policy "places_insert_own_private"
on public.places
for insert
to authenticated
with check (
  is_published = false
  and created_by = (select auth.uid())
);

-- 5. public.places UPDATE politikası:
-- Kullanıcı yalnızca kendi oluşturduğu özel mekanı güncelleyebilir ve
-- `is_published = false` durumunu değiştiremez.
drop policy if exists "places_update_own_private" on public.places;
create policy "places_update_own_private"
on public.places
for update
to authenticated
using (
  is_published = false
  and created_by = (select auth.uid())
)
with check (
  is_published = false
  and created_by = (select auth.uid())
);

-- 6. public.places DELETE politikası:
-- Kullanıcı yalnızca kendi oluşturduğu özel mekanı silebilir.
drop policy if exists "places_delete_own_private" on public.places;
create policy "places_delete_own_private"
on public.places
for delete
to authenticated
using (
  is_published = false
  and created_by = (select auth.uid())
);

-- 7. public.visits INSERT politikasının özel mekan sahibini kapsadığının doğrulanması
drop policy if exists "visits_insert_own" on public.visits;
create policy "visits_insert_own"
on public.visits
for insert
to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1
    from public.places p
    where p.id = visits.place_id
      and (
        p.is_published = true
        or p.created_by = (select auth.uid())
      )
  )
);

-- 8. public.wishlist_items politikalarının ("Add to own wishlist" & "Update own wishlist")
--    özel mekan sahibini kapsayacak şekilde güncellenmesi (canlı DB'de manuel uygulandı)
drop policy if exists "Add to own wishlist" on public.wishlist_items;
create policy "Add to own wishlist"
on public.wishlist_items
for insert
to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1
    from public.places p
    where p.id = wishlist_items.place_id
      and (
        p.is_published = true
        or p.created_by = (select auth.uid())
      )
  )
);

drop policy if exists "Update own wishlist" on public.wishlist_items;
create policy "Update own wishlist"
on public.wishlist_items
for update
to authenticated
using (user_id = (select auth.uid()))
with check (
  user_id = (select auth.uid())
  and exists (
    select 1
    from public.places p
    where p.id = wishlist_items.place_id
      and (
        p.is_published = true
        or p.created_by = (select auth.uid())
      )
  )
);

-- 9. public.trip_stops politikasının ("Manage own trip stops")
--    seyahat sahipliğini koruyup özel mekan sahibini kapsayacak şekilde güncellenmesi
--    (canlı DB'de manuel uygulandı)
drop policy if exists "Manage own trip stops" on public.trip_stops;
create policy "Manage own trip stops"
on public.trip_stops
for all
to authenticated
using (
  exists (
    select 1
    from public.trip_days td
    join public.trips t on t.id = td.trip_id
    where td.id = trip_stops.trip_day_id
      and t.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.trip_days td
    join public.trips t on t.id = td.trip_id
    where td.id = trip_stops.trip_day_id
      and t.user_id = (select auth.uid())
  )
  and exists (
    select 1
    from public.places p
    where p.id = trip_stops.place_id
      and (
        p.is_published = true
        or p.created_by = (select auth.uid())
      )
  )
);

commit;
