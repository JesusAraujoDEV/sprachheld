import 'package:flutter/material.dart';

import 'audio_button.dart';
import '../theme/app_theme.dart';

/// Superficie compartida de las caras de carta (Flashcard, Quiz de género):
/// glow difuso del color semántico + botón de audio fijo arriba-derecha.
/// docs/PLAN.md §8.
class GlowCardFace extends StatelessWidget {
  final Widget child;
  final Color accent;
  final String audioText;

  const GlowCardFace({
    required this.child,
    required this.accent,
    required this.audioText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurfaceContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kOutline),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.4),
            blurRadius: 60,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(alignment: Alignment.topRight, child: AudioButton(text: audioText)),
          Center(child: child),
        ],
      ),
    );
  }
}
