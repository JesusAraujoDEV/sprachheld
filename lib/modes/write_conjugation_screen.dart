import 'dart:math';

import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../engine/check.dart';
import '../engine/question.dart';
import '../engine/session.dart';
import '../models/verb.dart';
import '../state/progress_notifier.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_button.dart';
import '../widgets/quiz_shell.dart';
import 'write_conjugation/distractor_pool.dart';
import 'write_conjugation/tense_selector.dart';
import 'write_conjugation/write_conjugation_options.dart';
import 'write_conjugation/write_text_input.dart';

const _personLabels = ['ich', 'du', 'er/sie/es', 'wir', 'ihr', 'sie/Sie'];

class _WriteItem {
  final Verb verb;
  final int personIndex;
  final String tenseLabel;
  final String answer;
  const _WriteItem({required this.verb, required this.personIndex, required this.tenseLabel, required this.answer});
}

/// "Escribir la conjugación": dado infinitivo+persona+tiempo, escribir la
/// forma correcta. docs/PLAN.md §6.2.
class WriteConjugationScreen extends StatefulWidget {
  final ProgressNotifier progress;
  const WriteConjugationScreen({required this.progress, super.key});
  @override
  State<WriteConjugationScreen> createState() => _State();
}

class _State extends State<WriteConjugationScreen> {
  List<Question>? _session;
  int _index = 0;
  int _correct = 0;
  CheckResult? _result;
  String? _chosen;
  bool _useMcq = false;
  TenseFilter _tense = TenseFilter.both;
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  Future<void> _load() async {
    final verbs = await DataRepository.loadVerbs();
    final qs = <Question>[];
    for (final v in verbs) {
      for (var i = 0; i < 6; i++) {
        if (_tense != TenseFilter.praeteritum) qs.add(_q(v, i, 'Präsens', v.praesens[i]));
        if (_tense != TenseFilter.praesens) qs.add(_q(v, i, 'Präteritum', v.praeteritum[i]));
      }
    }
    final s = buildSession(qs, SessionOptions(size: 12, srs: widget.progress.states));
    if (mounted) setState(() => _session = s);
  }

  Question _q(Verb v, int p, String t, String a) => Question(
    id: '${v.id}_${t.toLowerCase()}_$p', mode: QuizMode.writeConjugation,
    prompt: _WriteItem(verb: v, personIndex: p, tenseLabel: t, answer: a), answer: a,
  );

  _WriteItem get _item => _session![_index].prompt as _WriteItem;

  void _onTenseChanged(TenseFilter f) {
    setState(() { _tense = f; _session = null; _index = 0; _correct = 0; _result = null; _chosen = null; _ctrl.clear(); });
    _load();
  }

  void _submit() {
    if (_result != null) { _next(); return; }
    if (_ctrl.text.trim().isEmpty) return;
    final r = checkAnswer(_item.answer, _ctrl.text);
    _record(r.correct);
    setState(() => _result = r);
  }

  void _choose(String option) {
    if (_chosen != null) return;
    final ok = option == _item.answer;
    _record(ok);
    setState(() { _chosen = option; _result = CheckResult(correct: ok, expected: _item.answer); });
  }

  void _record(bool ok) { widget.progress.record(_session![_index].id, correct: ok); if (ok) _correct++; }

  void _next() {
    if (_index + 1 >= _session!.length) {
      widget.progress.recordSessionComplete();
      showDialog<void>(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
        backgroundColor: kSurfaceContainer,
        title: const Text('¡Ronda terminada!'),
        content: Text('Acertaste $_correct de ${_session!.length}.'),
        actions: [TextButton(onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); }, child: const Text('Volver'))],
      ));
      return;
    }
    setState(() { _index++; _result = null; _chosen = null; _ctrl.clear(); });
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final item = _item;
    return Scaffold(
      body: QuizShell(
        index: _index, total: session.length,
        onClose: () => Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TenseSelector(selected: _tense, onChanged: _onTenseChanged),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Flexible(child: Text(item.verb.infinitiv, style: Theme.of(context).textTheme.displayLarge)),
              AudioButton(text: item.verb.infinitiv),
            ]),
            Text(item.verb.es, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 12),
            Text('${_personLabels[item.personIndex]} · ${item.tenseLabel}', textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: kOnSurfaceVariant, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Align(alignment: Alignment.centerRight, child: IconButton(
              icon: Icon(_useMcq ? Icons.keyboard : Icons.checklist),
              tooltip: _useMcq ? 'Escribir' : 'Opciones',
              onPressed: _result == null ? () => setState(() => _useMcq = !_useMcq) : null,
            )),
            const SizedBox(height: 8),
            if (_useMcq) _mcq(item) else WriteTextInput(
              controller: _ctrl, focusNode: _focus,
              enabled: _result == null, correct: _result?.correct, onSubmitted: _submit,
            ),
            const SizedBox(height: 12),
            if (_result != null) _feedback(item),
            const SizedBox(height: 12),
            if (!_useMcq || _chosen != null)
              FilledButton(onPressed: _useMcq ? _next : _submit,
                child: Text(_result == null ? 'Comprobar' : 'Siguiente')),
          ]),
        ),
      ),
    );
  }

  Widget _mcq(_WriteItem item) {
    final opts = [item.answer, ...distractorPool(item.verb, item.answer, random: Random(_index))]
      ..shuffle(Random(_index * 7));
    return WriteConjugationOptions(options: opts, chosen: _chosen, correctValue: item.answer, onTap: _choose);
  }

  Widget _feedback(_WriteItem item) {
    return Column(children: [
      Text(_result!.correct ? '¡Correcto!' : 'Correcto: ${item.answer}', textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: _result!.correct ? kGenderDas : kError, fontWeight: FontWeight.w700)),
      if (item.verb.conjugationNote != null) ...[
        const SizedBox(height: 8),
        Text(item.verb.conjugationNote!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
      ],
    ]);
  }
}
