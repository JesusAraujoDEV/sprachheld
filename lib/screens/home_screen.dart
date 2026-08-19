import 'package:flutter/material.dart';

import '../modes/timed_arcade_screen.dart';
import '../state/config_notifier.dart';
import '../state/progress_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_background.dart';
import '../widgets/mode_card.dart';
import '../widgets/player_name_tile.dart';
import '../widgets/stat_chip.dart';
import 'home/lookup_list.dart';
import 'home/practice_grid.dart';

/// Home: modo destacado (Contrarreloj) → grid "Practicar" → lista "Consulta
/// y progreso" → ajustes. Reordenado para que 6 modos de práctica + 3 de
/// consulta no se sientan como una lista sin jerarquía (docs/PLAN-hora.md §7).
class HomeScreen extends StatelessWidget {
  final ConfigNotifier config;
  final ProgressNotifier progress;

  const HomeScreen({required this.config, required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🦸 Sprachheld',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  'Practica alemán',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: kOnSurfaceVariant),
                ),
                const SizedBox(height: 20),
                ListenableBuilder(listenable: progress, builder: (context, _) => _buildStats(context)),
                const SizedBox(height: 24),
                ModeCard(
                  title: 'Contrarreloj',
                  subtitle: '60 segundos, racha y puntos',
                  accent: kError,
                  onTap: () => _push(context, TimedArcadeScreen(progress: progress)),
                ),
                const SizedBox(height: 24),
                _sectionHeader(context, 'Practicar'),
                const SizedBox(height: 12),
                PracticeGrid(progress: progress),
                const SizedBox(height: 24),
                _sectionHeader(context, 'Consulta y progreso'),
                const SizedBox(height: 12),
                LookupList(progress: progress),
                const SizedBox(height: 32),
                ListenableBuilder(
                  listenable: config,
                  builder: (context, _) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: config.ttsEnabled,
                    onChanged: config.setTtsEnabled,
                    title: const Text('Pronunciación (TTS)'),
                    activeThumbColor: kPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const PlayerNameTile(),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Desarrollado por Jesús Araujo',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: kOnSurfaceVariant.withValues(alpha: 0.6),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: kOnSurfaceVariant),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kSurfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOutline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StatChip(icon: '🔥', label: '${progress.streakDays} días'),
          StatChip(icon: '⭐', label: '${progress.xp} XP'),
          StatChip(icon: '✅', label: '${progress.masteredCount} dominados'),
          StatChip(icon: '📌', label: '${progress.weakCount} débiles'),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
