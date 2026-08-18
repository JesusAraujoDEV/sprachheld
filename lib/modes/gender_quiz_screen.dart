import 'dart:async';

import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../engine/question.dart';
import '../engine/session.dart';
import '../models/gender_rule.dart';
import '../models/noun.dart';
import '../state/progress_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/flip_card.dart';
import '../widgets/glow_card_face.dart';
import '../widgets/quiz_shell.dart';

/// Quiz de género: palabra + 3 botones der/die/das. Al elegir, feedback
/// inmediato en el botón (verde/ámbar) y la carta voltea mostrando la
/// respuesta con la regla que aplica — el "por qué" (docs/PLAN.md §6.4).
class _GenderQuizItem {
  final String word;
  final Gender gender;
  final String plural;
  final String es;
  final String? ruleExplanation;

  const _GenderQuizItem({
    required this.word,
    required this.gender,
    required this.plural,
    required this.es,
    this.ruleExplanation,
  });

  String get speak => '${gender.name} $word';
}

class GenderQuizScreen extends StatefulWidget {
  final ProgressNotifier progress;

  /// Si viene, filtra el mazo a sustantivos de esa regla (deep-link desde
  /// GenderTipsScreen — "⚡ Prueba esto"). Null = todas.
  final String? ruleId;

  const GenderQuizScreen({required this.progress, this.ruleId, super.key});

  @override
  State<GenderQuizScreen> createState() => _GenderQuizScreenState();
}

class _GenderQuizScreenState extends State<GenderQuizScreen> {
  List<Question>? _session;
  int _index = 0;
  int _correct = 0;
  Gender? _chosen;
  GlobalKey<FlipCardState> _flipKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      DataRepository.loadNouns(),
      DataRepository.loadGenderRules(),
    ]);
    final allNouns = results[0] as List<Noun>;
    final rules = {for (final r in results[1] as List<GenderRule>) r.id: r};
    final filtered = widget.ruleId == null
        ? allNouns
        : allNouns.where((n) => n.ruleId == widget.ruleId).toList();
    final nouns = filtered.isEmpty ? allNouns : filtered;
    final questions = [
      for (final n in nouns)
        Question(
          id: n.id,
          mode: QuizMode.genderQuiz,
          prompt: _GenderQuizItem(
            word: n.word,
            gender: n.gender,
            plural: n.plural,
            es: n.es,
            ruleExplanation: n.ruleId != null ? rules[n.ruleId]?.explanation : null,
          ),
          answer: n.gender.name,
        ),
    ];
    final session = buildSession(
      questions,
      SessionOptions(size: 12, srs: widget.progress.states),
    );
    if (mounted) setState(() => _session = session);
  }

  _GenderQuizItem get _current => _session![_index].prompt as _GenderQuizItem;

  void _choose(Gender gender) {
    if (_chosen != null) return;
    final correct = gender == _current.gender;
    widget.progress.record(_session![_index].id, correct: correct);
    if (correct) _correct++;
    setState(() => _chosen = gender);
    Timer(const Duration(milliseconds: 450), () {
      if (mounted) _flipKey.currentState?.flip();
    });
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
      _flipKey = GlobalKey<FlipCardState>();
    });
  }

  void _showResults(int total) {
    showDialog<void>(
      context: context,
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
              Expanded(child: Center(child: _buildCard(item))),
              const SizedBox(height: 24),
              _buildButtons(item),
              const SizedBox(height: 16),
              if (_chosen != null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: _next, child: const Text('Siguiente')),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(_GenderQuizItem item) {
    final width = MediaQuery.sizeOf(context).width * 0.86;
    return SizedBox(
      width: width,
      height: width * 1.1,
      child: FlipCard(
        key: _flipKey,
        front: GlowCardFace(
          accent: kPrimary,
          audioText: item.speak,
          child: Text(
            item.word,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        back: GlowCardFace(
          accent: colorForGender(item.gender),
          audioText: item.speak,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item.gender.name} ${item.word}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: colorForGender(item.gender)),
              ),
              const SizedBox(height: 8),
              Text(
                'Pl. ${item.plural} · ${item.es}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (item.ruleExplanation != null) ...[
                const SizedBox(height: 12),
                Text(
                  item.ruleExplanation!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(_GenderQuizItem item) {
    return Row(
      children: [
        for (final gender in Gender.values) ...[
          if (gender != Gender.values.first) const SizedBox(width: 12),
          Expanded(
            child: _GenderButton(
              gender: gender,
              chosen: _chosen,
              correctGender: item.gender,
              onTap: () => _choose(gender),
            ),
          ),
        ],
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  final Gender gender;
  final Gender? chosen;
  final Gender correctGender;
  final VoidCallback onTap;

  const _GenderButton({
    required this.gender,
    required this.chosen,
    required this.correctGender,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final answered = chosen != null;
    final isCorrectButton = gender == correctGender;
    final isChosenButton = gender == chosen;

    var background = colorForGender(gender).withValues(alpha: 0.15);
    var border = colorForGender(gender);
    if (answered) {
      if (isCorrectButton) {
        background = kGenderDas.withValues(alpha: 0.28);
        border = kGenderDas;
      } else if (isChosenButton) {
        background = kError.withValues(alpha: 0.28);
        border = kError;
      } else {
        background = Colors.transparent;
        border = kOutline;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: answered ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                gender.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: colorForGender(gender)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
