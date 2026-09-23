import 'package:flutter/material.dart';

import '../../modes/fill_phrase_screen.dart';
import '../../modes/preposition_double_screen.dart';
import '../../state/progress_notifier.dart';
import '../../theme/app_theme.dart';
import '../../theme/breakpoints.dart';

/// Bottom sheet "¿Qué querés practicar?" (Nivel 1 / Nivel 2 de preposiciones),
/// invocado desde el tile "Preposiciones" del Home.
void showPrepositionLevelSheet(BuildContext context, ProgressNotifier progress) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: kSurfaceContainer,
    constraints: const BoxConstraints(maxWidth: kModalMaxWidth),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      String? caseFilter; // null = Ambos (no filtering)
      return StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
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
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final entry in const [
                      (value: 'dativ', label: 'Dativ'),
                      (value: 'akkusativ', label: 'Akkusativ'),
                      (value: null, label: 'Ambos'),
                    ])
                      ChoiceChip(
                        label: Text(entry.label),
                        selected: caseFilter == entry.value,
                        selectedColor: kPrimary.withValues(alpha: 0.22),
                        onSelected: (_) => setSheetState(() => caseFilter = entry.value),
                      ),
                  ],
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
                              caseFilter: caseFilter,
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
                        MaterialPageRoute(
                          builder: (_) => PrepositionDoubleScreen(progress: progress),
                        ),
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
    },
  );
}
