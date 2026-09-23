# 2026-09-23 — Voz alemana en web con Piper + auto-deploy por webhook

## What changed
En web, el botón de pronunciación ahora sintetiza alemán con Piper (WASM, voz
Thorsten) en vez de `speechSynthesis`; móvil sigue con `flutter_tts`. Además se
activó el redeploy automático en Dokploy con un webhook de GitHub que dispara con
cada push a `main`.

## Why
La web hablaba en español: el Chrome del usuario solo tiene voces `es-MX` y
`en-GB` (verificado con `speechSynthesis.getVoices()`), y `flutter_tts` en web no
puede crear una voz alemana que el sistema no tiene. Aparte, el usuario pidió que
cada commit se despliegue solo. También pidió mover el dominio a
`jesusaraujo.lat`, pero esa raíz ya la usa la app `portafolio` del mismo panel:
quedó pendiente de su decisión.

## How
- Decisión y alternativas en `docs/decisions/0002-piper-german-voice-on-web.md`.
- `web/piper/` (paquete `@mintplex-labs/piper-tts-web` 1.0.5 vendoreado),
  `web/piper_bridge.js` (expone `window.sprachheldSpeakDe`), import map en
  `web/index.html` para `onnxruntime-web/wasm`.
- Dart: `german_voice_web.dart` (dart:js_interop) y `german_voice_stub.dart`
  con import condicional; `SpeakService` usa Piper si `kIsWeb`;
  `AudioButton` muestra "Preparando la voz alemana…" mientras carga y un mensaje
  si falla (antes los errores de TTS se perdían).
- Verificación en el navegador embebido de Orca sobre el build local: la síntesis
  de "Ich gehe nach Hazse" produjo un audio de ~1 s reproducido hasta el final; el
  botón real de la tabla de posesivos disparó el camino Dart→JS completo. Frase
  nueva ≈ 0,7 s, repetida ≈ 30 ms. No se pudo verificar de oído que suene alemán.
- Webhook: creado en GitHub (`push`, JSON) apuntando al endpoint de deploy de la
  app en Dokploy; el ping inicial respondió 200.

## Promoted knowledge
`AGENTS.md` (fila Audio del Stack) referencia el ADR 0002. El ADR es la fuente
para el porqué de Piper en web.

## Follow-ups
- [ ] Decidir el dominio: `jesusaraujo.lat` está ocupado por `portafolio`
      (mover el portafolio a `www.` o usar `sprachheld.jesusaraujo.lat`).
- [ ] Confirmar que este push disparó un redeploy automático en Dokploy.
- [ ] La primera pronunciación descarga ~63 MB (cacheado luego); si molesta,
      alojar modelo y wasm en el propio despliegue (ver "Migration notes" del ADR).
