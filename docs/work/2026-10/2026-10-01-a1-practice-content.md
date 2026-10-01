# 2026-10-01 — Contenido A1: Akkusativ, demostrativos, cortesía, modales y tabla de declinación

## What changed
Se agregaron cuatro bancos de contenido A1/A2 y una pantalla de apuntes. Tres
bancos de "completar la frase" nuevos: pronombres personales en Akkusativ
(ihn/sie/es, 24 ítems), demostrativos dieser/diese/dieses en Akkusativ (24
ítems) y fórmulas de cortesía en Konjunktiv II (hätte gern / möchte / Könnten
Sie…?, 20 ítems). Se completaron los verbos modales agregando `dürfen` y
`sollen` a `verbs.json` (los otros cuatro ya estaban correctos). Y una pantalla
de solo consulta `ArticleDeclensionTableScreen` con la declinación de artículos
(der/die/das/plural) y los nueve pronombres personales en Nominativ/Akkusativ/
Dativ. Todo enganchado al Home.

## Why
Temas de repaso A1 pedidos tras clases de alemán: el caso Akkusativ (cuándo
usar ihn/sie/es y diesen/diese/dieses según el género), las fórmulas de cortesía
de memoria para pedir en restaurante/tienda, y los seis modales. La tabla de
declinación cubre el follow-up abierto del 2026-09-09 (los modales y los apuntes
de casos no tenían módulo). Mantiene la línea "el contenido es dato, no código":
los tres quizzes nuevos no agregan ni una línea de Dart.

## How
- Tres JSON nuevos con el mismo esquema `Phrase` (`akkusativ-pronomen-phrases`,
  `demonstrativ-phrases`, `konjunktiv2-hoeflichkeit-phrases`). Reusan
  `FillPhraseScreen(asset: …)` tal como el banco de posesivos; cero código.
- `verbs.json`: `dürfen` y `sollen` con las seis formas de Präsens/Präteritum,
  Partizip II y `aux` haben. Decisión no obvia de `frequencyRank`: la banda
  1-100 es una permutación fija que `data_integrity_test` verifica ("exactamente
  100 verbos con rank ≤ 100"), y los ranks 101-609 están libres (el grueso
  empieza en 610). Poner los modales en 10-60 como sugería el brief habría
  roto ese invariante, así que van en 101/102 — todavía muy por debajo del
  grueso, reflejando su alta frecuencia, sin tocar el test.
- Apuntes: modelo `ArticleDeclension` + `article-declensions.json` +
  `DataRepository.loadArticleDeclensions()` + `article_declension_table_screen`,
  mismo molde que `PossessiveTableScreen`. Se eligió una sola tabla con columna
  `kind` (article/pronoun) en vez de tabs o dos pantallas: 13 filas no justifican
  más estructura.
- Home: tres tiles en `practice_grid.dart` (acentos y íconos existentes) y una
  fila en `lookup_list.dart`.
- `data_integrity_test.dart`: un loop sobre los tres bancos nuevos (answer en
  options, hueco presente, ids únicos) y un test de la tabla de declinación
  (ids únicos, campos de caso no vacíos, kind válido).

## Promoted knowledge
None — contenido y UI que siguen patrones ya documentados por el código
(quiz reusando `FillPhraseScreen` + JSON, tabla de consulta clonando
`PossessiveTableScreen`). El invariante de `frequencyRank` ya estaba codificado
y explicado en `data_integrity_test.dart`.

## Follow-ups
- [ ] El id del modal `mögen` usa Umlaut mientras el resto del archivo usa
      transliteración ASCII (koennen/muessen); no se normalizó para no arriesgar
      el asset de 7600 verbos en esta tarea. Candidato a una limpieza aparte.
- [ ] Comparativos/superlativos siguen sin módulo (ya anotado el 2026-09-09).
