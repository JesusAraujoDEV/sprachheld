# 0002 — Voz alemana en web con Piper (WASM) en vez de speechSynthesis

- **Status**: Accepted
- **Date**: 2026-09-23
- **Owner role**: system-architect
- **Affects**: `lib/services/speak_service.dart`, `lib/services/german_voice_*.dart`, `lib/widgets/audio_button.dart`, `web/index.html`, `web/piper_bridge.js`, `web/piper/`

## Context

`flutter_tts` en web usa `speechSynthesis` del navegador, que solo ofrece las voces
instaladas en el sistema. En la máquina del usuario (Windows + Chrome) las únicas voces son
`es-MX` y `en-GB`: sin voz alemana, `setLanguage('de-DE')` no tiene efecto y el texto
alemán se pronuncia con la voz española por defecto (verificado listando
`speechSynthesis.getVoices()`). En el teléfono funciona porque Android trae voz alemana.
Ningún cambio de código sobre flutter_tts puede crear una voz que el sistema no tiene.

## Decision

En **web**, sintetizar con **Piper** (`@mintplex-labs/piper-tts-web` 1.0.5, MIT) y la voz
`de_DE-thorsten-medium`, ejecutado en WASM dentro del navegador. En móvil/escritorio nativo
se mantiene `flutter_tts`.

- El paquete se **vendorea** en `web/piper/` (3 archivos JS, ~330 KB) para fijar la versión;
  `web/piper_bridge.js` expone `window.sprachheldSpeakDe(text)`, que Dart invoca con
  `dart:js_interop` (import condicional: `german_voice_web.dart` / `german_voice_stub.dart`).
- Un import map en `web/index.html` resuelve el import `onnxruntime-web/wasm` del paquete
  hacia jsDelivr (build ESM de onnxruntime-web 1.18.0).
- En runtime el navegador descarga: onnxruntime wasm (cdnjs), phonemizer (jsDelivr) y el
  modelo (~63 MB, Hugging Face); el modelo queda cacheado en el origin private file system.
- `AudioButton` avisa mientras carga ("Preparando la voz alemana…") y muestra un mensaje si
  la síntesis falla, en vez de fallar en silencio.

## Considered alternatives

- **Instalar la voz alemana en Windows / usar Edge** — cero código, pero depende de cada
  dispositivo y del usuario; no resuelve "la web habla alemán" de forma portable. Se
  mantiene como alternativa manual.
- **meSpeak.js (eSpeak)** — ~1 MB y sin descarga grande, pero voz robótica; mala para
  aprender pronunciación.
- **TTS en la nube (Azure/Google/ElevenLabs)** — requiere backend o claves y red; choca con
  "sin backend" (ADR 0001 ya relajó eso solo para el ranking).
- **Audio pregrabado por palabra** — miles de verbos/sustantivos; inviable en tamaño.

## Consequences

- **Positive**: pronunciación alemana consistente en cualquier navegador, sin depender de
  voces del sistema; funciona igual en Windows/Mac/Linux.
- **Negative**: primera pronunciación descarga ~63 MB (luego cacheado) y tarda unos
  segundos; la síntesis usa CPU (WASM); dependencias de CDN en runtime (cdnjs, jsDelivr,
  Hugging Face) — sin red a esos hosts no hay audio en web; dependencia nueva vendoreada.
- **Neutral**: móvil no cambia.

## Migration notes

- Si se quiere funcionamiento offline en web: alojar el modelo, los wasm y el phonemizer
  dentro del propio despliegue (el paquete permite `wasmPaths` propios) y quitar los CDN.
- Si Piper deja de servir: volver a `flutter_tts` en web es borrar la rama `kIsWeb` de
  `speak_service.dart`.
