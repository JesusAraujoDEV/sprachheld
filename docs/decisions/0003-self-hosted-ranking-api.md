# 0003 — Reemplazar Supabase por una API propia sobre Postgres ya existente

- **Status**: Accepted
- **Date**: 2026-11-02
- **Owner role**: system-architect (con lente data-architect y security-compliance)
- **Affects**: `lib/services/score_service.dart`, `lib/main.dart`, `pubspec.yaml`, nuevo `server/`, elimina `supabase/`
- **Supersedes**: [0001-supabase-leaderboard.md](0001-supabase-leaderboard.md)

## Context

El ranking online (ADR 0001) corría sobre Supabase. El usuario decidió reemplazarlo por
infraestructura propia: reutilizar un Postgres compartido ya desplegado en su Dokploy
(`jesulovesdatabases`, instancia "DatajesusBase") en vez de depender de un proveedor externo.
Esto no reabre el riesgo que motivó el ADR 0001 (conectar el cliente Flutter directo a la
base con la contraseña embebida) — la solución sigue siendo cliente → API → base, solo que la
API ahora es propia en vez de ser la de Supabase.

## Decision

Desplegar un servicio HTTP mínimo (`server/`, Node puro sin framework — dos endpoints no
justifican Express) en el mismo Dokploy, dentro del proyecto `sprachheld`, hablando con un
**schema propio** (`sprachheld`) en la base compartida, a través de un **usuario de Postgres
acotado** (`sprachheld_api`) con permisos únicos de `SELECT` + `INSERT` sobre
`sprachheld.scores` — sin `UPDATE`, sin `DELETE`, sin acceso a ningún otro schema de esa base
compartida (verificado: intentar leer `mundial.*` o hacer DDL falla con permission denied).

El contrato HTTP y el modelo de datos son el mismo que ya existía con Supabase, solo cambia el
transporte:
- `POST /scores` — inserta un puntaje (mismos campos: `name?`, `mode`, `correct`, `total`,
  `best_combo?`, `score?`, `duration_seconds?`). Mismas validaciones que antes vivían en el
  `CHECK` de la tabla y en RLS, ahora en el endpoint + la tabla.
- `GET /scores?mode=X&limit=N` — top N de ese modo, igual orden (`score desc nulls last,
  created_at desc`).
- CORS restringido al único origen real (`https://sprachheld.jesusaraujo.lat`).

No se agrega sistema de identidad (secreto por dispositivo, tokens, etc.). El ADR 0001 ya
aceptó conscientemente el riesgo de "cualquiera puede insertar con cualquier nombre" — este
ADR no lo reabre ni lo endurece, solo cambia dónde corre.

## Considered alternatives

- **Mantener Supabase** — rechazada: el usuario quiere dejar de depender de un proveedor
  externo cuando ya paga y opera su propia infraestructura.
- **Cliente Flutter → Postgres directo** — la misma opción que el ADR 0001 ya rechazó
  (credencial embebida en el APK/build web, acceso total a la base compartida). Sigue
  rechazada por el mismo motivo.
- **Identidad por secreto de dispositivo + anti-abuso con rate limiting** (explorado primero
  con system-architect/data-architect antes de notar el ADR 0001 existente) — descartada para
  esta v1: es más de lo que el usuario pidió y más de lo que el diseño original necesitaba;
  el riesgo de spam ya estaba aceptado como conocido en el ADR 0001, no es un requisito nuevo.

## Consequences

- **Positive**: sin dependencia de un proveedor externo; el usuario controla y opera toda la
  pila; mismo contrato HTTP, cero cambios en las 4 pantallas que ya consumen `ScoreService`.
- **Negative**: ahora hay un servicio propio que mantener (deploys, logs, caídas) — antes
  Supabase se encargaba de eso; la base compartida tiene un vector de ataque más (aunque
  acotado a un schema y sin DDL/UPDATE/DELETE para el rol de la API).
- **Neutral**: sigue siendo best-effort/offline-first — si el servicio no responde, la app
  funciona igual, el ranking queda vacío o el envío falla en silencio para el usuario (mismo
  comportamiento que con Supabase).

## Migration notes

- `pubspec.yaml`: quitar `supabase_flutter`, agregar `http`.
- `lib/main.dart`: quitar la inicialización de Supabase.
- `lib/services/score_service.dart`: reemplazar las llamadas a `supabase_flutter` por `http`
  contra `https://sprachheld-api.jesusaraujo.lat`, mismo contrato público (`submit`/`top`).
- Eliminar `supabase/migrations/0001_scores.sql` — ya no aplica, la migración equivalente
  corrió directo en Postgres (schema `sprachheld`, tabla `scores`, mismos `CHECK`).
- `AGENTS.md`: la línea de "Locked decisions: no backend" ya no es cierta — se actualiza para
  reflejar este ADR en vez de contradecirlo.
- `docs/decisions/0001-supabase-leaderboard.md`: status → `Superseded by 0003`.

## Open coordination points

- **security-compliance**: mismo punto que dejó abierto el ADR 0001 — no hay rate limiting ni
  anti-spam real, es un riesgo conocido y aceptado, no una omisión. Si aparece abuso real,
  ahí sí se justifica una vuelta con QA/security para endurecerlo (no antes).
