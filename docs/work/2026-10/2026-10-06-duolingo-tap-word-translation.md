# 2026-10-06 — Traducción palabra-por-palabra al tocar (estilo Duolingo)

## What changed
Tocar una palabra de una frase alemana ahora abre un mini-modal con la palabra,
su significado en español y un botón para escucharla sola (TTS). Se agregó el
asset `assets/data/word-glosses.json` (mapa plano palabra→español, 22 380
entradas, 695 798 bytes) derivado por un script nuevo, un widget reutilizable
`TappableGermanText`, un loader cacheado en `DataRepository`, y se enganchó en
las pantallas "Completar la frase" y "Escribir la conjugación".

## Why
Pedido del usuario: "como en Duolingo — si clickeo en una palabra, me salta una
mini modal con lo que significa y su pronunciación". El banco de frases es el
contenido que más se toca, así que la cobertura de esas palabras es prioritaria
sobre la cobertura genérica del diccionario.

## How
- **Diccionario como dato, no código**: `scripts/derive_word_glosses.py`
  (Python puro, sin deps, mismo estilo que `derive_nouns.py`/`derive_verbs.py`)
  fusiona `nouns.json` (word + plural), `adjectives.json`, `verbs.json`
  (frequencyRank ≤ 1000: infinitiv, 6 Präsens, 6 Präteritum, partizipII) y una
  lista cerrada de palabras función escritas a mano. Keys en minúscula, lookup
  O(1). El script **falla** si alguna palabra de alguna frase de los
  `*-phrases.json` queda sin glosa — garantía dura de cobertura.
- **Resolución de homógrafos**: con el orden nouns→adjectives→verbs→función, un
  sustantivo nominalizado raro ("das Gut", "der Reif", "das Schreiben") pisaba a
  la palabra común. Se resolvió con un flag `force`: adjetivos, verbos (ordenados
  por frecuencia, gana el más común) y la lista función/correcciones le ganan al
  sustantivo homógrafo. Correcciones puntuales de sentidos secundarios en
  `nouns.json` (kaffee→café, tee→té, rock→falda, glas→vaso…) se hacen en el
  script, **sin tocar** el banco de dominio.
- **Widget**: `lib/widgets/tappable_german_text.dart` — `StatelessWidget` que
  recibe la frase y el glosario ya cargado, parte por espacios en un `Wrap` de
  spans tocables, limpia puntuación de los bordes para el lookup y el TTS, y
  muestra el popup. Fallback "(traducción no disponible)" cuando no hay glosa;
  el audio sigue andando igual.
- **Repository**: `DataRepository.loadWordGlosses()` cachea el `Future<Map>` con
  guard (`_glossesCache ??= _loadGlosses()`) porque se pide en cada pantalla de
  quiz, a diferencia de los mazos que se cargan una vez por sesión.
- **Enganche**: `fill_phrase_screen.dart` (la frase con el hueco resuelto) y
  `write_conjugation_screen.dart` (el infinitivo). Ambas cargan el glosario en
  `_load` y lo guardan en estado.

## Decisión de UI del popup
Se eligió `showDialog` con un `Dialog` chico centrado (fondo `kSurfaceContainer`,
radio 16, palabra en `titleLarge` bold + significado en `bodyMedium` + ícono de
audio `kPrimary`), **no** un overlay anclado a la palabra
(`CompositedTransformTarget/Follower`). El UX architect prefería el anclado por
contexto espacial; el frontend architect recomendó el diálogo por simplicidad.
Se optó por el diálogo porque: (a) entra holgado en el tope de 150 líneas del
widget, (b) el barrier de `showDialog` ya da "tocar afuera cierra" sin manejar
posicionamiento/flip/cleanup en scroll, (c) es confiable en web y móvil por
igual. Trade-off aceptado: el popup aparece centrado, no pegado a la palabra.

## Convivencia con la selección de texto en web
`main.dart` envuelve todo en `SelectionArea` cuando `kIsWeb`, que se queda con
el tap antes que el `GestureDetector`. Se envolvió el `Wrap` del widget en
`SelectionContainer.disabled()`: desactiva la selección solo dentro de la frase
tocable (ahí el tap llega al word span), y la selección de texto sigue
funcionando en el resto de la app. Verificado por `flutter build web --release`
(compila, el asset se empaqueta en `build/web/assets/assets/data/`).

## Límite de frequencyRank usado
`VERB_FREQUENCY_CUTOFF = 1000` (el valor sugerido). El archivo final quedó en
0.66 MB, muy por debajo del tope de ~3 MB, así que no hizo falta recortar.

## Promoted knowledge
Ninguna guía viva nueva. El patrón de cacheo en `DataRepository` queda
documentado en el docstring del propio método; el estilo del script queda en su
docstring, consistente con `scripts/README.md`.

## Follow-ups
- [ ] **Agrupar frases/expresiones fijas en un solo toque** (ej. "zu Hause",
  "Ich hätte gern") — fuera de alcance de esta iteración; hoy cada palabra se
  toca individualmente.
- [ ] **Enganchar el widget en más pantallas** con frase alemana + `AudioButton`:
  `preposition_double_screen`, `article_declension_table_screen`,
  `possessive_table_screen`, `clock_quiz_screen`, `timed_arcade_screen`,
  `conjugation_table`. Se dejaron fuera porque son tablas/ítems con layouts más
  ajustados, no el patrón limpio "frase + AudioButton al lado" — forzarlo ahora
  arriesga romper esos layouts.
- [ ] **Calidad de datos en `nouns.json`**: varias glosas traen un sentido
  secundario/raro como primario (Kaffee→"la cafetería", Tee→"el soporte de
  golf", Reif→"el aro", Rock→"la chaqueta", Post→"la publicación"…). Se
  corrigieron en el script solo para las palabras que aparecen en frases; valdría
  revisar y corregir el banco de dominio en su propia pasada.
- [ ] **Dedup de significados**: el glosario no desambigua homógrafos reales
  (una key = un significado). Si en el futuro importa el contexto (ej. "sie" =
  ella/ellos/usted), habría que modelar múltiples sentidos por palabra.
