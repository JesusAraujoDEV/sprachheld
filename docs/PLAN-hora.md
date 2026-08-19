# 🕐 Plan — Modo "La Hora" (Die Uhrzeit) + reorden del Home

> Plan de un modo nuevo para practicar la hora alemana (formal 24h e informal con
> *halb*/*Viertel*/*vor*/*nach*) y del reorden del Home que lo acompaña. Sintetiza el
> trabajo de 2 roles del crew (data-architect = contenido y schema, ux-architect =
> layout del Home) bajo criterio ponytail. **Todavía sin código.**

## 0. Cómo leer este documento

- **§1** — el contenido lingüístico, tal cual está en tus notas de clase (30/05 y 13/06).
- **§2** — la decisión de fondo: derivar la hora, no curarla.
- **§3** — modelo de datos y algoritmo de derivación.
- **§4** — cómo encaja en el motor de quiz existente.
- **§5** — simplificaciones deliberadas (🪶).
- **§6** — estimación.
- **§7** — reorden del Home (para que el décimo modo no desborde la pantalla).
- **§8** — preguntas abiertas.

---

## 1. Contenido lingüístico (fuente: tus notas de clase)

### 1.1 Hora formal / oficial (24h)

Fórmula: **[Hora] + Uhr + [Minutos]**.

- `12:00` → *zwölf Uhr* — `08:00` → *acht Uhr*
- `14:30` → *vierzehn Uhr dreißig*
- `Wie viel Uhr ist es?` → ¿Qué hora es? · `Wann?` → ¿Cuándo?/¿A qué hora?
- `Es ist Punkt neun Uhr` / `Es ist genau neun Uhr` → en punto / exactamente.

### 1.2 Hora informal (12h) — la mentalidad "hacia adelante"

El alemán no mira los minutos que **pasaron**, mira cuánto falta para la **media hora
de la hora siguiente**. Los 4 puntos cardinales de cada hora:

| Minuto | Regla | Ejemplo (base 8) |
|---|---|---|
| `:00` | hora en punto | *acht* |
| `:15` | *Viertel nach* + hora actual | *Viertel nach acht* |
| `:30` | *halb* + hora **siguiente** | *halb neun* (8:30 = "mitad para las 9") |
| `:45` | *Viertel vor* + hora siguiente | *Viertel vor neun* |

Nunca se usa formato 24h en la hora informal (no "halb zwanzig" para 19:30 → "halb acht"
de la tarde, por contexto).

### 1.3 Los minutos intermedios — *vor*/*nach* relativos al *halb*

Entre los 4 cardinales, la referencia deja de ser la hora en punto y pasa a ser el
*halb* más cercano (ejemplo completo de tu nota, base 5→6):

| Digital | Expresión | Lógica |
|---|---|---|
| 05:05 | *fünf nach fünf* | 5 después de las 5 |
| 05:15 | *Viertel nach fünf* | — |
| 05:20 | *zehn vor halb sechs* | 10 antes de la media para las 6 |
| 05:25 | *fünf vor halb sechs* | 5 antes de la media para las 6 |
| 05:30 | *halb sechs* | — |
| 05:35 | *fünf nach halb sechs* | 5 después de la media para las 6 |
| 05:40 | *zehn nach halb sechs* | 10 después de la media para las 6 |
| 05:45 | *Viertel vor sechs* | — |
| 05:50 | *zehn vor sechs* | — |

### 1.4 Expresiones sueltas

- **Mahlzeit!** — saludo de mediodía (~11:30–13:30) entre colegas; funciona como
  "¡Hola!" + "¡Buen provecho!" a la vez.
- **die Mitternacht** — la medianoche (00:00). Compuesta de *Mitte* + *Nacht*.

---

## 2. Decisión de fondo: derivar, no curar

Una hora alemana es una función pura de `(hora, minuto)`. Las ~144 combinaciones
(12 horas × 12 múltiplos de 5) no son contenido: son el output de las cuatro reglas de
§1.2–1.3, ya verificadas contra tus notas. Curarlas a mano en JSON crea 144 filas que se
desincronizan de la regla real y no enseñan nada que el generador no sepa.

Mismo patrón que los tiempos compuestos de verbos ([`PLAN.md`](PLAN.md) §3.1): **se
almacena lo irreducible (numerales, léxico), se deriva lo combinatorio (la hora)**.

Lo que **sí** se cura a mano: las tarjetas del modo Tips (las 4 reglas cardinales,
*Mahlzeit*, *Mitternacht*, *Punkt*/*genau*, *Wann?*) — eso es explicación, no combinatoria.

---

## 3. Modelo de datos

Una hora concreta **no persiste** como ítem de contenido (no tiene `id`/`level` propio,
es efímera):

```dart
// lib/models/clock_time.dart
class ClockTime {
  final int hour;    // 0..23
  final int minute;  // 0..55, múltiplos de 5
  const ClockTime(this.hour, this.minute);

  String get digital => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

// lib/models/clock_expression.dart
/// Una expresión hablada ya construida. [tokens] es la fuente de verdad;
/// [de] y [phonetic] son dos renderizados del mismo token list.
class ClockExpression {
  final List<String> tokens;   // ["zehn", "vor", "halb", "sechs"]
  final String de;             // "zehn vor halb sechs"
  final String phonetic;       // "[tsen for halb zeks]"
}
```

El único JSON nuevo, mismo patrón que `GenderRule` ([`PLAN.md`](PLAN.md) §3.2):

```dart
// lib/models/clock_tip.dart
class ClockTip {
  final String id;
  final String title;          // "halb = la mitad PARA la hora siguiente"
  final String explanation;    // el "por qué", en español
  final List<String> examples; // ["8:30 → halb neun", "12:30 → halb eins"]
  final Level level;           // A1 en todos, filtrable como el resto
  final String? note;
}
```

`assets/data/clock-tips.json` — ~8 tarjetas curadas (4 cardinales + Mahlzeit +
Mitternacht + Punkt/genau + Wann). Sin `speak` en el schema: el TTS recibe
`expression.de` directo (mismo patrón que [`PLAN.md`](PLAN.md) §5).

### 3.1 Algoritmo de derivación

Dos tablas Dart literales (léxico cerrado del idioma, no contenido editable — **no**
van a JSON): numerales 0–59 (`eins`..`zwanzig`, decenas compuestas) y un mapa
token→fonética castellana aproximada (~25 entradas: numerales base + *nach*/*vor*/
*Viertel*/*halb*/*Uhr*/*zehn*). La fonética es el mismo `join` de tokens con el otro
diccionario — una sola derivación, dos renderizados.

```
formal(t):
  tokens = [num(t.hour), "Uhr"]
  if t.minute > 0: tokens += [num(t.minute)]        # "vierzehn Uhr dreißig"

informal(t):
  h12  = t.hour % 12; if h12 == 0 → 12
  next = h12 % 12 + 1                                # la hora "hacia la que se va"
  switch t.minute:
    0        → [num(h12)]                            # "fünf"
    15       → ["Viertel", "nach", num(h12)]
    30       → ["halb", num(next)]
    45       → ["Viertel", "vor", num(next)]
    5 | 10   → [num(m), "nach", num(h12)]             # "fünf nach fünf"
    20 | 25  → [num(30-m), "vor", "halb", num(next)]
    35 | 40  → [num(m-30), "nach", "halb", num(next)]
    50 | 55  → [num(60-m), "vor", num(next)]
```

Dos casos que **no** se recortan (el modo enseñaría mal sin ellos): `1` es *eins* suelto
(`halb eins`, `Es ist eins`) pero *ein* pegado a `Uhr` (`ein Uhr`); y `next` con wrap
12→1, exactamente el caso `12:30 = halb eins` de tu nota.

**Check obligatorio** (lógica no trivial → un test, regla del proyecto): fixture literal
con las 10 filas de la tabla §1.3 (05:00→05:50) más `12:30 → halb eins` y
`13:00 → ein Uhr`, en `test/engine/clock_test.dart`. Si el generador se rompe, la tabla
falla.

---

## 4. Encaje con el motor de quiz

Un valor nuevo en `QuizMode`: `clockQuiz`. `Question` genérico ya sirve — `prompt` es
`ClockTime` + dirección, `answer` es `String`. Tres direcciones, mismo widget de chips:

| Dirección | Prompt | Respuesta |
|---|---|---|
| digital → informal | `08:45` | "Viertel vor neun" |
| informal → digital | "zehn vor halb sechs" | `05:20` |
| formal → digital | "vierzehn Uhr dreißig" | `14:30` |

**Los distractores también se derivan** — y ahí está el valor pedagógico real: para una
hora objetivo, los candidatos son los errores típicos del castellanohablante (la hora en
punto anterior en vez de la siguiente — el error de mirar "hacia atrás"; *nach*/*vor*
invertido; ±5 minutos). Se generan 3, se barajan con la correcta. Mejores distractores
que los que se escribirían a mano, y cero curación.

`checkAnswer` no se toca: comparación normalizada exacta, sin fuzzy — para
"informal → digital" el input es un chip `HH:MM`, listo para comparar como string.

Las tarjetas de `clock-tips.json` entran al modo Tips existente por composición (mismo
layout título/explicación/ejemplos). Contrarreloj hereda `clockQuiz` gratis por ser
tap-only.

---

## 5. Simplificaciones deliberadas

🪶 **Solo múltiplos de 5 minutos.** Techo: `07:23` no es expresable. Upgrade: rama
`[num(m), "nach", num(h)]` para minutos arbitrarios — una línea, pero nadie habla así en
A1/A2 y admitirlo solo agrega distractores basura.

🪶 **Fonética castellana aproximada, no IPA.** Techo: no distingue `ö`/`ü` ni vocal
larga — es la misma muleta que ya usan tus notas (`[fünf naj fünf]`). Upgrade: IPA por
token en un segundo valor del mismo mapa, si hace falta precisión — el audio real ya lo
cubre el TTS.

🪶 **Una sola variante regional por hora.** `08:15` se enseña como *Viertel nach acht*,
sin el *viertel neun* de sur/este de Alemania. Techo: el usuario puede oír una forma que
la app marca incorrecta. Upgrade: `List<String>` de expresiones aceptadas — se aplaza
hasta que aparezca el problema real, enseñar dos sistemas a la vez confunde más de lo
que ayuda.

🪶 **Sin SRS por hora individual.** El progreso trackea el modo, no cada una de las 144
horas. Techo: no se detecta que fallás sistemáticamente en *halb*. Upgrade: clave SRS
sintética `clock:<minuto>` (12 buckets) — ahí está la señal real, el minuto, no la hora
puntual.

🪶 **Tokens fonéticos en Dart, no en JSON.** Es léxico cerrado del idioma; en assets
invitaría a editarlo a mano y desincronizarlo del generador que lo consume.

---

## 6. Estimación

| Milestone | Est. hours | Started | Finished | Actual hours | Notes |
|---|---|---|---|---|---|
| Generador de numerales 0–59 + mapa fonético | 1.5 | | | | Tablas literales; incluye `eins`/`ein` |
| `ClockTime` / `ClockExpression` + derivación formal e informal | 2.0 | | | | Núcleo, pseudocódigo §3.1 |
| Test con la tabla 05:00→05:50 de la nota | 0.5 | | | | Fixture literal, gate de la lógica |
| `ClockTip` + `clock-tips.json` curado | 1.0 | | | | ~8 tarjetas |
| Generador de distractores + integración en `Question` | 1.0 | | | | Reusa `checkAnswer` sin tocarlo |
| `clock_quiz_screen.dart` (3 direcciones, chips) | 2.5 | | | | Límite 200 líneas de screen |
| Reorden del Home + registro del modo nuevo (§7) | 1.5 | | | | Incluye Contrarreloj/Tips/menú |
| **Total** | **10.0** | | | | |

---

## 7. Reorden del Home

El décimo modo agrava un problema que ya existía: `home_screen.dart` es hoy 9
`_ModeCard` full-width apiladas sin jerarquía — el modo estrella (Contrarreloj) pesa
visualmente igual que un modo de sola consulta (Tabla de conjugación).

**Criterio de agrupación: intención de uso**, no tema gramatical — entrás sabiendo si
querés "drillear rápido", "practicar algo puntual" o "consultar/ver progreso".

1. **Modo destacado** (full-width, arriba de todo, como ya está hoy) — **Contrarreloj**.
   Mayor prioridad visual: sesión corta y gamificada, la acción de mayor conversión.
2. **Practicar** (grid 2 columnas, tarjetas compactas cuadradas) — Verbos, der/die/das,
   Escribir conjugación, Completar la frase, Preposiciones de lugar, **La Hora** (nuevo).
   Seis modos del mismo peso funcional; sin subtítulo largo, solo icono + título corto
   bajo un header "Practicar".
3. **Consulta y progreso** (filas compactas tipo `ListTile`, no cards con sombra) —
   Ranking, Tabla de conjugación, Tips: der/die/das. Son "mirar/buscar", no "jugar" —
   bajan de peso visual para leerse como secundarios.

```
Column
 ├─ header + stats (sin cambios)
 ├─ _ModeCard full-width — Contrarreloj (destacado)
 ├─ "Practicar" + GridView.count(2, shrinkWrap, NeverScrollable) → 6 _ModeTile compactas
 ├─ "Consulta y progreso" + Container con 3 ListTile + Divider
 ├─ TTS switch + player name tile (sin cambios)
```

"La Hora" entra como séptima celda del grid — la fila queda impar (una celda sola), es
visualmente aceptable y no rompe el patrón. Sin promoción a destacado por ahora: eso se
evalúa si se vuelve el modo más usado, no se especula hoy.

Se descarta: tabs/`PageView` por categoría (más estado del que 10 ítems en una pantalla
de un solo usuario justifican) y un accordion para "Consulta y progreso" (3 filas ya son
cortas, no necesitan colapsar). Accesibilidad: mismos accent colors ya validados en el
resto de la app, tap targets ≥48dp por el aspect ratio de la celda, orden de lectura del
árbol coincide con el orden visual (destacado → practicar → consulta), sin motion nuevo
que gatear contra `prefers-reduced-motion`.

Archivo afectado: `lib/screens/home_screen.dart`. Sin dependencias nuevas
(`GridView`/`Wrap`/`ListTile` son SDK de Flutter).

---

## 8. Preguntas abiertas

1. **"informal → digital": ¿chips `HH:MM` o reloj analógico tappable?** Lo segundo es el
   gesto natural del contenido pero es UI nueva — a decidir si vale la pena vs. reusar
   el patrón de chips ya existente en todo el resto de la app.
2. **¿`clockQuiz` entra al arcade de Contrarreloj desde la fase 1**, o se estabiliza
   primero como modo suelto antes de mezclarlo con género/frases en la ráfaga?

---

*Plan sintetizado del trabajo de data-architect y ux-architect. Sin código todavía —
confirmá luz verde y las preguntas de §8 antes de arrancar Fase 0.*
