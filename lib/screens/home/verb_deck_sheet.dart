import 'package:flutter/material.dart';

import '../../modes/verb_quiz_screen.dart';
import '../../state/progress_notifier.dart';
import '../../theme/app_theme.dart';

/// Bottom sheet "¿Qué verbos practicás?" (Top 100/500/1000/Todos), invocado
/// desde el tile "Verbos" del Home.
void showVerbDeckSheet(BuildContext context, ProgressNotifier progress) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: kSurfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Qué verbos practicás?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Según qué tan usados son en alemán real',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 20),
            for (final option in const [
              (label: 'Top 100', maxRank: 100),
              (label: 'Top 500', maxRank: 500),
              (label: 'Top 1000', maxRank: 1000),
              (label: 'Todos', maxRank: null),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VerbQuizScreen(progress: progress, maxRank: option.maxRank),
                        ),
                      );
                    },
                    child: Text(option.label),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
