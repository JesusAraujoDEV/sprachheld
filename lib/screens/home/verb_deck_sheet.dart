import 'package:flutter/material.dart';

import '../../models/verb_direction.dart';
import '../../modes/verb_quiz_screen.dart';
import '../../state/progress_notifier.dart';
import '../../theme/app_theme.dart';
import '../../theme/breakpoints.dart';
import 'verb_deck/direction_option_card.dart';

const _rankOptions = [
  (label: 'Top 100', maxRank: 100),
  (label: 'Top 500', maxRank: 500),
  (label: 'Top 1000', maxRank: 1000),
  (label: 'Todos', maxRank: null),
];

const _directionOptions = [
  (
    value: VerbDirection.deToEs,
    emoji: '🇩🇪',
    title: 'Verbo en alemán y opciones en español',
    example: 'gehen · ir, caminar, andar',
  ),
  (
    value: VerbDirection.esToDe,
    emoji: '🇪🇸',
    title: 'Verbo en español y opciones en alemán',
    example: 'ir · gehen, fahren, laufen',
  ),
  (
    value: VerbDirection.mixed,
    emoji: '🔀',
    title: 'Ambas, mezcladas',
    example: 'Alterna entre los dos sentidos',
  ),
];

/// Bottom sheet "¿Qué verbos practicás?" invocado desde el tile "Verbos" del
/// Home. Dos pasos: 1) rango (Top 100/500/1000/Todos), 2) dirección del quiz.
void showVerbDeckSheet(BuildContext context, ProgressNotifier progress) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: kSurfaceContainer,
    constraints: const BoxConstraints(maxWidth: kModalMaxWidth),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      int? chosenMaxRank;
      var pickingDirection = false;

      void openQuiz(VerbDirection direction) {
        Navigator.of(sheetContext).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VerbQuizScreen(progress: progress, maxRank: chosenMaxRank, direction: direction),
          ),
        );
      }

      return StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pickingDirection
                  ? [
                      Text('¿Qué preferís?', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Cómo se muestran la pregunta y las opciones',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 16),
                      for (final option in _directionOptions)
                        DirectionOptionCard(
                          emoji: option.emoji,
                          title: option.title,
                          example: option.example,
                          onTap: () => openQuiz(option.value),
                        ),
                    ]
                  : [
                      Text('¿Qué verbos practicás?', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Según qué tan usados son en alemán real',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 20),
                      for (final option in _rankOptions)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => setSheetState(() {
                                chosenMaxRank = option.maxRank;
                                pickingDirection = true;
                              }),
                              child: Text(option.label),
                            ),
                          ),
                        ),
                    ],
            ),
          ),
        ),
      );
    },
  );
}
