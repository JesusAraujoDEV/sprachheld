# 🧭 Plan — Modo "Preposiciones de lugar"

> Plan de un modo nuevo para practicar **in / an / auf / zu** y el resto del sistema de
> preposiciones alemanas. Sintetiza el trabajo de 3 roles del crew (researcher = contenido
> lingüístico, data-architect = schema, ux-architect = diseño de los quizzes) bajo criterio
> ponytail. Reemplaza y desarrolla la nota de "fase futura" de [`PLAN.md`](PLAN.md) §11.

## 0. Cómo leer este documento

- **§1** — la decisión de fondo (qué construimos y por qué así).
- **§2** — el contenido lingüístico: las ~20 preposiciones por caso (para curar el JSON).
- **§3** — schema de datos (modelos, cómo se resuelve la declinación).
- **§4** — diseño de los dos niveles de quiz.
- **§5** — trampas gramaticales que hay que respetar o el quiz enseñará mal.
- **§6** — roadmap por fases.

---

## 1. Decisión de fondo

Un modo nuevo, **progresivo en dos niveles**, porque la dificultad real tiene dos capas que
abruman a un A2 si se atacan juntas:

1. **Nivel 1 · "Solo la preposición"** — la frase ya trae el artículo; el usuario elige solo
   la preposición (in/an/auf/zu…). **Reutiliza el modo "Completar la frase" tal cual** — el
   `Phrase` que ya existe (`sentence` con hueco, `answer`, `options`, `note`) es exactamente
   este ejercicio. Cero código nuevo, solo contenido.
2. **Nivel 2 · "Preposición + artículo"** — dos filas de chips en secuencia en una sola
   pantalla: primero la preposición, y al contestarla se revela la fila del artículo
   declinado (den/dem/das…). Enseña la **cadena causal** `in + movimiento → acusativo → den`,
   que es justo lo que se pierde si se parte en dos pantallas.

Contenido **curado a mano**, no generado combinando preposición × sustantivo: el caso de una
Wechselpräposition depende del verbo y la semántica de la frase (`in den Park **gehen**` Akk
vs `im Park **spielen**` Dat), no del sustantivo — un generador produciría gramática ambigua
o incorrecta (§5).

🪶 **Semilla = solo las 9 Wechselpräpositionen de lugar** (in/an/auf/vor/hinter/über/unter/
neben/zwischen) + el nudo **zu vs in/an/auf**. Es el set con la dualidad Akk/Dativ, el más
rico y el punto exacto donde está el usuario. El resto de preposiciones (Akkusativ fijas,
Dativ fijas, Genitiv) entran como Tips de referencia desde ya, y como ejercicios en una fase
posterior.

---

## 2. Contenido lingüístico (para curar el JSON)

Fuente: researcher, verificado contra Duden/DWDS. **Verificar cada dato contra
[Goethe](https://www.goethe.de/), [DW Nicos Weg](https://learngerman.dw.com/) o
[Duden](https://www.duden.de/) antes de darlo por bueno — es una app de enseñanza.**

### 2.1 Wechselpräpositionen — las 9 de doble caso (el corazón del modo)

Regla central:

| Pregunta | Caso | Sentido | Verbos típicos |
|---|---|---|---|
| **Wohin?** (¿a dónde?) | **Akkusativ** | movimiento / dirección | gehen, fahren, stellen, legen, setzen, hängen (transitivo) |
| **Wo?** (¿dónde?) | **Dativ** | ubicación estática | sein, stehen, liegen, sitzen, bleiben, hängen (intransitivo) |

Pista de oro: los pares **legen/liegen**, **stellen/stehen**, **setzen/sitzen** delatan el
caso — el primero (transitivo) → Akkusativ, el segundo (intransitivo) → Dativ.

| Prep. | Sentido espacial | Ejemplo Akk (Wohin) | Ejemplo Dat (Wo) |
|---|---|---|---|
| **an** | borde / contacto vertical / junto a | Ich hänge das Bild **an die** Wand. | Das Bild hängt **an der** Wand. |
| **auf** | sobre superficie horizontal | Ich lege das Buch **auf den** Tisch. | Das Buch liegt **auf dem** Tisch. |
| **in** | dentro / interior cerrado | Ich gehe **in die** Schule. | Ich bin **in der** Schule. |
| **über** | encima **sin** contacto | Ich hänge die Lampe **über den** Tisch. | Die Lampe hängt **über dem** Tisch. |
| **unter** | debajo / entre (varios) | Die Katze läuft **unter das** Bett. | Die Katze schläft **unter dem** Bett. |
| **vor** | delante de | Ich stelle das Auto **vor das** Haus. | Das Auto steht **vor dem** Haus. |
| **hinter** | detrás de | Ich gehe **hinter das** Haus. | Der Garten ist **hinter dem** Haus. |
| **neben** | al lado de | Ich stelle die Lampe **neben das** Sofa. | Die Lampe steht **neben dem** Sofa. |
| **zwischen** | entre (dos) | Ich stelle die Bank **zwischen die** Bäume. | Die Bank steht **zwischen den** Bäumen. |

### 2.2 El nudo zu vs in/an/auf/nach (la confusión que reportó el usuario)

- **zu** (+ Dativ) → **personas siempre** ("zum Arzt", "zu meiner Oma") y lugares como punto
  de destino ("zum Bahnhof", "zur Arbeit"). Error típico del hispanohablante: "voy *al*
  médico" → ✗ "in den Arzt". **Regla segura: persona → siempre zu.**
- **in** (+ Akk) → entrar en espacio cerrado ("ins Kino", "in die Schule").
- **an** (+ Akk) → borde/agua ("ans Meer", "an den See").
- **auf** (+ Akk) → superficie o instituciones tradicionales ("auf die Post", "auf die Bank").
- **nach** → sin artículo: ciudades/países neutros ("nach Berlin", "nach Deutschland").
- Fórmulas fijas de casa: **nach Hause** (movimiento) / **zu Hause** (ubicación), sin artículo.

### 2.3 Contracciones obligatorias (enseñar primero estas 8)

**am** (an+dem) · **ans** (an+das) · **im** (in+dem) · **ins** (in+das) · **zum** (zu+dem) ·
**zur** (zu+der) · **beim** (bei+dem) · **vom** (von+dem). La contracción es obligatoria salvo
artículo enfático/demostrativo.

### 2.4 Preposiciones de caso fijo (Tips de referencia + fase posterior)

- **Akkusativ fijas:** durch, für, gegen, ohne, um (núcleo) + bis, entlang, wider.
- **Dativ fijas:** aus, bei, mit, nach, seit, von, zu (núcleo) + gegenüber, ab, außer.
- **Genitiv (B1+):** während, wegen, trotz, statt, innerhalb, außerhalb — con la nota de que
  en el habla coloquial se usan mucho con dativo ("wegen dem Regen").

Lista completa con significados y ejemplos: ver el volcado del researcher (guardado en
`docs/work/` cuando se implemente).

### 2.5 Prioridad de enseñanza (orden para curar los primeros ejercicios)

Las 10 más rentables por frecuencia: **in, mit, auf, für, an, zu, von, nach, aus, bei**. La
secuencia didáctica: caso fijo (memorizable en bloques) → 9 Wechsel (Wohin/Wo) → contracciones
→ zu vs in/an/auf → genitivas al final.

---

## 3. Schema de datos

### 3.1 `Preposition` — dato de referencia (~20 filas, alimenta los Tips)

Es la tabla "qué preposición rige qué caso". Las Wechsel se modelan con **lista de casos**, no
con un booleano ni dos filas. La regla Wohin/Wo NO va como campo estructurado — vive en los
ejemplos y en la nota de cada ejercicio, porque depende de la frase, no de la preposición.

```dart
enum GermanCase { nominativ, akkusativ, dativ, genitiv }
enum PrepCategory { akkusativ, dativ, wechsel, genitiv }

class Preposition {
  final String id;                 // "in" (== prep, sirve de key)
  final String prep;               // "in"
  final PrepCategory category;
  final List<GermanCase> governs;  // wechsel → [akkusativ, dativ]; resto → 1 elemento
  final String es;                 // "en / dentro de"
  final Level level;               // A2 | B1
  final List<String> examples;     // 1-2 frases (las wechsel contrastan mov/ubic)
}
```
`assets/data/prepositions.json` — ~20 filas.

### 3.2 La declinación → derivar, no almacenar

La tabla de artículos definidos es **4 géneros × 4 casos, fija, no cambia jamás**. Se deriva
en runtime; **no se tocan los 9.400 sustantivos** (guardar formas declinadas multiplicaría el
asset ×4 sin ganancia).

```dart
// lib/engine/declension.dart — solo si se autogeneran chips distractores.
const _definiteArticle = {
  Gender.der: {akkusativ:'den', dativ:'dem', ...},   // der→den→dem→des
  Gender.die: {akkusativ:'die', dativ:'der', ...},
  Gender.das: {akkusativ:'das', dativ:'dem', ...},
};
const _contractions = {'in+dem':'im','in+das':'ins','an+dem':'am','an+das':'ans',
                       'zu+dem':'zum','zu+der':'zur','bei+dem':'beim','von+dem':'vom'};
```

🪶 Las "irregularidades" (‑n del dativo plural `den Kindern`, sustantivos débiles
`den Studenten`) **no rompen esto**: afectan al *sustantivo*, no al *artículo*, y el
sustantivo va escrito en la frase — no se declina en runtime. Fuera de scope. El único gotcha
real de las preposiciones de lugar son las contracciones, y esas son un lookup de 8 entradas.

### 3.3 Ítems de quiz — reconciliación de las dos recomendaciones

Los roles divergieron; la síntesis:

- **Nivel 1 reutiliza `Phrase`** (un hueco, una respuesta) — coinciden ambos roles. Contenido
  en `preposition-phrases.json`, parseado con el **mismo `Phrase.fromJson`** (aísla el banco
  sin duplicar modelo). Reusa `QuizMode.fillPhrase` y `checkAnswer` tal cual.
- **Nivel 2 sí necesita un modelo nuevo** `PrepositionItem` — `Phrase` tiene una sola
  `answer`, y el Nivel 2 tiene dos respuestas (preposición + artículo). Es un modelo mínimo,
  no un motor:

```dart
class PrepositionItem {
  final String id;
  final String sentence;             // "Ich gehe ___ ___ Park" (dos marcadores)
  final String prep;                 // "in"      — respuesta 1
  final List<String> prepOptions;    // chips fila 1
  final String article;              // "den"     — respuesta 2
  final List<String> articleOptions; // chips fila 2
  final String es;
  final String note;                 // el "por qué"
  final Level level;
}
```
🪶 El ítem cuenta como acierto en SRS solo si **ambas** filas fueron correctas; granularidad
por sub-respuesta es upgrade posterior. Contenido combinatorio descartado (§5).

---

## 4. Diseño de los quizzes (UX)

Base: `fill_phrase_screen.dart` es el patrón exacto. Reutiliza `QuizShell`, `GlowCardFace`, el
patrón de chips y `AudioButton`. **Promover `_OptionChip` a `lib/widgets/option_chip.dart`**
(hoy es privado de fill_phrase) para compartirlo — refactor de reutilización, no componente
nuevo.

### 4.1 Nivel 1 · "Solo la preposición"
`FillPhraseScreen` sin cambios, cargando `preposition-phrases.json`. Frase con un `___` + chips
de preposición (3-4 opciones) + audio de la frase completa + nota del "por qué".

### 4.2 Nivel 2 · "Preposición + artículo"
Fork de `FillPhraseScreen` con **dos filas secuenciales**:
- Frase con dos marcadores que se rellenan progresivamente: `ich gehe ___ ___ Park` →
  `ich gehe in ___ Park` → `ich gehe in den Park`.
- **Fila 1 (Preposición)** activa; al contestar se bloquea (verde/ámbar) y **revela la Fila 2
  (Artículo)**. Con ambas resueltas aparece el "por qué" + Siguiente.
- Si falla la preposición: la Fila 2 se arma con la preposición **correcta** (no la que eligió
  mal), para que aprenda la declinación bien igual.
- Etiquetas de fila pequeñas ("Preposición" / "Artículo", `labelSmall`).

⚠️ **Los chips de artículo (den/dem/das/die/der) van en superficie NEUTRA — nunca los colores
der/die/das.** Esos colores significan *género*; den/dem son *caso*. Pintarlos de azul/rojo/
verde enseñaría un mapeo falso. Feedback verde/ámbar igual que el resto.

### 4.3 Entrada y selección
- Una `_ModeCard` en Home: título "Preposiciones de lugar", subtítulo "in / an / auf + el caso
  correcto", accent a definir con visual-identity (azul `kGenderDer` o violeta `kSecondary`).
- Al tocarla, **bottom-sheet de nivel** (mismo patrón que el selector de verbos): "Solo la
  preposición" / "Preposición + artículo".
- 🪶 Selector de sub-tema (Wechsel / Dativ / Akkusativ / Todas) **diferido** hasta tener
  volumen de contenido; se agrega como segunda fila del sheet cuando lo justifique.

---

## 5. Trampas gramaticales (respetar o el quiz enseña mal)

Del researcher — cada una marcaría respuestas correctas como erróneas si se ignora:

1. **Usos no-locales de las 9 Wechsel tienen caso FIJO**, no siguen Wohin/Wo: temporal
   (`am Montag`, `in einer Woche`, `vor zwei Tagen` → Dativ fijo) y figurado (`über Politik
   sprechen` → Akk fijo). **La semilla debe ser solo uso LOCAL de lugar.** No mezclar.
2. **Persona → siempre zu.** Nunca in/an/auf con personas.
3. **entlang, gegenüber, ab** tienen posición variable (pre/pospuesta) que cambia el caso — si
   entran, tratarlas aparte, no con la regla general.
4. **Registro de las genitivas:** norma escrita = genitivo, habla = dativo (`wegen dem Regen`).
   Decidir explícitamente qué se evalúa antes de curar ejercicios de genitivo — es decisión de
   producto (tuya), no técnica. Recomendación: para A2→B1, enseñar el genitivo normativo y
   mencionar el dativo coloquial en la nota.
5. **Contracciones obligatorias vs enfáticas:** `zum Arzt` (default) vs `zu dem Arzt, den…`
   (demostrativo). La semilla usa solo el caso default/obligatorio.

---

## 6. Roadmap por fases

| Fase | Entregable | Est. |
|---|---|---|
| ✅ **P1. Datos de referencia** | `Preposition` model + `GermanCase` enum + `prepositions.json` (~20 filas curadas A2/B1) | hecho |
| ✅ **P2. Nivel 1** | `preposition-phrases.json` + `FillPhraseScreen` reutilizado con `asset` param + `_ModeCard` en Home (se lanza directo al Nivel 1; el bottom-sheet de nivel llega con P3) | hecho |
| **P3. Nivel 2** | `PrepositionItem` model + pantalla fork de fill_phrase (2 filas secuenciales + reveal) + `option_chip.dart` compartido + bottom-sheet de nivel + test del gating (correct = prep && article) | 6h |
| **P4. Tips** | `prepositions.json` alimenta una tarjeta de referencia (categoría × caso) en el modo Tips existente | 1.5h |
| **P5. Ampliación** | Ejercicios de caso fijo (Akk/Dativ) + genitivas + selector de sub-tema en el sheet | según uso |

P1+P2 (Nivel 1 jugable) implementado en esta iteración. P3 (el doble-quiz) queda para la siguiente.

---

## 7. Decisiones abiertas (tuyas, antes de construir)

1. **Accent del ModeCard** — azul o violeta (con visual-identity).
2. **Registro del genitivo** (§5.4) — recomendado: normativo + nota coloquial.
3. **¿Arrancamos por P1+P2** (Nivel 1 jugable rápido, reusa lo que ya hay) **o vamos directo a
   P3** (el doble quiz, más trabajo pero es "la" feature)? Recomendado: P1→P2 primero para
   tener algo tocable en el teléfono en una sesión, y P3 después.

---

*Plan sintetizado del trabajo de researcher, data-architect y ux-architect. Sin código todavía
— siguiente paso es P1 cuando des luz verde.*
