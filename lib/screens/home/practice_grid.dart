import 'package:flutter/material.dart';

import '../../modes/clock_quiz_screen.dart';
import '../../modes/fill_phrase_screen.dart';
import '../../modes/gender_quiz_screen.dart';
import '../../modes/write_conjugation_screen.dart';
import '../../state/progress_notifier.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mode_tile.dart';
import 'preposition_level_sheet.dart';
import 'verb_deck_sheet.dart';

/// Grid 2 columnas de los 6 modos de práctica del mismo peso funcional
/// (docs/PLAN-hora.md §7).
class PracticeGrid extends StatelessWidget {
  final ProgressNotifier progress;

  const PracticeGrid({required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      (
        title: 'Verbos',
        icon: Icons.translate_rounded,
        accent: kPrimary,
        onTap: () => showVerbDeckSheet(context, progress),
      ),
      (
        title: 'der / die / das',
        icon: Icons.label_outline_rounded,
        accent: kGenderDas,
        onTap: () => _push(context, GenderQuizScreen(progress: progress)),
      ),
      (
        title: 'Escribir conjugación',
        icon: Icons.edit_note_rounded,
        accent: kSecondary,
        onTap: () => _push(context, WriteConjugationScreen(progress: progress)),
      ),
      (
        title: 'Completar la frase',
        icon: Icons.short_text_rounded,
        accent: kGenderDer,
        onTap: () => _push(context, FillPhraseScreen(progress: progress)),
      ),
      (
        title: 'Preposiciones',
        icon: Icons.pin_drop_outlined,
        accent: kGenderDer,
        onTap: () => showPrepositionLevelSheet(context, progress),
      ),
      (
        title: 'La Hora',
        icon: Icons.access_time_rounded,
        accent: kSecondary,
        onTap: () => _push(context, ClockQuizScreen(progress: progress)),
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        for (final tile in tiles)
          ModeTile(title: tile.title, icon: tile.icon, accent: tile.accent, onTap: tile.onTap),
      ],
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
