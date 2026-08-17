import 'package:flutter/material.dart';

import '../services/speak_service.dart';
import '../theme/app_theme.dart';

/// Botón de pronunciación. Misma posición en todos los modos (esquina
/// superior derecha de la carta) — memoria muscular (docs/PLAN.md §5).
class AudioButton extends StatelessWidget {
  final String text;

  const AudioButton({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.volume_up_rounded),
      color: kOnSurfaceVariant,
      tooltip: 'Escuchar pronunciación',
      onPressed: () => SpeakService.instance.speak(text),
    );
  }
}
