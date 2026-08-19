# 2026-08-19 — Modo de práctica de preposiciones (Nivel 1)

## What changed
Se implementó el modo "Preposiciones de lugar" (P1+P2 de `docs/PLAN-preposiciones.md`):
una tarjeta nueva en el Home que practica in/an/auf/zu y el resto del sistema de
preposiciones alemanas eligiendo la preposición correcta en una frase con hueco. Incluye
dos assets de contenido nuevos (24 preposiciones de referencia + 30 ejercicios Nivel 1),
un modelo `Preposition` con su enum `GermanCase`, y la reutilización del motor de
"Completar la frase" para no duplicar pantalla.

## Why
El usuario (nivel A2) acaba de ver las preposiciones de lugar en clase y pidió un modo
para practicarlas. El plan (`docs/PLAN-preposiciones.md`, sintetizado antes por 3 roles
del crew) ya tenía el diseño; esta iteración ejecuta las dos primeras fases: los datos de
referencia (P1) y el Nivel 1 jugable (P2), dejando el doble-quiz preposición+artículo (P3)
para después por ser más trabajo.

## How
- **Contenido** curado por un subagente `data-architect` y verificado contra Duden:
  `assets/data/prepositions.json` (9 Wechselpräpositionen + 5 Akkusativ + 7 Dativ + 3
  Genitiv) y `assets/data/preposition-phrases.json` (30 ejercicios). Se respetaron las
  trampas gramaticales del plan §5: solo uso LOCAL de lugar (nada temporal/figurado),
  persona→siempre zu, y contracciones obligatorias como respuesta propia.
- **Reutilización (ponytail):** `FillPhraseScreen` ganó un parámetro `asset` opcional, así
  el Nivel 1 corre sobre el mismo motor y UI de "Completar la frase" cambiando solo el
  JSON — sin pantalla nueva. Los ids `prep_*` segregan el progreso SRS automáticamente.
- **Modelo** `Preposition`/`GermanCase` a mano (sin codegen), con la invariante wechsel=2
  casos / resto=1 caso validada por test.
- La `_ModeCard` del Home lanza directo al Nivel 1; el bottom-sheet de nivel llega con P3.

## Promoted knowledge
- `docs/PLAN-preposiciones.md` §6: roadmap marcado P1+P2 como hechos, P3 reescrito para
  incluir el bottom-sheet de nivel que se difirió.
- `test/data_integrity_test.dart`: dos checks nuevos — prepositions.json parsea con la
  invariante de casos, y cada ejercicio tiene su answer en options + hueco.

## Follow-ups
- [ ] P3: Nivel 2 (doble-quiz preposición + artículo declinado en secuencia) con el
      modelo `PrepositionItem`, la pantalla fork de fill_phrase, y el bottom-sheet de nivel.
- [ ] P4: alimentar el modo Tips existente con `prepositions.json` (tabla categoría × caso).
- [ ] Verificación visual del usuario en el teléfono físico (build lanzado al cierre de
      esta iteración; commit y tests ya en verde).
