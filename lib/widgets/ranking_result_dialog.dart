import 'package:flutter/material.dart';

import '../services/score_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Diálogo de fin de ronda con opción de subir el resultado al ranking
/// (aciertos/total). Compartido por los modos que no son arcade — el arcade
/// tiene su propio diálogo con puntaje y combo. [onClose] cierra la pantalla.
///
/// Usa el nombre guardado en StorageService. Si el usuario aún no tiene nombre,
/// muestra el campo para ingresarlo y lo persiste para futuros quizzes.
Future<void> showRankingResult({
  required BuildContext context,
  required String mode,
  required int correct,
  required int total,
  required VoidCallback onClose,
}) async {
  final storage = await StorageService.create();
  final savedName = storage.playerName;
  final nameController = TextEditingController(text: savedName ?? '');
  var submitState = 'idle'; // idle | sending | done | failed

  if (!context.mounted) return;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        Future<void> submit() async {
          final name = nameController.text.trim();
          setDialogState(() => submitState = 'sending');
          // Persist the name for future quizzes.
          if (name.isNotEmpty) await storage.setPlayerName(name);
          final ok = await ScoreService.submit(
            mode: mode,
            score: correct, // ordena el ranking por aciertos
            correct: correct,
            total: total,
            name: name.isEmpty ? null : name,
          );
          setDialogState(() => submitState = ok ? 'done' : 'failed');
        }

        final hasName = savedName != null && savedName.isNotEmpty;

        return AlertDialog(
          backgroundColor: kSurfaceContainer,
          title: const Text('¡Ronda terminada!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Acertaste $correct de $total.'),
              const SizedBox(height: 16),
              if (submitState == 'idle') ...[
                if (hasName)
                  Text('Nombre: $savedName',
                      style: const TextStyle(color: kOnSurfaceVariant))
                else
                  TextField(
                    controller: nameController,
                    maxLength: 24,
                    decoration: const InputDecoration(
                      labelText: 'Tu nombre (opcional)',
                      counterText: '',
                    ),
                  ),
              ] else if (submitState == 'sending')
                const Text('Subiendo…',
                    style: TextStyle(color: kOnSurfaceVariant))
              else if (submitState == 'done')
                const Text('¡Subido al ranking! 🎉',
                    style: TextStyle(color: kGenderDas))
              else
                const Text('No se pudo subir (sin conexión).',
                    style: TextStyle(color: kError)),
            ],
          ),
          actions: [
            if (submitState == 'idle')
              TextButton(
                  onPressed: submit, child: const Text('Subir al ranking')),
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
