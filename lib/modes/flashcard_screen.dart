import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../engine/question.dart';
import '../engine/session.dart';
import '../theme/app_theme.dart';
import '../widgets/flip_card.dart';
import '../widgets/glow_card_face.dart';
import '../widgets/quiz_shell.dart';

/// Flashcard verbo↔traducción. El género der/die/das tiene su propio modo
/// (GenderQuizScreen) — la interacción de "voltear y autoevaluarse" no
/// encajaba con "elegir el artículo correcto".
class FlashcardItem {
  final String front;
  final String back;
  final String speak;

  const FlashcardItem({required this.front, required this.back, required this.speak});
}

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

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
    final verbs = await DataRepository.loadVerbs();
    final questions = [
      for (final v in verbs)
        Question(
          id: v.id,
          mode: QuizMode.flashcard,
          prompt: FlashcardItem(front: v.infinitiv, back: v.es, speak: v.infinitiv),
          answer: v.es,
        ),
    ];
    final session = buildSession(questions, const SessionOptions(size: 12));
    if (mounted) setState(() => _session = session);
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
        front: GlowCardFace(
          accent: kPrimary,
          audioText: item.speak,
          child: Text(
            item.front,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        back: GlowCardFace(
          accent: kPrimary,
          audioText: item.speak,
          child: Text(
            item.back,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
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
