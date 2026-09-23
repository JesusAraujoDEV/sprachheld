import 'package:flutter/material.dart';

import '../services/speak_service.dart';
import '../theme/app_theme.dart';

/// Botón de pronunciación. Misma posición en todos los modos (esquina
/// superior derecha de la carta) — memoria muscular (docs/PLAN.md §5).
class AudioButton extends StatelessWidget {
  final String text;

  const AudioButton({required this.text, super.key});

  Future<void> _speak(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final service = SpeakService.instance;
    if (service.needsWarmup) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Preparando la voz alemana… la primera vez descarga ~63 MB'),
        duration: Duration(minutes: 2),
      ));
    }
    try {
      await service.speak(text);
      messenger.hideCurrentSnackBar();
    } catch (e) {
      debugPrint('TTS falló: $e');
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('No se pudo reproducir el audio')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.volume_up_rounded),
      color: kOnSurfaceVariant,
      tooltip: 'Escuchar pronunciación',
      onPressed: () => _speak(context),
    );
  }
}
