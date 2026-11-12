-- =============================================================================
-- Roamory — T13 Seyahat Günleri (`trip_days`) & Kontrol Listesi (`trip_checklist_items`)
--            Canlı DB İnceleme + Güvenli SQL Düzeltme Önerisi
-- Dosya: supabase/migrations/20260412000003_trips_and_checklist_proposal.sql
-- Durum: KULLANICI ONAYI BEKLİYOR — OTOMATİK OLARAK CANLI VERİTABANINA UYGULANMADI
-- =============================================================================
--
-- CANLI EMÜLATÖR LOGCAT KÖK NEDENLERİ:
-- 1. `+ Gün Ekle` (`POST /rest/v1/trip_days`):
--    PostgrestException(
--      code: 42501,
--      message: "new row violates row-level security policy for table \"trip_days\""
--    )
--    Neden: Mevcut `trip_days` RLS politikası `day_date` tarihinin üst `trips`
--    kaydının `[start_date, end_date]` aralığında olmasını zorunlu tutmaktadır.
--    Uygulama tarafında `SupabaseTripsRepository.addTripDay` artık yeni gün mevcut
--    aralığın dışına taşarsa önce `trips.end_date` / `start_date` sınırını güvenli
--    biçimde genişletir ve hata durumunda geri alır.
--
-- 2. Checklist Ekleme (`POST /rest/v1/trip_checklist_items` — `category: 'general'`):
--    PostgrestException(
--      code: 23514,
--      message: "new row for relation \"trip_checklist_items\" violates check constraint \"trip_checklist_items_category_check\""
--    )
--    Neden: Canlı `trip_checklist_items` tablosundaki CHECK kısıtı `'general'`
--    kodunu kabul etmemektedir (`docs`/`gear`/`hotel` veya farklı bir şema kümesi
--    tanımlı olabilir).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ADIM 1 (SALT OKUNUR İNCELEME): Önce Supabase SQL Editor'de çalıştırıp canlı
-- politika ve CHECK tanımını kontrol edin.
-- -----------------------------------------------------------------------------
select
  tablename,
  policyname,
  cmd,
  qual,
  with_check
from pg_policies
where schemaname = 'public'
  and tablename in ('trips', 'trip_days', 'trip_checklist_items')
order by tablename, policyname;

select
  c.conname as constraint_name,
  pg_get_constraintdef(c.oid) as constraint_definition
from pg_constraint c
join pg_class t on t.oid = c.conrelid
join pg_namespace n on n.oid = t.relnamespace
where n.nspname = 'public'
  and t.relname = 'trip_checklist_items'
  and c.contype = 'c';

-- -----------------------------------------------------------------------------
-- ADIM 2 (KULLANICI ONAYLI GÜVENLİ DÜZELTME):
-- Mevcut verileri silmeden yalnızca checklist kategori kısıtını Roamory V1
-- kanonik kodlarıyla (`general`, `docs`, `gear`, `hotel`) hizalar ve
-- `trip_days` / `trip_checklist_items` sahiplik politikalarını doğrular.
-- -----------------------------------------------------------------------------
begin;

-- 1. `trip_checklist_items` kategori CHECK kısıtını uygulama ile uyumlu hale getir.
alter table public.trip_checklist_items
  drop constraint if exists trip_checklist_items_category_check;

alter table public.trip_checklist_items
  add constraint trip_checklist_items_category_check
  check (category in ('general', 'docs', 'gear', 'hotel'));

-- 2. `authenticated` rolünün `trip_days` ve `trip_checklist_items` tablo yetkileri
grant select, insert, update, delete on table public.trip_days to authenticated;
grant select, insert, update, delete on table public.trip_checklist_items to authenticated;

alter table public.trip_days enable row level security;
alter table public.trip_checklist_items enable row level security;

-- Not: Adım 1 çıktısında `trip_days` veya `trip_checklist_items` üzerinde farklı
-- isimli eski bir kısıtlayıcı politika görünüyorsa yalnızca adını doğrulayıp
-- aşağıdaki sahip bazlı politikalarla birleştirebilirsiniz:
drop policy if exists "Manage own trip checklist items" on public.trip_checklist_items;
create policy "Manage own trip checklist items"
on public.trip_checklist_items
for all
to authenticated
using (
  exists (
    select 1
    from public.trips t
    where t.id = trip_checklist_items.trip_id
      and t.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.trips t
    where t.id = trip_checklist_items.trip_id
      and t.user_id = (select auth.uid())
  )
);

-- `trip_days` için güvenli sahiplik politikası (tarih aralığı uyumu uygulama
-- tarafında da korunur; politika yalnızca seyahat sahibinin işlem yapmasına izin verir):
drop policy if exists "Manage own trip days" on public.trip_days;
create policy "Manage own trip days"
on public.trip_days
for all
to authenticated
using (
  exists (
    select 1
    from public.trips t
    where t.id = trip_days.trip_id
      and t.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.trips t
    where t.id = trip_days.trip_id
      and t.user_id = (select auth.uid())
  )
);

commit;

