# 2026-08-17 — Pivote a Flutter, scaffold Fase 0 e instalación del crew

## What changed
Se reemplazó el stack planeado (React+TS+Vite+Tailwind) por Flutter, para cubrir
móvil+web+desktop desde un solo codebase. Se completó la Fase 0 del roadmap: proyecto
Flutter scaffoldeado (Android/iOS/Web), schema de datos en Dart (`Verb`, `Noun`,
`GenderRule`, `Adjective`, `Phrase`), mazos semilla curados desde el diccionario de
Notion del usuario, y una pantalla de verificación que confirma que el schema y el
parsing de assets funcionan de punta a punta (`flutter analyze` limpio, `flutter test`
en verde). Además se instaló el scaffold estándar del crew en el proyecto (`AGENTS.md`,
`docs/{briefs,decisions,guides,proposals,requirements,stories,work}`, `standards/`).

## Why
El plan original (`docs/PLAN.md`) asumía una web-app pura; el usuario pidió que la app
esté "también orientada a teléfono" y eligió Flutter explícitamente por experiencia
previa (tesis de grado), evitando la curva de aprendizaje de un stack nuevo. La
instalación del crew se pidió aparte, al ver la estructura de `docs/` de otro proyecto
del usuario y confirmar que acá faltaba scaffoldear.

## How
El schema (`lib/models/`) deriva los tiempos verbales compuestos (Perfekt,
Plusquamperfekt, Futur I/II) de `aux + partizipII` en vez de almacenarlos, y cada
`Noun` referencia su `GenderRule` por id para que el "por qué" der/die/das sea dato
consultable en vez de texto suelto — ambas decisiones ya estaban en `docs/PLAN.md` §3–4
y se implementaron sin cambios. `DataRepository` carga los JSON de `assets/data/` con
`rootBundle` + `jsonDecode`, sin codegen (`json_serializable`/`freezed` descartados por
ponytail: 5 tipos chicos y estables no lo justifican). Dependencias nuevas: solo
`shared_preferences` y `flutter_tts`. El trabajo se dividió en 4 commits (scaffold,
datos, pantalla de verificación, docs) para que la historia sea legible. La instalación
del crew se delegó al agente `crew-installer` (subagente), que corrió
`bin/init-project.sh` del plugin de forma idempotente y añadió a mano `docs/audits/`
(no incluida en la plantilla estándar).

## Promoted knowledge
- `README.md` — tabla de stack actualizada a Flutter.
- `docs/PLAN.md` — §2 y §9 reescritas para arquitectura Flutter (el resto del plan,
  agnóstico de framework, sigue vigente).
- `AGENTS.md` / `docs/DEVIATIONS.md` — creados por el crew-installer; documentan que el
  spec vive en `docs/PLAN.md` (no `docs/spec.md`), que el estándar de calidad aplica sus
  equivalentes Dart (`flutter analyze` + `flutter_lints`) en vez de las reglas TS de la
  plantilla, y que `docs/audits/` es un árbol extra sobre la taxonomía estándar.

## Follow-ups
- [ ] Fase 1 del roadmap: ampliar mazos semilla (más verbos/sustantivos) y construir el
      motor de conjugación derivado (`lib/engine/conjugation.dart`).
- [ ] Convertir `docs/PLAN.md` en requirements/stories formales del circuito de entrega
      (trabajo de FA, no de este cierre).
- [ ] Commitear el scaffold del crew instalado (`AGENTS.md`, `docs/{...}`,
      `standards/`) — quedó sin commitear a la espera de que el usuario lo revise.
