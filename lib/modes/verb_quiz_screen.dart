import 'dart:math';

import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../engine/question.dart';
import '../engine/srs.dart';
import '../models/verb.dart';
import '../state/progress_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/glow_card_face.dart';
import '../widgets/quiz_shell.dart';
import '../widgets/ranking_result_dialog.dart';

const _sessionSize = 12;

enum _Direction { deToEs, esToDe }

/// Quiz de opción múltiple bidireccional (diseño de ux-architect): a veces
/// alemán→español, a veces español→alemán, mezclado en la sesión. Reemplaza
/// el flip-card de verbos — el usuario pidió específicamente este formato.
class _VerbQuizItem {
  final Verb verb;
  final _Direction direction;
  final List<String> options;
  final String correct;

  const _VerbQuizItem({
    required this.verb,
    required this.direction,
    required this.options,
    required this.correct,
  });

  String get prompt => direction == _Direction.deToEs ? verb.infinitiv : verb.es;
}

class VerbQuizScreen extends StatefulWidget {
  final ProgressNotifier progress;

  /// Si viene, limita el mazo a los N verbos más usados (Top 100/500/1000
  /// del selector en Home). Null = todos.
  final int? maxRank;

  const VerbQuizScreen({required this.progress, this.maxRank, super.key});

  @override
  State<VerbQuizScreen> createState() => _VerbQuizScreenState();
}

class _VerbQuizScreenState extends State<VerbQuizScreen> {
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
    final allVerbs = await DataRepository.loadVerbs();
    final maxRank = widget.maxRank;
    final pool = maxRank == null
        ? allVerbs
        : allVerbs.where((v) => v.frequencyRank != null && v.frequencyRank! <= maxRank).toList();

    // Prioriza/selecciona sobre Verb (barato) ANTES de armar preguntas con
    // distractores — antes se construía una Question completa (con su
    // búsqueda de distractores) para cada verbo del mazo entero y recién
    // después se recortaba a 12, o sea O(n²) sobre miles de verbos. Ahora
    // el filtrado es O(n) y los distractores se calculan solo para los
    // ~12 elegidos.
    final rnd = Random();
    final shuffled = List<Verb>.from(pool)..shuffle(rnd);
    final now = DateTime.now();
    final due = <Verb>[];
    final fresh = <Verb>[];
    final notDue = <Verb>[];
    for (final v in shuffled) {
      final state = widget.progress.states[v.id];
      if (state == null) {
        fresh.add(v);
      } else if (Srs.isDue(state, now)) {
        due.add(v);
      } else {
        notDue.add(v);
      }
    }
    final selected = [...due, ...fresh, ...notDue].take(_sessionSize).toList();

    final questions = <Question>[
      for (final v in selected) _buildQuestion(v, pool, rnd),
    ];
    if (mounted) setState(() => _session = questions);
  }

  Question _buildQuestion(Verb v, List<Verb> deck, Random rnd) {
    final direction = rnd.nextBool() ? _Direction.deToEs : _Direction.esToDe;
    String valueOf(Verb x) => direction == _Direction.deToEs ? x.es : x.infinitiv;
    final correct = valueOf(v);

    var pool = deck
        .where((x) => x.level == v.level && x.id != v.id && valueOf(x) != correct)
        .toList();
    if (pool.length < 3) {
      pool = deck.where((x) => x.id != v.id && valueOf(x) != correct).toList();
    }
    pool.shuffle(rnd);
    final options = [correct, ...pool.take(3).map(valueOf)]..shuffle(rnd);

    return Question(
      id: v.id,
      mode: QuizMode.flashcard,
      prompt: _VerbQuizItem(verb: v, direction: direction, options: options, correct: correct),
      answer: correct,
    );
  }

  _VerbQuizItem get _current => _session![_index].prompt as _VerbQuizItem;

  void _choose(String option) {
    if (_chosen != null) return;
    final correct = option == _current.correct;
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
    showRankingResult(
      context: context,
      mode: 'verbs',
      correct: _correct,
      total: total,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final item = _current;
    return Scaffold(
      body: QuizShell(
        index: _index,
        total: session.length,
        onClose: () => Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                width: double.infinity,
                child: GlowCardFace(
                  accent: kPrimary,
                  audioText: item.verb.infinitiv,
                  child: Text(
                    item.prompt,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    for (final option in item.options)
                      _VerbOptionButton(
                        label: option,
                        chosen: _chosen,
                        correctValue: item.correct,
                        onTap: () => _choose(option),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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

class _VerbOptionButton extends StatelessWidget {
  final String label;
  final String? chosen;
  final String correctValue;
  final VoidCallback onTap;

  const _VerbOptionButton({
    required this.label,
    required this.chosen,
    required this.correctValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final answered = chosen != null;
    final isCorrect = label == correctValue;
    final isChosen = label == chosen;

    var background = kSurfaceContainer;
    var border = kOutline;
    if (answered) {
      if (isCorrect) {
        background = kGenderDas.withValues(alpha: 0.22);
        border = kGenderDas;
      } else if (isChosen) {
        background = kError.withValues(alpha: 0.22);
        border = kError;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: answered ? null : onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
