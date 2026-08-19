import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/clock.dart' as clock_engine;
import '../engine/question.dart';
import '../engine/session.dart';
import '../models/clock_time.dart';
import '../state/progress_notifier.dart';
import '../widgets/audio_button.dart';
import '../widgets/option_chip.dart';
import '../widgets/quiz_shell.dart';
import '../widgets/ranking_result_dialog.dart';

const _sessionSize = 12;

enum _Direction { digitalToInformal, informalToDigital, formalToDigital }

/// Ítem del quiz de "La Hora": prompt/opciones/respuesta ya resueltos por
/// dirección (docs/PLAN-hora.md §4). [speakText] siempre es la expresión
/// alemana en juego, aunque a veces sea la respuesta — mismo criterio que
/// VerbQuizScreen (audio pronuncia la palabra alemana, no "esconde" nada).
class _ClockQuizItem {
  final String prompt;
  final String speakText;
  final List<String> options;
  final String correct;

  const _ClockQuizItem({
    required this.prompt,
    required this.speakText,
    required this.options,
    required this.correct,
  });
}

class ClockQuizScreen extends StatefulWidget {
  final ProgressNotifier progress;

  const ClockQuizScreen({required this.progress, super.key});

  @override
  State<ClockQuizScreen> createState() => _ClockQuizScreenState();
}

class _ClockQuizScreenState extends State<ClockQuizScreen> {
  List<Question>? _session;
  int _index = 0;
  int _correct = 0;
  String? _chosen;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final rnd = Random();
    final deck = <Question>[
      for (var h = 0; h < 24; h++)
        for (var m = 0; m < 60; m += 5) _buildQuestion(ClockTime(h, m), rnd),
    ];
    final session = buildSession(deck, SessionOptions(size: _sessionSize, srs: widget.progress.states));
    if (mounted) setState(() => _session = session);
  }

  Question _buildQuestion(ClockTime t, Random rnd) {
    final direction = _Direction.values[rnd.nextInt(_Direction.values.length)];
    final item = switch (direction) {
      _Direction.digitalToInformal => _ClockQuizItem(
          prompt: t.digital,
          speakText: clock_engine.informal(t).de,
          options: clock_engine.clockOptions(t, (c) => clock_engine.informal(c).de, random: rnd),
          correct: clock_engine.informal(t).de,
        ),
      _Direction.informalToDigital => _ClockQuizItem(
          prompt: clock_engine.informal(t).de,
          speakText: clock_engine.informal(t).de,
          options: clock_engine.clockOptions(t, (c) => c.digital, random: rnd),
          correct: t.digital,
        ),
      _Direction.formalToDigital => _ClockQuizItem(
          prompt: clock_engine.formal(t).de,
          speakText: clock_engine.formal(t).de,
          options: clock_engine.clockOptions(t, (c) => c.digital, random: rnd),
          correct: t.digital,
        ),
    };
    return Question(id: 'clock:${t.hour}:${t.minute}', mode: QuizMode.clockQuiz, prompt: item, answer: item.correct);
  }

  _ClockQuizItem get _current => _session![_index].prompt as _ClockQuizItem;

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
      mode: 'clock',
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
              Text(
                item.prompt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 4),
              AudioButton(text: item.speakText),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    for (final option in item.options)
                      OptionChip(
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
