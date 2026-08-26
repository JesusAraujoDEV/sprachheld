import 'dart:math';

import '../../models/verb.dart';

/// Generates [count] distractor options from the same verb's conjugation
/// forms, excluding the [correct] answer. Pulls from all praesens +
/// praeteritum persons, deduplicates, shuffles, and takes [count].
///
/// Pedagogical rationale: distractors are real forms of the same verb
/// (wrong person or tense) — grammatically plausible, not random strings.
List<String> distractorPool(
  Verb verb,
  String correct, {
  int count = 3,
  Random? random,
}) {
  final rnd = random ?? Random();
  final pool = <String>{
    ...verb.praesens,
    ...verb.praeteritum,
  };
  pool.remove(correct);

  final candidates = pool.toList()..shuffle(rnd);

  if (candidates.length >= count) {
    return candidates.sublist(0, count);
  }

  // Guard: fewer than [count] unique forms (unlikely for praesens+praeteritum
  // = up to 12 forms minus 1). Pad by repeating candidates.
  final result = List<String>.from(candidates);
  while (result.length < count) {
    result.add(candidates[result.length % candidates.length]);
  }
  return result;
}
