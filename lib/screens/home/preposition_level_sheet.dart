import 'package:flutter/material.dart';

import '../../modes/fill_phrase_screen.dart';
import '../../modes/preposition_double_screen.dart';
import '../../state/progress_notifier.dart';
import '../../theme/app_theme.dart';

/// Bottom sheet "¿Qué querés practicar?" (Nivel 1 / Nivel 2 de preposiciones),
/// invocado desde el tile "Preposiciones" del Home.
void showPrepositionLevelSheet(BuildContext context, ProgressNotifier progress) {
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
            Text('¿Qué querés practicar?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Empezá por la preposición; después sumá el artículo',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FillPhraseScreen(
                          progress: progress,
                          asset: 'assets/data/preposition-phrases.json',
                        ),
                      ),
                    );
                  },
                  child: const Text('Solo la preposición'),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PrepositionDoubleScreen(progress: progress)),
                  );
                },
                child: const Text('Preposición + artículo'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
