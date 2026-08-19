-- Sprachheld — ranking online opcional (ver docs/decisions/0001-supabase-leaderboard.md).
-- Aplicar una vez en el proyecto Supabase (SQL Editor → pegar y Run).
--
-- Modelo: una sola tabla de puntajes. Sin datos personales — "name" es un
-- alias libre y opcional. RLS es la barrera real: anon puede insertar su
-- puntaje y leer el ranking, nada más.

create table if not exists public.scores (
  id               bigint generated always as identity primary key,
  name             text,                       -- alias opcional, sin login
  mode             text not null,              -- 'arcade' | 'verbs' | 'gender' | 'prepositions' | ...
  correct          int  not null default 0,
  total            int  not null default 0,
  best_combo       int,                        -- solo el arcade lo usa
  score            int,                        -- puntos del arcade
  duration_seconds int,
  created_at       timestamptz not null default now(),

  constraint scores_name_len     check (name is null or char_length(name) <= 24),
  constraint scores_mode_len     check (char_length(mode) between 1 and 32),
  constraint scores_counts_valid check (correct >= 0 and total >= 0 and correct <= total),
  constraint scores_score_valid  check (score is null or score >= 0)
);

-- Consultas típicas del leaderboard: por modo, ordenado por puntaje/combo/fecha.
create index if not exists scores_mode_score_idx
  on public.scores (mode, score desc nulls last, created_at desc);

alter table public.scores enable row level security;

-- anon (la clave pública de la app) puede LEER el ranking...
drop policy if exists "scores_select_anon" on public.scores;
create policy "scores_select_anon"
  on public.scores for select
  to anon
  using (true);

-- ...y SUBIR su propio puntaje. Nada más: sin update ni delete.
drop policy if exists "scores_insert_anon" on public.scores;
create policy "scores_insert_anon"
  on public.scores for insert
  to anon
  with check (true);
