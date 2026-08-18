# Scripts de contenido

Herramientas para escalar `assets/data/verbs.json` y `assets/data/nouns.json`
más allá de curación 100% manual — ver `docs/PLAN.md` §12. Python puro,
sin dependencias (`urllib`/`csv`/`json` de la librería estándar).

## Flujo de trabajo

1. Corré el script pidiendo un lote:
   ```bash
   python scripts/derive_verbs.py --batch-size 200 --start 0
   python scripts/derive_nouns.py --batch-size 200 --start 0
   ```
   Cada uno deja dos archivos en `scripts/output/` (gitignored, se regeneran):
   - `..._batch_N_M.json` — el lote en el formato exacto de `verbs.json`/`nouns.json`,
     con `es`/`level` vacíos (y `separable` a revisar en verbos).
   - `..._batch_N_M_prompt.txt` — el texto listo para pegarle a Gemini.

2. Pegá el contenido del `_prompt.txt` en Gemini. Te devuelve la traducción
   en el mismo orden, una línea por palabra/verbo.

3. Volvé al `.json` del lote y completá:
   - `es`: la traducción que dio Gemini (revisala vos, no la pegues a ciegas).
   - `level`: A1/A2/B1 a tu criterio.
   - En verbos, `separable` ya viene autodetectado — solo verificalo si te
     genera dudas.

4. Pegá los objetos completados al final del array en `assets/data/verbs.json`
   o `nouns.json` (antes del `]` final, con una coma después del último
   elemento existente).

5. Corré `flutter test` — `test/data_integrity_test.dart` avisa si metiste
   un id duplicado o un `ruleId` que no existe.

## Qué hace cada script

- **`derive_verbs.py`** — lee `github.com/viorelsfetea/german-verbs-database`
  (CC, sin LICENSE explícito — dato derivado de Wiktionary CC BY-SA) y deriva
  las 6 formas de Präsens y las 6 de Präteritum con reglas gramaticales fijas
  (documentadas en el docstring del archivo), no con heurísticas de
  traducción. Verificado contra los 71 verbos ya curados a mano: coincide
  100%. Excluye automáticamente los verbos que ya están en `verbs.json`.

- **`derive_nouns.py`** — cruza `github.com/gambolputty/german-nouns`
  (CC BY-SA 4.0, género + plural) con `github.com/mejutoco/german-grammar-statistics`
  (CC BY 4.0, frecuencia de uso) para priorizar los sustantivos más comunes
  primero. Auto-asigna `ruleId` cuando la terminación de la palabra matchea
  alguna regla ya en `gender-rules.json`; si no, queda `null` (igual que el
  resto del banco — nunca se inventa una regla).

## Límites conocidos

- Ninguno de los dos intenta detectar el `level` (A1/A2/B1) — es criterio
  humano.
- `derive_verbs.py` no verifica que el verbo sea de uso realmente común
  (el dataset trae 8000+ verbos, incluye rarezas). Priorizá a mano o pedile
  a Gemini que marque cuáles son de uso cotidiano al traducir el lote.
- La traducción de Gemini SIEMPRE se revisa antes de mergear — es el paso
  que evita que una traducción ambigua entre a una app de aprendizaje.
