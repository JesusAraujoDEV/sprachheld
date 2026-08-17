# 🦸 Sprachheld

App de práctica de alemán con quizzes interactivos (estilo Quizlet/Blooket) enfocada en verbos: su significado, su conjugación en todos los tiempos verbales, y ejemplos de uso en contexto real.

## Por qué

Parte de mi propio proceso de aprendizaje de alemán (A1 → B1) camino a Alemania. Las apps que ya uso (Duolingo, DW Learn German) son buenas para el curso estructurado, pero no tienen un modo de *drill* rápido y gamificado enfocado específicamente en verbos y su conjugación — que es donde más se traba el alemán. Esta app cubre ese hueco, para mi propio uso primero.

## Qué hace (v1)

- **Banco de verbos**: entrada `infinitivo → traducción` (ej. `schreiben → escribir`, `laufen → correr`, `haben → tener`, `kommen → venir`), con marca de si es regular/irregular y separable/inseparable.
- **Conjugación completa por verbo**: Präsens, Präteritum, Perfekt, Plusquamperfekt, Futur I, Futur II, y modo Konjunktiv I/II — para las 6 personas gramaticales.
- **Frases de ejemplo**: 2-3 oraciones de uso real por verbo y por tiempo, para ver el verbo en contexto, no solo la tabla de conjugación aislada.
- **Modos de quiz** (estilo Quizlet/Blooket):
  - *Flashcard*: verbo ↔ traducción.
  - *Escribir la conjugación*: dado infinitivo + persona + tiempo, escribir la forma correcta.
  - *Completar la frase*: oración con hueco, elegir/escribir la conjugación correcta.
  - *Contrarreloj / racha*: modo arcade, puntos y velocidad, para que se sienta como juego y no como tarea.
- **Progreso**: qué verbos/tiempos domina el usuario vs. cuáles falla seguido (para repetir más los débiles, tipo spaced repetition simple).

## Qué NO hace (v1) — por ahora

- No es multi-idioma (solo alemán, desde español).
- No tiene multiplayer/salas en vivo (eso es un "quizás v2" si el modo contrarreloj funciona bien solo).
- No cubre vocabulario general fuera de verbos (sustantivos, adjetivos, etc. quedan fuera del alcance inicial).

## Stack posible

Pensado para reusar lo que ya manejo (ver mi CV/experiencia), no para aprender un stack nuevo encima de aprender alemán:

| Capa | Elección | Por qué |
|---|---|---|
| Frontend | React + TypeScript + Vite | Mismo stack que uso en `wallets-frontend`, curva de aprendizaje cero. |
| Estado/datos de progreso | `localStorage` en v1 (sin cuenta de usuario) | Es una app personal de un solo usuario al inicio — no hay razón para backend/auth todavía. Se puede migrar a backend real si algún día se vuelve multi-usuario. |
| Datos de verbos | Archivo(s) JSON estático(s) en el repo, curado a mano (empezando con los verbos más comunes A1-B1) | No hace falta una base de datos para una lista de verbos que no cambia en tiempo real. |
| Estilo | Tailwind CSS | Rápido para armar UI de quiz/tarjetas sin reinventar componentes. |
| Hosting | Vercel o GitHub Pages (build estático) | Sin backend en v1, cualquiera de los dos sirve gratis. |

**Si crece a v2** (multi-usuario, progreso sincronizado entre dispositivos, contribuciones de la comunidad a la base de verbos): ahí sí se justificaría un backend (Node.js/Express + PostgreSQL, mismo patrón que `wallets-backend`) — no antes.

## Roadmap inicial

1. Definir el esquema de datos de un verbo (infinitivo, traducción, tipo, conjugaciones por tiempo/persona, frases de ejemplo).
2. Cargar a mano los primeros ~30-50 verbos más comunes de A1/A2.
3. Construir el modo Flashcard (el más simple) para validar el esquema de datos.
4. Construir el modo "escribir la conjugación".
5. Agregar tracking de progreso en `localStorage`.
6. Modo contrarreloj/racha.
7. Evaluar si vale la pena un backend según cómo se use.

---

*Repo inicial — solo plan y stack por ahora, sin código todavía.*
