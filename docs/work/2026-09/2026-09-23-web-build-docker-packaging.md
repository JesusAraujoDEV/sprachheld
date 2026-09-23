# 2026-09-23 — Empaquetado web (Docker + nginx) para deploy en Dokploy

## What changed
Se empaquetó la versión web de Sprachheld para desplegarla en un panel
Dokploy: `Dockerfile` multi-stage (compila Flutter web y lo sirve con nginx),
`nginx.conf` y `.dockerignore`. Además la app se centra en una columna de
600 px máx. en pantallas anchas.

## Why
El usuario quiere usar la app también desde el navegador, solo para uso
personal. El proyecto ya era Flutter con carpeta `web/` y sin `dart:io`, así
que no hacía falta otro repo: bastaba publicar el build web.

## How
- `Dockerfile`: etapa `ghcr.io/cirruslabs/flutter:stable` corre
  `flutter build web --release`; etapa final `nginx:alpine` sirve `build/web`
  en el puerto 80.
- `nginx.conf`: gzip para los JSON grandes (`verbs.json` ≈ 4.3 MB) y fallback
  a `index.html`.
- `lib/main.dart`: `MaterialApp.builder` con `ColoredBox` + `ConstrainedBox`
  de 600 px (`ponytail:` ancho fijo, sin breakpoints).
- Se verificó `flutter build web --release` y `flutter analyze` limpios. El
  deploy en Dokploy lo ejecutó el agente Estibador aparte; su resultado no
  forma parte de esta entrada.

## Promoted knowledge
None — es empaquetado puntual; el hecho de que la web es el mismo código
Flutter ya está en `AGENTS.md` (Stack).

## Follow-ups
- [ ] Confirmar que el deploy en Dokploy quedó arriba y probar que el ranking
      (Supabase) y el TTS funcionan en el navegador.
- [ ] El progreso es local por navegador: la web y el teléfono no comparten
      avance (sin backend de sincronización).
