import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../engine/question.dart';
import '../engine/session.dart';
import '../models/preposition_item.dart';
import '../state/progress_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_button.dart';
import '../widgets/option_chip.dart';
import '../widgets/quiz_shell.dart';

/// Nivel 2 del modo preposiciones (docs/PLAN-preposiciones.md §4.2): dos filas
/// de chips en secuencia. Primero la preposición; al contestarla se revela el
/// artículo. Enseña la cadena preposición → caso → artículo en una sola
/// pantalla. Cuenta como acierto en SRS solo si ambas filas son correctas.
class PrepositionDoubleScreen extends StatefulWidget {
  final ProgressNotifier progress;

  const PrepositionDoubleScreen({required this.progress, super.key});

  @override
  State<PrepositionDoubleScreen> createState() => _PrepositionDoubleScreenState();
}

class _PrepositionDoubleScreenState extends State<PrepositionDoubleScreen> {
  List<Question>? _session;
  int _index = 0;
  int _correct = 0;
  String? _chosenPrep;
  String? _chosenArticle;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DataRepository.loadPrepositionItems();
    final questions = [
      for (final it in items)
        Question(id: it.id, mode: QuizMode.fillPhrase, prompt: it, answer: it.prep),
    ];
    final session = buildSession(
      questions,
      SessionOptions(size: 12, srs: widget.progress.states),
    );
    if (mounted) setState(() => _session = session);
  }

  PrepositionItem get _current => _session![_index].prompt as PrepositionItem;
  bool get _done => _chosenPrep != null && _chosenArticle != null;

  void _choosePrep(String option) {
    if (_chosenPrep != null) return;
    setState(() => _chosenPrep = option);
  }

  void _chooseArticle(String option) {
    if (_chosenArticle != null) return;
    final item = _current;
    final bothCorrect = _chosenPrep == item.prep && option == item.article;
    widget.progress.record(_current.id, correct: bothCorrect);
    if (bothCorrect) _correct++;
    setState(() => _chosenArticle = option);
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
      _chosenPrep = null;
      _chosenArticle = null;
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

  /// Frase con los dos huecos rellenados progresivamente, siempre con las
  /// respuestas CORRECTAS (aunque el usuario haya errado la preposición, la
  /// fila del artículo se arma sobre la preposición correcta).
  String _renderSentence(PrepositionItem item) {
    final prepFill = _chosenPrep == null ? '___' : item.prep;
    final articleFill = _chosenArticle == null ? '___' : item.article;
    return item.sentence.replaceFirst('___', prepFill).replaceFirst('___', articleFill);
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final item = _current;
    final correctSentence =
        item.sentence.replaceFirst('___', item.prep).replaceFirst('___', item.article);
    final sentenceColor = !_done
        ? kOnSurface
        : (_chosenPrep == item.prep && _chosenArticle == item.article ? kGenderDas : kError);

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
                      _renderSentence(item),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: sentenceColor),
                    ),
                  ),
                  AudioButton(text: correctSentence),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.es,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: kOnSurfaceVariant),
              ),
              if (_done) ...[
                const SizedBox(height: 16),
                Text(
                  item.note,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
              const Spacer(),
              _rowLabel('Preposición'),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final option in item.prepOptions)
                    OptionChip(
                      label: option,
                      chosen: _chosenPrep,
                      correctValue: item.prep,
                      onTap: () => _choosePrep(option),
                    ),
                ],
              ),
              if (_chosenPrep != null) ...[
                const SizedBox(height: 20),
                _rowLabel('Artículo'),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final option in item.articleOptions)
                      OptionChip(
                        label: option,
                        chosen: _chosenArticle,
                        correctValue: item.article,
                        onTap: () => _chooseArticle(option),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              if (_done)
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

  Widget _rowLabel(String text) => Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: kOnSurfaceVariant),
      );
}
