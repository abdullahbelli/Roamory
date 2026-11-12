-- =============================================================================
-- Roamory — T16 Güvenli Bildirim Üretimi (Notifications Triggers & RLS) Kaydı
-- Dosya: supabase/migrations/20260412000002_notifications_triggers_proposal.sql
-- Durum: KULLANICI TARAFINDAN CANLI SUPABASE'DE UYGULANDI
--        (Bu dosyayı canlı veritabanında otomatik/tekrar çalıştırma.)
-- =============================================================================
--
-- CANLI SUPABASE SQL EDITOR UYGULAMA ÖZETİ:
-- 1. Mevcut RLS politikaları korundu:
--    - "View own notifications" (`SELECT` for owner `auth.uid()`)
--    - "Mark own notifications read" / "Mark own notifications as read"
--      (`UPDATE` for owner `auth.uid()`)
-- 2. Yetkiler (Grants):
--    - İstemciden (`anon`, `authenticated`) `notifications` tablosuna `INSERT`
--      ve `DELETE` yetkileri kaldırıldı (`REVOKE INSERT, DELETE`).
--    - `authenticated` rolüne yalnızca `SELECT` ve kolon düzeyinde
--      `UPDATE (is_read)` izni verildi.
-- 3. Trigger Mimarisi:
--    - Ortak `SECURITY DEFINER` fonksiyonu `private.create_social_notification`
--      oluşturuldu.
--    - `public.follows`, `public.post_likes` ve `public.comments` tablolarına
--      `AFTER INSERT` trigger'ları bağlandı; kendi kendine yapılan işlemlerde
--      ve `public.user_blocks` engellerinde bildirim üretilmez.
-- 4. Flutter İstemci Uyumu (`NotificationsScreen` & `ProfileSettingsRepository`):
--    - `markNotificationRead` ve `markAllNotificationsRead` yalnızca
--      `{'is_read': true}` güncellemesi yapar; başka hiçbir kolon değiştirilmez.
-- =============================================================================
--
-- Not: Aşağıdaki SQL bloğu başlangıçta öneri taslağı olarak yazılmış olup canlı
-- veritabanında `private.create_social_notification` ortak fonksiyonu ve
-- mevcut `"View own notifications"` / `"Mark own notifications as read"`
-- politikaları korunarak eşdeğer biçimde uygulanmıştır; tekrar çalıştırmayın.

begin;

create schema if not exists private;

-- İstemcinin doğrudan `notifications` tablosuna INSERT/DELETE veya `is_read` dışı UPDATE atmasını engelle.
revoke insert, delete, update on table public.notifications from anon, authenticated;
grant select, update (is_read) on table public.notifications to authenticated;

alter table public.notifications enable row level security;

-- Canlı veritabanında mevcut olan "View own notifications" ve
-- "Mark own notifications as read" RLS politikaları korunur (tekrar drop edilmez).
--
-- Referans taslak fonksiyonlar (Canlı veritabanında bunların yerine ortak
-- `private.create_social_notification()` fonksiyonu ve `follows`,
-- `post_likes`, `comments` `AFTER INSERT` trigger'ları uygulanmıştır;
-- aşağıdaki taslağı canlı DB'de tekrar çalıştırmayın.):

-- 1) Yeni takipçi bildirimi (`public.follows`)
create or replace function private.notify_on_follow()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_name text;
begin
  if new.follower_id = new.following_id then
    return new;
  end if;

  if exists (
    select 1
    from public.user_blocks b
    where (b.blocker_id = new.following_id and b.blocked_id = new.follower_id)
       or (b.blocker_id = new.follower_id and b.blocked_id = new.following_id)
  ) then
    return new;
  end if;

  -- Aynı kullanıcıya ait okunmamış aynı takip bildirimi zaten varsa tekrar spam üretme.
  if exists (
    select 1
    from public.notifications n
    where n.user_id = new.following_id
      and n.actor_id = new.follower_id
      and n.type = 'follow'
      and n.is_read = false
  ) then
    return new;
  end if;

  select coalesce(nullif(trim(p.full_name), ''), '@' || nullif(trim(p.username), ''), 'Bir gezgin')
    into v_actor_name
  from public.profiles p
  where p.id = new.follower_id;

  insert into public.notifications (user_id, actor_id, type, title, body, post_id, is_read)
  values (
    new.following_id,
    new.follower_id,
    'follow',
    'Yeni Takipçi',
    coalesce(v_actor_name, 'Bir gezgin') || ' seni takip etmeye başladı.',
    null,
    false
  );

  return new;
end;
$$;

drop trigger if exists trg_notify_on_follow on public.follows;
create trigger trg_notify_on_follow
after insert on public.follows
for each row execute function private.notify_on_follow();

-- 2) Gönderi beğenisi bildirimi (`public.post_likes`)
create or replace function private.notify_on_post_like()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_post_owner uuid;
  v_post_status text;
  v_actor_name text;
begin
  select p.user_id, p.status
    into v_post_owner, v_post_status
  from public.posts p
  where p.id = new.post_id;

  if v_post_owner is null or v_post_owner = new.user_id then
    return new;
  end if;

  if v_post_status is distinct from 'published' then
    return new;
  end if;

  if exists (
    select 1
    from public.user_blocks b
    where (b.blocker_id = v_post_owner and b.blocked_id = new.user_id)
       or (b.blocker_id = new.user_id and b.blocked_id = v_post_owner)
  ) then
    return new;
  end if;

  -- Aynı gönderi için okunmamış beğeni bildirimi zaten varsa tekrar ekleme.
  if exists (
    select 1
    from public.notifications n
    where n.user_id = v_post_owner
      and n.actor_id = new.user_id
      and n.post_id = new.post_id
      and n.type = 'like'
      and n.is_read = false
  ) then
    return new;
  end if;

  select coalesce(nullif(trim(pr.full_name), ''), '@' || nullif(trim(pr.username), ''), 'Bir gezgin')
    into v_actor_name
  from public.profiles pr
  where pr.id = new.user_id;

  insert into public.notifications (user_id, actor_id, type, title, body, post_id, is_read)
  values (
    v_post_owner,
    new.user_id,
    'like',
    'Yeni Beğeni',
    coalesce(v_actor_name, 'Bir gezgin') || ' gönderini beğendi.',
    new.post_id,
    false
  );

  return new;
end;
$$;

drop trigger if exists trg_notify_on_post_like on public.post_likes;
create trigger trg_notify_on_post_like
after insert on public.post_likes
for each row execute function private.notify_on_post_like();

-- 3) Gönderi yorumu bildirimi (`public.comments`)
create or replace function private.notify_on_comment()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_post_owner uuid;
  v_post_status text;
  v_actor_name text;
  v_snippet text;
begin
  select p.user_id, p.status
    into v_post_owner, v_post_status
  from public.posts p
  where p.id = new.post_id;

  if v_post_owner is null or v_post_owner = new.user_id then
    return new;
  end if;

  if v_post_status is distinct from 'published' then
    return new;
  end if;

  if exists (
    select 1
    from public.user_blocks b
    where (b.blocker_id = v_post_owner and b.blocked_id = new.user_id)
       or (b.blocker_id = new.user_id and b.blocked_id = v_post_owner)
  ) then
    return new;
  end if;

  select coalesce(nullif(trim(pr.full_name), ''), '@' || nullif(trim(pr.username), ''), 'Bir gezgin')
    into v_actor_name
  from public.profiles pr
  where pr.id = new.user_id;

  v_snippet := left(coalesce(nullif(trim(new.content), ''), 'Yeni bir yorum yaptı.'), 80);

  insert into public.notifications (user_id, actor_id, type, title, body, post_id, is_read)
  values (
    v_post_owner,
    new.user_id,
    'comment',
    'Yeni Yorum',
    coalesce(v_actor_name, 'Bir gezgin') || ': ' || v_snippet,
    new.post_id,
    false
  );

  return new;
end;
$$;

drop trigger if exists trg_notify_on_comment on public.comments;
create trigger trg_notify_on_comment
after insert on public.comments
for each row execute function private.notify_on_comment();

commit;
