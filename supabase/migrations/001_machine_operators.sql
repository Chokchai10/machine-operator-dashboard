create table if not exists public.machine_operators (
  id bigint primary key, name text not null, phone text not null, company text not null,
  area text not null check (area in ('F2', '3 E0 Stone Yard 3')),
  type text not null check (type in ('Bulldozer', 'Excavator', 'Grader', 'Roller')),
  code text not null unique, job text default '',
  status text not null default 'working' check (status in ('working','break','waiting','broken','finished','ot')),
  image text default '', start_time text default '07:00', end_time text default '17:00',
  ot_start text default '', ot_end text default '', note text default '',
  updated_at timestamptz not null default now()
);
alter table public.machine_operators enable row level security;
create policy "public read operators" on public.machine_operators for select using (true);
create policy "public insert operators" on public.machine_operators for insert with check (true);
create policy "public update operators" on public.machine_operators for update using (true) with check (true);
insert into storage.buckets (id, name, public) values ('operator-images', 'operator-images', true)
on conflict (id) do update set public = true;
create policy "public view operator images" on storage.objects for select using (bucket_id = 'operator-images');
create policy "public upload operator images" on storage.objects for insert with check (bucket_id = 'operator-images');
create policy "public update operator images" on storage.objects for update using (bucket_id = 'operator-images');
do $$ begin alter publication supabase_realtime add table public.machine_operators;
exception when duplicate_object then null; end $$;
