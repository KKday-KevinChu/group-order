-- ① sessions 表
create table sessions (
  token        text primary key,
  name         text not null,
  created_at   timestamptz default now(),
  closed       boolean default false,
  deadline     timestamptz
);

-- ② orders 表
create table orders (
  id           uuid primary key default gen_random_uuid(),
  session_token text references sessions(token) on delete cascade,
  person       text not null,
  person_token text not null,
  drink        text not null,
  size         text,
  ice          text,
  sugar        text,
  addons       text[],
  price        int  not null,
  created_at   timestamptz default now()
);

-- ③ 開啟 Realtime
alter publication supabase_realtime add table sessions;
alter publication supabase_realtime add table orders;

-- ④ RLS — 全公開讀寫
alter table sessions enable row level security;
alter table orders   enable row level security;

create policy "public read sessions"  on sessions for select using (true);
create policy "public insert sessions" on sessions for insert with check (true);
create policy "public update sessions" on sessions for update using (true);

create policy "public read orders"   on orders for select using (true);
create policy "public insert orders" on orders for insert with check (true);
create policy "public update orders" on orders for update using (true);
create policy "public delete orders" on orders for delete using (true);
