-- HOCHEBENE – Supabase Schema Setup
-- Run this in the Supabase SQL Editor:
-- https://supabase.com/dashboard/project/olbjelxyeabslimuwsxg/sql/new

-- ── TABLES ────────────────────────────────────────────────────

create table if not exists boards (
  id       text primary key,
  name     text not null,
  position integer not null default 0
);

create table if not exists team_members (
  id       text primary key,
  board_id text not null references boards(id) on delete cascade,
  name     text not null,
  color    text not null default '#ff6b2b'
);

create table if not exists modules (
  id        text primary key,
  board_id  text not null references boards(id) on delete cascade,
  parent_id text references modules(id) on delete cascade,
  name      text not null,
  color     text not null default '#ff6b2b',
  owner     text not null default '',
  position  integer not null default 0
);

create table if not exists columns (
  id        text primary key,
  board_id  text not null references boards(id) on delete cascade,
  module_id text not null references modules(id) on delete cascade,
  name      text not null,
  color     text not null default '#6b6b88',
  position  integer not null default 0
);

create table if not exists cards (
  id          text primary key,
  board_id    text not null references boards(id) on delete cascade,
  column_id   text not null references columns(id) on delete cascade,
  module_id   text not null references modules(id) on delete cascade,
  title       text not null,
  note        text not null default '',
  owner       text not null default '',
  due_date    text,
  priority    text not null default 'mid',
  position    integer not null default 0,
  check_items jsonb not null default '[]'
);

-- ── INDEXES ───────────────────────────────────────────────────

create index if not exists idx_team_members_board on team_members(board_id);
create index if not exists idx_modules_board      on modules(board_id);
create index if not exists idx_columns_board      on columns(board_id);
create index if not exists idx_columns_module     on columns(module_id);
create index if not exists idx_cards_board        on cards(board_id);
create index if not exists idx_cards_column       on cards(column_id);
create index if not exists idx_cards_module       on cards(module_id);

-- ── ROW LEVEL SECURITY ────────────────────────────────────────
-- The app uses the anon key, so we need permissive policies.
-- If you want auth-based access control, remove these and add proper policies.

alter table boards       enable row level security;
alter table team_members enable row level security;
alter table modules      enable row level security;
alter table columns      enable row level security;
alter table cards        enable row level security;

-- Allow full access for anonymous (anon) role
create policy "anon_all_boards"       on boards       for all to anon using (true) with check (true);
create policy "anon_all_team_members" on team_members for all to anon using (true) with check (true);
create policy "anon_all_modules"      on modules      for all to anon using (true) with check (true);
create policy "anon_all_columns"      on columns      for all to anon using (true) with check (true);
create policy "anon_all_cards"        on cards        for all to anon using (true) with check (true);

-- ── REALTIME ──────────────────────────────────────────────────
-- Enable realtime for all tables (do this in Supabase Dashboard → Database → Replication
-- OR run the statements below)

alter publication supabase_realtime add table boards;
alter publication supabase_realtime add table team_members;
alter publication supabase_realtime add table modules;
alter publication supabase_realtime add table columns;
alter publication supabase_realtime add table cards;
