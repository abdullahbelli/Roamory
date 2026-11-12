-- =============================================================================
-- Roamory — T13 Seyahat Günleri (`trip_days`) & Kontrol Listesi (`trip_checklist_items`)
--            Canlı DB İnceleme Sorgusu ve Şema Notu
-- Dosya: supabase/migrations/20260412000003_trips_and_checklist_proposal.sql
-- Durum: SALT OKUNUR İNCELEME (Mevcut `trip_checklist_items_category_check`
--        constraint'i KESİNLİKLE DEĞİŞTİRİLMEYECEK; Flutter tarafı canlı DB
--        değerleriyle hizalanacaktır.)
-- =============================================================================
--
-- CANLI EMÜLATÖR LOGCAT KÖK NEDENLERİ:
-- 1. `+ Gün Ekle` (`POST /rest/v1/trip_days`):
--    PostgrestException(
--      code: 42501,
--      message: "new row violates row-level security policy for table \"trip_days\""
--    )
--    Neden & Çözüm: Canlı `trip_days` RLS politikası `day_date` değerinin üst `trips`
--    kaydının `[start_date, end_date]` aralığında olmasını zorunlu tutmaktadır.
--    Uygulama tarafında `SupabaseTripsRepository.addTripDay` artık yeni gün mevcut
--    aralığın dışına taşarsa önce `trips.end_date` / `start_date` sınırını güvenli
--    biçimde genişletir ve insert başarısız olursa geri alır.
--
-- 2. Checklist Ekleme (`POST /rest/v1/trip_checklist_items` — önceki varsayılan `'general'`):
--    PostgrestException(
--      code: 23514,
--      message: "new row for relation \"trip_checklist_items\" violates check constraint \"trip_checklist_items_category_check\""
--    )
--    Neden & Çözüm: Canlı Supabase SQL Editor sorgusu ile `trip_checklist_items_category_check`
--    kısıtının yalnızca `documents`, `packing`, `bookings`, `other` değerlerini kabul
--    ettiği doğrulandı. Veritabanındaki CHECK constraint DEĞİŞTİRİLMEDİ; bunun yerine
--    Flutter `TripChecklistCategory` sabitleri, `SupabaseTripsRepository` ve
--    `TripChecklistScreen` UI/ARB etiketleri canlı veritabanı değerleriyle hizalandı
--    (varsayılan: `'other'`).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- SALT OKUNUR İNCELEME SORGULARI (Supabase SQL Editor):
-- Çıktıyı inceleyip `trip_checklist_items_category_check` içindeki gerçek
-- kategori değerlerini Flutter `TripChecklistCategory` ile eşleştirin.
-- -----------------------------------------------------------------------------
select
  c.conname as constraint_name,
  pg_get_constraintdef(c.oid) as constraint_definition
from pg_constraint c
join pg_class t on t.oid = c.conrelid
join pg_namespace n on n.oid = t.relnamespace
where n.nspname = 'public'
  and t.relname = 'trip_checklist_items'
  and c.contype = 'c';

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
