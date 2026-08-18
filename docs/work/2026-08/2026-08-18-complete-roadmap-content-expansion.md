# 2026-08-18 — Roadmap completo (fases 5-9), quiz de verbos rediseñado, contenido 4x

## What changed
Se completaron las fases 5 a 9 del roadmap: modos Escribir conjugación y Completar
frase, progreso persistido (Leitner + XP + racha diaria + high score de arcade), modo
Contrarreloj, y una pasada de contenido que llevó el banco de datos de 20→71 verbos,
24→61 sustantivos y 12→20 reglas de género. Además se rehizo el quiz de verbos (antes
flip-card con autoevaluación) a opción múltiple bidireccional por pedido explícito del
usuario, se agregó audio por fila en la tabla de conjugación, y se dejaron anotadas
(sin implementar) dos ideas de alcance mayor: un quiz de preposiciones+caso y un plan
realista para escalar contenido con datasets externos.

## Why
El usuario pidió terminar "todas las fases" en una sola sesión y, en el camino, señaló
que la flashcard de verbos no encajaba con el patrón de opción múltiple que ya le había
gustado en el quiz de género — pidió el mismo formato para verbos. También preguntó por
escalar a "los 1000 verbos más usados" y pidió revisar sus 12 clases de Notion para
sacar más vocabulario y tips reales en vez de contenido genérico.

## How
- **Contenido**: se despacharon dos subagentes en paralelo — `data-architect` curó 27
  verbos de alta frecuencia + 8 reglas de género (las que el usuario copió textualmente
  de sus apuntes: -ismus, -ist, -ig, -ling, -en, -ich, -eur, -iker) con ejemplos
  verificados; en paralelo se leyeron las 12 páginas de clases de Notion del usuario,
  de donde se minaron 24 verbos adicionales con Partizip II tomado directamente de las
  tablas que su profesor/IA ya le había verificado (gehört, gespielt, gekocht, gegessen,
  gesungen, getrunken, gestohlen...). Se dedupe por id antes de fusionar — cero
  solapamiento entre ambas fuentes.
- **Progreso**: `lib/state/progress_notifier.dart` — un solo `ChangeNotifier` con
  `SrsState` por ítem (reutiliza el motor Leitner de la Fase 2) + xp/racha/high-score,
  persistido en `sh.progress`/`sh.stats`. Se conecta a `buildSession(srs: ...)` en cada
  modo, así el propio motor prioriza ítems vencidos/débiles sin lógica nueva.
- **Quiz de verbos**: diseño de `ux-architect` — dirección DE→ES o ES→DE decidida 50/50
  por ítem al construir la sesión (no por sesión completa), distractores filtrados por
  mismo nivel A1/A2 y sin traducciones duplicadas, grid 2×2 en vez de fila de 4 (las
  opciones son frases largas, no letras sueltas como der/die/das).
- **Investigación de escalabilidad**: `researcher` evaluó datasets abiertos
  (`gambolputty/german-nouns`, `mejutoco/german-grammar-statistics`, UniMorph,
  Wiktextract) y concluyó honestamente que no existe una fuente única lista para
  importar 1000 verbos verificados — quedó un plan por lotes en `docs/PLAN.md` §12 en
  vez de fabricar contenido sin verificar.
- Se agregó `test/data_integrity_test.dart` (ids únicos, `ruleId` válidos) dado el
  volumen de JSON editado a mano en una sola sesión — es la clase de error silencioso
  que no se nota jugando pero rompe un item específico.

## Promoted knowledge
- `docs/PLAN.md` §10: roadmap marcado 100% completo.
- `docs/PLAN.md` §11 (nueva): diseño de alto nivel del futuro quiz de preposición+caso
  (Wechselpräpositionen + declinación), anotado para cuando se retome.
- `docs/PLAN.md` §12 (nueva): plan de escalado de contenido por lotes con fuentes y
  licencias concretas, para no repetir la investigación.

## Follow-ups
- [ ] Verificar visualmente en el teléfono físico los 3 modos nuevos (Escribir
      conjugación, Completar frase, Contrarreloj) — commiteado y testeado, pendiente de
      confirmación visual del usuario en el momento de este commit.
- [ ] `docs/DEVIATIONS.md` no se actualizó con la decisión de omitir Konjunktiv I/II en
      la mayoría de los 51 verbos nuevos (igual que los 20 originales) — sigue vigente,
      no es una desviación nueva, pero vale confirmarlo si se retoma el contenido.
- [ ] Fase futura de preposición+caso y plan de escalado de contenido (§11-12 del plan)
      siguen sin implementar, a propósito — quedan como trabajo de sesiones futuras.
