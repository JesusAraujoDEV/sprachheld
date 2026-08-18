import 'package:flutter/material.dart';

import '../models/noun.dart';

/// Tokens visuales "aura" (docs/PLAN.md §8) aterrizados a Flutter por
/// visual-identity. Dark-first: fondo casi-negro con glow difuso detrás de
/// tarjetas/botones, nunca colores planos de UI genérica.
const kBackground = Color(0xFF0B0B14);
const kSurface = Color(0xFF14101F);
const kSurfaceContainer = Color(0xFF1C1730);
const kOnSurface = Color(0xFFF5F3FF);
const kOnSurfaceVariant = Color(0xFFB8B3C7);

const kPrimary = Color(0xFF8B5CF6);
const kOnPrimary = Color(0xFF0B0B14);
const kPrimaryContainer = Color(0xFF2D2350);
const kOnPrimaryContainer = Color(0xFFD9C9FF);

const kSecondary = Color(0xFFA78BFA);
const kOnSecondary = Color(0xFF0B0B14);

const kError = Color(0xFFF59E0B); // ámbar — nunca el rojo semántico de "die"
const kOnError = Color(0xFF0B0B14);

const kOutline = Color(0x14FFFFFF);
const kOutlineVariant = Color(0x0AFFFFFF);

/// Paleta semántica der/die/das — no son roles Material, van aparte.
const kGenderDer = Color(0xFF3B82F6);
const kGenderDie = Color(0xFFF43F5E);
const kGenderDas = Color(0xFF10B981);

Color colorForGender(Gender gender) => switch (gender) {
      Gender.der => kGenderDer,
      Gender.die => kGenderDie,
      Gender.das => kGenderDas,
    };

ThemeData buildAppTheme() {
  final textTheme = TextTheme(
    displayLarge: const TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: kOnSurface,
    ),
    headlineSmall: const TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: kOnSurface,
    ),
    bodyLarge: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: kOnSurface),
    labelSmall: const TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: kOnSurfaceVariant,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBackground,
    textTheme: textTheme,
    colorScheme: const ColorScheme.dark(
      surface: kSurface,
      onSurface: kOnSurface,
      onSurfaceVariant: kOnSurfaceVariant,
      primary: kPrimary,
      onPrimary: kOnPrimary,
      primaryContainer: kPrimaryContainer,
      onPrimaryContainer: kOnPrimaryContainer,
      secondary: kSecondary,
      onSecondary: kOnSecondary,
      error: kError,
      onError: kOnError,
      outline: kOutline,
      outlineVariant: kOutlineVariant,
    ),
  );
}
