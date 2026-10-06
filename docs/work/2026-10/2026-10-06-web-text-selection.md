# 2026-10-06 — Habilitar selección/copia de texto en web

## What changed
En web, la app ahora se envuelve en `SelectionArea` cuando `kIsWeb`, lo que
permite seleccionar y copiar cualquier texto de la UI. Móvil queda sin
cambios.

## Why
El usuario reportó que en `sprachheld.jesusaraujo.lat` no podía seleccionar
ni copiar texto. Flutter no habilita selección de texto por defecto; sin
`SelectionArea` ningún `Text` es seleccionable.

## How
`lib/main.dart`: el `builder` de `MaterialApp` envuelve `child` en
`SelectionArea` solo cuando `kIsWeb` — en móvil el long-press ya se usa para
otras cosas (abrir menús, etc.) y no se tocó. Verificado con `flutter
analyze` y `flutter test` (45/45) en limpio.

## Promoted knowledge
None — es un fix puntual de una línea de comportamiento, no una regla nueva.

## Follow-ups
- [ ] Confirmar visualmente en el navegador que la selección por arrastre no
      choca con el nuevo widget de palabras tocables que está construyendo
      Kiro en paralelo (`duolingo-tap-words`); ya está pedido como parte de
      la verificación de esa tarea.
