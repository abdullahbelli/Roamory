-- =============================================================================
-- Roamory — T16 Güvenli Bildirim Üretimi (Notifications Triggers & RLS) Önerisi
-- Dosya: supabase/migrations/20260412000002_notifications_triggers_proposal.sql
-- Durum: KULLANICI ONAYI BEKLİYOR (Canlı veritabanında otomatik çalıştırılmadı)
-- =============================================================================
--
-- AMAÇ:
-- 1. İstemciden sahte bildirim INSERT edilmesini tamamen engellemek (`notifications`
--    üzerinde istemci yalnızca kendi bildirimlerini `SELECT` ve `is_read` olarak
--    `UPDATE` edebilir).
-- 2. Canlı `public.notifications` şemasıyla (`id, user_id, actor_id, type, title,
--    body, post_id, is_read, created_at`) %100 uyumlu biçimde:
--    - Takip (`public.follows` INSERT -> `type = 'follow'`, `actor_id`)
--    - Beğeni (`public.post_likes` INSERT -> `type = 'like'`, `actor_id`, `post_id`)
--    - Yorum (`public.comments` INSERT -> `type = 'comment'`, `actor_id`, `post_id`)
--    bildirimlerini `SECURITY DEFINER` + `set search_path = public` ile üretmek.
-- 3. Kendi kendine yapılan işlemlerde ve `public.user_blocks` ile engellenmiş
--    kullanıcı çiftlerinde bildirim üretmemek.
-- 4. Tekrarlanan takip/beğeni işlemlerinde okunmamış mükerrer bildirim spam'ini
--    önlemek (`is_read = false` kontrolü).
-- =============================================================================

begin;

create schema if not exists private;

-- İstemcinin doğrudan `notifications` tablosuna INSERT atmasını engelle.
revoke insert, delete on table public.notifications from anon, authenticated;
grant select, update on table public.notifications to authenticated;

alter table public.notifications enable row level security;

drop policy if exists "Read own notifications" on public.notifications;
create policy "Read own notifications"
on public.notifications
for select
to authenticated
using (user_id = (select auth.uid()));

drop policy if exists "Mark own notifications read" on public.notifications;
create policy "Mark own notifications read"
on public.notifications
for update
to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));

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
