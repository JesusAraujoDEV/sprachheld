# 🦸 Sprachheld — Plan de desarrollo

> Plan de la v1. **Todavía sin código.** Sintetiza el trabajo de 4 roles del crew
> (datos, UX, audio, arquitectura frontend) bajo criterio ponytail: lo mínimo que
> realmente sirve, cero over-engineering. Cada simplificación deliberada va marcada
> con 🪶 y su "añadir cuando…".

## 0. Cómo leer este documento

- **§1–§2**: qué es y qué se decidió (stack + los 4 toggles de producto).
- **§3–§5**: el contenido — schema de datos, sistema der/die/das, audio.
- **§6–§9**: la app — modos de quiz, gamificación, estética, arquitectura.
- **§10**: roadmap por fases.
- **§11**: decisiones abiertas que confirmar antes de construir.

---

## 1. Visión y alcance v1

App personal de práctica de alemán (A1→B1) estilo Quizlet/Blooket: *drill* rápido y
gamificado. Tres bloques de contenido —**verbos + conjugación**, **sustantivos con
género der/die/das**, **adjetivos**— más un **modo Tips** de reglas navegables (el
"por qué" de todo). Un solo usuario, sin cuenta, progreso en `localStorage`, sin backend.

**Fuera de v1:** multi-idioma, multiplayer/salas en vivo, vocabulario fuera de
verbos/sustantivos/adjetivos, cuentas y sincronización entre dispositivos.

## 2. Decisiones tomadas

**Stack (del README, confirmado 2026-08-17 — pivote a móvil):** Flutter (Dart), un solo
codebase para móvil + web + desktop. Datos JSON estáticos como assets. Progreso en
`shared_preferences` (equivalente Flutter de `localStorage`). Distribución: build web
estático (Vercel/GitHub Pages) + APK/IPA para el teléfono.
**Dependencias nuevas: mínimas** — `shared_preferences` (persistencia) y `flutter_tts`
(TTS nativo por plataforma). Todo lo demás, SDK de Flutter.

> El diseño de §3–§8 (schema, reglas der/die/das, audio, modos, gamificación, estética)
> es **agnóstico de framework** — se pensó con roles genéricos y aplica igual en Dart.
> Solo §9 (arquitectura) se reescribe abajo para Flutter; el resto de este documento
> sigue vigente tal cual, leyendo "componente" como "widget" y "hook" como
> "servicio/notifier".

**Toggles de producto (recomendación tomada; cambiar en §11 si no):**

| Decisión | Elegido | Por qué |
|---|---|---|
| Quiz de verbos pregunta por… | forma individual (persona+tiempo) | El schema `Persons` lo cubre por índice; más granular para SRS. |
| "Completar frase" usa… | chips de opción | Más arcade, menos frustración de tipeo. |
| Flashcard usa… | autoevaluación 2 botones ("Sabía/No sabía") | Habilita la repetición espaciada. |
| Router en v1 | ninguno (estado `view` en App) | 3 pantallas, sin deep-links. HashRouter solo si molesta el botón atrás. |

---

## 3. Modelo de datos (schema)

Orden fijo de personas en toda conjugación, índice 0..5:
`[ich, du, er/sie/es, wir, ihr, sie/Sie]`.

```ts
type Persons = [string, string, string, string, string, string];
type Level = "A1" | "A2" | "B1";
```

### 3.1 Verbos

Clave del ahorro: en alemán solo los tiempos **sintéticos** (una palabra) se almacenan.
Los **compuestos** (Perfekt, Plusquamperfekt, Futur I/II) se **derivan en runtime** de
`aux + partizipII + infinitiv` con un helper de ~10 líneas → cero repetición de
auxiliar y participio.

```ts
interface Verb {
  id: string;
  infinitiv: string;
  es: string;
  level: Level;
  regularity: "regular" | "irregular";
  separable: boolean;

  aux: "haben" | "sein";     // UNA vez
  partizipII: string;        // "gemacht" / "gegangen", UNA vez

  praesens: Persons;
  praeteritum: Persons;
  konjunktivII?: Persons;    // 🪶 opcional, relevante desde B1

  examples: string[];        // 2-3 frases. 🪶 string plano hasta que el quiz pida {de,es}
  conjugationNote?: string;  // "regular: raíz + -st (du)" / "fahren → fährst, umlaut"
}
```

Derivación de compuestos (nota de diseño, no va al JSON): defines `haben`, `sein`,
`werden` como `Verb` normales (traen su Präsens/Präteritum). Entonces:
Perfekt = `aux` Präsens + `partizipII`; Plusquamperfekt = `aux` Präteritum + `partizipII`;
Futur I = `werden` Präsens + `infinitiv`; Futur II = `werden` Präsens + `partizipII` + `aux`.

🪶 **Konjunktiv I omitido** (casi nunca <B2). Konjunktiv II opcional.

### 3.2 Sustantivos + reglas de género

Regla como **dato consultable** (alimenta el modo Tips y el "por qué" de cada respuesta);
el sustantivo la referencia por id.

```ts
interface Noun {
  id: string;
  word: string;                        // sin artículo: "Zeitung"
  gender: "der" | "die" | "das";
  plural: string;                      // forma completa: "Zeitungen"
  es: string;
  level: Level;
  ruleId: string | null;               // → GenderRule.id. null = excepción sin regla clara
}

interface GenderRule {
  id: string;
  gender: "der" | "die" | "das";
  kind: "ending" | "semantic";
  pattern: string;                     // "-ung" | "alcoholes" | "puntos cardinales"
  explanation: string;                 // "Sustantivos en -ung son femeninos"
  examples: string[];                  // 2-3, para la tarjeta Tip
  exceptions: string[];                // ["Bier"] para alcoholes→der
}
```

🪶 Un solo `ruleId` por sustantivo (no array): si dos reglas compiten, gana la más
específica y esa decisión se toma **al curar el dato**, no en runtime.

### 3.3 Adjetivos

```ts
interface Adjective {
  id: string;
  de: string;
  es: string;
  level: Level;
  opposite?: string;                   // 🪶 texto libre, no id
}
```

### 3.4 Organización de archivos

Un archivo por tipo, nivel como **campo filtrable** (no como carpeta):

```
src/data/
  verbs.json          Verb[]
  nouns.json          Noun[]
  adjectives.json     Adjective[]
  gender-rules.json   GenderRule[]
  phrases.json        Phrase[]         # "completar frase"
  schema.ts           # interfaces
```

Import estático (`import verbs from "@/data/verbs.json"`), filtrado por `level` en runtime.
🪶 No partas por nivel/categoría: array plano carga instantáneo con cientos de ítems y es
trivial de curar. Partir es premature hasta miles de ítems o hasta querer lazy-load.

---

## 4. Sistema der/die/das (el corazón "tips")

El género no es un dato suelto: cada `Noun` apunta a una `GenderRule`, y esas reglas
—terminaciones (-ung→die, -chen→das, -er→der…) y categorías semánticas (alcoholes→der
excepto Bier, puntos cardinales→der, metales→das, préstamos→das…)— son **el mismo dato**
que:

1. **Explica cada respuesta** del Quiz de género inline ("-heit/-keit/-ung → *die*").
2. **Llena el modo Tips** como micro-lecciones navegables.
3. **Cierra el loop**: la línea de regla en el quiz es tappable → abre la tarjeta Tip
   completa → botón "⚡ Prueba esto" lanza un quiz filtrado a esa regla.

Color semántico reusado de tus apuntes: **der = azul, die = rojo/rosa, das = verde**.
Fuente de datos inicial: tu diccionario de Notion (ya trae reglas + excepciones curadas).

---

## 5. Audio / pronunciación

**v1: Web Speech API nativa (`SpeechSynthesis`, `lang="de-DE"`).** Cero archivos, cero
coste, offline según voz, ~30 líneas. El input del TTS **ya es la palabra** (`infinitiv`
/ `word` / `de`) → sin campo de audio en el schema.

Detalles que **no** se recortan (o falla):
- Escuchar el evento `voiceschanged` antes de elegir voz (`getVoices()` es async y la 1ª
  llamada suele devolver `[]`).
- Disparar **siempre desde un `onClick`** (gesto de usuario), nunca en `useEffect` de
  carga → obligatorio en iOS Safari.

Único hueco opcional en el schema: `speak?: string` para override (ej. leer un sustantivo
CON artículo: "die Zeitung"). Casi siempre vacío.

🪶 **Saltado:** banco de MP3, APIs de pago, build de audio. Techo conocido: la calidad de
voz depende del SO. **Camino de upgrade v2** (si tu iPhone suena mal): script one-shot que
recorre el dataset, llama **Azure TTS** (500K chars/mes gratis permanente, mejor voz
neuronal alemana) y escupe `public/mp3/<hash>.mp3`; `speak()` prefiere el MP3 si existe y
cae a `SpeechSynthesis` si no. Sigue siendo 0€, sin backend, sin claves en runtime.
Pre-generar **solo frases clave**, no todo el diccionario.

---

## 6. Modos de quiz

Contrarreloj **no es un modo**: es una flag `timed` aplicable a cualquier modo.

1. **Flashcard** (verbo↔traducción, sustantivo↔género). Ves una cara → flip 3D → te
   autoevalúas "Sabía/No sabía" (alimenta SRS). Dorso de sustantivo: artículo coloreado +
   plural + línea de regla. Audio 🔊 arriba-derecha.
2. **Escribir la conjugación.** Prompt `gehen · du · Präsens` → input → Enter. Error
   muestra tu respuesta tachada vs. la correcta, resaltando la terminación fallada; debajo,
   `conjugationNote`. Normaliza mayúsculas/espacios y ß↔ss. 🪶 Sin fuzzy-match.
3. **Completar la frase.** Oración con hueco que pulsa + traducción en gris. **Chips** de
   opción (3-4). El hueco se rellena en verde; línea del "por qué" (caso/preposición).
4. **Quiz de género der/die/das.** Palabra enorme sin artículo + tres botones a todo el
   ancho, cada uno con SU color. Siempre muestra la regla que aplica (tappable → Tip).
5. **Tips (micro-lecciones).** No es sesión: mazo navegable de `GenderRule[]` por categoría
   (Género · Terminaciones · Casos · Irregulares). Título + regla + ejemplos coloreados +
   excepciones. Botón "⚡ Prueba esto".
6. **Contrarreloj / racha (arcade).** 3·2·1 → ráfaga de preguntas tap (género + completar,
   cero tipeo) → timer que se vacía. **Streak multiplier** (×2, ×3…) que sube con aciertos
   y cae al fallar = el gancho adictivo. Bonus por velocidad. Sin explicaciones inline; el
   "por qué" se difiere a Resultados. Guarda high score.

---

## 7. Progreso / gamificación (mínimo satisfactorio)

- **XP** por acierto (arcade da más) → barra diaria en Home + nivel acumulado.
- **Racha diaria 🔥** (+1 por día con ≥1 sesión). 🪶 Sin streak-freeze ni push.
- **Repetición espaciada — Leitner 5 cajas**, no SM-2. Intervalos `[0,1,3,7,16]` días;
  acierto sube de caja, fallo vuelve a 1. Home muestra "Dominados N / Débiles M" y un chip
  "Repaso débiles (N)" que arma sesión con lo flojo. Guarda por ítem `{box, dueDate,
  wrongCount, lastSeen}`. 🪶 Techo: no optimiza intervalos finos; `lastSeen` ya deja la
  puerta a SM-2. Sin badges por ahora (racha + nivel + high score = 3 bucles ya).

---

## 8. Estética "aura"

- **Dark-first.** Fondo casi-negro con gradiente radial que respira (`#0B0B14`→`#14101F`).
- **Aura = glow** difuso detrás de tarjetas/botones activos (box-shadow grande, blur alto,
  baja opacidad) + velo ligero (`backdrop-blur` suave + borde 1px `rgba(255,255,255,.08)`).
- **Paleta semántica:** der `#3B82F6` · die `#F43F5E` · das `#10B981` · acento/XP violeta
  `#8B5CF6`. **Error = ámbar `#F59E0B`** (nunca el rojo de "die", para no colisionar).
- **Tipografía:** display geométrica para el alemán y números grandes (Space Grotesk /
  Clash Display); cuerpo Inter. La palabra alemana es la estrella.
- **Microinteracciones con sentido:** flip 3D 250ms; acierto = pulse de glow + tick + XP
  count-up; error = shake corto + borde ámbar; cartas entran deslizando (sensación de mazo).
  🪶 CSS puro (`transition`/`@keyframes`), sin librería de animación.
- **Accesibilidad (no se simplifica):** género/estado nunca solo por color (texto+icono
  además); contraste AA sobre el fondo oscuro; teclado completo (espacio=voltear, 1/2/3=
  género, Enter=validar); `prefers-reduced-motion` → cross-fade sin flips/shakes.

Handoff visual: los tokens concretos de color/tipografía los aterriza `visual-identity`.

---

## 9. Arquitectura Flutter

```
lib/
  data/           # assets/data/*.json (fuera de lib/, ver assets:) + repositorios de carga
    repositories/ verb_repository.dart noun_repository.dart adjective_repository.dart ...
  models/         verb.dart noun.dart gender_rule.dart adjective.dart phrase.dart
                  # clases planas + fromJson/toJson a mano. Sin freezed/json_serializable.
  engine/         session.dart (buildSession)  check.dart (checkAnswer)  srs.dart (Leitner)
                  # Dart puro, sin Flutter — testeable con `dart test` sin widgets
  services/       storage_service.dart (wrapper shared_preferences)  speak_service.dart (flutter_tts)
  state/          quiz_session_notifier.dart (ChangeNotifier)  config_notifier.dart (ChangeNotifier)
  modes/          flashcard_screen.dart write_conjugation_screen.dart fill_phrase_screen.dart
                  gender_quiz_screen.dart tips_screen.dart
  widgets/        quiz_shell.dart (progreso/timer/audio)  audio_button.dart  flip_card.dart
  screens/        home_screen.dart  session_screen.dart (orquesta)  results_screen.dart
  main.dart       # MaterialApp + rutas nombradas
assets/
  data/           verbs.json nouns.json adjectives.json gender-rules.json phrases.json
```

**Genérico (1 vez) vs por modo (fino):** el motor de sesión y `QuizShell` son genéricos;
solo cambian el **widget de la pregunta** y una **rama de `checkAnswer`**. Flashcard
verbo↔traducción y sustantivo↔género son el **mismo** widget con distinto deck.
🪶 Sin registry/factory de tipos de pregunta: un `switch(mode)` en `session_screen.dart`
que elige el widget + el checker. Se abstrae si pasan de ~8 modos (nunca).

**Motor de quiz (Dart puro, sin `import 'package:flutter/...'`, testeable con `dart test`):**
```dart
List<Question> buildSession(List<DeckItem> deck, Mode mode, {int size, Map<String,SrsState>? srs, bool shuffle = true});
CheckResult checkAnswer(Question q, String input);
```
`QuizSessionNotifier` (un `ChangeNotifier` simple) envuelve la lista de `Question` y expone
`current, index, score, streak, timeLeft, submit(), next(), done`. Contrarreloj = flag
`timed` del mismo notifier, no un modo aparte. Tips reusa `buildSession` sin `checkAnswer`.

**Estado:** `ChangeNotifier` + `ListenableBuilder`/`AnimatedBuilder` de Flutter estándar.
🪶 **No Riverpod/Bloc/Provider-avanzado:** dos piezas de estado (sesión efímera de una
pantalla + config global chica) no justifican una librería de arquitectura de estado
completa. `ChangeNotifier` es la herramienta nativa del SDK para exactamente este tamaño
de problema. Se reconsidera si aparecen muchas pantallas leyendo el mismo estado en vivo
o si el árbol de widgets crece mucho y el rebuild manual duele.

**Persistencia:** un `StorageService` fino sobre `shared_preferences`, con
`getJson<T>(key, fallback)` / `setJson<T>(key, value)` que serializa con `dart:convert`.
Llaves `sh.config`, `sh.progress`, `sh.stats`. 🪶 Sin Hive/Isar/sqflite: son claves-valor
pequeñas (progreso por ítem, config, stats), no una base de datos relacional — meter un
motor de BD ahí es resolver un problema que no existe. Sin migración de esquema: `try/catch`
que cae al `fallback`; versionar cuando cambie la forma del progreso.

**Carga de datos:** `rootBundle.loadString('assets/data/verbs.json')` + `jsonDecode` en
cada repositorio, una vez al arrancar, cacheado en memoria (lista estática del repo). 🪶 Sin
`json_serializable`/codegen: son 5 tipos de dato chicos y estables; `fromJson` a mano es
menos fricción que mantener un build_runner para esto.

**TTS:** `flutter_tts` — es la envoltura estándar y minimal sobre el motor nativo de cada
plataforma (`AVSpeechSynthesizer` en iOS, `TextToSpeech` en Android, Web Speech API en
Flutter Web). Mismo rol que "Web Speech API nativa" del plan original, ahora
multiplataforma real (incluye iOS/Android nativos, no solo navegador). Idéntica lógica de
uso: setLanguage `de-DE`, disparar `speak()` solo dentro de un handler de tap.

**Navegación:** rutas nombradas simples de `MaterialApp` (`Navigator.pushNamed`), sin
`go_router`. 🪶 3-4 pantallas con navegación lineal no justifican un router declarativo;
se añade `go_router` si hace falta deep-linking real (compartir una sesión, web con URLs
navegables) — no es el caso de una app de un usuario.

**Dependencias nuevas totales: 2.** `shared_preferences` (persistencia) y `flutter_tts`
(audio). Todo lo demás — estado, navegación, parsing, animaciones (`AnimatedContainer`,
`AnimatedSwitcher`, `Hero` para el flip de carta) — SDK de Flutter puro.

**Por qué Flutter cubre "también teléfono" sin costo extra:** el mismo `lib/` compila a
Android/iOS (APK/IPA) y a Web/desktop sin capa de compatibilidad ni proyecto paralelo —
a diferencia de React Native, que necesita `react-native-web` (dependencia adicional, con
sus propias limitaciones de paridad) para cubrir el target web del plan original.

---

## 10. Roadmap por fases

| Fase | Entregable | Valida |
|---|---|---|
| **0. Scaffold** | `flutter create`, modelos Dart (`lib/models/`), 1 mazo semilla de cada tipo en `assets/data/` | `flutter analyze` limpio, `flutter run` levanta y muestra conteos |
| ✅ **1. Datos semilla** | 20 verbos + 24 sustantivos + 12 reglas + 19 adjetivos + 6 frases, curados de Notion | el schema aguanta datos reales |
| ✅ **2. Núcleo** | `StorageService` + `ConfigNotifier` + engine (`conjugation`/`session`/`check`/`srs`) con self-check | 8 tests de lógica pura en verde |
| ✅ **3. Primer modo** | Flashcard (verbos + der/die/das) + `QuizShell` + `AudioButton` (TTS) + tema "aura" | el motor + schema funcionan end-to-end en pantalla real |
| ✅ **4. Género der/die/das** | Quiz de género (palabra+3 botones+flip) + Tips navegables + Tabla de conjugación con buscador | el sistema de reglas cierra el loop |
| ✅ **5. Escribir + Completar** | WriteConjugationScreen + FillPhraseScreen (chips) | cubre conjugación y contexto |
| ✅ **6. Tips** | Mazo de reglas navegable + deep-link tip→quiz filtrado por regla | micro-lecciones |
| ✅ **7. Progreso** | `ProgressNotifier` (Leitner por ítem) + Home (racha/XP/dominados/débiles) | `buildSession` prioriza due/débiles en todos los modos |
| ✅ **8. Arcade** | `TimedArcadeScreen`: cuenta atrás, 60s, streak multiplier, high score persistido | el modo estrella |
| ✅ **9. Pulido** | Quiz de verbos rehecho a opción múltiple bidireccional (diseño ux-architect), audio por fila en la tabla de conjugación, 71 verbos / 61 sustantivos / 20 reglas (curados de Notion + data-architect) | roadmap v1 completo |

**Fase 9, alcance real vs. plan original:** el "pulido" del plan original (reduced-motion,
a11y exhaustiva) ya venía cubierto desde Fase 3 (`AuraBackground`/`FlipCard` respetan
`disableAnimations`, botones nativos son focuseables). Lo que se agregó en esta iteración
fue pulido de contenido y del modo de verbos, no una pasada de accesibilidad aparte — queda
como trabajo abierto de bajo riesgo, no bloqueante para uso diario.

## 11. Fase futura (anotada, no implementada): preposiciones + caso

Pedido del usuario para más adelante: un "doble quiz" tipo *"Ich gehe ___ Park"* que
combine (1) elegir la preposición correcta según si es movimiento o ubicación
(*Wechselpräpositionen*: in/an/auf rigen acusativo o dativo según el contexto) y (2) elegir
el artículo **declinado** por caso (*den* Park, no *der* Park — acusativo masculino).

Por qué no entra en esta iteración (vía ux-architect):
- Nuevo dato: qué preposición rige qué caso en qué contexto — hoy no existe ese modelo,
  es una tabla de reglas contextuales, no un campo fijo por palabra.
- Nuevo dato: declinación completa por caso además del género — `Noun` hoy solo guarda
  género+plural (nominativo), no las formas acusativo/dativo/genitivo.
- La pregunta evalúa dos decisiones a la vez (preposición + artículo declinado), no una
  sola respuesta — el engine actual (`checkAnswer`, `Question`) asume una respuesta.
- Depende pedagógicamente de que el usuario ya domine género (prerequisito natural).

Cuando se retome: nuevo modelo `CaseDeclension` (o extender `Noun` con las 3 formas no
nominativas) + tabla de reglas de preposición/caso + un modo nuevo que reutilice
`buildSession`/`QuizShell` pero con un `checkAnswer` de dos partes.

## 12. Escalar el contenido más allá de curación manual — implementado

✅ El usuario preguntó por escalar a ~1000 verbos y los sustantivos más comunes.
`scripts/derive_verbs.py` y `scripts/derive_nouns.py` (ver `scripts/README.md` para el
flujo completo) resuelven la parte mecánica:

- **Verbos**: `github.com/viorelsfetea/german-verbs-database` (8049 verbos, dato derivado
  de Wiktionary CC BY-SA) trae infinitivo + 3 personas de Präsens + 1 de Präteritum +
  Partizip II + auxiliar. Las 8 formas que faltan (wir/ihr/sie de Präsens, 5 de Präteritum)
  se derivan con reglas gramaticales fijas — no heurísticas de traducción, documentadas en
  el docstring del script y verificadas al 100% contra los 71 verbos ya curados a mano.
  Los verbos separables (CSV ya los da con el prefijo separado, ej. "breche ab") se
  detectan y `separable` se autoasigna.
- **Sustantivos**: `github.com/gambolputty/german-nouns` (CC BY-SA 4.0, género+plural+
  declinación) cruzado con `github.com/mejutoco/german-grammar-statistics` (CC BY 4.0,
  frecuencia) para priorizar los más comunes primero. `ruleId` se auto-asigna reutilizando
  las reglas de `gender-rules.json`.
- **Traducción al español**: sigue siendo manual vía Gemini, en lotes (el script genera el
  prompt listo para pegar) **con revisión humana antes de mergear** — eso no se automatiza,
  es la salvaguarda real contra traducciones erróneas en una app de aprendizaje.
- **Verbos irregulares**: la derivación mecánica ya cubre esto también (el patrón de
  Präteritum es 100% regular incluso en verbos fuertes, una vez que se tiene el ich-form) —
  a diferencia de lo que se pensaba en la investigación original de `researcher`, no hacía
  falta curar cada irregular a mano uno por uno.

Los 71 verbos y 61 sustantivos curados en Fase 9 siguen siendo la base verificada más
sólida; los scripts son para crecer desde ahí en lotes, con Gemini + revisión humana como
único paso manual restante.

## 13. Decisiones abiertas (confirmar antes de construir)

Los 4 toggles de §2 ya vienen con recomendación tomada — cámbialos aquí si no te cuadran:
1. **Verbos:** ¿forma individual (elegido) o tabla completa? Si nunca preguntas Futur II por
   persona, se puede eliminar hasta esa derivación.
2. **Completar frase:** ¿chips (elegido) o input libre?
3. **Flashcard:** ¿autoevaluación 2 botones (elegido, habilita SRS) o flip simple sin tracking?
4. **Router:** ¿ninguno (elegido) o HashRouter por el botón atrás?

---

*Plan sintetizado del trabajo de data-architect, ux-architect, researcher y
frontend-architect. Sin código todavía — siguiente paso es Fase 0 cuando des luz verde.*
