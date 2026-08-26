import 'dart:math';

import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../engine/question.dart';
import '../engine/srs.dart';
import '../models/verb.dart';
import '../models/verb_direction.dart';
import '../state/progress_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/glow_card_face.dart';
import '../widgets/quiz_shell.dart';
import '../widgets/ranking_result_dialog.dart';
import 'verb_quiz/verb_option_button.dart';
import 'verb_quiz/verb_quiz_item.dart';
import 'verb_quiz/verb_quiz_question_builder.dart';

const _sessionSize = 12;

class VerbQuizScreen extends StatefulWidget {
  final ProgressNotifier progress;

  /// Si viene, limita el mazo a los N verbos más usados (Top 100/500/1000
  /// del selector en Home). Null = todos.
  final int? maxRank;

  /// Direction for the quiz session.
  final VerbDirection direction;

  const VerbQuizScreen({
    required this.progress,
    this.maxRank,
    this.direction = VerbDirection.mixed,
    super.key,
  });

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
      for (final v in selected) buildVerbQuestion(v, pool, rnd, widget.direction),
    ];
    if (mounted) setState(() => _session = questions);
  }

  VerbQuizItem get _current => _session![_index].prompt as VerbQuizItem;

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
                      VerbOptionButton(
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
