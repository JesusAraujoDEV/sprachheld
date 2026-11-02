# 2026-11-02 — Reemplazar Supabase por una API de ranking propia

## What changed

El ranking online de Sprachheld dejó de depender de Supabase y pasó a corer sobre un
servicio HTTP propio (`server/`, Node puro, sin framework) desplegado en el Dokploy del
usuario, usando un schema (`sprachheld`) dentro de un Postgres compartido ya existente
(`jesulovesdatabases`) con un rol de DB acotado (`sprachheld_api`, solo INSERT+SELECT sobre
su propia tabla). El contrato HTTP y el modelo de datos (`scores`: name/mode/correct/total/
best_combo/score/duration_seconds) son idénticos a los que ya usaban las 4 pantallas con
ranking — `score_service.dart` cambió de transporte (Supabase client → `http`), no de forma.

## Why

El usuario (dueño único del proyecto) pidió explícitamente dejar de depender de un proveedor
externo y usar su propia infraestructura. Esto revierte la decisión "no backend" que
`AGENTS.md` tenía marcada como bloqueada ("no re-discuss") — se confirmó la reversión con el
usuario antes de tocar nada, documentada en ADR 0003 (que supersede el ADR 0001 de
Supabase).

## How

- Se descubrió, vía la API de Dokploy, que ya existía un Postgres compartido
  (`jesulovesdatabases`, appName `jess-araujo-datajesusbase-kiffr1`) usado por otros
  proyectos del usuario, cada uno en su propio schema.
- Se creó el schema `sprachheld` + rol `sprachheld_api` con permisos mínimos, verificados
  (no puede leer otros schemas, no puede hacer DDL ni DELETE).
- Intento inicial de diseño (con subagentes system-architect/data-architect, antes de notar
  el ADR 0001 existente) propuso identidad por secreto de dispositivo y anti-spam — se
  descartó al confirmar que el diseño real ya aceptaba conscientemente "insert anónimo sin
  rate limiting" (mismo riesgo que RLS+anon ya aceptaba en Supabase). Se replicó el esquema
  original (`scores`) en vez del esquema sobre-diseñado.
- Servicio Node (`server/index.js`, 2 endpoints: `POST/GET /scores`) desplegado como app
  nueva en Dokploy, conectado a la DB por **red interna de Docker** (nombre de contenedor,
  puerto 5432) — la primera versión usaba el dominio público + puerto externo y se colgaba
  (timeout), corregido al pasar a hostname interno.
- `lib/services/score_service.dart` reescrito contra `http`; `lib/main.dart` perdió la
  inicialización de Supabase; `pubspec.yaml` cambió `supabase_flutter` por `http`;
  `supabase/migrations/0001_scores.sql` y `lib/config/supabase_config.dart` eliminados.
- Verificado end-to-end en producción (insert + read reales contra el dominio público,
  limpiados después) antes de cerrar. `flutter analyze` sin issues, `flutter test` 48/48.

## Promoted knowledge

- `AGENTS.md`: la línea de "Locked decisions" ya no incluye "no backend" y ahora permite
  `http` como dependencia — actualizado en el mismo cambio (regla viva, no solo narrativa).
- `docs/decisions/0003-self-hosted-ranking-api.md`: la decisión en sí, con alternativas
  consideradas y consecuencias — es la fuente de verdad sobre el *por qué*, esta entrada de
  work es solo la crónica de *cómo* se ejecutó.

## Follow-ups

- [ ] Sin rate limiting ni identidad de jugador — riesgo conocido y aceptado (igual que en
      el diseño original con Supabase), no una omisión. Revisar con QA/security-compliance
      solo si aparece abuso real en el ranking, no antes.
- [ ] El servicio nuevo no tiene healthcheck configurado en Dokploy (`healthCheckSwarm` null)
      ni alertas si se cae — hoy el fallback es el comportamiento best-effort de la app
      (ranking vacío, sin romper el juego), pero no hay aviso proactivo si el servicio muere.
