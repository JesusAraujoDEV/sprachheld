# 2026-08-18 — Modo Flashcard, quiz de género, tabla de conjugación y tips

## What changed
Fase 3 y 4 del roadmap: primer modo jugable (Flashcard de verbos) con el
sistema visual "aura" aterrizado a Flutter (tema, glow, flip 3D, TTS), y
luego el quiz de género der/die/das rehecho al formato pedido por el
usuario (palabra + 3 botones + animación de acierto/error + flip con la
respuesta). Se agregaron dos features fuera del roadmap original pedidas
directamente por el usuario: una tabla de conjugación con buscador de
verbos (consulta, no quiz) y un mazo navegable de tips de reglas de
género der/die/das, con deep-link tip→quiz filtrado por regla.

## Why
El usuario pidió explícitamente una interfaz "aura" de calidad tipo
Duolingo, no "cochinadas anticuadas" — se consultó a visual-identity para
aterrizar la dirección ya definida en docs/PLAN.md §8 a valores concretos
de Flutter (ColorScheme, Google Fonts, BoxShadow, Matrix4). Luego,
probando la app, el usuario marcó que la flashcard de sustantivos no
encajaba con "elegir el artículo correcto" y pidió el formato de botones.
Las dos features nuevas (tabla de conjugación, tips) fueron pedidos
directos del usuario, diseñados con ux-architect antes de implementar.

## How
- `lib/theme/app_theme.dart`: ColorScheme/TextTheme Material 3 con los
  tokens exactos de visual-identity (fondo #0B0B14→#14101F, glow por
  BoxShadow con blur 60/spread -10, Space Grotesk + Inter vía
  `google_fonts`, colores semánticos der/die/das aparte del ColorScheme).
- `lib/widgets/flip_card.dart`: flip 3D con `Matrix4` nativo, sin paquete;
  el ángulo de la cara trasera se remapea (`angle - pi`) para que el texto
  nunca se vea espejado.
- `lib/modes/gender_quiz_screen.dart`: reemplaza la flashcard de
  sustantivos. Tres botones der/die/das con `AnimatedContainer` para el
  feedback (verde/ámbar), luego `Timer` de 450ms antes de voltear la
  carta. Acepta un `ruleId` opcional para el deep-link desde Tips.
- `lib/modes/conjugation_table_screen.dart`: `Autocomplete<Verb>` nativo
  de Flutter (sin dependencia nueva) + un tab por tiempo verbal
  (Presente/Pasado/Futuro) en vez de una tabla ancha — ux-architect
  descartó `DataTable` porque las formas compuestas alemanas fuerzan
  scroll horizontal en un teléfono. Futuro se deriva en runtime con
  `Conjugation.futurI`.
- `lib/modes/gender_tips_screen.dart`: `PageView` dentro del `QuizShell`
  existente, con chips de filtro (Terminaciones/Semánticas) y botón
  "⚡ Prueba esto" que abre `GenderQuizScreen(ruleId: ...)`.
- `lib/widgets/glow_card_face.dart`: extrae la superficie de carta
  (glow + audio) que antes estaba duplicada entre Flashcard y el quiz de
  género.
- Se usaron subagentes del crew (visual-identity para tokens, ux-architect
  para las dos pantallas nuevas) antes de escribir código, siguiendo el
  pedido explícito del usuario de "usar los subagentes para mejores
  resultados".

## Promoted knowledge
- `docs/PLAN.md` §10 (roadmap): Fases 3 y 4 marcadas como completas.
- Ningún ADR nuevo — las decisiones de UI (Autocomplete nativo, tabs en
  vez de tabla ancha, Matrix4 sin paquete) quedan documentadas como
  comentarios `docs/PLAN.md §X` en el código, no ameritan un ADR propio
  por ahora.

## Follow-ups
- [ ] Verificar visualmente en el teléfono físico — la depuración USB
      quedó sin autorizar a mitad de sesión (SM A356E, RFCX315W1SJ);
      quedó corriendo en Chrome como fallback mientras tanto.
- [ ] Hay un `icono.png` (512×512) sin trackear en la raíz del repo,
      de origen desconocido — confirmar con el usuario si es el ícono de
      la app antes de commitearlo o descartarlo.
- [ ] Fases 5-9 del roadmap siguen pendientes (Escribir conjugación,
      Completar frase, progreso/Leitner persistido en Home, Contrarreloj,
      pulido final).
