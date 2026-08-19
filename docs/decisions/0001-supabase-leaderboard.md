# 0001 — Añadir Supabase para un ranking online opcional

- **Status**: Accepted
- **Date**: 2026-08-19
- **Owner role**: system-architect (con lente security-compliance)
- **Affects**: `lib/services/`, `lib/main.dart`, `pubspec.yaml`, nuevo `supabase/` (migraciones)

## Context

El usuario quiere un ranking/leaderboard online opcional: al terminar un quiz puede
subir su puntaje (con un nombre elegido, sin cuenta ni login) y ver rankings de otros.
Esto choca con dos decisiones bloqueadas en `AGENTS.md` ("no backend", "no dependency
beyond shared_preferences y flutter_tts sin ADR"), y con el intento inicial del usuario de
conectar la app directo a un Postgres propio con la contraseña embebida — un agujero de
seguridad grave (cualquiera que descompile el APK obtiene acceso total a la base).

## Decision

Usar **Supabase** como backend gestionado para el ranking online, con la app conectándose
vía el paquete `supabase_flutter` usando la **clave anónima (publishable) y la URL del
proyecto** — ambas públicas por diseño —, y **Row Level Security (RLS)** como la barrera
real que protege los datos.

Modelo concreto:
- Una tabla `public.scores` (nombre opcional, modo, aciertos/total, combo, puntaje,
  duración, fecha). Sin datos personales identificables: el "nombre" es un alias libre.
- RLS: `anon` puede **INSERT** (subir su puntaje) y **SELECT** (leer el ranking); NO puede
  UPDATE ni DELETE. La clave anónima nunca puede borrar ni alterar datos ajenos.
- La integración es **best-effort y no bloqueante**: si no hay red o Supabase falla, la app
  funciona exactamente igual que hoy (offline-first, progreso local intacto). El ranking es
  una capa opcional encima, nunca un requisito para jugar.
- La clave anónima puede vivir en el repo (es pública por diseño de Supabase); lo que
  protege los datos es RLS, no el secreto de la clave. La `service_role` key (que sí es
  secreta y saltea RLS) **nunca** entra a la app ni al repo.

## Considered alternatives

- **Conexión directa Flutter → Postgres propio** — la app habla directo a la base con la
  contraseña. Rechazada: la credencial queda en el APK, acceso total a toda la base para
  cualquiera que lo descompile. Es el disparador de este ADR, no una opción real.
- **API mínima propia (Node/Express) contra el Postgres del usuario** — un servicio propio
  que guarda la credencial en el servidor. Rechazada para v1: implica montar y mantener un
  backend propio; Supabase da lo mismo (API + RLS) sin servidor que operar.
- **Mantenerlo 100% local (sin nube)** — el récord vive solo en el teléfono. Rechazada
  porque el usuario quiere ranking entre usuarios; se mantiene como fallback cuando no hay
  red.

## Consequences

- **Positive**: ranking online sin operar infraestructura; la app sigue offline-first; sin
  login (RLS + alias); clave anónima segura por diseño; el Postgres personal del usuario no
  queda expuesto.
- **Negative**: dependencia nueva (`supabase_flutter` y su árbol); acoplamiento a un
  proveedor (Supabase); superficie nueva que asegurar vía políticas RLS (si están mal, el
  dato queda expuesto — por eso el schema las define explícitas y restrictivas).
- **Neutral**: el proyecto deja de ser "sin backend" en sentido estricto, pero conserva el
  principio de fondo (jugar no requiere red ni cuenta).

## Migration notes

- `pubspec.yaml`: añadir `supabase_flutter`.
- `lib/main.dart`: inicializar Supabase al arranque, envuelto en try/catch — si falla, la
  app arranca igual sin ranking.
- `supabase/migrations/0001_scores.sql`: crear la tabla + RLS. Se aplica una vez en el
  proyecto Supabase (SQL Editor o CLI).
- `lib/services/score_service.dart`: `submitScore` y `topScores`, ambos best-effort (nunca
  lanzan al caller; devuelven vacío/silencio ante error).

## Open coordination points

- **security-compliance**: las políticas RLS son la barrera real — revisar que `anon` no
  pueda UPDATE/DELETE y que no se guarde ningún dato personal (el alias es libre y opcional).
  Rate-limiting de INSERT queda como mejora futura si aparece spam.
