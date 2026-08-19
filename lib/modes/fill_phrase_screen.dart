import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../engine/question.dart';
import '../engine/session.dart';
import '../models/phrase.dart';
import '../state/progress_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_button.dart';
import '../widgets/option_chip.dart';
import '../widgets/quiz_shell.dart';

/// "Completar la frase": oración con hueco + chips de opción. docs/PLAN.md §6.3.
///
/// [asset] elige el banco de frases: el genérico por defecto, o el de
/// preposiciones de lugar (Nivel 1, docs/PLAN-preposiciones.md §4.1). El
/// mismo motor y UI sirven para ambos — solo cambia el JSON.
class FillPhraseScreen extends StatefulWidget {
  final ProgressNotifier progress;
  final String asset;

  const FillPhraseScreen({
    required this.progress,
    this.asset = 'assets/data/phrases.json',
    super.key,
  });

  @override
  State<FillPhraseScreen> createState() => _FillPhraseScreenState();
}

class _FillPhraseScreenState extends State<FillPhraseScreen> {
  List<Question>? _session;
  int _index = 0;
  int _correct = 0;
  String? _chosen;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final phrases = await DataRepository.loadPhrases(widget.asset);
    final questions = [
      for (final p in phrases)
        Question(id: p.id, mode: QuizMode.fillPhrase, prompt: p, answer: p.answer),
    ];
    final session = buildSession(
      questions,
      SessionOptions(size: questions.length, srs: widget.progress.states),
    );
    if (mounted) setState(() => _session = session);
  }

  Phrase get _current => _session![_index].prompt as Phrase;

  void _choose(String option) {
    if (_chosen != null) return;
    final correct = option == _current.answer;
    widget.progress.record(_session![_index].id, correct: correct);
    if (correct) _correct++;
    setState(() => _chosen = option);
  }

  void _next() {
    final session = _session!;
    if (_index + 1 >= session.length) {
      widget.progress.recordSessionComplete();
      _showResults(session.length);
      return;
    }
    setState(() {
      _index++;
      _chosen = null;
    });
  }

  void _showResults(int total) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kSurfaceContainer,
        title: const Text('¡Ronda terminada!'),
        content: Text('Acertaste $_correct de $total.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final phrase = _current;
    final gapText = _chosen == null ? '___' : phrase.answer;
    final sentence = phrase.sentence.replaceFirst('___', gapText);

    return Scaffold(
      body: QuizShell(
        index: _index,
        total: session.length,
        onClose: () => Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      sentence,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _chosen == null
                                ? kOnSurface
                                : (_chosen == phrase.answer ? kGenderDas : kError),
                          ),
                    ),
                  ),
                  // Siempre pronuncia la frase completa y correcta (con el
                  // hueco resuelto), sin importar si ya se contestó.
                  AudioButton(text: phrase.sentence.replaceFirst('___', phrase.answer)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                phrase.es,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: kOnSurfaceVariant),
              ),
              if (_chosen != null && phrase.note != null) ...[
                const SizedBox(height: 16),
                Text(
                  phrase.note!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
              const Spacer(),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final option in phrase.options)
                    OptionChip(
                      label: option,
                      chosen: _chosen,
                      correctValue: phrase.answer,
                      onTap: () => _choose(option),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (_chosen != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: _next, child: const Text('Siguiente')),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

