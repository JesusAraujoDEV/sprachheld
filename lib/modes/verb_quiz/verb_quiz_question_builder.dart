import 'dart:math';

import '../../engine/question.dart';
import '../../models/verb.dart';
import '../../models/verb_direction.dart';
import 'verb_quiz_item.dart';

/// Builds a single verb quiz [Question] with distractors from [deck].
/// Pure function — no widget dependency.
Question buildVerbQuestion(Verb v, List<Verb> deck, Random rnd, VerbDirection direction) {
  final VerbDirection dir;
  switch (direction) {
    case VerbDirection.mixed:
      dir = rnd.nextBool() ? VerbDirection.deToEs : VerbDirection.esToDe;
    case VerbDirection.deToEs:
    case VerbDirection.esToDe:
      dir = direction;
  }
  String valueOf(Verb x) => dir == VerbDirection.deToEs ? x.es : x.infinitiv;
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
    prompt: VerbQuizItem(verb: v, direction: dir, options: options, correct: correct),
    answer: correct,
  );
}
