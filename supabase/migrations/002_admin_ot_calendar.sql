alter table public.machine_operators add column if not exists ot_slots jsonb not null default '[]'::jsonb;
alter table public.machine_operators add column if not exists work_date date not null default current_date;
update public.machine_operators set ot_slots=jsonb_build_array(jsonb_build_object('start',ot_start,'end',ot_end)) where ot_start<>'' and ot_slots='[]'::jsonb;
drop policy if exists "public insert operators" on public.machine_operators;
drop policy if exists "public update operators" on public.machine_operators;
drop policy if exists "public delete operators" on public.machine_operators;
drop policy if exists "public upload operator images" on storage.objects;
drop policy if exists "public update operator images" on storage.objects;
create extension if not exists pgcrypto;
create or replace function public.admin_check(p_pin text) returns boolean language sql security definer set search_path=public,extensions as $$select encode(extensions.digest(p_pin,'sha256'),'hex')='a04554cfb9c4ff4d0ac8f98bd0773a42c8902094c073cfda6d2d0d5c82da748e'$$;
create or replace function public.admin_upsert_operator(p_pin text,p_operator jsonb) returns void language plpgsql security definer set search_path=public as $$begin
if encode(extensions.digest(p_pin,'sha256'),'hex')<>'a04554cfb9c4ff4d0ac8f98bd0773a42c8902094c073cfda6d2d0d5c82da748e' then raise exception 'Invalid admin PIN' using errcode='42501'; end if;
insert into public.machine_operators(id,name,phone,company,area,type,code,job,status,image,start_time,end_time,ot_start,ot_end,ot_slots,work_date,note,updated_at)
values((p_operator->>'id')::bigint,p_operator->>'name',p_operator->>'phone',p_operator->>'company',p_operator->>'area',p_operator->>'type',p_operator->>'code',coalesce(p_operator->>'job',''),p_operator->>'status',coalesce(p_operator->>'image',''),coalesce(p_operator->>'start_time','07:00'),coalesce(p_operator->>'end_time','17:00'),'','',coalesce(p_operator->'ot_slots','[]'::jsonb),coalesce((p_operator->>'work_date')::date,current_date),coalesce(p_operator->>'note',''),now())
on conflict(id) do update set name=excluded.name,phone=excluded.phone,company=excluded.company,area=excluded.area,type=excluded.type,code=excluded.code,job=excluded.job,status=excluded.status,image=excluded.image,start_time=excluded.start_time,end_time=excluded.end_time,ot_slots=excluded.ot_slots,work_date=excluded.work_date,note=excluded.note,updated_at=now(); end$$;
create or replace function public.admin_delete_operator(p_pin text,p_id bigint) returns void language plpgsql security definer set search_path=public,extensions as $$begin if encode(extensions.digest(p_pin,'sha256'),'hex')<>'a04554cfb9c4ff4d0ac8f98bd0773a42c8902094c073cfda6d2d0d5c82da748e' then raise exception 'Invalid admin PIN' using errcode='42501'; end if; delete from public.machine_operators where id=p_id; end$$;
revoke all on function public.admin_check(text) from public; revoke all on function public.admin_upsert_operator(text,jsonb) from public; revoke all on function public.admin_delete_operator(text,bigint) from public;
grant execute on function public.admin_check(text) to anon; grant execute on function public.admin_upsert_operator(text,jsonb) to anon; grant execute on function public.admin_delete_operator(text,bigint) to anon;
