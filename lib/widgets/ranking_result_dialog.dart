import 'package:flutter/material.dart';

import '../services/score_service.dart';
import '../theme/app_theme.dart';

/// Diálogo de fin de ronda con opción de subir el resultado al ranking
/// (aciertos/total). Compartido por los modos que no son arcade — el arcade
/// tiene su propio diálogo con puntaje y combo. [onClose] cierra la pantalla.
Future<void> showRankingResult({
  required BuildContext context,
  required String mode,
  required int correct,
  required int total,
  required VoidCallback onClose,
}) {
  final nameController = TextEditingController();
  var submitState = 'idle'; // idle | sending | done | failed

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        Future<void> submit() async {
          setDialogState(() => submitState = 'sending');
          final ok = await ScoreService.submit(
            mode: mode,
            score: correct, // ordena el ranking por aciertos
            correct: correct,
            total: total,
            name: nameController.text,
          );
          setDialogState(() => submitState = ok ? 'done' : 'failed');
        }

        return AlertDialog(
          backgroundColor: kSurfaceContainer,
          title: const Text('¡Ronda terminada!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Acertaste $correct de $total.'),
              const SizedBox(height: 16),
              if (submitState == 'idle')
                TextField(
                  controller: nameController,
                  maxLength: 24,
                  decoration: const InputDecoration(
                    labelText: 'Tu nombre (opcional)',
                    counterText: '',
                  ),
                )
              else if (submitState == 'sending')
                const Text('Subiendo…', style: TextStyle(color: kOnSurfaceVariant))
              else if (submitState == 'done')
                const Text('¡Subido al ranking! 🎉', style: TextStyle(color: kGenderDas))
              else
                const Text('No se pudo subir (sin conexión).', style: TextStyle(color: kError)),
            ],
          ),
          actions: [
            if (submitState == 'idle')
              TextButton(onPressed: submit, child: const Text('Subir al ranking')),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onClose();
              },
              child: const Text('Volver'),
            ),
          ],
        );
      },
    ),
  );
}
