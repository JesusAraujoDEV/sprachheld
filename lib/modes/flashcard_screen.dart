import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../engine/question.dart';
import '../engine/session.dart';
import '../models/gender_rule.dart';
import '../models/noun.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_button.dart';
import '../widgets/flip_card.dart';
import '../widgets/quiz_shell.dart';

enum FlashcardDeck { verbs, nouns }

/// Contenido de una tarjeta. Vive solo en este modo — no forma parte del
/// engine genérico (docs/PLAN.md §9: prompt/answer del Question son
/// `dynamic`, cada modo define su propia forma).
class FlashcardItem {
  final String front;
  final String back;
  final String speak;
  final Color accent;
  final String? note;

  const FlashcardItem({
    required this.front,
    required this.back,
    required this.speak,
    this.accent = kPrimary,
    this.note,
  });
}

class FlashcardScreen extends StatefulWidget {
  final FlashcardDeck deck;

  const FlashcardScreen({required this.deck, super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Question>? _session;
  int _index = 0;
  int _known = 0;
  bool _flipped = false;
  final _flipKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = widget.deck == FlashcardDeck.verbs
        ? await _verbItems()
        : await _nounItems();
    final questions = [
      for (final item in items)
        Question(id: item.speak, mode: QuizMode.flashcard, prompt: item, answer: item.back),
    ];
    final session = buildSession(questions, const SessionOptions(size: 12));
    if (mounted) setState(() => _session = session);
  }

  Future<List<FlashcardItem>> _verbItems() async {
    final verbs = await DataRepository.loadVerbs();
    return [
      for (final v in verbs)
        FlashcardItem(front: v.infinitiv, back: v.es, speak: v.infinitiv),
    ];
  }

  Future<List<FlashcardItem>> _nounItems() async {
    final results = await Future.wait([
      DataRepository.loadNouns(),
      DataRepository.loadGenderRules(),
    ]);
    final nouns = results[0] as List<Noun>;
    final rules = {for (final r in results[1] as List<GenderRule>) r.id: r};
    return [
      for (final n in nouns)
        FlashcardItem(
          front: n.word,
          back: '${n.gender.name} ${n.word} · Pl. ${n.plural}\n${n.es}',
          speak: '${n.gender.name} ${n.word}',
          accent: colorForGender(n.gender),
          note: n.ruleId != null ? rules[n.ruleId]?.explanation : null,
        ),
    ];
  }

  void _advance({required bool knew}) {
    if (knew) _known++;
    final session = _session!;
    if (_index + 1 >= session.length) {
      _showResults(session.length);
      return;
    }
    setState(() {
      _index++;
      _flipped = false;
    });
  }

  void _showResults(int total) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kSurfaceContainer,
        title: const Text('¡Ronda terminada!'),
        content: Text('Sabías $_known de $total.'),
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
    final item = session[_index].prompt as FlashcardItem;
    return Scaffold(
      body: QuizShell(
        index: _index,
        total: session.length,
        onClose: () => Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _flipKey.currentState?.flip();
                      setState(() => _flipped = !_flipped);
                    },
                    child: _buildCard(item),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildActions(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(FlashcardItem item) {
    final width = MediaQuery.sizeOf(context).width * 0.86;
    return SizedBox(
      width: width,
      height: width * 1.3,
      child: FlipCard(
        key: _flipKey,
        front: _cardFace(
          accent: item.accent,
          audioText: item.speak,
          child: Text(
            item.front,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        back: _cardFace(
          accent: item.accent,
          audioText: item.speak,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.back,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (item.note != null) ...[
                const SizedBox(height: 12),
                Text(
                  item.note!,
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

  Widget _cardFace({
    required Widget child,
    required Color accent,
    required String audioText,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurfaceContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kOutline),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.4),
            blurRadius: 60,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(alignment: Alignment.topRight, child: AudioButton(text: audioText)),
          Center(child: child),
        ],
      ),
    );
  }

  Widget _buildActions() {
    if (!_flipped) {
      return Text(
        'Toca la carta para voltear',
        style: Theme.of(context).textTheme.labelSmall,
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _advance(knew: false),
            child: const Text('No sabía'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: () => _advance(knew: true),
            child: const Text('Sabía'),
          ),
        ),
      ],
    );
  }
}
