import '../../models/verb.dart';
import '../../models/verb_direction.dart';

/// Internal data object for a single verb quiz question: the verb, the
/// direction shown, the answer options, and the correct answer.
class VerbQuizItem {
  final Verb verb;
  final VerbDirection direction;
  final List<String> options;
  final String correct;

  const VerbQuizItem({
    required this.verb,
    required this.direction,
    required this.options,
    required this.correct,
  });

  String get prompt => direction == VerbDirection.deToEs ? verb.infinitiv : verb.es;
}
