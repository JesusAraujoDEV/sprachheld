import 'package:flutter/material.dart';

import '../../modes/conjugation_table_screen.dart';
import '../../modes/gender_tips_screen.dart';
import '../../state/progress_notifier.dart';
import '../../theme/app_theme.dart';
import '../leaderboard_screen.dart';

/// Lista compacta de "consulta y progreso": ranking, tabla de conjugación y
/// tips — son "mirar/buscar", no "jugar" (docs/PLAN-hora.md §7).
class LookupList extends StatelessWidget {
  final ProgressNotifier progress;

  const LookupList({required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        title: 'Ranking',
        subtitle: 'Los mejores puntajes de cada modo',
        icon: Icons.leaderboard_outlined,
        onTap: () => _push(context, const LeaderboardScreen()),
      ),
      (
        title: 'Tabla de conjugación',
        subtitle: 'Buscá un verbo y mirá sus formas',
        icon: Icons.table_rows_outlined,
        onTap: () => _push(context, const ConjugationTableScreen()),
      ),
      (
        title: 'Tips: der/die/das',
        subtitle: 'Reglas de género, una por una',
        icon: Icons.lightbulb_outline_rounded,
        onTap: () => _push(context, GenderTipsScreen(progress: progress)),
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        children: [
          for (final row in rows) ...[
            if (row != rows.first) const Divider(height: 1, color: kOutlineVariant),
            ListTile(
              leading: Icon(row.icon, color: kOnSurfaceVariant),
              title: Text(row.title),
              subtitle: Text(row.subtitle, style: Theme.of(context).textTheme.labelSmall),
              trailing: const Icon(Icons.chevron_right_rounded, color: kOnSurfaceVariant),
              onTap: row.onTap,
            ),
          ],
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
