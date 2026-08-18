import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../engine/check.dart';
import '../engine/question.dart';
import '../engine/session.dart';
import '../state/progress_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/quiz_shell.dart';

const _personLabels = ['ich', 'du', 'er/sie/es', 'wir', 'ihr', 'sie/Sie'];

class _WriteItem {
  final String infinitiv;
  final String es;
  final int personIndex;
  final String tenseLabel;
  final String answer;
  final String? conjugationNote;

  const _WriteItem({
    required this.infinitiv,
    required this.es,
    required this.personIndex,
    required this.tenseLabel,
    required this.answer,
    this.conjugationNote,
  });
}

/// "Escribir la conjugación": dado infinitivo+persona+tiempo, escribir la
/// forma correcta. docs/PLAN.md §6.2.
class WriteConjugationScreen extends StatefulWidget {
  final ProgressNotifier progress;

  const WriteConjugationScreen({required this.progress, super.key});

  @override
  State<WriteConjugationScreen> createState() => _WriteConjugationScreenState();
}

class _WriteConjugationScreenState extends State<WriteConjugationScreen> {
  List<Question>? _session;
  int _index = 0;
  int _correct = 0;
  CheckResult? _result;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final verbs = await DataRepository.loadVerbs();
    final questions = <Question>[];
    for (final v in verbs) {
      for (var i = 0; i < 6; i++) {
        questions.add(Question(
          id: '${v.id}_praesens_$i',
          mode: QuizMode.writeConjugation,
          prompt: _WriteItem(
            infinitiv: v.infinitiv,
            es: v.es,
            personIndex: i,
            tenseLabel: 'Präsens',
            answer: v.praesens[i],
            conjugationNote: v.conjugationNote,
          ),
          answer: v.praesens[i],
        ));
        questions.add(Question(
          id: '${v.id}_praeteritum_$i',
          mode: QuizMode.writeConjugation,
          prompt: _WriteItem(
            infinitiv: v.infinitiv,
            es: v.es,
            personIndex: i,
            tenseLabel: 'Präteritum',
            answer: v.praeteritum[i],
            conjugationNote: v.conjugationNote,
          ),
          answer: v.praeteritum[i],
        ));
      }
    }
    final session = buildSession(
      questions,
      SessionOptions(size: 12, srs: widget.progress.states),
    );
    if (mounted) setState(() => _session = session);
  }

  _WriteItem get _current => _session![_index].prompt as _WriteItem;

  void _submit() {
    if (_result != null) {
      _next();
      return;
    }
    if (_controller.text.trim().isEmpty) return;
    final item = _current;
    final result = checkAnswer(item.answer, _controller.text);
    widget.progress.record(_session![_index].id, correct: result.correct);
    if (result.correct) _correct++;
    setState(() => _result = result);
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
      _result = null;
      _controller.clear();
    });
    _focusNode.requestFocus();
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
    final borderColor =
        _result == null ? kPrimary : (_result!.correct ? kGenderDas : kError);
    return Scaffold(
      body: QuizShell(
        index: _index,
        total: session.length,
        onClose: () => Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                item.infinitiv,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 4),
              Text(
                item.es,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 16),
              Text(
                '${_personLabels[item.personIndex]} · ${item.tenseLabel}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: kOnSurfaceVariant, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: _result == null,
                textAlign: TextAlign.center,
                autocorrect: false,
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kSurfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              if (_result != null) _buildFeedback(item),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submit,
                child: Text(_result == null ? 'Comprobar' : 'Siguiente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback(_WriteItem item) {
    final result = _result!;
    return Column(
      children: [
        Text(
          result.correct ? '¡Correcto!' : 'Correcto: ${item.answer}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: result.correct ? kGenderDas : kError,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (item.conjugationNote != null) ...[
          const SizedBox(height: 8),
          Text(
            item.conjugationNote!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ],
    );
  }
}
