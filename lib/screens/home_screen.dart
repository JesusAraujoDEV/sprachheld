import 'package:flutter/material.dart';

import '../modes/conjugation_table_screen.dart';
import '../modes/fill_phrase_screen.dart';
import '../modes/gender_quiz_screen.dart';
import '../modes/gender_tips_screen.dart';
import '../modes/preposition_double_screen.dart';
import '../modes/timed_arcade_screen.dart';
import '../modes/verb_quiz_screen.dart';
import '../modes/write_conjugation_screen.dart';
import '../state/config_notifier.dart';
import '../state/progress_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/aura_background.dart';

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
                _ModeCard(
                  title: 'Verbos',
                  subtitle: 'Elegí la traducción correcta',
                  accent: kPrimary,
                  onTap: () => _pickVerbDeck(context),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  title: 'der / die / das',
                  subtitle: 'Elegí el artículo correcto',
                  accent: kGenderDas,
                  onTap: () => _push(context, GenderQuizScreen(progress: progress)),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  title: 'Escribir conjugación',
                  subtitle: 'Infinitivo · persona · tiempo → escribí la forma',
                  accent: kSecondary,
                  onTap: () => _push(context, WriteConjugationScreen(progress: progress)),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  title: 'Completar la frase',
                  subtitle: 'Oración con hueco + opciones',
                  accent: kGenderDer,
                  onTap: () => _push(context, FillPhraseScreen(progress: progress)),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  title: 'Preposiciones de lugar',
                  subtitle: 'in / an / auf + el caso correcto',
                  accent: kGenderDer,
                  onTap: () => _pickPrepositionLevel(context),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  title: 'Contrarreloj',
                  subtitle: '60 segundos, racha y puntos',
                  accent: kError,
                  onTap: () => _push(context, TimedArcadeScreen(progress: progress)),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  title: 'Tabla de conjugación',
                  subtitle: 'Buscá un verbo y mirá sus formas',
                  accent: kSecondary,
                  onTap: () => _push(context, const ConjugationTableScreen()),
                ),
                const SizedBox(height: 16),
                _ModeCard(
                  title: 'Tips: der/die/das',
                  subtitle: 'Reglas de género, una por una',
                  accent: kGenderDie,
                  onTap: () => _push(context, GenderTipsScreen(progress: progress)),
                ),
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

  void _pickVerbDeck(BuildContext context) {
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
                        _push(
                          context,
                          VerbQuizScreen(progress: progress, maxRank: option.maxRank),
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

  void _pickPrepositionLevel(BuildContext context) {
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
                      _push(
                        context,
                        FillPhraseScreen(
                          progress: progress,
                          asset: 'assets/data/preposition-phrases.json',
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
                    _push(context, PrepositionDoubleScreen(progress: progress));
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
          _StatChip(icon: '🔥', label: '${progress.streakDays} días'),
          _StatChip(icon: '⭐', label: '${progress.xp} XP'),
          _StatChip(icon: '✅', label: '${progress.masteredCount} dominados'),
          _StatChip(icon: '📌', label: '${progress.weakCount} débiles'),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kSurfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kOutline),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: -8,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 40,
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(6)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kOnSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
