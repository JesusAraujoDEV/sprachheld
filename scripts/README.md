# Scripts de contenido

Herramientas para escalar `assets/data/verbs.json` y `assets/data/nouns.json`
más allá de curación 100% manual — ver `docs/PLAN.md` §12. Python puro,
sin dependencias (`urllib`/`csv`/`json` de la librería estándar).

## Flujo de trabajo

1. Corré el script pidiendo un lote (no hace falta pasar `--start`, el
   default ya es `0` y el script excluye solo lo que ya esté en
   `verbs.json`/`nouns.json` — nunca hay que llevar la cuenta a mano):
   ```bash
   python scripts/derive_verbs.py --batch-size 200
   python scripts/derive_nouns.py --batch-size 200
   ```
   Cada uno deja **tres** archivos en `scripts/output/` (gitignored, se
   regeneran) y te imprime el comando exacto del paso 3, ya con las rutas
   completas — copiar y pegar:
   - `..._batch_N_M.json` — el lote en el formato exacto de `verbs.json`/`nouns.json`,
     con `es`/`level` vacíos (y `separable`/`ruleId` ya resueltos).
   - `..._batch_N_M_prompt.txt` — **liviano**: solo la lista de palabras y el
     pedido de traducción ("infinitivo -> traducción" / "der/die/das Wort ->
     traducción"). Gemini nunca ve el JSON pesado (praesens/praeteritum/etc.).
   - `..._batch_N_M_translations.txt` — **vacío**, creado a propósito para que
     solo tengas que abrirlo y pegar ahí la respuesta de Gemini. Al tener
     siempre el mismo nombre que el `.json` del lote (cambiando el sufijo),
     el siguiente paso lo encuentra solo — no hay forma de mezclar el
     `.txt` de un lote con el `.json` de otro.

2. Pegá el contenido de `_prompt.txt` en Gemini, y su respuesta pegala tal
   cual en el `_translations.txt` que ya existe (guardalo).

3. Fusioná — un solo argumento, el `.txt` se infiere solo:
   ```bash
   python scripts/apply_translations.py scripts/output/verbs_batch_0_200.json --level A1
   ```
   `--level` es opcional — si el lote completo es del mismo nivel, se lo pone
   a todos de una; si no, lo editás a mano por objeto en el `_merged.json`
   que genera. Si el `.txt` todavía está vacío o mal formado, el script lo
   dice y no genera nada a medias.

4. Revisá el `_merged.json` (traducciones y niveles) y pegame el array
   completo — lo appendeo al final de `assets/data/verbs.json` o `nouns.json`
   y corro `flutter test`. `test/data_integrity_test.dart` avisa solo si
   metiste un id duplicado o un `ruleId` que no existe.

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

- **`apply_translations.py`** — fusiona la respuesta liviana de Gemini
  (`clave -> traducción`, una por línea) con el `.json` del lote, sin que
  Gemini tenga que ver ni tocar los campos ya derivados.

## Límites conocidos

- Ninguno de los dos intenta detectar el `level` (A1/A2/B1) — es criterio
  humano.
- `derive_verbs.py` no verifica que el verbo sea de uso realmente común
  (el dataset trae 8000+ verbos, incluye rarezas). Priorizá a mano o pedile
  a Gemini que marque cuáles son de uso cotidiano al traducir el lote.
- La traducción de Gemini SIEMPRE se revisa antes de mergear — es el paso
  que evita que una traducción ambigua entre a una app de aprendizaje.
