import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../models/noun.dart';
import '../models/phrase.dart';
import '../state/progress_notifier.dart';
import '../theme/app_theme.dart';

/// Modo arcade: cuenta atrás 3-2-1, ráfaga de preguntas (género + completar
/// frase) solo con tap, timer de 60s, streak multiplier. docs/PLAN.md §6.6.
class _ArcadeItem {
  final String prompt;
  final List<String> options;
  final String answer;

  const _ArcadeItem({required this.prompt, required this.options, required this.answer});
}

class TimedArcadeScreen extends StatefulWidget {
  final ProgressNotifier progress;

  const TimedArcadeScreen({required this.progress, super.key});

  @override
  State<TimedArcadeScreen> createState() => _TimedArcadeScreenState();
}

class _TimedArcadeScreenState extends State<TimedArcadeScreen>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(seconds: 60);

  List<_ArcadeItem>? _items;
  int _index = 0;
  int _score = 0;
  int _combo = 0;
  String? _chosen;
  late final AnimationController _timerController;
  bool _started = false;
  bool _finished = false;
  int _countdown = 3;
  Timer? _countdownTimer;

  int get _multiplier => 1 + (_combo ~/ 3);

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && _started) _finish();
      });
    _load();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      DataRepository.loadNouns(),
      DataRepository.loadPhrases(),
    ]);
    final nouns = results[0] as List<Noun>;
    final phrases = results[1] as List<Phrase>;
    final rnd = Random();

    final genderItems = nouns.map((n) => _ArcadeItem(
          prompt: n.word,
          options: [for (final g in Gender.values) g.name]..shuffle(rnd),
          answer: n.gender.name,
        ));
    final phraseItems = phrases.map((p) => _ArcadeItem(
          prompt: p.sentence,
          options: List<String>.from(p.options)..shuffle(rnd),
          answer: p.answer,
        ));

    final items = [...genderItems, ...phraseItems]..shuffle(rnd);
    if (mounted) setState(() => _items = items);
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        setState(() => _started = true);
        _timerController.reverse(from: 1.0);
      }
    });
  }

  void _choose(String option) {
    if (_chosen != null || !_started || _items == null) return;
    final item = _items![_index % _items!.length];
    final correct = option == item.answer;
    setState(() {
      _chosen = option;
      if (correct) {
        _score += 10 * _multiplier;
        _combo++;
      } else {
        _combo = 0;
      }
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted || !_started) return;
      setState(() {
        _index++;
        _chosen = null;
      });
    });
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    setState(() => _started = false);
    widget.progress.recordSessionComplete();
    widget.progress.recordArcadeScore(_score);
    _showResults();
  }

  void _showResults() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kSurfaceContainer,
        title: const Text('¡Tiempo!'),
        content: Text('Puntos: $_score\nMejor puntaje: ${widget.progress.arcadeHighScore}'),
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
    final items = _items;
    if (items == null || items.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_started) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Text(
            _finished ? '' : (_countdown > 0 ? '$_countdown' : '¡Ya!'),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 80),
          ),
        ),
      );
    }
    final item = items[_index % items.length];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: kOnSurfaceVariant,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _timerController,
                      builder: (context, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _timerController.value,
                          minHeight: 8,
                          backgroundColor: kOutlineVariant,
                          valueColor: AlwaysStoppedAnimation(
                            _timerController.value < 0.2 ? kError : kPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$_score pts', style: Theme.of(context).textTheme.headlineSmall),
                  if (_multiplier > 1)
                    Text(
                      '×$_multiplier',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: kPrimary),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      item.prompt,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final option in item.options)
                          _ArcadeOptionChip(
                            label: option,
                            chosen: _chosen,
                            correctValue: item.answer,
                            onTap: () => _choose(option),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcadeOptionChip extends StatelessWidget {
  final String label;
  final String? chosen;
  final String correctValue;
  final VoidCallback onTap;

  const _ArcadeOptionChip({
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
        background = kGenderDas.withValues(alpha: 0.28);
        border = kGenderDas;
      } else if (isChosen) {
        background = kError.withValues(alpha: 0.28);
        border = kError;
      }
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ),
      ),
    );
  }
}
